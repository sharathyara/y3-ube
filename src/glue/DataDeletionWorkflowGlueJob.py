from ffdputils import deletionworkflow, FFDPLogger
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from datetime import datetime
from awsglue.job import Job
import boto3
import uuid
import sys


## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME','raw_bucket','data_schema_key', 'data_schema_bucket','hudi_table_name','entity_field_id','output_folder','entity_table_name', 'gs_index_name', 'target_folder_path', 'query_days'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
logger = glueContext.get_logger()

#Global params:
rawEventEntityTableName=args['entity_table_name']
bucketName  = args['raw_bucket']
schemaKey = args['data_schema_key']
schemaBucket = args['data_schema_bucket']
hudiTableName = args["hudi_table_name"]
entityFieldIdName = args["entity_field_id"] 
outputRootFolder = args['output_folder']
indexName = args['gs_index_name']
target_raw_avro_folder = args['target_folder_path']
jobRunId = args['JOB_RUN_ID']
jobName = args["JOB_NAME"]
queryDays = int(args['query_days'])

traceId = uuid.uuid4()  
log_former = FFDPLogger.FFDPLogger(traceId, jobName, jobRunId)

timestamp_window = None
if queryDays > 0:
    ## calculate window before - in days
    now = int(datetime.now().timestamp())
    before = 86400 * queryDays
    timestamp_window = (now - before) * 1000000

jobOutputRootFolder = outputRootFolder + "/" + jobRunId

# DynamoDB table
dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
entityTable = dynamodb.Table(rawEventEntityTableName)

# S3 clients and resources
s3 = boto3.resource('s3')
s3_client = boto3.client('s3')

#################################### MAIN ############################################
bucket = s3.Bucket(bucketName)

logger.info(log_former.get_message("********* loading schema **********"))
schema_obj = deletionworkflow.getSchema(s3, schemaBucket, schemaKey)

logger.info(log_former.get_message("********* getting list of entities from metastore **********"))
## list all delete entities for hudiTableName 
itemListDict = deletionworkflow.getEntityDictForDeletion(entityTable, indexName, hudiTableName, timestamp_window, logger, log_former)

itemList = []
for key in itemListDict:
    itemList.append(key)

# get entity-file dict
fileListDict = deletionworkflow.getEntityFileDictForDeletion(entityTable, itemList, logger, log_former)

totalCount = len(list(fileListDict))
count = 1
logger.info(log_former.get_message("********* performing deletion **********"))
for key in fileListDict:
    logger.info(log_former.get_message(f"********* processing record '{key}' as '{count}' out of '{totalCount}' **********"))
    count +=1
    entityId = key
    fileList = fileListDict[key]
    for fileItem in fileList:
        logger.info(log_former.get_message('Start processing file from RAW bucket: ' + fileItem))
        deletionworkflow.softDeleteRecord(glueContext, fileItem, schema_obj, entityId, entityFieldIdName, bucketName, jobOutputRootFolder, logger, log_former)
       
    ####### MOVE FILES PART  #######        
    logger.info(log_former.get_message(f"********* moving files to raw bucket for entityId '{entityId}' **********"))
    
    jobOutputRootFolderEntity = jobOutputRootFolder + "/" + entityId
    
    deletionworkflow.moveTmpFilesToTarget(s3, s3_client, entityTable, bucketName, jobOutputRootFolder, target_raw_avro_folder, jobName, jobRunId, logger, log_former)

    # finally finished - update entity items status as 'deleted'   
    logger.info(log_former.get_message(f"********* updating metastore for entityId '{entityId}' **********"))
    sortKey = itemListDict[entityId]
    ## TODO uncomment
    deletionworkflow.updateProcessedRecords(entityTable, entityId, sortKey, logger, log_former)
    logger.info(log_former.get_message("********* updating metastore finished **********"))

logger.info(log_former.get_message("********* final check and clean up **********"))
jobFolder = bucket.objects.filter(Prefix=jobOutputRootFolder)
logger.info(log_former.get_message(f"Count of remaining objects in bucket: '{bucketName}/{jobOutputRootFolder}' is: '{len(list(jobFolder))}'"))

if len(list(jobFolder)) == 0:
    logger.info(log_former.get_message(f"Deleting root folder in bucket: '{bucketName}/{jobOutputRootFolder}'"))
    bucket.objects.filter(Prefix=jobOutputRootFolder).delete()
else:
    logger.error(log_former.get_message(f"Remaining objects in bucket: '{bucketName}/{jobOutputRootFolder}' is: '{len(list(jobFolder))}'"))
    raise Exception(f"Remaining objects in bucket: '{bucketName}/{jobOutputRootFolder}' is: '{len(list(jobFolder))}'")

job.init(args['JOB_NAME'], args)
job.commit()