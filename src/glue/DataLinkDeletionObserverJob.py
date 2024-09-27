import uuid
from datetime import datetime
import boto3
import sys

from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from ffdputils import FFDPLogger, Observer

# Get job parameters
args = getResolvedOptions(sys.argv,
                          ['JOB_NAME', 'maps_bucket_name', 'maps_extracted_folder', 'deletion_dynamodb_table',
                           'gs_index_name', 'outbound_s3_bucket_name', 'redshift_connection_user',
                           'redshift_db_name', 'redshift_cluster_name', 'verification_entity_list', 'failure_buffer_days'])

# Initialize job parameters
jobRunId = args['JOB_RUN_ID']
jobName = args['JOB_NAME']
mapsBucket = args['maps_bucket_name']
mapsExtractedFolder = args['maps_extracted_folder']
deletionDynamodbTable = args['deletion_dynamodb_table']
gsIndexName = args['gs_index_name']
outboundS3Bucket = args['outbound_s3_bucket_name']
redshiftClusterDetails = {
    'redshiftClusterName': args['redshift_cluster_name'],
    'redshiftDBName': args['redshift_db_name'],
    'redshiftUser': args['redshift_connection_user']
}
enitiesToVerify = args['verification_entity_list'].split(',')
retryBufferDays = int(args['failure_buffer_days'])
traceId = str(uuid.uuid4())
log_former = FFDPLogger.FFDPLogger(traceId, jobName, jobRunId)

# Initialize constants
drAttributesMap = Observer.DELETION_REQUEST_ATTRIBUTES_MAP
drStatusMap = Observer.DELETION_REQUEST_STATUS_MAP

# Initialize Spark session and Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
logger = glueContext.get_logger()

# Initialize AWS resources
s3 = boto3.resource('s3')
dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
dynamodb_table = dynamodb.Table(deletionDynamodbTable)
redshiftDataClient = boto3.client('redshift-data', region_name='eu-central-1')

# Fetch delete requests from DynamoDB
logger.info(log_former.get_message("Fetching records from DynamoDB table..."))
deleteRequests = Observer.get_deletion_requests_from_dynamodb(
    dynamodb_table=dynamodb_table, index_name=gsIndexName, key_condition=drAttributesMap['status'],
    key_value=drStatusMap['inprogress'], logger=logger, log_former=log_former
)
logger.info(log_former.get_message(
    f"Fetched {len(deleteRequests)} delete requests from DynamoDB table."
))
logger.info(log_former.get_message(
    f"Sample data of deleteRequests {deleteRequests[:5]}."
))

# TODO: Good to have: need to profile deletionrequest (what is status and how long there are in that status, to measure if some deletionrequest are orphaned)

failureverification_items = []
successverification_items = []
skipverification_items = []

# Verify delete requests in maps bucket and Redshift curated_Schema and ffdp2_0 schema
logger.info(log_former.get_message("Verifying delete requests..."))
for deleteRequest in deleteRequests:
    logger.info(log_former.get_message(f"Verifying delete request: {deleteRequest[drAttributesMap['requestid']]}"))
    # Call verify_entities function
    verification_status_flag = Observer.verify_entities(s3, enitiesToVerify,
                                                        deleteRequest, mapsBucket,
                                                        redshiftDataClient, redshiftClusterDetails,
                                                        logger, log_former)
    logger.info(log_former.get_message(
        f"Verification status is '{verification_status_flag}' for delete request: {deleteRequest[drAttributesMap['requestid']]} "))
    current_time = datetime.utcnow()

    if verification_status_flag:
        # Update deleteRequest status='completed' and the statusupdatedat timestamp with current time
        deleteRequest[drAttributesMap['status']] = drStatusMap['completed']
        deleteRequest[drAttributesMap['statusupdatedat']] = current_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ')
        # Append the deleteRequest to success verification list
        successverification_items.append(deleteRequest)
    else:
        # Calculate the threshold for failure
        # todo: what if stastatusupdatedat key doesn't exist
        threshold = (current_time - datetime.strptime(deleteRequest[drAttributesMap['statusupdatedat']],
                                                      '%Y-%m-%dT%H:%M:%S.%fZ')).days
        logger.info(log_former.get_message(
            f"DeleteRequestId : {deleteRequest[drAttributesMap['requestid']]} has Threshold value for failure: {threshold}"))
        if threshold > retryBufferDays:
            # Update deleteRequest status='failed' and statusReason='...' and the statusupdatedat timestamp
            deleteRequest[drAttributesMap['status']] = drStatusMap['failed']
            # TODO: finilize the failure message
            deleteRequest[drAttributesMap['statusreason']] = "Failed to delete in FFDP ecosystem"
            deleteRequest[drAttributesMap['statusupdatedat']] = current_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ')
            # Append the deleteRequest to failure verification list
            failureverification_items.append(deleteRequest)
        else:
            skipverification_items.append(deleteRequest)

# Log verification results
logger.info(log_former.get_message("==============Completed verification for deleteRequests.=============="))
logger.info(log_former.get_message(f"Success verification items count: {len(successverification_items)}"))
logger.info(log_former.get_message(f"Success verification sample items list : {successverification_items[:5]}"))
logger.info(log_former.get_message(f"Failed verification items count: {len(failureverification_items)}"))
logger.info(log_former.get_message(f"Failed verification sample items list : {failureverification_items[:5]}"))
logger.info(log_former.get_message(f"Skipped verification items count: {len(skipverification_items)}"))
logger.info(log_former.get_message(f"Skipped verification sample items list : {skipverification_items[:5]}"))

# Verify the length of the lists
try:
    total_length = len(failureverification_items) + len(successverification_items) + len(skipverification_items)
    assert total_length == len(deleteRequests)
except AssertionError:
    errormsg = "Lengths of lists do not match the deleteRequests list"
    logger.error(log_former.get_message(f"{errormsg = }"))
    raise ValueError(errormsg)

# Process success and failure verification items
if successverification_items:
    logger.info(log_former.get_message("==============Starting to handle Completed verification deleteRequest=============="))
    Observer.process_kafka_notification(successverification_items, s3, outboundS3Bucket, dynamodb_table, logger, log_former)
    logger.info(log_former.get_message("==============Completed to handle Completed verification deleteRequest=============="))
if failureverification_items:
    logger.info(log_former.get_message("==============Starting to handle Failed verification deleteRequest=============="))
    Observer.process_kafka_notification(failureverification_items, s3, outboundS3Bucket, dynamodb_table, logger, log_former)
    logger.info(log_former.get_message("==============Completed to handle Failed verification deleteRequest=============="))

logger.info(log_former.get_message("Job Finished"))

job.init(args['JOB_NAME'], args)
job.commit()