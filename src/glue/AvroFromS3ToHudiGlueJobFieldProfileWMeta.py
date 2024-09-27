import sys
from pyspark.context import SparkContext
from pyspark.sql.session import SparkSession
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from awsglue.utils import getResolvedOptions
from pyspark.sql.types import *
from datetime import datetime as dt
import pandas as pd
import boto3
from botocore.exceptions import ClientError
import json
import time
from pyspark.sql.types import StructType, StructField, StringType, ShortType, DoubleType, TimestampType

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
    
def getAllTuples(SourcePDF, schema_obj, dict_of_none_values, avro_file_path, glue_logger): #bucket_name, prefix, avro_file_path, s3, 
    list_of_all_tuples = []
  
    for idx in range(SourcePDF.shape[0]):
        data = dict_of_none_values 
        tpl = ()
        data_list = list(SourcePDF["data"][idx].asDict())
        all_columns_list = SourcePDF.columns
        
        for field in schema_obj:
            if field["parent"] is None:
                if field["fieldName"] == "created_at": 
                    tpl += (str((SourcePDF['dateTimeOccurred'][idx])[:10]), ) 
                else: 
                    if field["fieldName"] in all_columns_list:
                        if pd.isna(SourcePDF[field["fieldName"]][idx]):
                            tpl += (None, )
                        elif field["type"] in "ShortType":
                            tpl += (int(SourcePDF[field["fieldName"]][idx]), )
                        elif field["type"] in "DoubleType":
                            tpl += (float(SourcePDF[field["fieldName"]][idx]), )
                        elif field["type"] == "TimestampType":
                            tpl += (dt.strptime(SourcePDF[field["fieldName"]][idx], '%Y-%m-%dT%H:%M:%S.%fZ'), )
                        else:
                            tpl += (str(SourcePDF[field["fieldName"]][idx]), ) 
                    else:
                        if field["fieldName"] == "avroFilePath":
                            tpl += (avro_file_path, ) 
                        else:    
                            tpl += (None, ) 
            else:
                if field["fieldName"] in data_list:
                    if pd.isna(SourcePDF['data'][idx][field["fieldName"]]):
                        tpl += (None, )
                    elif field["type"] in "ShortType":
                        tpl += (int(SourcePDF['data'][idx][field["fieldName"]]), )
                    elif field["type"] in "DoubleType":
                        tpl += (float(SourcePDF['data'][idx][field["fieldName"]]), )
                    else: 
                        tpl += (str(SourcePDF['data'][idx][field["fieldName"]]), )   
                else: 
                    tpl += (None, ) 
                    
        list_of_all_tuples.append(tpl) 
    
    print(list_of_all_tuples)
    glue_logger.info("List of tuples created.")
    return list_of_all_tuples


def getUpsertTuplesFlat(SourcePDF, schema_obj, glue_logger):
    list_of_tuples = []
  
    for idx in range(SourcePDF.shape[0]):
        tpl = ()
        for field in schema_obj:
            if pd.isna(SourcePDF[field["fieldName"]][idx]):
                tpl += (None, )
            else:
                if field["type"] == "ShortType":
                    tpl += (int(SourcePDF[field["fieldName"]][idx]), ) 
                elif field["type"] == "DoubleType":
                    tpl += (float(SourcePDF[field["fieldName"]][idx]), )
                elif field["type"] == "TimestampType":
                    tpl += (SourcePDF[field["fieldName"]][idx].to_pydatetime(), ) 
                else:    
                    tpl += (str(SourcePDF[field["fieldName"]][idx]), ) 
        list_of_tuples.append(tpl) 
    
    print(list_of_tuples)
    glue_logger.info("List of tuples created.")
    return list_of_tuples
 
def getDeleteTuplesFlat(SourcePDF, schema_obj, hudi_record_key, hudi_partition_field, hudi_precombine_field, glue_logger):
    list_of_tuples = []
  
    for idx in range(SourcePDF.shape[0]):
        tpl = ()
        for field in schema_obj:
            if pd.isna(SourcePDF[field["fieldName"]][idx]):
                tpl += (None, )
            elif field["isPIIData"]: 
                tpl += (None, )
            elif field["type"] == "ShortType":
                tpl += (int(SourcePDF[field["fieldName"]][idx]), ) 
            elif field["type"] == "DoubleType":
                tpl += (float(SourcePDF[field["fieldName"]][idx]), )
            elif field["type"] == "TimestampType":
                tpl +=  (SourcePDF[field["fieldName"]][idx].to_pydatetime(), ) 
            else:    
                tpl += (str(SourcePDF[field["fieldName"]][idx]), ) 
        list_of_tuples.append(tpl) 
    
    print(list_of_tuples)
    glue_logger.info("List of tuples created.")
    return list_of_tuples

def put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_table_name, list_of_fields_flat, keyword_delete, glue_logger):
    metaDataDF.show(1)
    metaDataPDF = metaDataDF.toPandas()
    metaDataPDF.head(1)

    for idx in range(metaDataPDF.shape[0]):
        eventTypeItem = metaDataPDF['eventType'][idx] 
        entityId = metaDataPDF[hudi_record_key][idx]
        
        putItem={
            'entityId' : entityId,
            'cdcProcessedTs' : int(dt.now().timestamp() * 1000000),
            'cdcProcessedDate' : str(dt.now().date()), 
            'entityName' : hudi_record_key, 
            'topicName': f'stage-yara-digitalsolution-fafm-{hudi_table_name}',
            'rawFile' : metaDataPDF[list_of_fields_flat[-1]][idx],
            'eventTypeList' : eventTypeItem
        }
    
        if eventTypeItem == keyword_delete:
            putItem['isDeleteRequest'] = 'x'
            putItem['eventOccurrenceTime'] = str(dt.now())
            putItem['isDeletePerformed'] = False
        
        glue_logger.info(f"Ingesting the metadata for {hudi_record_key}: {entityId}")
        
        entityTable.put_item(
            Item=putItem
            )
            
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'conformed_bucket', 'hudi_connection_name', 'hudi_db_name', 'hudi_table_name', 'glue_metric_namespace', 'glue_metric_name', 'batch_max_limit', 'message_event_types', 'data_schema_location', 'hudi_record_key', 'hudi_partition_field', 'hudi_precombine_field', 's3_object'])
glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
bucket_name = args['conformed_bucket']
hudi_connection_name = args['hudi_connection_name']
hudi_db_name = args['hudi_db_name']
hudi_table_name = args['hudi_table_name']
glue_metric_namespace = args['glue_metric_namespace']
glue_metric_name = args['glue_metric_name']
batch_max_limit = int(args['batch_max_limit'])
message_event_types =  json.loads(args['message_event_types'])
data_schema_location = args['data_schema_location']
hudi_record_key = args['hudi_record_key']
hudi_partition_field = args['hudi_partition_field']
hudi_precombine_field = args['hudi_precombine_field']

prefix = f'hudi-cdc-tables/{hudi_table_name}/processing.lock'
notification_bucket_name = (args['s3_object']).split("/")[2]
notification_prefix = (args['s3_object']).replace(f"s3://{notification_bucket_name}/", "")
notification_lock_file_name = 'processing.lock'

keyword_insert = [message_event_types['insert']]
keyword_update = [message_event_types['update']]
keyword_delete = [message_event_types['delete']]

schema_bucket_name = data_schema_location.split("/")[2]
schema_prefix = data_schema_location.replace(f"s3://{schema_bucket_name}/", "")

dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
entityTable = dynamodb.Table('RawEventEntity_v5')
s3 = boto3.resource('s3')

for obj in s3.Bucket(schema_bucket_name).objects.filter(Prefix=schema_prefix):
    body = obj.get()['Body'].read().decode('utf8')

schema_obj = json.loads(body)


list_of_fields = []
list_of_fields_flat = []
dict_of_none_values = {}
fields = []
for field in schema_obj:
    if field["type"] == "ShortType":
        fields.append(StructField(field["fieldName"], ShortType(), field["isNullable"]))
    elif field["type"] == "DoubleType":
        fields.append(StructField(field["fieldName"], DoubleType(), field["isNullable"]))
    elif field["type"] == "TimestampType":
        fields.append(StructField(field["fieldName"], TimestampType(), field["isNullable"]))
    else:
        fields.append(StructField(field["fieldName"], StringType(), field["isNullable"]))
    list_of_fields_flat.append(field["fieldName"]) 
    dict_of_none_values[field["fieldName"]] = None
    if field["parent"] is None:
        list_of_fields.append(f'{field["fieldName"]}')
    else:
        list_of_fields.append(f'{field["parent"]}.{field["fieldName"]}')

schema = StructType(fields)

spark = SparkSession.builder.config('spark.serializer','org.apache.spark.serializer.KryoSerializer').config('spark.sql.hive.convertMetastoreParquet','false').getOrCreate()

sc = spark.sparkContext
glueContext = GlueContext(sc)
job = Job(glueContext)

logger = glueContext.get_logger()
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
        logger.info('main DataFrame prepared.')

        for obj in s3.Bucket(notification_bucket_name).objects.filter(Prefix=notification_prefix):
            files_to_process_ordered.append(obj.key.split("/")[-1])
        files_to_process_ordered.remove(notification_lock_file_name)    
        files_to_process_ordered.sort()
        
        for file_name in files_to_process_ordered: 
            notification_file_name = file_name 
            logger.info(f"notification_file_name: {notification_file_name}")
            if len(notification_file_name) > 0 : 
                logger.info(f'Processing {notification_file_name} file notification')
                file_path = ""
                for obj in s3.Bucket(notification_bucket_name).objects.filter(Prefix=(notification_prefix + notification_file_name)):
                    file_path = obj.get()['Body'].read().decode('utf8')
            
                logger.info("Reading avro in S3:")
                logger.info(f"Full S3 object path: {file_path}")
                
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
                if (total_row_no + current_df_row_no) > batch_max_limit and total_row_no != 0:
                    ready_for_hudi_processing = not is_hudi_locked(s3, bucket_name, prefix, glue_job_run_id, logger)
                
                if not ready_for_hudi_processing:
                    reference_files_processed.append(notification_file_name)
                    total_row_no += current_df_row_no

                    logger.info("Selecting DynamicFrame for all records")
                    allDF = DF.select_fields(paths=list_of_fields)
                    logger.info("DynamicFrame selected.")
                    
                    logger.info("Converting DynamicFrame to Pandas DataFrames")
                    AllPDF = allDF.toDF().toPandas()
                    logger.info("Pandas DataFrame created.")
                    
                    logger.info("Creating list of tuples")
                    list_of_all_tuples = []
  
                    list_of_all_tuples = getAllTuples(AllPDF, schema_obj, dict_of_none_values, file_path, logger)  #notification_bucket_name, f"{hudi_table_name}/logs/{hudi_record_key}", file_path, s3, 
                    
                    logger.info("Creating DataFrames with required schema")
                    allProcessedDF = spark.createDataFrame(list_of_all_tuples, schema)
                    
                    allProcessedDF.printSchema()
                    allProcessedDF.show(1)
                    
                    logger.info("DataFrames created.")
                    
                    if mainDF.count() == 0:

                        logger.info("Copying the records")
                        mainDF = allProcessedDF

                        logger.info(f"The records were copied to the main DataFrame") 
                    else:
                        logger.info("Adding the records")
                        mainDF = mainDF.union(allProcessedDF)

                        logger.info(f"The records were added to the main DataFrame") 
                    
                else:
                    logger.info(f"batch max limit reached ({total_row_no + current_df_row_no} records) and ready for Hudi operations")
                    total_row_no = 0
                    break
            
        logger.info(f"Preparing DynamicFrame from main DataFrame")
        mainDyF = DynamicFrame.fromDF(mainDF, glueContext, "mainDyF")
        logger.info(f"The main DynamicFrame has the following amount of records: {mainDyF.count()}")
        
        logger.info("Selecting DynamicFrame for insert/update/delete")
        mainDF.printSchema()
        print(list_of_fields_flat)
        insertDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_insert).select_fields(paths=list_of_fields_flat)
        updateDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_update).select_fields(paths=list_of_fields_flat)
        deleteDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_delete).select_fields(paths=list_of_fields_flat)
        insertDyF.show(10)
        logger.info("DynamicFrame selected.")
        
        logger.info("Cleaning DataFrames")
        mainDF = spark.createDataFrame(data = emp_RDD, schema = schema)
        mainDyF = DynamicFrame.fromDF(mainDF, glueContext, "mainDyF")
        logger.info("DataFrames cleaned up")
        
        insertPDF = insertDyF.toDF().toPandas()
        updatePDF = updateDyF.toDF().toPandas()
        deletePDF = deleteDyF.toDF().toPandas()
                    
        logger.info("Creating list of insert tuples")
        
        list_of_insert_tuples = []
        list_of_insert_tuples = getUpsertTuplesFlat(insertPDF, schema_obj, logger)
        
        logger.info("Creating list of update tuples")
        list_of_update_tuples = []
        list_of_update_tuples = getUpsertTuplesFlat(updatePDF, schema_obj, logger)
        
        logger.info("Creating list of delete tuples")
        list_of_delete_tuples = []
        list_of_delete_tuples = getDeleteTuplesFlat(deletePDF, schema_obj, hudi_record_key, hudi_partition_field, hudi_precombine_field, logger)
        
        insrtDF = spark.createDataFrame(list_of_insert_tuples, schema)
        updtDF = spark.createDataFrame(list_of_update_tuples, schema)
        dltDF = spark.createDataFrame(list_of_delete_tuples, schema)
        
        insrtDyF = DynamicFrame.fromDF(insrtDF, glueContext, "insrtDyF")
        logger.info("Dynamic frame for insert created.")

        updtDyF = DynamicFrame.fromDF(updtDF, glueContext, "updtDyF")
        logger.info("Dynamic frame for update created.")

        dltDyF = DynamicFrame.fromDF(dltDF, glueContext, "dltDyF")
        logger.info("Dynamic frame for delete created.")

        
        logger.info("Hudi is ready for data operations.")
        
        while aquire_lock(s3, bucket_name, prefix, glue_job_run_id, logger) != 'Success':
            pass
        
        additional_options={
            "hoodie.table.name": f'{hudi_table_name}',
            "hoodie.datasource.write.storage.type": "COPY_ON_WRITE",
            'hoodie.datasource.write.payload.class': 'org.apache.hudi.common.model.DefaultHoodieRecordPayload',
            'hoodie.index.type':'GLOBAL_BLOOM',
            "hoodie.datasource.write.operation": "upsert",
            "hoodie.datasource.write.recordkey.field": f'{hudi_record_key}',
            "hoodie.datasource.write.precombine.field": f'{hudi_precombine_field}',
            "hoodie.datasource.write.partitionpath.field": f'{hudi_partition_field}',
            "hoodie.datasource.write.hive_style_partitioning": "true",
            "hoodie.datasource.hive_sync.enable": "true",
            "hoodie.datasource.hive_sync.database": f'{hudi_db_name}',
            "hoodie.datasource.hive_sync.table": f'{hudi_table_name}',
            "hoodie.datasource.hive_sync.partition_fields": f'{hudi_partition_field}',
            "hoodie.datasource.hive_sync.partition_extractor_class": "org.apache.hudi.hive.MultiPartKeysValueExtractor",
            "hoodie.datasource.hive_sync.use_jdbc": "false",
            "hoodie.datasource.hive_sync.mode": "hms",
            'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 
            'hoodie.cleaner.fileversions.retained':1,
            "path": f's3://{bucket_name}/hudi-cdc-tables/{hudi_table_name}'
        }
        
        if insrtDyF.count() > 0:
            logger.info("Starting insert into hudi table")
                       
            insrtDF.show(1)
            insrtDF.select(list_of_fields_flat[:-1]).show(1)
            
            glueContext.write_data_frame.from_catalog(frame = insrtDF.select(list_of_fields_flat[:-1]), database = f'{hudi_db_name}', table_name = f'{hudi_table_name}', additional_options=additional_options)
            
            metaDataDF = insrtDF[[hudi_record_key, 'eventType', list_of_fields_flat[-1]]]
            put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_table_name, list_of_fields_flat, keyword_delete, logger)
            
        if updtDyF.count() > 0:
            logger.info("Starting update for hudi table")
            
            glueContext.write_data_frame.from_catalog(frame = updtDF.select(list_of_fields_flat[:-1]), database = f'{hudi_db_name}', table_name = f'{hudi_table_name}', additional_options=additional_options)
            
            metaDataDF = updtDF[[hudi_record_key, 'eventType', list_of_fields_flat[-1]]]
            put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_table_name, list_of_fields_flat, keyword_delete, logger)            
        
        if dltDyF.count() > 0:
            logger.info("Starting delete in hudi table")
            
            glueContext.write_data_frame.from_catalog(frame = dltDF.select(list_of_fields_flat[:-1]), database = f'{hudi_db_name}', table_name = f'{hudi_table_name}', additional_options=additional_options)

            metaDataDF = dltDF[[hudi_record_key, 'eventType', list_of_fields_flat[-1]]]
            put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_table_name, list_of_fields_flat, keyword_delete, logger)
                
        release_lock(s3, bucket_name, prefix, logger)
    
        logger.info("The notification file(s) processed.")
        remove_processed_notification(s3, notification_bucket_name, notification_prefix, reference_files_processed, logger)
        reference_files_processed = []
    release_notification_lock(s3, notification_bucket_name, (notification_prefix + notification_lock_file_name), logger)
except Exception as e:
    logger.error(str(e))
    raise Exception(str(e))

logger.info("Job completed. Exiting the job")
job.init(args['JOB_NAME'], args)
job.commit()
