from awsglue.utils import getResolvedOptions
from pyspark.sql.session import SparkSession
from awsglue.context import GlueContext
from ffdputils import hudiparammaper, lock, FFDPLogger, TransformationFunction
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType
import pyspark.sql.functions as F
from datetime import datetime
from awsglue.job import Job
import boto3
import uuid
import sys
import json



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
fieldList = ["request_cropping_AdditionalParameters", "request_UserDefinedProducts", "request_UserAppliedProducts" ,"response_payload_yield_Items", "response_payload_precropyield_Items",  "response_payload_postcropyield_Items", "response_payload_demandunitdata_Items", "response_payload_splitdata_Items", "response_payload_Recommendationdata_Items", "response_payload_organicsupply_Items", "response_payload_cropdemand_Items", "response_payload_soilimprovementdemand_Items", "response_payload_fertilizerneed_Items", "response_payload_config_Items", "response_errordata_Errors"]
super_datatype_columns = ["request_field_Boundaries", "request_cropping_AdditionalParameters","request_UserDefinedProducts", "request_UserAppliedProducts", "response_payload_yield_Items","response_payload_precropyield_Items","response_payload_postcropyield_Items","response_payload_demandunitdata_Items","response_payload_splitdata_Items","response_payload_Recommendationdata_Items","response_payload_organicsupply_Items","response_payload_cropdemand_Items","response_payload_soilimprovementdemand_Items","response_payload_fertilizerneed_Items","response_payload_config_Items","response_errordata_Errors"]

hudi_precombine_field = "dateTimeOccurred"
hudi_partition_field = "created_at"

json_udf = udf(lambda string:TransformationFunction.json_function(str(string)), StringType())

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

dataSourceQueryDF = spark.read.format('org.apache.hudi').load('s3://' + source_bucket_name + f'/hudi-cdc-tables/{hudi_table_name}' + '/*/*').select("dateTimeOccurred", "request_location_CountryId", "request_location_RegionId", "request_field_Id", "request_field_Boundaries", "request_field_Size", "request_field_SizeUnitId", "request_field_SoilTypeId", "request_cropping_CropId","request_cropping_Yield", "request_cropping_YieldUnit", "request_cropping_FarmId", "request_cropping_FieldId", "request_cropping_CroppableArea", "request_cropping_CroppableAreaUnit", "request_cropping_AdditionalParameters", "request_cropping_CropResidueManagementId", "request_rotation_PreCropId", "request_rotation_PreCropYield", "request_rotation_PreCropYieldUnit","request_rotation_PreCropResidueManagementId", "request_rotation_PostCropId", "request_rotation_PostCropYield", "request_rotation_PostCropYieldUnit", "request_rotation_PostCropResidueManagementId", "request_insight_Locale", "request_insight_IncludeInsights", "request_analysis_classes_N", "request_analysis_classes_P","request_analysis_classes_K", "request_analysis_classes_S", "request_analysis_classes_Mg", "request_analysis_classes_Ca", "request_analysis_classes_B",  "request_analysis_classes_Mo", "request_analysis_classes_Zn", "request_analysis_classes_Cu", "request_analysis_classes_Fe",  "request_analysis_classes_Mn", "request_analysis_classes_Na", "request_analysis_classes_Se",  "request_analysis_classes_Co", "request_analysis_values_NMin", "request_analysis_values_SMin", "request_analysis_values_Clay","request_analysis_values_Sand", "request_analysis_values_Silt","request_analysis_values_Slit","request_analysis_values_SumOfBases", "request_analysis_values_EC","request_analysis_values_OrgM", "request_analysis_values_OrgC","request_analysis_values_CEC", "request_analysis_values_pH", "request_analysis_values_BpH", "request_analysis_values_BsSat","request_analysis_values_KSat", "request_analysis_values_MgSat","request_analysis_values_CaSat", "request_analysis_values_AlSat","request_analysis_values_NO3",  "request_analysis_values_NH4","request_analysis_values_N", "request_analysis_values_P",  "request_analysis_values_K", "request_analysis_values_S", "request_analysis_values_Mg", "request_analysis_values_Ca","request_analysis_values_Zn", "request_analysis_values_B","request_analysis_values_Mo", "request_analysis_values_Cu", "request_analysis_values_Fe", "request_analysis_values_Mn",   "request_analysis_values_Al", "request_analysis_values_Na", "request_analysis_values_Se", "request_analysis_values_Co", "request_analysis_values_SMP", "request_analysis_values_PRem",  "request_demand_crop_N", "request_demand_crop_P", "request_demand_crop_K", "request_demand_crop_S", "request_demand_crop_Mg", "request_demand_crop_Ca","request_demand_crop_B", "request_demand_crop_Mo","request_demand_crop_Zn","request_demand_crop_Cu", "request_demand_crop_Fe", "request_demand_crop_Mn", "request_demand_crop_Na", "request_demand_crop_Se", "request_demand_crop_Co", "request_demand_soil_N", "request_demand_soil_P", "request_demand_soil_K",  "request_demand_soil_S", "request_demand_soil_Mg","request_demand_soil_Ca", "request_demand_soil_B", "request_demand_soil_Mo", "request_demand_soil_Zn","request_demand_soil_Cu", "request_demand_soil_Fe",  "request_demand_soil_Mn",  "request_demand_soil_Na","request_demand_soil_Se", "request_demand_soil_Co", "request_demand_unit_N", "request_demand_unit_P","request_demand_unit_K",  "request_demand_unit_S", "request_demand_unit_Mg", "request_demand_unit_Ca","request_demand_unit_B", "request_demand_unit_Mo", "request_demand_unit_Zn", "request_demand_unit_Cu", "request_demand_unit_Fe",  "request_demand_unit_Mn",  "request_demand_unit_Na", "request_demand_unit_Se",  "request_demand_unit_Co", "request_demand_unit_NUnitId", "request_demand_unit_PUnitId", "request_demand_unit_KUnitId",  "request_demand_unit_SUnitId", "request_demand_unit_MgUnitId", "request_demand_unit_CaUnitId", "request_demand_unit_BUnitId",  "request_demand_unit_MoUnitId", "request_demand_unit_ZnUnitId", "request_demand_unit_CuUnitId", "request_demand_unit_FeUnitId", "request_demand_unit_MnUnitId", "request_demand_unit_NaUnitId", "request_demand_unit_SeUnitId",  "request_demand_unit_CoUnitId", "request_demand_unit_Amount",   "request_UserDefinedProducts",  "request_UserAppliedProducts",  "request_config_RecommendAfterSplitApplication",  "request_config_CheckCropChlorideSensitivity",  "request_config_UseYaraPreferredProducts", "request_config_Capability",  "request_requestdetails_Id", "request_requestdetails_Date",   "request_requestdetails_RulesetVersion", "response_Success", "response_Begin", "response_End", "response_payload_yield_Items", "response_payload_precropyield_Items",  "response_payload_postcropyield_Items", "response_payload_demandunitdata_Items", "response_payload_splitdata_Items", "response_payload_Recommendationdata_Items", "response_payload_organicsupply_Items", "response_payload_cropdemand_Items", "response_payload_soilimprovementdemand_Items", "response_payload_fertilizerneed_Items", "response_payload_config_Items", "response_requestdetails_Id",  "response_requestdetails_Date", "response_requestdetails_RulesetVersion",  "response_errordata_Errors", "response_errordata_solution",  "eventSource",  "eventType",  "eventId",  "created_at")

dataSourceQueryDF.show(5)
dfs=dataSourceQueryDF.head(5)
counts=dataSourceQueryDF.count()
logger.info(log_former.get_message(f'dataSourceQueryDF: {dfs}'))
logger.info(log_former.get_message(f'dataSourceQueryDF: {counts}'))
logger.info(log_former.get_message(f'{hudi_table_name} Schema'))
dataSourceQueryDF.printSchema() 

## Flattening part
logger.info(log_former.get_message(f'Flattening fields {fieldList} in dataframe'))
for fieldName in fieldList:
    dataSourceQueryDF = dataSourceQueryDF.withColumn(fieldName,F.to_json(fieldName).alias(fieldName + "_json"))
dataSourceQueryDF.show(5)

logger.info(log_former.get_message(f'Checking the fields {super_datatype_columns} in dataframe'))
for column in super_datatype_columns:
    dataSourceQueryDF =  dataSourceQueryDF.withColumn(f"new_{column}", json_udf(dataSourceQueryDF[column]))
    dataSourceQueryDF = dataSourceQueryDF.drop(column).withColumnRenamed(f"new_{column}", column)

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
