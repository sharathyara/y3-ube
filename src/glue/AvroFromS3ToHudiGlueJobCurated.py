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
import json
from pyspark.sql.types import StructType, StructField, StringType, ShortType

# @metric_scope
def push_metrics(glue_job_run_id, glue_job_name='AvroFromS3ToHudiGlueJobCurated', operation='INSERT', value=0, avro_file_name='None', unit='None', metric_name='HudiCRUDMetric', metric_namespace='HudiDataOperations'):
    cloudwatch = boto3.client('cloudwatch')
    metric_data = [
            {
                'MetricName': 'DefaultMetricName',
                'Dimensions': [
                    {
                        'Name': 'JobName',
                        'Value': 'DefaultJobName'
                    },
                    {
                        'Name': 'JobRunId',
                        'Value': 'DefaultJobRunId'
                    },
                    {
                        'Name': 'Operation',
                        'Value': 'DefaultOperation'
                    },
                    {
                        'Name': 'File',
                        'Value': 'DefaultFileName'
                    }
                ],
                'Unit': 'None',
                'Value': 0
            },
        ]
    metric_data[0]['MetricName'] = metric_name
    metric_data[0]['Dimensions'][0]['Value'] = glue_job_name
    metric_data[0]['Dimensions'][1]['Value'] = glue_job_run_id
    metric_data[0]['Dimensions'][2]['Value'] = operation
    metric_data[0]['Dimensions'][3]['Value'] = avro_file_name
    metric_data[0]['Unit'] = unit
    metric_data[0]['Value'] = value
    response = cloudwatch.put_metric_data(
        MetricData = metric_data,
        Namespace = metric_namespace
    )
    print(response)

def send_notification(glue_job_name, glue_job_run_id, error_message):
    # Replace sender@example.com with your "From" address.
    # This address must be verified with Amazon SES.
    SENDER = "c057185@yara.com"
    
    # is still in the sandbox, this address must be verified.
    RECIPIENT = "viktoras.ciumanovas@yara.com"
    
    # If necessary, replace us-west-2 with the AWS Region you're using for Amazon SES.
    AWS_REGION = "eu-central-1"
    
    # The subject line for the email.
    SUBJECT = f'AWS Glue Job "{glue_job_name}" processing failure'
    
    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = ("Failure notification for AWS Glue Job\r\n"
                 f'There was an issue processing data'
                )
                
    # The HTML body of the email.
    BODY_HTML = """<html>
    <head></head>
    <body>
      <h1>Failure notification for AWS Glue Job</h1>
      <p><b>Glue Job Name</b>: """ + glue_job_name + """</p>
      <p><b>Glue Job Id</b>: """ + glue_job_run_id + """</p>
      <p><b>The error message</b>: """ + error_message + """</p>
    </body>
    </html>
    """            
    
    # The character encoding for the email.
    CHARSET = "UTF-8"
    
    # Create a new SES resource and specify a region.
    client = boto3.client('ses',region_name=AWS_REGION)
    
    # Try to send the email.
    try:
        #Provide the contents of the email.
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
        )
    # Display an error if something goes wrong.	
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])
        
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']

spark = SparkSession.builder.config('spark.serializer','org.apache.spark.serializer.KryoSerializer').config('spark.sql.hive.convertMetastoreParquet','false').getOrCreate()

sc = spark.sparkContext
glueContext = GlueContext(sc)
job = Job(glueContext)

# print("Spark Version:" + spark.version)

print("Reading farm data in Hudi:")
# print(f'Full S3 object path: "s3://yara-das-ffdp-conformed-eucentral1-479055760150-stage-stitch/hudi-cdc-tables/farm/2022-10-05/812bd1df-d18f-4174-a196-093a549e9d60-0_0-61-956_20221108125453242.parquet"')
# farmDyF = glueContext.create_dynamic_frame.from_options(
#     connection_type="s3",
#     connection_options={"paths": ["s3://yara-das-ffdp-conformed-eucentral1-479055760150-stage-stitch/hudi-cdc-tables/farm/2022-10-05/"]},
#     format="parquet",
#     additional_options = {"inferSchema":"true"}
# )

# farmDyF.show()

farmQueryDF = spark.read.format('org.apache.hudi').load('s3://yara-das-ffdp-conformed-eucentral1-479055760150-stage-stitch/hudi-cdc-tables/farm' + '/*/*') \
    .select("farmId", "userId") #, "farmName", "created_at", "eventType")
#     .filter("created_at = '1520077642240'")

# snapshotQueryDF.show()

farmFilteredDyF = DynamicFrame.fromDF(farmQueryDF, glueContext, "farmFilteredDyF")   
# farmFilteredDF = farmDyF.toDF().select("farmId","userId")
# farmFilteredDF.show()
# farmFilteredDyF = DynamicFrame.fromDF(farmFilteredDF, glueContext, "farmFilteredDyF")

# farmFilteredDyF.show()

# usersDyF = glueContext.create_dynamic_frame.from_options(
#     connection_type="s3",
#     connection_options={"paths": ["s3://yara-das-ffdp-conformed-eucentral1-479055760150-stage-stitch/hudi-cdc-tables/users/2022-09-22/"]},
#     format="parquet",
#     additional_options = {"inferSchema":"true"}
# )

print("Reading users data in Hudi:")
usersQueryDF = spark.read.format('org.apache.hudi').load('s3://yara-das-ffdp-conformed-eucentral1-479055760150-stage-stitch/hudi-cdc-tables/users' + '/*/*') \
    .select("id", "auth_id", "first_name", "last_name", "phone", "primary_email", "country", "address", "zipcode", "source", "dateTimeOccurred" ,"created_at")

usersFilteredDyF = DynamicFrame.fromDF(usersQueryDF, glueContext, "usersFilteredDyF")

# usersFilteredDyF.show(1)

# Join farm and user by user ID
farm_usersDyF = farmFilteredDyF.join(
    paths1=["userId"], paths2=["id"], frame2=usersFilteredDyF
)

# farm_usersDyF.show()
# farm_usersDyF.printSchema() 

# usersFarmFilteredDF = farm_usersDyF.toDF().select("userId", "auth_id", "first_name", "last_name", "farmId", "phone", "primary_email", "country", "address", "zipcode", "source", "dateTimeOccurred" ,"created_at")
# usersFarmFilteredDyF = DynamicFrame.fromDF(usersFarmFilteredDF, glueContext, "usersFarmFilteredDyF")

# farm_usersDyF.show()

try:
    if farm_usersDyF.count() > 0:
        print("Starting insert into hudi table")
        glueContext.write_dynamic_frame.from_options(frame = farm_usersDyF, connection_type = "marketplace.spark", connection_options={'className' : 'org.apache.hudi', 'hoodie.datasource.write.precombine.field': 'dateTimeOccurred', 'hoodie.datasource.write.recordkey.field': 'farmId', 'hoodie.table.name': 'users-farm', 'hoodie.datasource.hive_sync.database': 'conformed-ub-data', 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.datasource.hive_sync.table': 'users-farm', 'hoodie.datasource.hive_sync.enable': 'true', 'path': 's3://yara-das-ffdp-curated-eucentral1-479055760150-stage-stitch/hudi-cdc-tables/users-farm', 'hoodie.datasource.write.partitionpath.field': 'created_at', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}) 
        
#         push_metrics(glue_job_run_id, glue_job_name, 'INSERT', insertDyF.count(), avro_file_name)
    # raise Exception("An error occurred while calling o147.pyWriteDynamicFrame. Failed to upsert for commit time 20221108225828869")    
    print("All finished")
except Exception as e:
    print(e)
    raise
    send_notification(glue_job_name, glue_job_run_id, str(e)) 

print("Exiting")

job.init(args['JOB_NAME'], args)
job.commit()
