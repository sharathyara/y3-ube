import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.session import SparkSession
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.types import *
import boto3
from datetime import datetime


def release_notification_lock(s3, bucket_name, prefix, glue_logger):
    glue_logger.info("Removing the notification lock")
    s3.Object(bucket_name, prefix).delete()
    glue_logger.info("The notification lock removed.")

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'curated_bucket', 'hudi_db_name', 'hudi_table_name', 'redshift_connection_user','redshift_url','aws_iam_role', 'redshift_db_name', 'redshift_cluster_name', 's3_object'], )

glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
source_bucket_name = args['curated_bucket']
hudi_db_name = args['hudi_db_name']
hudi_table_name = args['hudi_table_name']
redshift_user = args['redshift_connection_user']
redshift_url =args['redshift_url']
redshift_db_name = args['redshift_db_name']
redshift_cluster_name = args['redshift_cluster_name']

aws_iam_role = args['aws_iam_role']
staging_table_name = 'redshift_demo.user_staging';

notification_bucket_name = (args['s3_object']).split("/")[2]
notification_prefix = (args['s3_object']).replace(f"s3://{notification_bucket_name}/","")
notification_lock_file_name = 'processing.lock'

spark = SparkSession.builder.config('spark.serializer','org.apache.spark.serializer.KryoSerializer').config('spark.sql.hive.convertMetastoreParquet','false').getOrCreate()

sc = spark.sparkContext
glueContext = GlueContext(sc)
job = Job(glueContext)
redshift_client = boto3.client('redshift')
s3 = boto3.resource('s3')
logger = glueContext.get_logger()

logger.info('Starting job CuratedToRedshift')
date_format_str = '%d/%m/%Y %H:%M:%S.%f'
now = datetime.utcnow().strftime(date_format_str)[:-3]
logger.info(f"The time is {now}")

logger.info("Querying data in Curated bucket")
userQueryDF = spark.read.format('org.apache.hudi').load('s3://' + source_bucket_name +'/hudi-cdc-tables/' + hudi_table_name + '/*/*').select("*")

userQueryDF.show(5)

outputDYF = DynamicFrame.fromDF(userQueryDF, glueContext, "outputDYF")

######## GET REDSHIFT CLUSTER CREDENTIALS ########
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

logger.info(f"Credentials received for {redshift_credentials['userName']}")

######### REDSHIFT #########
counted_records = outputDYF.count()
logger.info(f"Count of records {counted_records}")

## PRE-ACTION : recreate staging table
pre_action_create_stage = 'DROP TABLE IF EXISTS redshift_demo.user_staging; \
                            CREATE TABLE redshift_demo.user_staging AS SELECT * FROM redshift_demo.user;'
    
## POST-ACTION : Within transaction perform UPSERT in target table
post_action_target_table = ' \
        begin transaction; \
        delete from redshift_demo.user_staging \
            using redshift_demo.user \
            where redshift_demo.user.userid = redshift_demo.user_staging.userid and redshift_demo.user._hoodie_commit_time = redshift_demo.user_staging._hoodie_commit_time; \
        delete from redshift_demo.user \
            using redshift_demo.user_staging \
            where redshift_demo.user.userid = redshift_demo.user_staging.userid and redshift_demo.user._hoodie_commit_time < redshift_demo.user_staging._hoodie_commit_time; \
        insert into redshift_demo.user \
            select * from redshift_demo.user_staging; \
        delete from redshift_demo.audit; \
        insert into redshift_demo.audit (audit_text) select concat (customtext, count) from (select \'Total count: Curated Bucket: '+ str(counted_records) +' | Table USER:  \' as customtext,  count(*) from redshift_demo.user as second); \
        DROP TABLE redshift_demo.user_staging; \
        end transaction;'
       
try:  
    ## Scenario 1 : Redshift public accessible - using Dynamic Frame from options
    redshift_connection_options = {  
        "url": redshift_url,
        "dbtable": staging_table_name,
        "user": redshift_credentials['userName'],
        "password": redshift_credentials['password'],
        "redshiftTmpDir": args["TempDir"],
        "aws_iam_role": aws_iam_role,
        "autoCreate" : False,
        "preactions": pre_action_create_stage,
        "postactions": post_action_target_table
    }

    glueContext.write_dynamic_frame.from_options(\
    frame = outputDYF,\
    connection_options = redshift_connection_options,\
    connection_type = 'redshift', 
    transformation_ctx = "Curated-to-Redshift")
   
    release_notification_lock(s3, notification_bucket_name, (notification_prefix + notification_lock_file_name), logger) 
except Exception as e:
    logger.error(f"ERROR during processing : '{str(e)}'")
    raise Exception(e)