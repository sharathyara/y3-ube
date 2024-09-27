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
fieldList = ["request_cropping_coProducts","request_appliedProducts","request_applied_products_directEnergyUse","request_applied_products_machineryUse","request_applied_products_transport","request_irrigationEvents","request_applied_products_cropProtectionApplications","request_treeBiomass","request_carbonChanges_carbonChanges","response_payload_totalEmissions"]

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




dataSourceQueryDF = spark.read.format('org.apache.hudi').load('s3://' + source_bucket_name + f'/hudi-cdc-tables/{hudi_table_name}' + '/*/*').select("dateTimeOccurred","request_location_countryId", "request_location_regionId", "request_field_fieldSize","request_field_fieldSizeUnitId","request_field_soil_soilTypeId","request_field_soil_organicMatter","request_field_soil_goodDrainage","request_field_soil_ph","request_field_longitude","request_field_latitude","request_cropping_cropRegionId","request_cropping_yield","request_cropping_yieldUnitId","request_cropping_farmGateReadyAmount","request_cropping_farmGateReadyAmountUnitId","request_cropping_harvestingYear","request_cropping_coProducts","request_climate_name","request_climate_averageTemperatureValue","request_climate_averageTemperatureValueUnitId","request_residues_amount","request_residues_amountUnitId","request_residues_cropResidueManagementId","request_appliedProducts","request_wasteWaterOrganicMatter_wasteWaterAmount","request_wasteWaterOrganicMatter_wasteWaterAmountUnitId","request_wasteWaterOrganicMatter_oxygenDemand","request_wasteWaterOrganicMatter_oxygenDemandUnitId","request_wasteWaterOrganicMatter_oxygenDemandTypeName","request_wasteWaterOrganicMatter_waterTreatmentTypeName","request_applied_products_directEnergyUse","request_applied_products_machineryUse","request_applied_products_transport","request_irrigationEvents","request_applied_products_cropProtectionApplications","request_treeBiomass","request_carbonChanges_carbonChanges","response_success","response_message","response_payload_summary_emissionsCO2eTotal","response_payload_summary_emissionsCO2eTotalUnitId","response_payload_summary_emissionsCO2ePerArea","response_payload_summary_emissionsCO2ePerAreaUnitId","response_payload_summary_emissionsCO2ePerProduct","response_payload_summary_emissionsCO2ePerProductUnitId","response_payload_summary_soilOrganicCarbon","response_payload_totalEmissions","configuration_solution","eventSource","eventType","eventId","created_at")

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
