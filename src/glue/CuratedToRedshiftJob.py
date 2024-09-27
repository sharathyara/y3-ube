from awsglue.transforms import *
from awsglue.dynamicframe import DynamicFrame
from awsglue.utils import getResolvedOptions
from pyspark.sql.session import SparkSession
from awsglue.context import GlueContext
from ffdputils import lock, FFDPLogger, TransformationFunction
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType
from datetime import datetime
from awsglue.job import Job
import boto3
import uuid
import sys
import json


args = getResolvedOptions(sys.argv,
                          ['JOB_NAME', 'curated_bucket', 'aws_iam_role', 'redshift_connection_user',
                           'redshift_url', 'redshift_db_name', 'redshift_cluster_name', 'hudi_table_name', 'hudi_record_key', 's3_object'])

glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
source_bucket_name = args['curated_bucket']
aws_iam_role = args['aws_iam_role']
redshift_user = args['redshift_connection_user']
redshift_url = args['redshift_url']
redshift_db_name = args['redshift_db_name']
redshift_cluster_name = args['redshift_cluster_name']

hudi_table_name = args['hudi_table_name']

redshift_schema_name = 'curated_schema'
redshift_table_name = hudi_table_name
redshift_staging_table_name = f"{redshift_table_name}_staging"
dynamic_frame_target_table = f"{redshift_schema_name}.{redshift_staging_table_name}"
redshift_unique_key = args['hudi_record_key']

hudi_metadata_columns_to_drop = ['_hoodie_record_key', '_hoodie_file_name', '_hoodie_partition_path', '_hoodie_commit_seqno', '_hoodie_commit_time']

notification_bucket_name = args['s3_object'].split("/")[2]
notification_prefix = args['s3_object'].replace(f"s3://{notification_bucket_name}/", "")
notification_lock_file_name = 'processing.lock'

json_udf = udf(lambda string:TransformationFunction.json_function(str(string)), StringType())

spark = SparkSession.builder.config('spark.serializer', 'org.apache.spark.serializer.KryoSerializer').config(
    'spark.sql.hive.convertMetastoreParquet', 'false').getOrCreate()

sc = spark.sparkContext
glueContext = GlueContext(sc)
job = Job(glueContext)
redshift_client = boto3.client('redshift')
s3 = boto3.resource('s3')
logger = glueContext.get_logger()

traceId = uuid.uuid4()  
log_former = FFDPLogger.FFDPLogger(traceId, glue_job_name, glue_job_run_id)

date_format_str = '%d/%m/%Y %H:%M:%S.%f'
now = datetime.utcnow().strftime(date_format_str)[:-3]

logger.info(log_former.get_message(f"The time is {now}"))
logger.info(log_former.get_message(f"Glue job id: {glue_job_run_id}"))

userQueryDF = spark.read.format('org.apache.hudi').load(f's3://{source_bucket_name}/hudi-cdc-tables/{hudi_table_name}/*/*').select("*")
userQueryDF.show(5)

if hudi_table_name == 'polaris_ndvi_performed':
    userQueryDF = userQueryDF.withColumn("new_imageUrl", json_udf(userQueryDF["imageUrl"]))
    userQueryDF = userQueryDF.drop("imageUrl").withColumnRenamed("new_imageUrl", "imageUrl")

filteredDF = userQueryDF.drop(*hudi_metadata_columns_to_drop)
outputDYF = DynamicFrame.fromDF(filteredDF, glueContext, "outputDYF")

# Get Redshift cluster credentials
credentialsResponse = redshift_client.get_cluster_credentials(
    DbUser=redshift_user,
    DbName=redshift_db_name,
    ClusterIdentifier=redshift_cluster_name,
    DurationSeconds=3600,
    AutoCreate=False
)

redshift_credentials = {
    'userName': credentialsResponse['DbUser'],
    'password': credentialsResponse['DbPassword']
}

logger.info(log_former.get_message(f"Credentials received for {redshift_credentials['userName']}"))

# Count the number of records
counted_records = outputDYF.count()
logger.info(log_former.get_message(f"Count of records: {counted_records}"))

# Pre-action: Recreate staging table
pre_action_create_stage = f"""
    DROP TABLE IF EXISTS {redshift_schema_name}.{redshift_staging_table_name};
    CREATE TABLE {redshift_schema_name}.{redshift_staging_table_name} BACKUP NO AS SELECT * FROM {redshift_schema_name}.{redshift_table_name} WHERE 1=2;
"""

# Post-action: call stored procedure to move data from staging and perform evaluation
post_action_target_table = f"""
    BEGIN TRANSACTION;
        CALL curated_schema.currated_redshift_postaction('{redshift_schema_name}', '{redshift_table_name}', '{redshift_staging_table_name}', {counted_records}, '{glue_job_run_id}', '{redshift_unique_key}');
    END TRANSACTION;
"""

try:
    redshift_connection_options = {
        "url": redshift_url,
        "dbtable": dynamic_frame_target_table,
        "user": redshift_credentials['userName'],
        "password": redshift_credentials['password'],
        "redshiftTmpDir": args["TempDir"],
        "aws_iam_role": aws_iam_role,
        "autoCreate": False,
        "preactions": pre_action_create_stage,
        "postactions": post_action_target_table
    }
    
    logger.info(log_former.get_message("Writing to Redshift started"))
    logger.info(log_former.get_message(f"Redshift table: {redshift_table_name}"))
    logger.info(log_former.get_message(f"Pre-actions: {pre_action_create_stage}"))
    logger.info(log_former.get_message(f"Post-actions: {post_action_target_table}"))
    
    glueContext.write_dynamic_frame.from_options(
        frame=outputDYF,
        connection_options=redshift_connection_options,
        connection_type='redshift',
        transformation_ctx="Curated-to-Redshift"
    )
    
    logger.info(log_former.get_message("Writing to Redshift completed"))
    
    lock.release_notification_lock(s3, notification_bucket_name, (notification_prefix + notification_lock_file_name), logger, log_former)
except Exception as e:
    logger.error(log_former.get_message(f"ERROR during processing: '{str(e)}'"))
    raise Exception(e)

logger.info(log_former.get_message("Job Finished"))