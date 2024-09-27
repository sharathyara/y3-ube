from ffdputils import hudiparammaper, lock, mapziphandler, FFDPLogger
from awsglue.utils import getResolvedOptions
from pyspark.sql.session import SparkSession
from awsglue.context import GlueContext
import pyspark.sql.functions as F
from datetime import datetime
from awsglue.job import Job
import boto3
import uuid
import sys


try:        
    args = getResolvedOptions(sys.argv, ['JOB_NAME', 'conformed_bucket', 'curated_bucket', 'hudi_db_name', 'hudi_table_name', 'hudi_target_table_name', 'hive_target_table_name', 'hudi_target_db_name', 'hudi_record_key_name', 'map_bucket_name', 'map_extraction_folder_name'], )
    
    glue_job_run_id = args['JOB_RUN_ID']
    glue_job_name = args['JOB_NAME']
    source_bucket_name = args['conformed_bucket'] 
    destination_bucket_name = args['curated_bucket'] 
    hudi_db_name = args['hudi_db_name']
    hudi_target_db_name = args['hudi_target_db_name']
    hudi_table_name = args['hudi_table_name']
    hudi_target_table_name = args['hudi_target_table_name']
    hudi_record_key_name = args['hudi_record_key_name']
    hive_target_table_name = args['hive_target_table_name']
    map_bucket_name = args['map_bucket_name']
    map_extraction_folder_name = args['map_extraction_folder_name']
    
    hudi_precombine_field = "dateTimeOccurred"
    hudi_partition_field = "created_at"
    
    map_source_attribute_name = "sourceFile_name"  
    map_file_attribute_name = "mapFile"
    map_file_location_label = "fileLocation"
    map_file_size_label = "fileSize" 
    
    prefix = f'hudi-cdc-tables/{hudi_table_name}/processing.lock'
    trigger_prefix = f'{hudi_table_name}-curated/eu-central-1/{hudi_table_name}-to-redshift-{(datetime.now()).strftime("%Y%m%d%H%M%S")}.trig'
    
    spark = SparkSession.builder.config('spark.serializer','org.apache.spark.serializer.KryoSerializer').config('spark.sql.hive.convertMetastoreParquet','false').getOrCreate()
    
    sc = spark.sparkContext
    glueContext = GlueContext(sc)
    job = Job(glueContext)
    s3 = boto3.resource('s3')
    s3_client = boto3.client('s3')
    logger = glueContext.get_logger()

    traceId = uuid.uuid4()  
    log_former = FFDPLogger.FFDPLogger(traceId, glue_job_name, glue_job_run_id)
    
    while lock.aquire_lock(s3, source_bucket_name, prefix, glue_job_run_id, logger, log_former) != 'Success':
        pass
    
    logger.info(log_former.get_message(f'Querying {hudi_table_name} data in Hudi'))
    
    dataSourceQueryDF = spark.read.format('org.apache.hudi').load('s3://' + source_bucket_name + f'/hudi-cdc-tables/{hudi_table_name}' + '/*/*').select("dateTimeOccurred", "sourceFile_name", "sourceFile_receivedDate", "mapFile", "seasonId", "filesCountInZip", "clientCode", "eventSource", "eventType", "eventId", "created_at").filter("created_at >= '2022-09-05'")
    
    lock.release_lock(s3, source_bucket_name, prefix, logger, log_former)
    
    dataSourceQueryDF = dataSourceQueryDF.withColumn(map_file_location_label, F.lit("")).withColumn(map_file_size_label, F.lit(0)) 
    
    dataSourceValidatedDF = mapziphandler.validate_map_files(spark, s3_client, map_bucket_name, map_extraction_folder_name, map_source_attribute_name, map_file_attribute_name, map_file_location_label, map_file_size_label, dataSourceQueryDF, logger, log_former)

    if dataSourceValidatedDF.count() > 0:
        logger.info(log_former.get_message("Starting insert into hudi table"))
        
        additional_options = hudiparammaper.get_hudi_config(destination_bucket_name, hudi_target_db_name, hudi_target_table_name, hive_target_table_name, hudi_record_key_name, hudi_precombine_field, hudi_partition_field)
        
        dataSourceValidatedDF.write.format("hudi") \
        .options(**additional_options) \
        .mode("append") \
        .save()

    lock.put_trigger_file(s3, destination_bucket_name, trigger_prefix, glue_job_run_id, logger, log_former)
    
except Exception as e:
    logger.error(log_former.get_message(str(e)))
    lock.release_lock_if_exists(s3, source_bucket_name, prefix, glue_job_run_id, logger, log_former)
    raise Exception(str(e))

job.init(args['JOB_NAME'], args)
job.commit()
