import sys
from pyspark.context import SparkContext
from pyspark.sql.session import SparkSession
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from awsglue.utils import getResolvedOptions
from pyspark.sql.types import *
import pandas as pd
import boto3
from botocore.exceptions import ClientError
from datetime import datetime
import json
import time
from pyspark.sql.types import StructType, StructField, StringType, ShortType


def aquire_lock(s3, bucket_name, prefix, glue_job_run_id, glue_logger):
    try:
        sleep_time = 3
        while True:
            s3.Object(bucket_name, prefix).load()
            glue_logger.info(f"Waiting for lock to be released... {sleep_time}s")
            time.sleep(sleep_time)
        return "Failed"
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            glue_logger.info("Requesting a lock")
            object = s3.Object(bucket_name, prefix)
            object.put(Body=glue_job_run_id)
            glue_logger.info("The lock requested.")
            glue_logger.info("Approving the lock")
            time.sleep(sleep_time)
            for obj in s3.Bucket(bucket_name).objects.filter(Prefix=prefix):
                body = obj.get()['Body'].read()
                if body != glue_job_run_id.encode('ascii'):
                    glue_logger.info(f"The lock was not approved! The job '{glue_job_run_id}' to be considered for retry")
                    return "Retry"        
                else:
                    glue_logger.info("The lock approved.")
            return "Success"


def put_trigger_file(s3, bucket_name, prefix, glue_job_run_id, glue_logger):
    glue_logger.info("Creating a trigger file")
    object = s3.Object(bucket_name, prefix)
    object.put(Body=glue_job_run_id)
    glue_logger.info("The trigger file created.")
    return "Success"


def release_lock(s3, bucket_name, prefix, glue_logger):
    glue_logger.info("Removing the lock")
    s3.Object(bucket_name, prefix).delete()
    glue_logger.info("The lock removed.")
    
        
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'conformed_bucket', 'curated_bucket', 'hudi_connection_name', 'hudi_db_name', 'hudi_table_name', 'hudi_table_name_2', 'glue_metric_namespace', 'glue_metric_name', 'batch_max_limit', 'hudi_target_table_name', 'hive_target_table_name', 'hudi_target_db_name'], )

glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
source_bucket_name = args['conformed_bucket'] 
destination_bucket_name = args['curated_bucket'] 
hudi_connection_name = args['hudi_connection_name']
hudi_db_name = args['hudi_db_name']
hudi_target_db_name = args['hudi_target_db_name']
hudi_table_name = args['hudi_table_name']
hudi_table_name_2 = args['hudi_table_name_2']
glue_metric_namespace = args['glue_metric_namespace']
glue_metric_name = args['glue_metric_name']
batch_max_limit = int(args['batch_max_limit'])
hudi_target_table_name = args['hudi_target_table_name']
hive_target_table_name = args['hive_target_table_name']

prefix = f'hudi-cdc-tables/{hudi_table_name}/processing.lock'
trigger_prefix = f'user-curated/eu-central-1/user-to-redshift-{(datetime.now()).strftime("%Y%m%d%H%M%S")}.trig'

spark = SparkSession.builder.config('spark.serializer','org.apache.spark.serializer.KryoSerializer').config('spark.sql.hive.convertMetastoreParquet','false').getOrCreate()

sc = spark.sparkContext
glueContext = GlueContext(sc)
job = Job(glueContext)
s3 = boto3.resource('s3')
logger = glueContext.get_logger()

while aquire_lock(s3, source_bucket_name, prefix, glue_job_run_id, logger) != 'Success':
    pass

userQueryDF = spark.read.format('org.apache.hudi').load('s3://' + source_bucket_name + '/hudi-cdc-tables/user' + '/*/*').select("dateTimeOccurred", "id", "userName", "createdBy","createdDateTime","modifiedBy", "modifiedDateTime", "eventType","created_at").withColumnRenamed("id", "userId").filter("created_at >= '2022-12-16'")    
userFilteredDyF = DynamicFrame.fromDF(userQueryDF, glueContext, "userFilteredDyF")
userFilteredDyF.show(5)
userFilteredDyF.printSchema() 

try:
    if userFilteredDyF.count() > 0:
        print("Starting insert into hudi table")
        
        commonConfig = {'connectionName': f'{hudi_connection_name}', 'className' : 'org.apache.hudi', 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.index.type':'GLOBAL_BLOOM', 'hoodie.datasource.write.precombine.field': 'dateTimeOccurred', 'hoodie.payload.ordering.field': 'dateTimeOccurred', 'hoodie.datasource.write.operation': 'upsert', 'hoodie.datasource.write.payload.class': 'org.apache.hudi.common.model.DefaultHoodieRecordPayload', 'hoodie.datasource.write.recordkey.field': 'userId', 'hoodie.table.name': f'{hudi_target_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'hoodie.datasource.hive_sync.database': f'{hudi_target_db_name}', 'hoodie.datasource.hive_sync.table': f'{hive_target_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'path': f's3://{destination_bucket_name}/hudi-cdc-tables/{hudi_target_table_name}', 'hoodie.datasource.write.partitionpath.field': 'created_at', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}
        combinedConf = {**commonConfig}
            
        ApacheHudiConnector = (
            glueContext.write_dynamic_frame.from_options(
                frame=userFilteredDyF,
                connection_type="marketplace.spark",
                connection_options=combinedConf,
                transformation_ctx="ApacheHudiConnector",
            )
        )

    release_lock(s3, source_bucket_name, prefix, logger)
    put_trigger_file(s3, destination_bucket_name, trigger_prefix, glue_job_run_id, logger)
    
except Exception as e:
    logger.error(str(e))
    raise Exception(str(e))

job.init(args['JOB_NAME'], args)
job.commit()
