from pyspark.sql.functions import when, lit, col
from awsglue.utils import getResolvedOptions
from pyspark.sql.session import SparkSession
from awsglue.context import GlueContext
from ffdputils import hudiparammaper, lock, FFDPLogger
from datetime import datetime, timedelta
from awsglue.job import Job
import boto3
import uuid
import sys
			
def replace(column, value):
    return when(column != value, column).otherwise(lit("{}"))
  
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'conformed_bucket', 'curated_bucket', 'hudi_db_name', 'hudi_table_name', 'hudi_target_table_name', 'hive_target_table_name', 'hudi_target_db_name', 'hudi_record_key_name', 'hudi_delta_filter'], )

glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
source_bucket_name = args['conformed_bucket'] 
destination_bucket_name = args['curated_bucket'] 
hudi_db_name = args['hudi_db_name']
hudi_target_db_name = args['hudi_target_db_name']
hudi_table_name = args['hudi_table_name']
hudi_target_table_name = args['hudi_target_table_name']
hudi_record_key_name = args['hudi_record_key_name']
hudi_delta_filter_days = int(args['hudi_delta_filter'])
hive_target_table_name = args['hive_target_table_name']

hudi_precombine_field = "dateTimeOccurred"
hudi_partition_field = "created_at"

created_at_filter = '2022-09-01'
if hudi_delta_filter_days > 0:
    current_date = datetime.now()
    created_at_filter = (current_date - timedelta(days=hudi_delta_filter_days)).strftime('%Y-%m-%d')

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

dataSourceQueryDF = spark.read.format('org.apache.hudi').load('s3://' + source_bucket_name + f'/hudi-cdc-tables/{hudi_table_name}' + '/*/*').select("bbox", "email", "ewkt", "point", "fieldId", "phone", "center", "eventId", "regionId", "feature", "fieldSize", "geoHash", "iouScore", "clientCode", "countryId", "boundaryId", "created_at", "eventType", "fieldSizeUOM", "eventSource", "sourceFarmId", "sourceFieldId", "sourceUserId", "geometryHash", "organizationId", "listOfFeatures", "dateTimeOccurred", "generatedId", "inputBasedIntersection", "outputBasedIntersection").withColumn("listOfFeatures", replace(col("listOfFeatures"), "*****")).withColumn("feature", replace(col("feature"), "*****")).withColumnRenamed("generatedId", "id").filter(f"created_at >= '{created_at_filter}'") 

dataSourceQueryDF = dataSourceQueryDF.na.fill({"listOfFeatures": "{}"})
dataSourceQueryDF = dataSourceQueryDF.na.fill({"feature": "{}"})

dataSourceQueryDF.show(5)
logger.info(log_former.get_message(f'{hudi_table_name} Schema'))
dataSourceQueryDF.printSchema() 

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
