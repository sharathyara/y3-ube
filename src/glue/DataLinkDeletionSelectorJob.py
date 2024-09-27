import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from ffdputils import FFDPLogger, Selector
from datetime import datetime, timezone
import pandas as pd
import boto3
import uuid
import json

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME','redshift_connection_user','redshift_url','redshift_db_name', 'redshift_cluster_name','redshift_temp_dir','entity_table_name', 'gs_index_name', 'required_entity','redshift_schema_name','output_avro_bucket','key_attribute','key_attribute_value','map_file_deletion_bucket','redshift_host','confluent_env'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
logger = glueContext.get_logger()

#Global params:
rawEventEntityTableName=args['entity_table_name']
indexName = args['gs_index_name']
jobName = args["JOB_NAME"]
jobRunId = args['JOB_RUN_ID']
redshift_user = args['redshift_connection_user']
redshift_url = args['redshift_url']
redshift_db_name = args['redshift_db_name']
redshift_cluster_name = args['redshift_cluster_name']
redshift_temp_dir = args['redshift_temp_dir']
redshift_host = args['redshift_host']
schema_name = args['redshift_schema_name']
output_avro_bucket = args['output_avro_bucket']
map_file_deletion_bucket = args['map_file_deletion_bucket']
key_attribute = args['key_attribute']
confluent_env = args['confluent_env']
key_attribute_value = args['key_attribute_value']
required_entity = args['required_entity']
required_entity = json.loads(required_entity)
traceId = uuid.uuid4() 
log_former = FFDPLogger.FFDPLogger(traceId, jobName, jobRunId)

#declaring the necessary resources and client
dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
redshift_client = boto3.client('redshift')
s3_client = boto3.client('s3')

entityTable = dynamodb.Table(rawEventEntityTableName)

#declaring the necessary objects
user_deletion_list = [] 
createdTs_dict = {}
user_id_dict = {}
entity_dict = {}

#getting the current datetime
current_datetime_utc = datetime.now(timezone.utc)
current_datetime_utc_format = current_datetime_utc.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z" 
current_month = current_datetime_utc.strftime("%m")
current_date = current_datetime_utc.strftime("%d")
 
# fetching the deletion requested deletionRequestId, deletionRequestCreatedTs, sourceUserId, clientCode from DynamoDB
logger.info(log_former.get_message(f"Fetching the data from DynamoDB"))

projection_expression = 'deletionRequestId, deletionRequestCreatedTs, sourceUserId, clientCode'

#calling extract_userid_data_from_dynamoDB function to fetch data from dynamoDB
index_name = indexName
deleteEntityResponseList =  Selector.extract_userid_data_from_dynamoDB(entityTable, index_name, key_attribute, key_attribute_value, projection_expression, logger, log_former)
logger.info(log_former.get_message(f"Fetched the deletion requested Data from DynamoDB"))


#checks if there is any item and extracts Item and convert it into our need
if (len(deleteEntityResponseList) != 0):
    for item in deleteEntityResponseList:
        SourceUserId = item['sourceUserId']
        if(SourceUserId != None):
            user_deletion_list.append(SourceUserId)
    
    user_deletion_details = pd.DataFrame(deleteEntityResponseList) #columns = deletionRequestId, deletionRequestCreatedTs, sourceUserId, clientCode

    # Converting list of userID into spark dataframe use:to compare it with userid retrieved from redshift 
    user_df = spark.createDataFrame([(item,) for item in user_deletion_list],["id"])

    # checking if UserID exists in Redshift use: to dynamically pass into the SQl query
    requestuserid = tuple(user_deletion_list) if len(user_deletion_list)>1 else f"('{user_deletion_list[0]}')"
    

#### checking if user exists in redshift ####

    # Get Redshift cluster credentials
    credentialsResponse = redshift_client.get_cluster_credentials(
        DbUser=redshift_user,
        DbName=redshift_db_name,
        ClusterIdentifier=redshift_cluster_name,
        DurationSeconds=3600,
        AutoCreate=False
    )

    redshift_credentials = {
        'userName': credentialsResponse['DbUser'],
        'password': credentialsResponse['DbPassword']
    }

    user_available_query = f"select sourceuserid from {schema_name}.di_user where sourceuserid in {requestuserid}"
    
    # calling function to query the redshift and get the result as a dynamic frame
    user_available_query_checker = Selector.redshift_query_to_create_dynamic_frame(glueContext, redshift_temp_dir, redshift_url, user_available_query, redshift_credentials)
    
    #available_user_df dataframe of userid available in redshift
    available_user_df = user_available_query_checker.toDF()
    logger.info(log_former.get_message(f"Deletion Requested User Available in FFDP Redshift Count: '{available_user_df.count()}'"))
    
    #checking the userid which is not available in redshift
    not_available_user_df = user_df.subtract(available_user_df)
    logger.info(log_former.get_message(f"Deletion Requested User Not Available in FFDP Redshift Count: '{not_available_user_df.count()}'"))
    
    if(available_user_df.count() != 0):
        available_user_list = available_user_df.select("sourceuserid").rdd.flatMap(lambda x: x).collect()
        available_user_tuple = tuple(available_user_list) if len(available_user_list)>1 else f"('{available_user_list[0]}')"

        #extracting the available users deletion event data from user_deletion_details Dataframe
        available_user_deletion_details = user_deletion_details[user_deletion_details['sourceUserId'].isin(available_user_list)]
        
        #### extraction of user related cascade details ####
            
        user_related_details_query = f"""Select user_fnf_season.sourceuserid as userid, coalesce(listagg(distinct user_fnf_season.sourcefarmid ,','),'None') as farmid , coalesce(listagg(distinct user_fnf_season.sourcefieldid ,','),'None') as fieldid , coalesce(listagg(distinct user_fnf_season.sourceseasonid ,','),'None') as seasonid ,  coalesce(listagg(distinct maps.filelocation ,','),'None') as filelocation  From {schema_name}.di_map maps
        Right join  
            (Select user_fnf.sourceuserid, user_fnf.sourcefarmid ,user_fnf.sourcefieldid , seasons.sourceseasonid from {schema_name}.di_season seasons
            Right Join 
                (Select farm_user.sourceuserid, farm_user.sourcefarmid, fields.sourcefieldid from {schema_name}.di_field fields
                Right join
                    (Select sourcefarmid, sourceuserid from {schema_name}.di_farm where sourceuserid in {available_user_tuple} and sourcefarmid is not null) farm_user
                On fields.sourcefarmid = farm_user.sourcefarmid ) user_fnf 
            On user_fnf.sourcefieldid = seasons.sourcefieldid ) user_fnf_season
        On maps.seasonid = user_fnf_season.sourceseasonid
        group by 1"""
        
        logger.info(log_former.get_message(f"Fetching users cascading details!!"))

        # calling function to query the redshift and get the result as a dynamic frame
        user_related_details_query_executor = Selector.redshift_query_to_create_dynamic_frame(glueContext, redshift_temp_dir, redshift_url, user_related_details_query, redshift_credentials)

        logger.info(log_former.get_message(f"Successfully fetched users cascading details!!"))
        
        #converting the extracted data into pandas dataframe for easy access
        user_details_df = user_related_details_query_executor.toDF().toPandas()
        
        #joining two dataframe use:single dataframe which has the required data  
        user_entire_details = pd.merge(user_details_df, available_user_deletion_details, left_on='userid',right_on='sourceUserId', how='right')
        
        if(not user_details_df.empty):
            #converting the fields from string to List
            for key, value in required_entity.items():
                user_entire_details[value] = user_entire_details[value].str.split(',') 

            logger.info(log_former.get_message(f"User Entire details count '{user_entire_details.count()}'"))
        
        #### updating the cascading details to the dynamoDB ####

            for index in user_entire_details.index:
                entity_dict={}
                deletion_request_id = user_entire_details['deletionRequestId'][index]
                user_id = user_entire_details['sourceUserId'][index]
                created_at = user_entire_details['deletionRequestCreatedTs'][index]
                
                for key, value in required_entity.items():
                    if(str(user_entire_details[value][index]) != 'nan'):
                        entity_dict[key] = user_entire_details[value][index]

                #bool is used to check whether dictionary is empty
                if (bool(entity_dict)):
                    expression_key = {'deletionRequestId': deletion_request_id, 'deletionRequestCreatedTs': created_at}
                    Selector.updating_update_expression_and_value(entityTable, entity_dict, expression_key)
        
        
    ####extracting farms detail and storing it as avro in s3

            user_farm_details = pd.DataFrame(user_entire_details[['farmid','sourceUserId','clientCode']].explode('farmid')).reset_index()
            user_farm_details = user_farm_details.dropna().reset_index()
        
            if (user_farm_details['farmid'].count() != 0):

                logger.info(log_former.get_message(f"Count of FarmID to generate avro file: {user_farm_details['farmid'].count()}"))    

                #adding a column for date time, eventSource, eventType, generating UUID for eventId and renaming column "farmid" to "sourceFarmId"
                user_farm_details['dateTimeOccurred'] = current_datetime_utc_format
                farmid_rename = {'farmid':'sourceFarmId'}
                user_farm_details.rename(columns = farmid_rename, inplace = True)
                user_farm_details['eventSource'] = "FFDP"
                user_farm_details['eventType'] = "FarmDeleted"

                # generating the eventId
                user_farm_details['eventId'] = None
                for index in user_farm_details.index:
                    farm_uuid = uuid.uuid4()
                    user_farm_details['eventId'][index] = str(farm_uuid)

                logger.info(log_former.get_message(f"Farm avro details count {user_farm_details.count()}"))

                #key is s3 key
                key = f'di_farm/eu-central-1/{confluent_env}-yara-digitalsolution-di-farm/year={current_datetime_utc.year}/month={current_month}/day={current_date}/{confluent_env}-yara-digitalsolution-di-farm-deletion_{current_datetime_utc_format}.avro' 

                # calling generate_cascading_avro_file to generate avro file and store it in s3 raw bucket
                Selector.generate_cascading_avro_file(s3_client, user_farm_details, output_avro_bucket, key, logger, log_former)
            
        #### s3 maps Zip file deletion ####

            # converting Map files into list for S3 maps deletion
            map_location_list = sum(user_entire_details['filelocation'].dropna(),[])
            logger.info(log_former.get_message(f"Count of map files location: {len(map_location_list)}"))
    
            if (len(map_location_list) != 0):

                #calling delete_s3_object to delete s3 maps file
                Selector.delete_s3_object(s3_client, map_location_list, map_file_deletion_bucket, logger, log_former)
                logger.info(log_former.get_message(f"Successfully Deleted all the map files'"))
            
    #### updating the dynamoDB status and statusUpdatedAt

        #updating dynamo DB

        for index in user_entire_details.index:
            deletion_request_id = user_entire_details['deletionRequestId'][index]
            created_at = user_entire_details['deletionRequestCreatedTs'][index]

            expression_key = {'deletionRequestId': deletion_request_id, 'deletionRequestCreatedTs': created_at}
            update_expression = "SET  #sts = :progressStatus, #updatedAt = :statusUpdatedAt"
            expression_attribute_values = {
                ':progressStatus': "INPROGRESS",
                ':statusUpdatedAt': str(current_datetime_utc_format),
            }
            expression_attributes_names = {
                "#sts": "status",
                "#updatedAt": "statusUpdatedAt"
            }
        
            response = Selector.update_dynamoDB(entityTable, expression_key, update_expression, expression_attribute_values, expression_attributes_names)

        logger.info(log_former.get_message(f"Successfully updated DynamoDB"))

    else:
        logger.info(log_former.get_message(f"There is no Deletion Requested User Available in FFDP Redshift"))

    if(not_available_user_df.count() != 0):
        not_available_user_list = not_available_user_df.select("id").rdd.flatMap(lambda x: x).collect()
        not_available_user_deletion_details = user_deletion_details[user_deletion_details['sourceUserId'].isin(not_available_user_list)]
        
        #updating dynamo DB

        for index in not_available_user_deletion_details.index:
            deletion_request_id = not_available_user_deletion_details['deletionRequestId'][index]
            created_at = not_available_user_deletion_details['deletionRequestCreatedTs'][index]

            expression_key = {'deletionRequestId': deletion_request_id, 'deletionRequestCreatedTs': created_at}
            update_expression = "SET  #sts = :progressStatus, #reason = :reason, #updatedAt = :statusUpdatedAt"
            expression_attribute_values = {
                ':progressStatus': "USER_NOT_AVAILABLE",
                ':reason': "User is not available in FFDP redshift",
                ':statusUpdatedAt': str(current_datetime_utc_format)
            }
            expression_attributes_names = {
                "#sts": "status",
                "#reason": "statusReason",
                "#updatedAt": "statusUpdatedAt"
            }
        
            response = Selector.update_dynamoDB(entityTable, expression_key, update_expression, expression_attribute_values, expression_attributes_names)

        logger.info(log_former.get_message(f"Not available users Successfully updated DynamoDB"))
    else:
        logger.info(log_former.get_message(f"All the users are available in FFDP redshift"))

    ####updating redshift table by nullifying the Map zip file location ####
    # map_location_tuple = tuple(map_location_list) if len(map_location_list)>1 else f"('{map_location_list[0]}')"
    # map_location_query = f"""update "{schema_name}"."maps" set filelocation = null where filelocation in {map_location_tuple}"""
    # nullify_maps_path(map_location_query, redshift_host,redshift_db_name, redshift_credentials)

else:
    logger.info(log_former.get_message(f"There is no user requested for deletion"))
    
job.init(args['JOB_NAME'], args)
job.commit()