import sys
from pyspark.context import SparkContext
from pyspark.sql.session import SparkSession
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from awsglue.utils import getResolvedOptions
from pyspark.sql.types import *
from pyspark.sql.types import Row
from datetime import datetime as dt
import pandas as pd
import boto3
from botocore.exceptions import ClientError
import json
import time
import uuid
from pyspark.sql.types import StructType, StructField, StringType, ShortType, IntegerType, DoubleType, TimestampType, BooleanType, ArrayType, MapType

def push_metrics(glue_job_run_id, glue_job_name='AvroFromS3ToHudiGlueJob', operation='INSERT', value=0, avro_file_name='None', unit='None', metric_name='HudiCRUDMetric', metric_namespace='HudiDataOperations', hudi_table_name='farm'):
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
                    },
                    {
                        'Name': 'Entity',
                        'Value': 'DefaultEntityName'
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
    metric_data[0]['Dimensions'][4]['Value'] = hudi_table_name
    metric_data[0]['Unit'] = unit
    metric_data[0]['Value'] = value
    response = cloudwatch.put_metric_data(
        MetricData = metric_data,
        Namespace = metric_namespace
    )
    print("Hudi operation metrics registered.") #response)

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
            time.sleep(sleep_time)
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
    

def append_with_prefix(field):
    if "prefix" in field.keys():
        field["fieldName"] = field["prefix"] + field["fieldName"]
    return field["fieldName"]


def get_nested_element(field, source_record_row):
    path_elmnts = field["parent"].split(".")
    path_elmnts.append(field["fieldName"])
    path_elmnts.remove("data")
    for lvl in path_elmnts:
        if lvl in list(source_record_row.asDict()):
            source_record_row = source_record_row[lvl]
        else: 
            return None
    return source_record_row


def getAllTuples(SourcePDF, schema_obj, dict_of_none_values, avro_file_path, glue_logger): #bucket_name, prefix, avro_file_path, s3, 
    list_of_all_tuples = []

    for idx in range(SourcePDF.shape[0]):
        tpl = ()
        data_list = list(SourcePDF["data"][idx].asDict())
        print(f"Data list: {data_list}")
        all_columns_list = SourcePDF.columns
        
        for field in schema_obj:
            if field["parent"] is None:
                if field["fieldName"] == "created_at": 
                    tpl += (str((SourcePDF['dateTimeOccurred'][idx])[:10]), ) 
                elif "isGenerated" in field.keys() and field["isGenerated"]:
                    tpl += (str(uuid.uuid4()), )
                elif field["fieldName"] == "avroFilePath":
                    tpl += (avro_file_path, ) 
                else: 
                    if field["fieldName"] in all_columns_list:
                        if pd.isna(SourcePDF[field["fieldName"]][idx]):
                            tpl += (None, )
                        elif field["type"] in "StringType":
                            tpl += (str(SourcePDF[field["fieldName"]][idx]), )
                        elif field["type"] in "IntegerType":
                            tpl += (int(SourcePDF[field["fieldName"]][idx]), )
                        elif field["type"] in "ShortType":
                            tpl += (int(SourcePDF[field["fieldName"]][idx]), )
                        elif field["type"] in "BooleanType":
                            tpl += (bool(SourcePDF[field["fieldName"]][idx]), )
                        elif field["type"] in "DoubleType":
                            tpl += (float(SourcePDF[field["fieldName"]][idx]), )
                        elif field["type"] == "TimestampType":
                            tpl += (dt.strptime(SourcePDF[field["fieldName"]][idx], '%Y-%m-%dT%H:%M:%S.%fZ'), )
                        elif field["type"] == "UUIDType":
                            tpl += (str(SourcePDF[field["fieldName"]][idx]), )
                        else:
                            tpl += (str(SourcePDF[field["fieldName"]][idx]), ) 
                    else:
                        tpl += (None, )  
            elif field["parent"] == 'data' or len(field["parent"].split(".")) > 1:
                test_tpl = get_nested_element(field, SourcePDF["data"][idx])
                if test_tpl is None and "isMergedTo" in field.keys():
                    pass
                elif test_tpl is None:
                    is_none = True
                    for chck_fld in schema_obj:
                        if "isMergedTo" in chck_fld.keys():
                            if chck_fld["isMergedTo"] == (field['parent'] + "." + field['fieldName']):
                                value = get_nested_element(field, SourcePDF["data"][idx])
                                if value is None:
                                    pass
                                else:
                                    is_none = False
                                    if chck_fld["type"] in "StringType":
                                        tpl += (str(value), )
                                    elif chck_fld["type"] in "ShortType":
                                        tpl += (int(value), )
                                    elif chck_fld["type"] in "IntegerType":
                                        tpl += (int(value), )
                                    elif chck_fld["type"] in "DoubleType":
                                        tpl += (float(value), )
                                    elif chck_fld["type"] == "TimestampType":
                                        tpl += (dt.strptime(value, '%Y-%m-%dT%H:%M:%S.%fZ'), ) 
                                    elif chck_fld["type"] in "UUIDType":
                                        tpl += (str(value), ) 
                                    elif chck_fld["type"] == "ArrayType":
                                        array_dict = []
                                        for aitem in value:
                                            print((aitem.asDict()).keys())
                                            item_test = {}
                                            for attr in list((aitem.asDict()).keys()):  
                                                print(attr)
                                                if isinstance(aitem[attr], Row):
                                                    item_test[attr] = str(aitem[attr].asDict()).replace('"','\\"').replace("'",'"')
                                                else:
                                                    item_test[attr] = aitem[attr]
                                            array_dict.append(item_test)
                                        tpl += (array_dict, )                        
                                    else: 
                                        tpl += (str(value), )
                    if is_none:  
                        tpl += (None, )
                else: 
                    if field["type"] in "StringType":
                        tpl += (str(test_tpl), )
                    elif field["type"] in "ShortType":
                        tpl += (int(test_tpl), )
                    elif field["type"] in "IntegerType":
                        tpl += (int(test_tpl), )
                    elif field["type"] in "DoubleType":
                        tpl += (float(test_tpl), )
                    elif field["type"] == "TimestampType":
                        tpl += (dt.strptime(test_tpl, '%Y-%m-%dT%H:%M:%S.%fZ'), ) 
                    elif field["type"] in "UUIDType":
                        tpl += (str(test_tpl), ) 
                    elif field["type"] == "ArrayType":
                        array_dict = []
                        for aitem in test_tpl:
                            item_test = {}
                            for attr in list((aitem.asDict()).keys()):  
                                if isinstance(aitem[attr], Row):
                                    item_test[attr] = str(aitem[attr].asDict()).replace('"','\\"').replace("'",'"')
                                else:
                                    item_test[attr] = aitem[attr]
                            array_dict.append(item_test)
                        tpl += (array_dict, )                        
                    else: 
                        tpl += (str(test_tpl), )
        list_of_all_tuples.append(tpl)
        print(f"processed: {field['fieldName']}")
        print(list_of_all_tuples)
    glue_logger.info("List of tuples created.")
    return list_of_all_tuples
    

def getUpsertTuplesFlat(SourcePDF, schema_obj, glue_logger):
    list_of_tuples = []
  
    for idx in range(SourcePDF.shape[0]):
        tpl = ()
        for field in schema_obj:
            print(f"field to be processed: {field['fieldName']}")
            if "additionalParameters" == field['fieldName']:
                print(SourcePDF[field["fieldName"]][idx])
                print(field)
            if "isMergedTo" not in field.keys():
                if SourcePDF[field["fieldName"]][idx] is None:
                    tpl += (None, )
                elif field["type"] == "ArrayType":
                    array_dict = []
                    for aitem in SourcePDF[field["fieldName"]][idx]:
                        print(f"The Item of array: {aitem}")
                        print((aitem.asDict()).keys())
                        item_test = {}
                        for attr in list((aitem.asDict()).keys()):  
                            print(attr)
                            if isinstance(aitem[attr], Row):
                                item_test[attr] = str(aitem[attr].asDict()).replace('"','\\"').replace("'",'"')
                            else:
                                item_test[attr] = aitem[attr]
                        array_dict.append(item_test)
                    tpl += (array_dict, )
                elif pd.isna(SourcePDF[field["fieldName"]][idx]): 
                    tpl += (None, )
                elif field["type"] == "StringType":
                    tpl += (str(SourcePDF[field["fieldName"]][idx]), )
                elif field["type"] == "ShortType":
                    tpl += (int(SourcePDF[field["fieldName"]][idx]), ) 
                elif field["type"] == "IntegerType":
                    tpl += (int(SourcePDF[field["fieldName"]][idx]), ) 
                elif field["type"] == "DoubleType":
                    tpl += (float(SourcePDF[field["fieldName"]][idx]), )
                elif field["type"] in "BooleanType":
                    tpl += (bool(SourcePDF[field["fieldName"]][idx]), )
                elif field["type"] == "TimestampType":
                    tpl += (SourcePDF[field["fieldName"]][idx].to_pydatetime(), )
                elif field["type"] == "UUIDType":
                    tpl += (str(SourcePDF[field["fieldName"]][idx]), )
                else:    
                    tpl += (str(SourcePDF[field["fieldName"]][idx]), )
        list_of_tuples.append(tpl) 
    
    print(list_of_tuples)
    glue_logger.info("List of tuples created.")
    return list_of_tuples
    
 
def getDeleteTuplesFlat(SourcePDF, schema_obj, glue_logger):
    list_of_tuples = []
  
    for idx in range(SourcePDF.shape[0]):
        tpl = ()
        for field in schema_obj:
            if "isMergedTo" not in field.keys():
                if SourcePDF[field["fieldName"]][idx] is None:
                    tpl += (None, )
                elif field["isPIIData"]: 
                    tpl += (None, )
                elif field["type"] == "ArrayType":
                    array_dict = []
                    for aitem in SourcePDF[field["fieldName"]][idx]:
                        print(f"The Item of array: {aitem}")
                        print((aitem.asDict()).keys())
                        item_test = {}
                        for attr in list((aitem.asDict()).keys()):  
                            print(attr)
                            if isinstance(aitem[attr], Row):
                                item_test[attr] = str(aitem[attr].asDict()).replace('"','\\"').replace("'",'"')
                            else:
                                item_test[attr] = aitem[attr]
                        array_dict.append(item_test)
                    tpl += (array_dict, )
                elif field["type"] == "StringType":
                    tpl += (str(SourcePDF[field["fieldName"]][idx]), )
                elif field["type"] == "ShortType":
                    tpl += (int(SourcePDF[field["fieldName"]][idx]), ) 
                elif field["type"] == "IntegerType":
                    tpl += (int(SourcePDF[field["fieldName"]][idx]), ) 
                elif field["type"] in "BooleanType":
                    tpl += (bool(SourcePDF[field["fieldName"]][idx]), )
                elif field["type"] == "DoubleType":
                    tpl += (float(SourcePDF[field["fieldName"]][idx]), )
                elif field["type"] == "UUIDType":
                    tpl += (str(SourcePDF[field["fieldName"]][idx]), )
                elif field["type"] == "TimestampType":
                    tpl +=  (SourcePDF[field["fieldName"]][idx].to_pydatetime(), )                
                else:    
                    tpl += (str(SourcePDF[field["fieldName"]][idx]), ) 
        list_of_tuples.append(tpl) 
    
    print(list_of_tuples)
    glue_logger.info("List of tuples created.")
    return list_of_tuples
    

def put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_precombine_field, hudi_table_name, list_of_fields_flat, keyword_delete, glue_logger):
    metaDataDF.show(1)
    metaDataPDF = metaDataDF.toPandas()
    metaDataPDF.head(1)

    for idx in range(metaDataPDF.shape[0]):
        eventTypeItem = metaDataPDF['eventType'][idx] 
        entityId = metaDataPDF[hudi_record_key][idx]
        
        putItem={
            'entityId' : entityId,
            'cdcProcessedTs' : int(dt.now().timestamp() * 1000000),
            'cdcProcessedDate' : str(dt.now().date()), #'2023-02-20', #manually to simulate #'entityName' : 'farmId',
            'entityName' : hudi_record_key, #'topicName': 'stage-yara-digitalsolution-fafm-farm',
            'topicName': f'stage-yara-digitalsolution-fafm-{hudi_table_name}',
            'rawFile' : metaDataPDF[list_of_fields_flat[-1]][idx],
            'eventTypeList' : eventTypeItem
        }
    
        if eventTypeItem in keyword_delete:
            putItem['isDeleteRequest'] = 'x'
            putItem['eventOccurenceDateTime'] = str(metaDataPDF[hudi_precombine_field][idx].to_pydatetime()) #str(dt.now())
            putItem['isDeletePerformed'] = False
        glue_logger.info(f"Ingesting the metadata for {hudi_record_key}: {entityId}")
        
        entityTable.put_item(
            Item=putItem
            )
            

def get_schema(schema_obj):
    list_of_fields = []
    list_of_fields_flat = []
    dict_of_none_values = {}
    fields = []
    for field in schema_obj:
        field["fieldName"] = append_with_prefix(field)
        if "isMergedTo" not in field.keys():
            if field["type"] == "ShortType":
                fields.append(StructField(field["fieldName"], ShortType(), field["isNullable"]))
            elif field["type"] == "IntegerType":
                fields.append(StructField(field["fieldName"], IntegerType(), field["isNullable"]))
            elif field["type"] == "DoubleType":
                fields.append(StructField(field["fieldName"], DoubleType(), field["isNullable"]))
            elif field["type"] == "TimestampType":
                fields.append(StructField(field["fieldName"], TimestampType(), field["isNullable"]))
            elif field["type"] == "UUIDType":
                fields.append(StructField(field["fieldName"], StringType(), field["isNullable"])) 
            elif field["type"] == "ArrayType":
                array_items = field["contentOfArray"].split('|')
                recs = []
                for item in array_items: 
                    field_item = item.split(',')   
                    if field_item[1] == "StringType":
                        recs.append(StructField(field_item[0], StringType(), field["isNullable"]))
                    elif field_item[1] == "ShortType":
                        recs.append(StructField(field_item[0], ShortType(), field["isNullable"]))
                    elif field_item[1] == "IntegerType":
                        recs.append(StructField(field_item[0], IntegerType(), field["isNullable"]))
                    elif field_item[1] == "DoubleType":
                        recs.append(StructField(field_item[0], DoubleType(), field["isNullable"]))
                    elif field_item[1] == "UUIDType":
                        recs.append(StructField(field_item[0], StringType(), field["isNullable"]))
                fields.append(StructField(field["fieldName"], ArrayType(StructType(recs)), field["isNullable"]))         
            else:
                fields.append(StructField(field["fieldName"], StringType(), field["isNullable"]))
                
            list_of_fields_flat.append(field["fieldName"]) 
            dict_of_none_values[field["fieldName"]] = None
                
            if field["parent"] is None:
                list_of_fields.append(f'{field["fieldName"]}')
            else:
                list_of_fields.append(f'{field["parent"]}.{field["fieldName"]}')
    
    schema = StructType(fields)
    return schema, list_of_fields, list_of_fields_flat, dict_of_none_values
            
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'conformed_bucket', 'hudi_connection_name', 'hudi_db_name', 'hudi_table_name', 'glue_metric_namespace', 'glue_metric_name', 'batch_max_limit', 'message_event_types', 'data_schema_location', 'hudi_record_key', 'hudi_partition_field', 'hudi_precombine_field', 'metastore_table_name', 's3_object'])
glue_job_run_id = args['JOB_RUN_ID']
glue_job_name = args['JOB_NAME']
bucket_name = args['conformed_bucket'] #'yara-das-ffdp-conformed-eucentral1-479055760150-stage-stitch'
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

for obj in s3.Bucket(schema_bucket_name).objects.filter(Prefix=schema_prefix):
    body = obj.get()['Body'].read().decode('utf8')
    
schema_obj = json.loads(body)

schema, list_of_fields, list_of_fields_flat, dict_of_none_values = get_schema(schema_obj)

spark = SparkSession.builder.config('spark.serializer','org.apache.spark.serializer.KryoSerializer').config('spark.sql.hive.convertMetastoreParquet','false').getOrCreate()

sc = spark.sparkContext
glueContext = GlueContext(sc)
job = Job(glueContext)

logger = glueContext.get_logger()
try:
    emp_RDD = sc.emptyRDD()
    while len(list(s3.Bucket(notification_bucket_name).objects.filter(Prefix=notification_prefix))) > 1:
        total_row_no = 0
        current_df_row_no = 0
        reference_files_processed = []
        files_to_process_ordered = [] 
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
            if len(notification_file_name) > 0: 
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
                    allDF.printSchema()
                    allDF.show(1)
                    logger.info("DynamicFrame selected.")
                    
                    logger.info("Converting DynamicFrame to Pandas DataFrames")
                    AllPDF = allDF.toDF().toPandas()
                    logger.info("Pandas DataFrame created.")
                    
                    logger.info("Creating list of tuples")
                    list_of_all_tuples = []
                    
                    print(AllPDF.head(2))
                    
                    list_of_all_tuples = getAllTuples(AllPDF, schema_obj, dict_of_none_values, file_path, logger)  #notification_bucket_name, f"{hudi_table_name}/logs/{hudi_record_key}", file_path, s3, 
                    
                    logger.info("Creating DataFrames with required schema")
                    allProcessedDF = spark.createDataFrame(list_of_all_tuples, schema)
                    allProcessedDF.show()
                    
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
                    total_row_no = 0
                    break
    
        logger.info(f"Preparing DynamicFrame from main DataFrame")
        mainDyF = DynamicFrame.fromDF(mainDF, glueContext, "mainDyF")
        logger.info(f"The main DynamicFrame has the following amount of records: {mainDyF.count()}")
        
        logger.info("Selecting DynamicFrame for insert/update/delete")

        insertDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_insert).select_fields(paths=list_of_fields_flat)
        updateDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_update).select_fields(paths=list_of_fields_flat)
        deleteDyF = mainDyF.filter(f=lambda x: x["eventType"] in keyword_delete).select_fields(paths=list_of_fields_flat)
        
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
        list_of_delete_tuples = getDeleteTuplesFlat(deletePDF, schema_obj, logger) 
        
        insrtDF = spark.createDataFrame(list_of_insert_tuples, schema)
        updtDF = spark.createDataFrame(list_of_update_tuples, schema)
        dltDF = spark.createDataFrame(list_of_delete_tuples, schema)
        
        insrtDyF = DynamicFrame.fromDF(insrtDF[list_of_fields_flat[:-1]], glueContext, "insrtDyF")
        logger.info("Dynamic frame for insert created.")
        updtDyF = DynamicFrame.fromDF(updtDF[list_of_fields_flat[:-1]], glueContext, "updtDyF")
        logger.info("Dynamic frame for update created.")
        dltDyF = DynamicFrame.fromDF(dltDF[list_of_fields_flat[:-1]], glueContext, "dltDyF")
        logger.info("Dynamic frame for delete created.")
        
        logger.info("Hudi is ready for data operations.")
        
        while aquire_lock(s3, bucket_name, prefix, glue_job_run_id, logger) != 'Success':
            pass
        
        if insrtDyF.count() > 0:
            logger.info("Starting insert into hudi table")
            
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
            put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_precombine_field, hudi_table_name, list_of_fields_flat, keyword_delete, logger)
            
            push_metrics(glue_job_run_id, glue_job_name, 'INSERT', insertDyF.count(), avro_file_name, 'None', glue_metric_name, glue_metric_namespace, hudi_table_name)
            
        if updtDyF.count() > 0:
            logger.info("Starting update for hudi table")
            
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
            put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_precombine_field, hudi_table_name, list_of_fields_flat, keyword_delete, logger)            
            
            push_metrics(glue_job_run_id, glue_job_name, 'UPDATE', updateDyF.count(), avro_file_name, 'None', glue_metric_name, glue_metric_namespace, hudi_table_name)
        
        if dltDyF.count() > 0:
            logger.info("Starting delete in hudi table")
            
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
            put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_precombine_field, hudi_table_name, list_of_fields_flat, keyword_delete, logger)
            
            push_metrics(glue_job_run_id, glue_job_name, 'DELETE', deleteDyF.count(), avro_file_name, 'None', glue_metric_name, glue_metric_namespace, hudi_table_name)
                
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