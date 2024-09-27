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
import time
from pyspark.sql.types import StructType, StructField, StringType, ShortType

# @metric_scope
def push_metrics(glue_job_run_id, glue_job_name, metric_name, metric_namespace, operation='INSERT', value=0, avro_file_name='None', unit='None'):
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
    print("Hudi operation metrics registered.") #response)

def aquire_lock(s3, bucket_name, prefix, glue_job_run_id):
    try:
        sleep_time = 3
        while True:
            s3.Object(bucket_name, prefix).load()
            print(f"Waiting for lock to be released... {sleep_time}s")
            time.sleep(sleep_time)
            # sleep_time += 1
        return "Failed"
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("Requesting a lock")
            object = s3.Object(bucket_name, prefix)
            object.put(Body=glue_job_run_id)
            print("The lock requested.")
            print("Approving the lock")
            time.sleep(0)
            for obj in s3.Bucket(bucket_name).objects.filter(Prefix=prefix):
                # key = obj.key
                body = obj.get()['Body'].read()
                if body != glue_job_run_id.encode('ascii'):
                    print(f"The lock was not approved! The job '{glue_job_run_id}' to be considered for retry")
                    return "Retry"        
                else:
                    print("The lock approved.")
            return "Success"

def release_lock(s3, bucket_name, prefix):
    print("Removing the lock")
    s3.Object(bucket_name, prefix).delete()
    print("The lock removed.")
    
def release_notification_lock(s3, bucket_name, prefix):
    print("Removing the notification lock")
    s3.Object(bucket_name, prefix).delete()
    print("The notification lock removed.")

def remove_processed_notification(s3, bucket_name, prefix):
    print(f'Removing the notification file: "{prefix.split("/")[-1]}"')
    s3.Object(bucket_name, prefix).delete()
    print("The notification file removed.")

def send_notification(glue_job_name, glue_job_run_id, full_file_path, error_message):
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
                 f'There was an issue processing "{full_file_path}" file'
                )
                
    # The HTML body of the email.
    BODY_HTML = """<html>
    <head></head>
    <body>
      <h1>Failure notification for AWS Glue Job</h1>
      <p><b>Glue Job Name</b>: """ + glue_job_name + """</p>
      <p><b>Glue Job Id</b>: """ + glue_job_run_id + """</p>
      <p><b>Issue with file</b>: """ + full_file_path + """</p>
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
    
args = getResolvedOptions(sys.argv, ['JOB_NAME', 's3_object','hudi_db_name','hudi_table_name','curated_bucket', 'glue_metric_name', 'glue_metric_namespace'])
glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
bucket_name = args['curated_bucket']
glue_metric_name = args['glue_metric_name']
glue_metric_namespace = args['glue_metric_namespace']
prefix = 'hudi-cdc-tables/farm/processing.lock'
notification_bucket_name = (args['s3_object']).split("/")[2]
# avro_file_name = (args['s3_object']).split("/")[-1]
notification_prefix = (args['s3_object']).replace(f"s3://{notification_bucket_name}/", "")
notification_lock_file_name = 'processing.lock'

keyword_insert = ['FarmAdded']
keyword_update = ['FarmUpdated']
keyword_delete = ['FarmDeleted']
list_of_fields = ["dateTimeOccurred", "data.farmId", "data.farmName", "data.userId", "data.organizationId", "data.regionId", "data.countryId", "data.address", "data.zipcode", "data.noOfFarmHands", "data.farmSizeUOMId", "data.createdBy", "data.createdDateTime", "modifiedBy", "modifiedDateTime", "eventSource", "eventType", "eventId", "created_at"]

schema = StructType([
    StructField('dateTimeOccurred', StringType(), False),
    StructField('farmId', StringType(), False),
    StructField('farmName', StringType(), True),
    StructField('userId', StringType(), True),
    StructField('organizationId', StringType(), True),
    StructField('regionId', StringType(), True),
    StructField('countryId', StringType(), True),
    StructField('address', StringType(), True),
    StructField('zipcode', StringType(), True),
    StructField('noOfFarmHands', ShortType(), True),
    StructField('farmSizeUOMId', StringType(), True),
    StructField('createdBy', StringType(), True),
    StructField('createdDateTime', StringType(), True),
    StructField('modifiedBy', StringType(), True),
    StructField('modifiedDateTime', StringType(), True),    
    StructField('eventSource', StringType(), False),
    StructField('eventType', StringType(), False),
    StructField('eventId', StringType(), True),
    StructField('created_at', StringType(), True)
    ])

spark = SparkSession.builder.config('spark.serializer','org.apache.spark.serializer.KryoSerializer').config('spark.sql.hive.convertMetastoreParquet','false').getOrCreate()

sc = spark.sparkContext
glueContext = GlueContext(sc)
job = Job(glueContext)
s3 = boto3.resource('s3')

logger = glueContext.get_logger()
logger.info("Reading avro in S3:")
logger.warn("Selecting DynamicFrame for insert")
logger.error("Creating list of insert tuples")

# print("Spark Version:" + spark.version)
try:
    while len(list(s3.Bucket(notification_bucket_name).objects.filter(Prefix=notification_prefix))) > 2:
        for obj in s3.Bucket(notification_bucket_name).objects.filter(Prefix=notification_prefix):
            notification_file_name = obj.key.split("/")[-1]
            if len(notification_file_name) > 0 and notification_file_name != notification_lock_file_name:
                print(f'Processing {notification_file_name} file notification')
                file_path = ""
                for obj in s3.Bucket(notification_bucket_name).objects.filter(Prefix=(notification_prefix + notification_file_name)):
                    # key = obj.key
                    file_path = obj.get()['Body'].read().decode('utf8')
            
                print("Reading avro in S3:")
                print(f"Full S3 object path: {file_path}")
                avro_file_name = file_path.split("/")[-1]
                DF = glueContext.create_dynamic_frame.from_options(
                    connection_type="s3",
                    connection_options={"paths": [file_path]},
                    format="avro",
                    additional_options = {"inferSchema":"true"}
                )
                
                # DF.show(10)
                print("Selecting DynamicFrame for insert")
                insertDF = DF.filter(f=lambda x: x["eventType"] in keyword_insert).select_fields(paths=list_of_fields)
                # insertDF.printSchema() 
                # insertDF.show(5)
                print("DynamicFrame selected.")
                
                print("Selecting DynamicFrame for update")
                updateDF = DF.filter(f=lambda x: x["eventType"] in keyword_update).select_fields(paths=list_of_fields)
                # updateDF.printSchema() 
                # updateDF.show(5)
                print("DynamicFrame selected.")
                
                print("Selecting DynamicFrame for delete")
                deleteDF = DF.filter(f=lambda x: x["eventType"] in keyword_delete).select_fields(paths=list_of_fields)
                # deleteDF.printSchema() 
                # deleteDF.show(5)
                print("DynamicFrame selected.")
                
                print("Converting DynamicFrames to Pandas DataFrames")
                insertPDF = insertDF.toDF().toPandas()
                updatePDF = updateDF.toDF().toPandas()
                deletePDF = deleteDF.toDF().toPandas()
                print("Pandas DataFrames created.")
                
                print("Creating list of insert tuples")
                list_of_insert_tuples = []
                for idx in range(insertPDF.shape[0]):
                    data = {"farmId": None, "farmName": None, "userId": None, "organizationId": None, "regionId": None, "countryId": None, "address": None, "zipcode": None, "noOfFarmHands": None, "farmSizeUOMId": None, "createdBy": None, "createdDateTime": None, "modifiedBy": None, "modifiedDateTime": None}
                    
                    # print(str(insertPDF["data"][0]))
                    # print(str(insertPDF["data"][0]).replace("Row(", '{"').replace("')", '"}').replace(", ", ', "').replace("', ", '", ').replace("='", '":"').replace("=", '":').replace('":":",', '==",').replace('":",', '=",'))
                    dateTimeOccurred = insertPDF['dateTimeOccurred'][idx]
                    eventSource = insertPDF["eventSource"][idx]
                    eventType = insertPDF["eventType"][idx]
                    eventId = insertPDF["eventId"][idx]
                    created_at = (insertPDF['dateTimeOccurred'][idx])[:10]
                    for key in list(json.loads(str(insertPDF["data"][0]).replace("Row(", '{"').replace("')", '"}').replace(", ", ', "').replace("', ", '", ').replace("='", '":"').replace("=", '":').replace('":":",', '==",').replace('":",', '=",')).keys()):
                        data[key] = insertPDF['data'][idx][key]
                        
                    tpl = (dateTimeOccurred, data["farmId"], data["farmName"], data["userId"], data["organizationId"], data["regionId"], data["countryId"], data["address"], data["zipcode"], data["noOfFarmHands"], data["farmSizeUOMId"], data["createdBy"], data["createdDateTime"], data["modifiedBy"], data["modifiedDateTime"], eventSource, eventType, eventId, created_at)
                    list_of_insert_tuples.append(tpl) 
                
                print("List of insert tuples created.")
                # print(list_of_insert_tuples)
                
                print("Creating list of update tuples")
                list_of_update_tuples = []
                for idx in range(updatePDF.shape[0]):
                    data = {"farmId": None, "farmName": None, "userId": None, "organizationId": None, "regionId": None, "countryId": None, "address": None, "zipcode": None, "noOfFarmHands": None, "farmSizeUOMId": None, "createdBy": None, "createdDateTime": None, "modifiedBy": None, "modifiedDateTime": None}
                    dateTimeOccurred = updatePDF['dateTimeOccurred'][idx]
                    eventSource = updatePDF["eventSource"][idx]
                    eventType = updatePDF["eventType"][idx]
                    eventId = updatePDF["eventId"][idx]
                    created_at = (updatePDF['dateTimeOccurred'][idx])[:10]
                    for key in list(json.loads(str(updatePDF["data"][0]).replace("Row(", '{"').replace("')", '"}').replace(", ", ', "').replace("', ", '", ').replace("='", '":"').replace("=", '":').replace('":":",', '==",').replace('":",', '=",')).keys()):
                        data[key] = updatePDF['data'][idx][key]
                        
                    tpl = (dateTimeOccurred, data["farmId"], data["farmName"], data["userId"], data["organizationId"], data["regionId"], data["countryId"], data["address"], data["zipcode"], data["noOfFarmHands"], data["farmSizeUOMId"], data["createdBy"], data["createdDateTime"], data["modifiedBy"], data["modifiedDateTime"], eventSource, eventType, eventId, created_at)
                    list_of_update_tuples.append(tpl) 
                
                print("List of update tuples created.")
                # print(list_of_update_tuples)
                
                print("Creating list of delete tuples")
                list_of_delete_tuples = []
                for idx in range(deletePDF.shape[0]):
                    data = {"farmId": None, "farmName": None, "userId": None, "organizationId": None, "regionId": None, "countryId": None, "address": None, "zipcode": None, "noOfFarmHands": None, "farmSizeUOMId": None, "createdBy": None, "createdDateTime": None, "modifiedBy": None, "modifiedDateTime": None}
                    dateTimeOccurred = deletePDF['dateTimeOccurred'][idx]
                    eventSource = deletePDF["eventSource"][idx]
                    eventType = deletePDF["eventType"][idx]
                    eventId = deletePDF["eventId"][idx]
                    created_at = (deletePDF['dateTimeOccurred'][idx])[:10]
                    
                    for key in list(json.loads(str(deletePDF["data"][0]).replace("Row(", '{"').replace("')", '"}').replace(", ", ', "').replace("', ", '", ').replace("='", '":"').replace("=", '":').replace('":":",', '==",').replace('":",', '=",')).keys()):
                        data[key] = deletePDF['data'][idx][key]
                        
                    tpl = (dateTimeOccurred, data["farmId"], data["farmName"], data["userId"], data["organizationId"], data["regionId"], data["countryId"], data["address"], data["zipcode"], data["noOfFarmHands"], data["farmSizeUOMId"], data["createdBy"], data["createdDateTime"], data["modifiedBy"], data["modifiedDateTime"], eventSource, eventType, eventId, created_at)
                    list_of_delete_tuples.append(tpl) 
                    
                print("List of delete tuples created.")
                # print(list_of_delete_tuples)
                
                print("Creating DataFrames with required schema")
                insrtDF = spark.createDataFrame(list_of_insert_tuples, schema)
                updtDF = spark.createDataFrame(list_of_update_tuples, schema)
                dltDF = spark.createDataFrame(list_of_delete_tuples, schema)
                
                print("DataFrames created.")
                # insrtDF.printSchema()
                # updtDF.printSchema()
                # dltDF.printSchema()
                
                print("Preparing dynamic frames for ingestion to hudi")
                insertDyF = DynamicFrame.fromDF(insrtDF, glueContext, "insertDyF")
                updateDyF = DynamicFrame.fromDF(updtDF, glueContext, "updateDyF")
                deleteDyF = DynamicFrame.fromDF(dltDF, glueContext, "deleteDyF")
                
                print("Dynamic frames created.")
            
                while aquire_lock(s3, bucket_name, prefix, glue_job_run_id) != 'Success':
                    pass
                print("Hudi is ready for data operations.")
            
                if insertDyF.count() > 0:
                    print("Starting insert into hudi table")
                    glueContext.write_dynamic_frame.from_options(frame = insertDyF, connection_type = "marketplace.spark", connection_options={'className' : 'org.apache.hudi', 'hoodie.datasource.write.precombine.field': 'dateTimeOccurred', 'hoodie.datasource.write.recordkey.field': 'farmId', 'hoodie.table.name': args['hudi_table_name'], 'hoodie.datasource.hive_sync.database': args['hudi_db_name']
                    , 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.datasource.hive_sync.table': args['hudi_table_name'], 'hoodie.datasource.hive_sync.enable': 'true', 'path': 's3://' + args['curated_bucket']+'/hudi-cdc-tables/'+ args['hudi_table_name'], 'hoodie.datasource.write.partitionpath.field': 'created_at', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}) 
                    
                    # , 'hoodie.write.lock.client.wait_time_ms': "12000", 'hoodie.write.lock.client.num_retries': "5"
                    push_metrics(glue_job_run_id, glue_job_name, glue_metric_name, glue_metric_namespace, 'INSERT', insertDyF.count(), avro_file_name, 'None')
                    
                if updateDyF.count() > 0:
                    print("Starting update for hudi table")
                    glueContext.write_dynamic_frame.from_options(frame = updateDyF, connection_type = "marketplace.spark", connection_options={'className' : 'org.apache.hudi', 'hoodie.datasource.write.precombine.field': 'dateTimeOccurred', 'hoodie.datasource.write.recordkey.field': 'farmId', 'hoodie.table.name': args['hudi_table_name'], 'hoodie.datasource.hive_sync.database': args['hudi_db_name'], 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.datasource.hive_sync.table': args['hudi_table_name'], 'hoodie.datasource.hive_sync.enable': 'true', 'path': 's3://' + args['curated_bucket']+'/hudi-cdc-tables/'+ args['hudi_table_name'], 'hoodie.datasource.write.partitionpath.field': 'created_at', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}) 
                    
                    # 'hoodie.write.concurrency.mode': 'optimistic_concurrency_control', 'hoodie.write.lock.provider': 'org.apache.hudi.hive.HiveMetastoreBasedLockProvider', 'hoodie.write.lock.hivemetastore.database': 'conformed-ub-data', 'hoodie.write.lock.hivemetastore.table': 'farm', 'hoodie.cleaner.policy.failed.writes': 'LAZY'
                    push_metrics(glue_job_run_id, glue_job_name, glue_metric_name, glue_metric_namespace, 'UPDATE', updateDyF.count(), avro_file_name, 'None', glue_metric_name, glue_metric_namespace)
                
                if deleteDyF.count() > 0:
                    print("Starting delete in hudi table")
                    glueContext.write_dynamic_frame.from_options(frame = deleteDyF, connection_type = "marketplace.spark", connection_options={'className' : 'org.apache.hudi', 'hoodie.datasource.write.precombine.field': 'dateTimeOccurred', 'hoodie.datasource.write.payload.class': 'org.apache.hudi.common.model.EmptyHoodieRecordPayload', 'hoodie.datasource.write.recordkey.field': 'farmId', 'hoodie.table.name': args['hudi_table_name'], 'hoodie.datasource.hive_sync.database': args['hudi_db_name'], 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.datasource.hive_sync.table': args['hudi_table_name'], 'hoodie.datasource.hive_sync.enable': 'true', 'path': 's3://' + args['curated_bucket']+'/hudi-cdc-tables/'+ args['hudi_table_name'], 'hoodie.datasource.write.partitionpath.field': 'created_at', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}) 
                    
                    push_metrics(glue_job_run_id, glue_job_name, glue_metric_name, glue_metric_namespace, 'DELETE', deleteDyF.count(), avro_file_name, 'None', glue_metric_name, glue_metric_namespace)
                
                release_lock(s3, bucket_name, prefix)
                # print("All finished.")

                print("The notification file processed.")
                remove_processed_notification(s3, notification_bucket_name, (notification_prefix + notification_file_name))
    release_notification_lock(s3, notification_bucket_name, (notification_prefix + notification_lock_file_name))
except Exception as e:
    send_notification(glue_job_name, glue_job_run_id, file_path, str(e))

print("Job completed. Exiting the job")
job.init(args['JOB_NAME'], args)
job.commit()
