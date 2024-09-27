from awsglue.utils import getResolvedOptions
from pyspark.sql.session import SparkSession
from awsglue.context import GlueContext
from ffdputils import hudiparammaper, lock, FFDPLogger
import pyspark.sql.functions as F
from datetime import datetime
from awsglue.job import Job
import boto3
import uuid
import sys


args = getResolvedOptions(sys.argv, ['JOB_NAME', 'conformed_bucket', 'curated_bucket', 'hudi_db_name', 'hudi_table_name', 'hudi_target_table_name', 'hive_target_table_name', 'hudi_target_db_name', 'hudi_record_key_name'], )

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
fieldList = ["request_appliedProducts"]

hudi_precombine_field = "dateTimeOccurred"
hudi_partition_field = "created_at"

prefix = f'hudi-cdc-tables/{hudi_table_name}/processing.lock'
trigger_prefix = f'{hudi_table_name}-curated/eu-central-1/{hudi_table_name}-to-redshift-{(datetime.now()).strftime("%Y%m%d%H%M%S")}.trig'

spark = SparkSession.builder.config('spark.serializer','org.apache.spark.serializer.KryoSerializer').config('spark.sql.hive.convertMetastoreParquet','false').getOrCreate()

sc = spark.sparkContext
glueContext = GlueContext(sc)
job = Job(glueContext)
s3 = boto3.resource('s3')
logger = glueContext.get_logger()

traceId = uuid.uuid4()
log_former = FFDPLogger.FFDPLogger(traceId, glue_job_name, glue_job_run_id)

while lock.aquire_lock(s3, source_bucket_name, prefix, glue_job_run_id, logger, log_former) != 'Success':
    pass

logger.info(log_former.get_message(f'Querying {hudi_table_name} data in Hudi'))

dataSourceQueryDF = spark.read.format('org.apache.hudi').load('s3://' + source_bucket_name + f'/hudi-cdc-tables/{hudi_table_name}' + '/*/*').select("dateTimeOccurred","request_location_countryId", "request_location_regionId", "request_field_latitude", "request_field_longitude", "request_cropRegionId", "request_yield", "request_yieldUnitId", "request_nExport", "request_climate_nDeposition", "request_appliedProducts", "request_configuration_requestType", "request_configuration_callbackUrl", "response_success", "response_message", "response_nInput_value", "response_nInput_unitId", "response_nOutput_value", "response_nOutput_unitId", "response_nSurplus_value", "response_nSurplus_unitId", "response_nue_value", "response_nue_unitId", "response_nDeposition_value", "response_nDeposition_unitId", "response_nDepositionInfo_dryDepositionOxidized", "response_nDepositionInfo_wetDepositionOxidized", "response_nDepositionInfo_dryDepositionReduced", "response_nDepositionInfo_wetDepositionReduced", "response_nDepositionInfo_defaultDeposition", "response_nDepositionInfo_requestDeposition", "response_type","configuration_solution", "eventSource", "eventType", "eventId", "created_at")

dataSourceQueryDF.show(5)
logger.info(log_former.get_message(f'{hudi_table_name} Schema'))
dataSourceQueryDF.printSchema() 

### Flattening part
logger.info(log_former.get_message(f'Flattening fields {fieldList} in dataframe'))
for fieldName in fieldList:
    dataSourceQueryDF = dataSourceQueryDF.withColumn(fieldName,F.to_json(fieldName).alias(fieldName + "_json"))
dataSourceQueryDF.show(5)

try:
    if dataSourceQueryDF.count() > 0:
        logger.info(log_former.get_message("Starting insert into hudi table"))
        
        additional_options = hudiparammaper.get_hudi_config(destination_bucket_name, hudi_target_db_name, hudi_target_table_name, hive_target_table_name, hudi_record_key_name, hudi_precombine_field, hudi_partition_field)
        
        dataSourceQueryDF.write.format("hudi") \
        .options(**additional_options) \
        .mode("append") \
        .save()

    lock.release_lock(s3, source_bucket_name, prefix, logger, log_former)
    lock.put_trigger_file(s3, destination_bucket_name, trigger_prefix, glue_job_run_id, logger, log_former)
    
except Exception as e:
    logger.error(log_former.get_message(str(e)))
    lock.release_lock_if_exists(s3, source_bucket_name, prefix, glue_job_run_id, logger, log_former)
    raise Exception(str(e))

job.init(args['JOB_NAME'], args)
job.commit()
