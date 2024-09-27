from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.session import SparkSession
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from ffdputils import lock, FFDPLogger
from datetime import datetime
from awsglue.job import Job
import boto3
import uuid
import sys

      
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'conformed_bucket', 'curated_bucket', 'hudi_connection_name', 'hudi_db_name', 'hudi_table_name', 'hudi_target_table_name', 'hive_target_table_name', 'hudi_target_db_name', 'hudi_record_key_name'], )

glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
source_bucket_name = args['conformed_bucket'] 
destination_bucket_name = args['curated_bucket'] 
hudi_connection_name = args['hudi_connection_name']
hudi_db_name = args['hudi_db_name']
hudi_target_db_name = args['hudi_target_db_name']
hudi_table_name = args['hudi_table_name']
hudi_target_table_name = args['hudi_target_table_name']
hudi_record_key_name = args['hudi_record_key_name']
hive_target_table_name = args['hive_target_table_name']


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

dataSourceQueryDF = spark.read.format('org.apache.hudi').load('s3://' + source_bucket_name + f'/hudi-cdc-tables/{hudi_table_name}' + '/*/*').select("dateTimeOccurred", "sourceFile_name", "sourceFile_receivedDate", "sourceFieldId", "fieldName", "sourceFarmId", "countryId", "regionId", "eventSource", "eventType", "eventId", "created_at").filter("created_at >= '2022-09-05'")

dataSourceQueryDF.show(5)
logger.info(log_former.get_message(f'{hudi_table_name} Schema'))
dataSourceQueryDF.printSchema() 
  
dataSourceFilteredDyF = DynamicFrame.fromDF(dataSourceQueryDF, glueContext, "dataSourceFilteredDyF")

try:
    if dataSourceFilteredDyF.count() > 0:
        logger.info(log_former.get_message("Starting insert into hudi table"))
        
        commonConfig = {'connectionName': f'{hudi_connection_name}', 'className' : 'org.apache.hudi', 'hoodie.datasource.hive_sync.use_jdbc':'false', 'hoodie.index.type':'GLOBAL_BLOOM', 'hoodie.datasource.write.precombine.field': 'dateTimeOccurred', 'hoodie.payload.ordering.field': 'dateTimeOccurred', 'hoodie.datasource.write.operation': 'upsert', 'hoodie.datasource.write.payload.class': 'org.apache.hudi.common.model.DefaultHoodieRecordPayload', 'hoodie.datasource.write.recordkey.field': f'{hudi_record_key_name}', 'hoodie.table.name': f'{hudi_target_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'hoodie.datasource.hive_sync.database': f'{hudi_target_db_name}', 'hoodie.datasource.hive_sync.table': f'{hive_target_table_name}', 'hoodie.datasource.hive_sync.enable': 'true', 'path': f's3://{destination_bucket_name}/hudi-cdc-tables/{hudi_target_table_name}', 'hoodie.datasource.write.partitionpath.field': 'created_at', 'hoodie.datasource.hive_sync.partition_fields': 'created_at', 'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor', 'hoodie.cleaner.policy':'KEEP_LATEST_FILE_VERSIONS', 'hoodie.cleaner.fileversions.retained':1}
        combinedConf = {**commonConfig}
            
        ApacheHudiConnector = (
            glueContext.write_dynamic_frame.from_options(
                frame=dataSourceFilteredDyF,
                connection_type="marketplace.spark",
                connection_options=combinedConf,
                transformation_ctx="ApacheHudiConnector",
            )
        )

    lock.release_lock(s3, source_bucket_name, prefix, logger, log_former)
    lock.put_trigger_file(s3, destination_bucket_name, trigger_prefix, glue_job_run_id, logger, log_former)
    
except Exception as e:
    logger.error(log_former.get_message(str(e)))
    lock.release_lock_if_exists(s3, source_bucket_name, prefix, glue_job_run_id, logger, log_former)
    raise Exception(str(e))

job.init(args['JOB_NAME'], args)
job.commit()