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
# def push_metrics(glue_job_run_id, glue_job_name='AvroFromS3ToHudiGlueJob', operation='INSERT', value=0, avro_file_name='None', unit='None', metric_name='HudiCRUDMetric', metric_namespace='HudiDataOperations'):
#     cloudwatch = boto3.client('cloudwatch')
#     metric_data = [
#             {
#                 'MetricName': 'DefaultMetricName',
#                 'Dimensions': [
#                     {
#                         'Name': 'JobName',
#                         'Value': 'DefaultJobName'
#                     },
#                     {
#                         'Name': 'JobRunId',
#                         'Value': 'DefaultJobRunId'
#                     },
#                     {
#                         'Name': 'Operation',
#                         'Value': 'DefaultOperation'
#                     },
#                     {
#                         'Name': 'File',
#                         'Value': 'DefaultFileName'
#                     }
#                 ],
#                 'Unit': 'None',
#                 'Value': 0
#             },
#         ]
#     metric_data[0]['MetricName'] = metric_name
#     metric_data[0]['Dimensions'][0]['Value'] = glue_job_name
#     metric_data[0]['Dimensions'][1]['Value'] = glue_job_run_id
#     metric_data[0]['Dimensions'][2]['Value'] = operation
#     metric_data[0]['Dimensions'][3]['Value'] = avro_file_name
#     metric_data[0]['Unit'] = unit
#     metric_data[0]['Value'] = value
#     response = cloudwatch.put_metric_data(
#         MetricData = metric_data,
#         Namespace = metric_namespace
#     )
#     print("Hudi operation metrics registered.") #response)

def aquire_lock(s3, bucket_name, prefix, glue_job_run_id, glue_logger):
    try:
        sleep_time = 3
        while True:
            s3.Object(bucket_name, prefix).load()
            glue_logger.info(f"Waiting for lock to be released... {sleep_time}s")
            time.sleep(sleep_time)
            # sleep_time += 1
        return "Failed"
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            glue_logger.info("Requesting a lock")
            object = s3.Object(bucket_name, prefix)
            object.put(Body=glue_job_run_id)
            glue_logger.info("The lock requested.")
            glue_logger.info("Approving the lock")
            time.sleep(0)
            for obj in s3.Bucket(bucket_name).objects.filter(Prefix=prefix):
                # key = obj.key
                body = obj.get()['Body'].read()
                if body != glue_job_run_id.encode('ascii'):
                    glue_logger.info(f"The lock was not approved! The job '{glue_job_run_id}' to be considered for retry")
                    return "Retry"        
                else:
                    glue_logger.info("The lock approved.")
            return "Success"

def is_hudi_locked(s3, bucket_name, prefix, glue_job_run_id, glue_logger):
    try:
        s3.Object(bucket_name, prefix).load()
        return True
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            return False            

def release_lock(s3, bucket_name, prefix, glue_logger):
    glue_logger.info("Removing the lock")
    s3.Object(bucket_name, prefix).delete()
    glue_logger.info("The lock removed.")
    
def release_notification_lock(s3, bucket_name, prefix, glue_logger):
    glue_logger.info("Removing the notification lock")
    s3.Object(bucket_name, prefix).delete()
    glue_logger.info("The notification lock removed.")

def remove_processed_notification(s3, bucket_name, prefix, reference_files_processed, glue_logger):
    for file in reference_files_processed:
        glue_logger.info(f'Removing the notification file: "{file}"')
        s3.Object(bucket_name, (prefix + file)).delete()
        glue_logger.info("The notification file removed.")

# def send_notification(glue_job_name, glue_job_run_id, full_file_path, error_message):
#     # Replace sender@example.com with your "From" address.
#     # This address must be verified with Amazon SES.
#     SENDER = "c057185@yara.com"
    
#     # is still in the sandbox, this address must be verified.
#     RECIPIENT = "viktoras.ciumanovas@yara.com"
    
#     # If necessary, replace us-west-2 with the AWS Region you're using for Amazon SES.
#     AWS_REGION = "eu-central-1"
    
#     # The subject line for the email.
#     SUBJECT = f'AWS Glue Job "{glue_job_name}" processing failure'
    
#     # The email body for recipients with non-HTML email clients.
#     BODY_TEXT = ("Failure notification for AWS Glue Job\r\n"
#                  f'There was an issue processing "{full_file_path}" file'
#                 )
                
#     # The HTML body of the email.
#     BODY_HTML = """<html>
#     <head></head>
#     <body>
#       <h1>Failure notification for AWS Glue Job</h1>
#       <p><b>Glue Job Name</b>: """ + glue_job_name + """</p>
#       <p><b>Glue Job Id</b>: """ + glue_job_run_id + """</p>
#       <p><b>Issue with file</b>: """ + full_file_path + """</p>
#       <p><b>The error message</b>: """ + error_message + """</p>
#     </body>
#     </html>
#     """            
    
#     # The character encoding for the email.
#     CHARSET = "UTF-8"
    
#     # Create a new SES resource and specify a region.
#     client = boto3.client('ses',region_name=AWS_REGION)
    
#     # Try to send the email.
#     try:
#         #Provide the contents of the email.
#         response = client.send_email(
#             Destination={
#                 'ToAddresses': [
#                     RECIPIENT,
#                 ],
#             },
#             Message={
#                 'Body': {
#                     'Html': {
#                         'Charset': CHARSET,
#                         'Data': BODY_HTML,
#                     },
#                     'Text': {
#                         'Charset': CHARSET,
#                         'Data': BODY_TEXT,
#                     },
#                 },
#                 'Subject': {
#                     'Charset': CHARSET,
#                     'Data': SUBJECT,
#                 },
#             },
#             Source=SENDER,
#         )
#     # Display an error if something goes wrong.	
#     except ClientError as e:
#         print(e.response['Error']['Message'])
#     else:
#         print("Email sent! Message ID:"),
#         print(response['MessageId'])
    
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'conformed_bucket', 'hudi_connection_name', 'hudi_db_name', 'hudi_table_name', 'glue_metric_namespace', 'glue_metric_name', 'batch_max_limit', 's3_object'])
glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
bucket_name = args['conformed_bucket'] #'yara-das-ffdp-conformed-eucentral1-479055760150-stage-stitch'
hudi_connection_name = args['hudi_connection_name']
hudi_db_name = args['hudi_db_name']
hudi_table_name = args['hudi_table_name']
glue_metric_namespace = args['glue_metric_namespace']
glue_metric_name = args['glue_metric_name']
batch_max_limit = int(args['batch_max_limit'])

prefix = f'hudi-cdc-tables/{hudi_table_name}/processing.lock'
notification_bucket_name = (args['s3_object']).split("/")[2]
# avro_file_name = (args['s3_object']).split("/")[-1]
notification_prefix = (args['s3_object']).replace(f"s3://{notification_bucket_name}/", "")
notification_lock_file_name = 'processing.lock'

keyword_insert = ['FarmAdded']
keyword_update = ['FarmUpdated']
keyword_delete = ['FarmDeleted']
list_of_fields = ["dateTimeOccurred", "data.farmId", "data.farmName", "data.userId", "data.organizationId", "data.regionId", "data.countryId", "data.address", "data.zipcode", "data.noOfFarmHands", "data.farmSizeUOMId", "data.createdBy", "data.createdDateTime", "modifiedBy", "modifiedDateTime", "eventSource", "eventType", "eventId", "created_at"]
list_of_fields_flat = ["dateTimeOccurred", "farmId", "farmName", "userId", "organizationId", "regionId", "countryId", "address", "zipcode", "noOfFarmHands", "farmSizeUOMId", "createdBy", "createdDateTime", "modifiedBy", "modifiedDateTime", "eventSource", "eventType", "eventId", "created_at"]

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

# print("Spark Version:" + spark.version)
try:
    # Create an empty RDD
    emp_RDD = sc.emptyRDD()
    while len(list(s3.Bucket(notification_bucket_name).objects.filter(Prefix=notification_prefix))) > 1:
        total_row_no = 0
        current_df_row_no = 0
        reference_files_processed = []
        files_to_process_ordered = [] 
        # Create an empty RDD with empty schema
        logger.info('Preparing main DataFrame')
        mainDF = spark.createDataFrame(data = emp_RDD, schema = schema)
        # mainDF.printSchema()
        logger.info('main DataFrame prepared.')

        for obj in s3.Bucket(notification_bucket_name).objects.filter(Prefix=notification_prefix):
            files_to_process_ordered.append(obj.key.split("/")[-1])
        # print(files_to_process_ordered)
        files_to_process_ordered.remove(notification_lock_file_name)    
        # print(files_to_process_ordered)
        files_to_process_ordered.sort()
        # print(files_to_process_ordered)
        
        for file_name in files_to_process_ordered: #s3.Bucket(notification_bucket_name).objects.filter(Prefix=notification_prefix):
            notification_file_name = file_name #.key.split("/")[-1]
            logger.info(f"notification_file_name: {notification_file_name}")
            if len(notification_file_name) > 0 : #and notification_file_name != notification_lock_file_name:
                logger.info(f'Processing {notification_file_name} file notification')
                # reference_files_processed.append(notification_file_name) 
                file_path = ""
                for obj in s3.Bucket(notification_bucket_name).objects.filter(Prefix=(notification_prefix + notification_file_name)):
                    # key = obj.key
                    file_path = obj.get()['Body'].read().decode('utf8')
            
                logger.info("Reading avro in S3:")
                logger.info(f"Full S3 object path: {file_path}")
                
                # avro_file_name = file_path.split("/")[-1]
                avro_file_name = notification_file_name
                DF = glueContext.create_dynamic_frame.from_options(
                    connection_type="s3",
                    connection_options={"paths": [file_path]},
                    format="avro",
                    additional_options = {"inferSchema":"true"}
                )
                current_df_row_no = DF.count()
                
                logger.info(f'Total record count (without current): {total_row_no}')
                logger.info(f'Curent record count: {current_df_row_no}')
                
                ready_for_hudi_processing = False
                if (total_row_no + current_df_row_no) > batch_max_limit:
                    ready_for_hudi_processing = not is_hudi_locked(s3, bucket_name, prefix, glue_job_run_id, logger)
                
                if not ready_for_hudi_processing:
                    reference_files_processed.append(notification_file_name)
                    total_row_no += current_df_row_no
                    # DF.show(10)
                    logger.info("Selecting DynamicFrame for all records")
                    allDF = DF.select_fields(paths=list_of_fields)
                    # insertDF.printSchema() 
                    # allDF.show(1)
                    logger.info("DynamicFrame selected.")
                    
                    logger.info("Converting DynamicFrame to Pandas DataFrames")
                    # print(allDF.toJSON())
                    AllPDF = allDF.toDF().toPandas()
                    logger.info("Pandas DataFrame created.")
                    
                    logger.info("Creating list of all tuples")
                    list_of_all_tuples = []
  
                    for idx in range(AllPDF.shape[0]):
                        data = {"farmId": None, "farmName": None, "userId": None, "organizationId": None, "regionId": None, "countryId": None, "address": None, "zipcode": None, "noOfFarmHands": None, "farmSizeUOMId": None, "createdBy": None, "createdDateTime": None, "modifiedBy": None, "modifiedDateTime": None}
                        
                        dateTimeOccurred = AllPDF['dateTimeOccurred'][idx]
                        eventSource = AllPDF["eventSource"][idx]
                        eventType = AllPDF["eventType"][idx]
                        eventId = AllPDF["eventId"][idx]
                        created_at = (AllPDF['dateTimeOccurred'][idx])[:10]
                        for key in list(AllPDF["data"][idx].asDict()):  
                            data[key] = AllPDF['data'][idx][key]
                            
                        tpl = (dateTimeOccurred, data["farmId"], data["farmName"], data["userId"], data["organizationId"], data["regionId"], data["countryId"], data["address"], data["zipcode"], data["noOfFarmHands"], data["farmSizeUOMId"], data["createdBy"], data["createdDateTime"], data["modifiedBy"], data["modifiedDateTime"], eventSource, eventType, eventId, created_at)
                        list_of_all_tuples.append(tpl) 
                    
                    logger.info("List of all tuples created.")
                    
                    
                    logger.info("Creating DataFrames with required schema")
                    allProcessedDF = spark.createDataFrame(list_of_all_tuples, schema)
                    logger.info("DataFrames created.")
                    
                    if mainDF.count() == 0:
                        # allProcessedDF.show(1)
                        logger.info("Copying the records")
                        mainDF = allProcessedDF
                        # mainDF.show(1)
                        logger.info(f"The records were copied to the main DataFrame") #mainDF.count()
                    else:
                        logger.info("Adding the records")
                        mainDF = mainDF.union(allProcessedDF)
                        # mainDF.show(5)
                        logger.info(f"The records were added to the main DataFrame") #mainDF.count()
                    
                    # logger.info("Dynamic frames created.")
                else:
                    logger.info(f"batch max limit reached ({total_row_no + current_df_row_no} records) and ready for Hudi operations")
                    break
            
            # while aquire_lock(s3, bucket_name, prefix, glue_job_run_id) != 'Success':
            #     pass
    

        logger.info(f"Preparing DynamicFrame from main DataFrame")
        mainDyF = DynamicFrame.fromDF(mainDF, glueContext, "mainDyF")
        logger.info(f"The main DynamicFrame has the following amount of records: {mainDyF.count()}")
        
        logger.info("Selecting DynamicFrame for insert/update/delete")
        # mainDF.printSchema()
        insertDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_insert).select_fields(paths=list_of_fields_flat)
        updateDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_update).select_fields(paths=list_of_fields_flat)
        deleteDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_delete).select_fields(paths=list_of_fields_flat)
        # insertDyF.printSchema()
        # insertDyF.show(10)
        logger.info("DynamicFrame selected.")
        
        logger.info("Cleaning DataFrames")
        mainDF = spark.createDataFrame(data = emp_RDD, schema = schema)
        mainDyF = DynamicFrame.fromDF(mainDF, glueContext, "mainDyF")
        logger.info("DataFrames cleaned up")
        
        # raise Exception("Program reached intended stop point")
        insertPDF = insertDyF.toDF().toPandas()
        updatePDF = updateDyF.toDF().toPandas()
        deletePDF = deleteDyF.toDF().toPandas()
                    
        logger.info("Creating list of insert tuples")
        
        list_of_insert_tuples = []
        for idx in range(insertPDF.shape[0]):
            data = {"farmId": None, "farmName": None, "userId": None, "organizationId": None, "regionId": None, "countryId": None, "address": None, "zipcode": None, "noOfFarmHands": None, "farmSizeUOMId": None, "createdBy": None, "createdDateTime": None, "modifiedBy": None, "modifiedDateTime": None}
            
            dateTimeOccurred = insertPDF['dateTimeOccurred'][idx]
            eventSource = insertPDF["eventSource"][idx]
            eventType = insertPDF["eventType"][idx]
            eventId = insertPDF["eventId"][idx]
            created_at = insertPDF['created_at'][idx]
            for key in list(data.keys()):
                data[key] = insertPDF[key][idx]
                # logger.info(f"key: {key}")
            if pd.isna(data["noOfFarmHands"]) or data["noOfFarmHands"] == None:
                data["noOfFarmHands"] = None
            else:
                data["noOfFarmHands"] = int(data["noOfFarmHands"])
                
            tpl = (dateTimeOccurred, data["farmId"], data["farmName"], data["userId"], data["organizationId"], data["regionId"], data["countryId"], data["address"], data["zipcode"], data["noOfFarmHands"], data["farmSizeUOMId"], data["createdBy"], data["createdDateTime"], data["modifiedBy"], data["modifiedDateTime"], eventSource, eventType, eventId, created_at)
            list_of_insert_tuples.append(tpl) 
        
        logger.info("List of insert tuples created.")
        # print(list_of_insert_tuples)
        
        logger.info("Creating list of update tuples")
        list_of_update_tuples = []
        for idx in range(updatePDF.shape[0]):
            data = {"farmId": None, "farmName": None, "userId": None, "organizationId": None, "regionId": None, "countryId": None, "address": None, "zipcode": None, "noOfFarmHands": None, "farmSizeUOMId": None, "createdBy": None, "createdDateTime": None, "modifiedBy": None, "modifiedDateTime": None}
            
            dateTimeOccurred = updatePDF['dateTimeOccurred'][idx]
            eventSource = updatePDF["eventSource"][idx]
            eventType = updatePDF["eventType"][idx]
            eventId = updatePDF["eventId"][idx]
            created_at = updatePDF['created_at'][idx]
            for key in list(data.keys()):
                data[key] = updatePDF[key][idx]
                
            if pd.isna(data["noOfFarmHands"]) or data["noOfFarmHands"] == None:
                data["noOfFarmHands"] = None
            else:
                data["noOfFarmHands"] = int(data["noOfFarmHands"])            
                
            tpl = (dateTimeOccurred, data["farmId"], data["farmName"], data["userId"], data["organizationId"], data["regionId"], data["countryId"], data["address"], data["zipcode"], data["noOfFarmHands"], data["farmSizeUOMId"], data["createdBy"], data["createdDateTime"], data["modifiedBy"], data["modifiedDateTime"], eventSource, eventType, eventId, created_at)
            list_of_update_tuples.append(tpl) 
        
        logger.info("List of update tuples created.")
        # print(list_of_update_tuples)
        
        logger.info("Creating list of delete tuples")
        list_of_delete_tuples = []
        for idx in range(deletePDF.shape[0]):
            data = {"farmId": None, "farmName": None, "userId": None, "organizationId": None, "regionId": None, "countryId": None, "address": None, "zipcode": None, "noOfFarmHands": None, "farmSizeUOMId": None, "createdBy": None, "createdDateTime": None, "modifiedBy": None, "modifiedDateTime": None}
            
            dateTimeOccurred = deletePDF['dateTimeOccurred'][idx]
            eventSource = deletePDF["eventSource"][idx]
            eventType = deletePDF["eventType"][idx]
            eventId = deletePDF["eventId"][idx]
            created_at = deletePDF['created_at'][idx]
            for key in list(data.keys()):
                data[key] = deletePDF[key][idx]
                
            if pd.isna(data["noOfFarmHands"]) or data["noOfFarmHands"] == None:
                data["noOfFarmHands"] = None
            else:
                data["noOfFarmHands"] = int(data["noOfFarmHands"])  
                
            tpl = (dateTimeOccurred, data["farmId"], data["farmName"], data["userId"], data["organizationId"], data["regionId"], data["countryId"], data["address"], data["zipcode"], data["noOfFarmHands"], data["farmSizeUOMId"], data["createdBy"], data["createdDateTime"], data["modifiedBy"], data["modifiedDateTime"], eventSource, eventType, eventId, created_at)
            list_of_delete_tuples.append(tpl) 
        
        logger.info("List of update delete created.")
        # print(list_of_delete_tuples)
        
        insrtDF = spark.createDataFrame(list_of_insert_tuples, schema)
        updtDF = spark.createDataFrame(list_of_update_tuples, schema)
        dltDF = spark.createDataFrame(list_of_delete_tuples, schema)
        
        insrtDyF = DynamicFrame.fromDF(insrtDF, glueContext, "insrtDyF")
        logger.info("Dynamic frame for insert created.")
        # insrtDyF.printSchema()
        updtDyF = DynamicFrame.fromDF(updtDF, glueContext, "updtDyF")
        logger.info("Dynamic frame for update created.")
        # updtDyF.printSchema()
        dltDyF = DynamicFrame.fromDF(dltDF, glueContext, "dltDyF")
        logger.info("Dynamic frame for delete created.")
        # dltDyF.printSchema()
        
        logger.info("Hudi is ready for data operations.")
        
        while aquire_lock(s3, bucket_name, prefix, glue_job_run_id, logger) != 'Success':
            pass
        
        if insrtDyF.count() > 0:
            logger.info("Starting insert into hudi table")
            
            commonConfig = {'connectionName': f'{hudi_connection_name}', 'className' : 'org.apache.hudi', 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.datasource.write.precombine.field': 'dateTimeOccurred', 'hoodie.datasource.write.recordkey.field': 'farmId', 'hoodie.table.name': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'hoodie.datasource.hive_sync.database': f'{hudi_db_name}', 'hoodie.datasource.hive_sync.table': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'path': f's3://{bucket_name}/hudi-cdc-tables/{hudi_table_name}', 'hoodie.datasource.write.partitionpath.field': 'created_at', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}
            combinedConf = {**commonConfig}
            
            ApacheHudiConnector = (
                glueContext.write_dynamic_frame.from_options(
                    frame=insrtDyF,
                    connection_type="marketplace.spark",
                    connection_options=combinedConf,
                    transformation_ctx="ApacheHudiConnector",
                )
            )
    
            # push_metrics(glue_job_run_id, glue_job_name, 'INSERT', insertDyF.count(), avro_file_name, 'None', glue_metric_name, glue_metric_namespace)
            
        if updtDyF.count() > 0:
            logger.info("Starting update for hudi table")
            
            commonConfig = {'connectionName': f'{hudi_connection_name}', 'className' : 'org.apache.hudi', 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.datasource.write.precombine.field': 'dateTimeOccurred', 'hoodie.datasource.write.recordkey.field': 'farmId', 'hoodie.table.name': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'hoodie.datasource.hive_sync.database': f'{hudi_db_name}', 'hoodie.datasource.hive_sync.table': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'path': f's3://{bucket_name}/hudi-cdc-tables/{hudi_table_name}', 'hoodie.datasource.write.partitionpath.field': 'created_at', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}
            combinedConf = {**commonConfig}
            
            ApacheHudiConnector = (
                glueContext.write_dynamic_frame.from_options(
                    frame=updtDyF,
                    connection_type="marketplace.spark",
                    connection_options=combinedConf,
                    transformation_ctx="ApacheHudiConnector",
                )
            )                    
            
        #     # push_metrics(glue_job_run_id, glue_job_name, 'UPDATE', updateDyF.count(), avro_file_name, 'None', glue_metric_name, glue_metric_namespace)
        
        if dltDyF.count() > 0:
            logger.info("Starting delete in hudi table")
            
            commonConfig = {'connectionName': f'{hudi_connection_name}', 'className' : 'org.apache.hudi', 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.datasource.write.precombine.field': 'dateTimeOccurred', 'hoodie.datasource.write.payload.class': 'org.apache.hudi.common.model.EmptyHoodieRecordPayload', 'hoodie.datasource.write.recordkey.field': 'farmId', 'hoodie.table.name': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'hoodie.datasource.hive_sync.database': f'{hudi_db_name}', 'hoodie.datasource.hive_sync.table': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'path': f's3://{bucket_name}/hudi-cdc-tables/{hudi_table_name}', 'hoodie.datasource.write.partitionpath.field': 'created_at', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}
            combinedConf = {**commonConfig}
            
            ApacheHudiConnector = (
                glueContext.write_dynamic_frame.from_options(
                    frame=dltDyF,
                    connection_type="marketplace.spark",
                    connection_options=combinedConf,
                    transformation_ctx="ApacheHudiConnector",
                )
            )                    
            
                    # push_metrics(glue_job_run_id, glue_job_name, 'DELETE', deleteDyF.count(), avro_file_name, 'None', glue_metric_name, glue_metric_namespace)
                
        release_lock(s3, bucket_name, prefix, logger)
        # print("All finished.")
    
        logger.info("The notification file(s) processed.")
        remove_processed_notification(s3, notification_bucket_name, notification_prefix, reference_files_processed, logger)
        reference_files_processed = []
        # raise Exception("Program reached intended stop point")
    release_notification_lock(s3, notification_bucket_name, (notification_prefix + notification_lock_file_name), logger)
except Exception as e:
    # send_notification(glue_job_name, glue_job_run_id, file_path, str(e))
    logger.error(str(e))
    raise Exception(str(e))

logger.info("Job completed. Exiting the job")
job.init(args['JOB_NAME'], args)
job.commit()
