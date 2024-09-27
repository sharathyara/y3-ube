from ffdputils import lock, cwmetrics, metastore, schemaparser, FFDPLogger
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.session import SparkSession
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
import boto3
import json
import uuid
import sys
        

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'conformed_bucket', 'hudi_connection_name', 'hudi_db_name', 'hudi_table_name', 'glue_metric_namespace', 'glue_metric_name', 'batch_max_limit', 'message_event_types', 'data_schema_location', 'hudi_record_key', 'hudi_partition_field', 'hudi_precombine_field', 'metastore_table_name', 's3_object'])
glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
# traceId = args['traceId']
traceId = uuid.uuid4()
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
metastore_table_name = args['metastore_table_name']

prefix = f'hudi-cdc-tables/{hudi_table_name}/processing.lock'
notification_bucket_name = (args['s3_object']).split("/")[2]
notification_prefix = (args['s3_object']).replace(f"s3://{notification_bucket_name}/", "")
notification_lock_file_name = 'processing.lock'

keyword_insert = message_event_types['insert'].split(",")
keyword_update = message_event_types['update'].split(",")
keyword_delete = message_event_types['delete'].split(",")

schema_bucket_name = data_schema_location.split("/")[2]
schema_prefix = data_schema_location.replace(f"s3://{schema_bucket_name}/", "")

dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
entityTable = dynamodb.Table(metastore_table_name)
s3 = boto3.resource('s3')
cw_client = boto3.client('cloudwatch') 

for obj in s3.Bucket(schema_bucket_name).objects.filter(Prefix=schema_prefix):
    body = obj.get()['Body'].read().decode('utf8')
    
schema_obj = json.loads(body)

schema, list_of_fields, list_of_fields_flat = schemaparser.get_schema(schema_obj)

spark = SparkSession.builder.config('spark.serializer','org.apache.spark.serializer.KryoSerializer').config('spark.sql.hive.convertMetastoreParquet','false').getOrCreate()

sc = spark.sparkContext
glueContext = GlueContext(sc)
job = Job(glueContext)

logger = glueContext.get_logger()
log_former = FFDPLogger.FFDPLogger(traceId, glue_job_name, glue_job_run_id)
try:
    emp_RDD = sc.emptyRDD()
    while len(list(s3.Bucket(notification_bucket_name).objects.filter(Prefix=notification_prefix))) > 1:
        total_row_no = 0
        current_df_row_no = 0
        reference_files_processed = []
        files_to_process_ordered = [] 
        logger.info(log_former.get_message("Preparing main DataFrame"))
        mainDF = spark.createDataFrame(data = emp_RDD, schema = schema)
        logger.info(log_former.get_message("main DataFrame prepared."))

        for obj in s3.Bucket(notification_bucket_name).objects.filter(Prefix=notification_prefix):
            files_to_process_ordered.append(obj.key.split("/")[-1])
        files_to_process_ordered.remove(notification_lock_file_name)    
        files_to_process_ordered.sort()
        
        for file_name in files_to_process_ordered: 
            notification_file_name = file_name
            logger.info(log_former.get_message(f"notification_file_name: {notification_file_name}"))
            if len(notification_file_name) > 0: 
                logger.info(log_former.get_message(f'Processing {notification_file_name} file notification'))
                file_path = ""
                for obj in s3.Bucket(notification_bucket_name).objects.filter(Prefix=(notification_prefix + notification_file_name)):
                    file_path = obj.get()['Body'].read().decode('utf8')
            
                logger.info(log_former.get_message("Reading avro in S3:"))
                logger.info(log_former.get_message(f"Full S3 object path: {file_path}"))
                
                avro_file_name = notification_file_name
                DF = glueContext.create_dynamic_frame.from_options(
                    connection_type="s3",
                    connection_options={"paths": [file_path]},
                    format="avro",
                    additional_options = {"inferSchema":"true"}
                )
                current_df_row_no = DF.count()
                DF.show(1)
                
                logger.info(log_former.get_message(f'Total record count (without current): {total_row_no}'))
                logger.info(log_former.get_message(f'Curent record count: {current_df_row_no}'))
                
                ready_for_hudi_processing = False
                if (total_row_no + current_df_row_no) > batch_max_limit and total_row_no != 0:
                    ready_for_hudi_processing = not lock.is_hudi_locked(s3, bucket_name, prefix, glue_job_run_id, logger)
                
                if not ready_for_hudi_processing:
                    reference_files_processed.append(notification_file_name)
                    total_row_no += current_df_row_no
                    logger.info(log_former.get_message("Selecting DynamicFrame for all records"))
                    allDF = DF.select_fields(paths=list_of_fields)
                    allDF.printSchema()
                    allDF.show(1)
                    logger.info(log_former.get_message("DynamicFrame selected."))
                    
                    logger.info(log_former.get_message("Converting DynamicFrame to Pandas DataFrames"))
                    AllPDF = allDF.toDF().toPandas()
                    logger.info(log_former.get_message("Pandas DataFrame created."))
                    
                    logger.info(log_former.get_message("Creating list of tuples"))
                    list_of_all_tuples = []
                    
                    list_of_all_tuples = schemaparser.getAllTuples(AllPDF, schema_obj, file_path, logger, log_former)  
                    
                    logger.info(log_former.get_message("Creating DataFrames with required schema"))
                    allProcessedDF = spark.createDataFrame(list_of_all_tuples, schema)
                    allProcessedDF.show()
                    
                    logger.info(log_former.get_message("DataFrames created."))
                    
                    if mainDF.count() == 0:
                        logger.info(log_former.get_message("Copying the records"))
                        mainDF = allProcessedDF
                        logger.info(log_former.get_message(f"The records were copied to the main DataFrame"))
                    else:
                        logger.info(log_former.get_message("Adding the records"))
                        mainDF = mainDF.union(allProcessedDF)
                        logger.info(log_former.get_message(f"The records were added to the main DataFrame")) 
                else:
                    logger.info(log_former.get_message(f"batch max limit reached ({total_row_no + current_df_row_no} records) and ready for Hudi operations"))
                    total_row_no = 0
                    break
    
        logger.info(log_former.get_message(f"Preparing DynamicFrame from main DataFrame"))
        mainDyF = DynamicFrame.fromDF(mainDF, glueContext, "mainDyF")
        logger.info(log_former.get_message(f"The main DynamicFrame has the following amount of records: {mainDyF.count()}"))
        
        logger.info(log_former.get_message("Selecting DynamicFrame for insert/update/delete"))

        insertDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_insert).select_fields(paths=list_of_fields_flat)
        updateDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_update).select_fields(paths=list_of_fields_flat)
        deleteDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_delete).select_fields(paths=list_of_fields_flat)
        
        logger.info(log_former.get_message("DynamicFrame selected."))
        
        logger.info(log_former.get_message("Cleaning DataFrames"))
        mainDF = spark.createDataFrame(data = emp_RDD, schema = schema)
        mainDyF = DynamicFrame.fromDF(mainDF, glueContext, "mainDyF")
        logger.info(log_former.get_message("DataFrames cleaned up"))
        
        insertPDF = insertDyF.toDF().toPandas()
        updatePDF = updateDyF.toDF().toPandas()
        deletePDF = deleteDyF.toDF().toPandas()
                    
        logger.info(log_former.get_message("Creating list of insert tuples"))
        
        list_of_insert_tuples = []
        list_of_insert_tuples = schemaparser.getUpsertTuplesFlat(insertPDF, schema_obj, hudi_record_key, logger, log_former)
        
        logger.info(log_former.get_message("Creating list of update tuples"))
        list_of_update_tuples = []
        list_of_update_tuples = schemaparser.getUpsertTuplesFlat(updatePDF, schema_obj, hudi_record_key, logger, log_former)
        
        
        logger.info(log_former.get_message("Creating list of delete tuples"))
        list_of_delete_tuples = []
        list_of_delete_tuples = schemaparser.getDeleteTuplesFlat(deletePDF, schema_obj, logger, log_former) 
        
        insrtDF = spark.createDataFrame(list_of_insert_tuples, schema)
        updtDF = spark.createDataFrame(list_of_update_tuples, schema)
        dltDF = spark.createDataFrame(list_of_delete_tuples, schema)
        
        insrtDyF = DynamicFrame.fromDF(insrtDF[list_of_fields_flat[:]], glueContext, "insrtDyF")
        logger.info(log_former.get_message("Dynamic frame for insert created."))
        updtDyF = DynamicFrame.fromDF(updtDF[list_of_fields_flat[:]], glueContext, "updtDyF")
        logger.info(log_former.get_message("Dynamic frame for update created."))
        dltDyF = DynamicFrame.fromDF(dltDF[list_of_fields_flat[:]], glueContext, "dltDyF")
        logger.info(log_former.get_message("Dynamic frame for delete created."))
        
        logger.info(log_former.get_message("Hudi is ready for data operations."))
        
        while lock.aquire_lock(s3, bucket_name, prefix, glue_job_run_id, logger, log_former) != 'Success':
            pass
        
        if insrtDyF.count() > 0:
            logger.info(log_former.get_message("Starting insert into hudi table"))
            
            commonConfig = {'connectionName': f'{hudi_connection_name}', 'className' : 'org.apache.hudi', 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.index.type':'GLOBAL_BLOOM', 'hoodie.datasource.write.precombine.field': f'{hudi_precombine_field}', 'hoodie.payload.ordering.field': f'{hudi_precombine_field}', 'hoodie.datasource.write.operation': 'upsert', 'hoodie.datasource.write.payload.class': 'org.apache.hudi.common.model.DefaultHoodieRecordPayload', 'hoodie.datasource.write.recordkey.field': f'{hudi_record_key}', 'hoodie.table.name': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'hoodie.datasource.hive_sync.database': f'{hudi_db_name}', 'hoodie.datasource.hive_sync.table': f'{hudi_table_name}', 'path': f's3://{bucket_name}/hudi-cdc-tables/{hudi_table_name}', 'hoodie.datasource.write.partitionpath.field': f'{hudi_partition_field}', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}
            combinedConf = {**commonConfig}
            
            ApacheHudiConnector = (
                glueContext.write_dynamic_frame.from_options(
                    frame=insrtDyF,
                    connection_type="marketplace.spark",
                    connection_options=combinedConf,
                    transformation_ctx="ApacheHudiConnector",
                )
            )
    
            metaDataDF = insrtDF[[hudi_precombine_field, hudi_record_key, 'eventType', list_of_fields_flat[-1]]]
            metastore.put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_precombine_field, hudi_table_name, list_of_fields_flat, keyword_delete, logger, log_former)
            
            cst_mtrcPDF = ((insertPDF[["avroFilePath", "created_at"]]).rename(columns={"created_at": "record_count"})).groupby("avroFilePath", as_index=False).count()
            cwmetrics.push_metrics(glue_job_run_id, glue_job_name, 'INSERT', cst_mtrcPDF, 'None', glue_metric_name, glue_metric_namespace, hudi_table_name, cw_client, logger, log_former)
            
        if updtDyF.count() > 0:
            logger.info(log_former.get_message("Starting update for hudi table"))
            
            commonConfig = {'connectionName': f'{hudi_connection_name}', 'className' : 'org.apache.hudi', 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.index.type':'GLOBAL_BLOOM', 'hoodie.datasource.write.precombine.field': f'{hudi_precombine_field}', 'hoodie.datasource.write.operation': 'upsert', 'hoodie.datasource.write.payload.class': 'org.apache.hudi.common.model.DefaultHoodieRecordPayload', 'hoodie.datasource.write.recordkey.field': f'{hudi_record_key}', 'hoodie.table.name': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'hoodie.datasource.hive_sync.database': f'{hudi_db_name}', 'hoodie.datasource.hive_sync.table': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'path': f's3://{bucket_name}/hudi-cdc-tables/{hudi_table_name}', 'hoodie.datasource.write.partitionpath.field': f'{hudi_partition_field}', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}
            combinedConf = {**commonConfig}
            
            ApacheHudiConnector = (
                glueContext.write_dynamic_frame.from_options(
                    frame=updtDyF,
                    connection_type="marketplace.spark",
                    connection_options=combinedConf,
                    transformation_ctx="ApacheHudiConnector",
                )
            ) 
            
            metaDataDF = updtDF[[hudi_precombine_field, hudi_record_key, 'eventType', list_of_fields_flat[-1]]]
            metastore.put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_precombine_field, hudi_table_name, list_of_fields_flat, keyword_delete, logger, log_former)            
            
            cst_mtrcPDF = ((updatePDF[["avroFilePath", "created_at"]]).rename(columns={"created_at": "record_count"})).groupby("avroFilePath", as_index=False).count()
            cwmetrics.push_metrics(glue_job_run_id, glue_job_name, 'UPDATE', cst_mtrcPDF, 'None', glue_metric_name, glue_metric_namespace, hudi_table_name, cw_client, logger, log_former)

        
        if dltDyF.count() > 0:
            logger.info(log_former.get_message("Starting delete in hudi table"))
            
            commonConfig = {'connectionName': f'{hudi_connection_name}', 'className' : 'org.apache.hudi', 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.index.type':'GLOBAL_BLOOM', 'hoodie.datasource.write.precombine.field': f'{hudi_precombine_field}', 'hoodie.datasource.write.operation': 'upsert', 'hoodie.datasource.write.payload.class': 'org.apache.hudi.common.model.DefaultHoodieRecordPayload', 'hoodie.datasource.write.recordkey.field': f'{hudi_record_key}', 'hoodie.table.name': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'hoodie.datasource.hive_sync.database': f'{hudi_db_name}', 'hoodie.datasource.hive_sync.table': f'{hudi_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'path': f's3://{bucket_name}/hudi-cdc-tables/{hudi_table_name}', 'hoodie.datasource.write.partitionpath.field': f'{hudi_partition_field}', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}
            combinedConf = {**commonConfig}
            
            ApacheHudiConnector = (
                glueContext.write_dynamic_frame.from_options(
                    frame=dltDyF,
                    connection_type="marketplace.spark",
                    connection_options=combinedConf,
                    transformation_ctx="ApacheHudiConnector",
                )
            )  
            
            metaDataDF = dltDF[[hudi_precombine_field, hudi_record_key, 'eventType', list_of_fields_flat[-1]]]
            metastore.put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_precombine_field, hudi_table_name, list_of_fields_flat, keyword_delete, logger, log_former)
            
            cst_mtrcPDF = ((deletePDF[["avroFilePath", "created_at"]]).rename(columns={"created_at": "record_count"})).groupby("avroFilePath", as_index=False).count()
            cwmetrics.push_metrics(glue_job_run_id, glue_job_name, 'DELETE', cst_mtrcPDF, 'None', glue_metric_name, glue_metric_namespace, hudi_table_name, cw_client, logger, log_former)
                
        lock.release_lock(s3, bucket_name, prefix, logger, log_former)
        
        logger.info(log_former.get_message("The notification file(s) processed."))
        lock.remove_processed_notification(s3, notification_bucket_name, notification_prefix, reference_files_processed, logger, log_former)
        reference_files_processed = []
    lock.release_notification_lock(s3, notification_bucket_name, (notification_prefix + notification_lock_file_name), logger, log_former)
except Exception as e:
    logger.error(log_former.get_message(str(e)))
    lock.release_lock_if_exists(s3, bucket_name, prefix, glue_job_run_id, logger, log_former)
    raise Exception(str(e))

logger.info(log_former.get_message("Job completed. Exiting the job"))
job.init(args['JOB_NAME'], args)
job.commit()