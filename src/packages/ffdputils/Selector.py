from boto3.dynamodb.conditions import Key
import fastavro
from io import BytesIO
import redshift_connector

#extracting details from dynamoDB
def extract_userid_data_from_dynamoDB(dynamodb_table, index_name, key_condition, key_value, projection_expression, logger, log_former):

    """
    Fetch deletion requests from DynamoDB table based on a specific key condition and value.
    Args:
        dynamodb_table (boto3.resources.factory.aws.DynamoDBTableResource): DynamoDB table resource.
        index_name (str): Name of the index to use for querying.
        key_condition (str): Key condition attribute name.
        key_value (str): Value of the key condition.
        projection_expression (str): Attributes of DynamoDB which has to be fetched.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.
    Returns:
        list: List of deletion request items fetched from DynamoDB.
    Raises:
        RuntimeError: If the scanned count and fetched count don't match.
    """

    items = []
    fetched_count = 0

    try:
        params = {
            'IndexName': index_name,
            'KeyConditionExpression': Key(key_condition).eq(key_value),
            'ProjectionExpression': projection_expression
        }

        while True:
            response = dynamodb_table.query(**params)
            fetched_count += response.get('Count', 0)
            scanned_count = response.get('ScannedCount')

            logger.info(log_former.get_message(f"Fetched Count: {fetched_count}"))

            if 'Items' in response:
                items.extend(response['Items'])

            if 'LastEvaluatedKey' in response:
                params['ExclusiveStartKey'] = response['LastEvaluatedKey']
            else:
                break

        if scanned_count != fetched_count:
            error_msg = f"There are {fetched_count} deletion requests available with {key_condition}={key_value}, " \
                        f"but according to DynamoDB table query, {scanned_count} are available"
            logger.error(log_former.get_message(error_msg))
            raise RuntimeError(error_msg)

        logger.info(log_former.get_message(f"Scanned Count: {scanned_count}"))
        return items

    except Exception as e:
        error_msg = f"Error querying DynamoDB table: {e}"
        logger.error(log_former.get_message(error_msg))
        raise RuntimeError(error_msg)

#function to create a dynamic frame with the result of SQL Query
def redshift_query_to_create_dynamic_frame(glueContext, redshift_temp_dir, redshift_url, query, redshift_credentials):

    """
    Query the redshift and converts the result into a dynamic frame.
    Args:
        glueContext: created by SparkContext.
        redshift_temp_dir (str): value of redshift temporary directory.
        redshift_url (str): value of redshift URL.
        query (str):  SQL query which is used to query the redshift.
        redshift_credentials (dict): Has the value of redshift username and Password.
    Returns:
        DynamicFrame: Result of the redshift query
    """

    query_executor = glueContext.create_dynamic_frame.from_options(
        connection_type="redshift",
        connection_options={
            "redshiftTmpDir": redshift_temp_dir,
            "url": redshift_url,
            "sampleQuery": query,
            "user": redshift_credentials['userName'],
            "password": redshift_credentials['password']
        }
    )
    return query_executor

#function to generate the update_expression  expression_attribute_values, expression_attributes_names for dynamoDB update
def updating_update_expression_and_value(entityTable, entity_dict, expression_key):

    """
    function to generate the update_expression  expression_attribute_values, expression_attributes_names for dynamoDB update.
    Args:
        entityTable: Resource representing the DynamoDB table.
        entity_dict (dict): dict of entity and its value for a single user.
        expression_key (dict): dict of sort and partition key of DynamoDB.
    calls:
       update_dynamoDB(): this function is used to update the values in DynamoDB
    """

    update_expression = 'SET '
    expression_attribute_values = {}
    expression_attributes_names = {}
    
    for key, value in entity_dict.items():
        if value[0] != 'None':
            update_expression +=f"#{key} = :val_{key}, "
            expression_attribute_values[f':val_{key}'] = set(value)
            expression_attributes_names[f'#{key}'] = key
    
    update_expression = update_expression[:-2]
    update_dynamoDB(entityTable, expression_key, update_expression, expression_attribute_values, expression_attributes_names)
        
#function to update the dynamoDB   
def update_dynamoDB(entityTable, expression_key, update_expression, expression_attribute_values, expression_attributes_names):

    """
    Fetch deletion requests from DynamoDB table based on a specific key condition and value.
    Args:
        entityTable: Resource representing the DynamoDB table.
        expression_key (dict): dict of sort and partition key of DynamoDB.
        update_expression (str): update query to set the attribute and its value.
        expression_attribute_values (dict): dict of values and alias mentioned in update_expression.
        expression_attributes_names (dict): dict of attributes name and alias mentioned in update_expression.
    Returns:
        None.
    """

    response = entityTable.update_item(
            Key=expression_key,
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_attribute_values,
            ExpressionAttributeNames=expression_attributes_names,
            ReturnValues="UPDATED_NEW"
        )
    

#function to delete the files in the S3 bucket
def delete_s3_object(s3_client, map_location_list, map_file_deletion_bucket, logger, log_former):

    """
    Delete the map files in the S3 bucket.
    Args:
        s3_client ((boto3.client): S3 client.
        map_location_list (list): List of map file S3 location.
        map_file_deletion_bucket (str): Name of the bucket.
        key_value (str): Value of the key condition.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.
    Returns:
        None.
    """

    for file_path in map_location_list:
        if file_path != 'None':
            s3_object_key = file_path[len(f's3://{map_file_deletion_bucket}/'):]
            s3_client.delete_object(Bucket=map_file_deletion_bucket, Key=s3_object_key)
            # logger.info(log_former.get_message(f"Deleted Path: '{file_path}'"))

#nullifying the redshift filelocation attribute after deleting the file
def nullify_maps_path(map_location_query, redshift_host, redshift_db_name, redshift_credentials):
    
    """
    Delete the map files in the S3 bucket.
    Args:
        map_location_query (str): SQL query to update the deleted map filelocations to NULL.
        redshift_host (str): Host of the redshift.
        redshift_db_name (str): redshift Database name.
        redshift_credentials (dict): Has the value of redshift username and Password.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.
    Returns:
        None.
    """
    
    # Script to update from Redshift
    conn = redshift_connector.connect(
        host=redshift_host,
        database=redshift_db_name,
        user=redshift_credentials['userName'],
        password=redshift_credentials['password']
        )

    cur = conn.cursor()
    cur.execute(map_location_query)
    conn.commit()
    cur.close()
    conn.close()

#function to generate avro schema and store it in s3
def generate_cascading_avro_file(s3_client, user_farm_details, output_avro_bucket, key, logger, log_former):

    """
        Generate avro files with farms data and upload to S3 bucket
        Args:
            s3_client ((boto3.client): S3 client.
            user_farm_details (dataframe): Has farms details necessary to create avro file.
            output_avro_bucket (str): Bucket name to upload the avro files.
            key (str): S3 Path and file name in which the file has to be uploaded.
        Returns:
            None.
    """

    avro_schema = {
        'type': 'record',
        'name': 'FarmDeleted',
        'fields': [
            {'name': 'dateTimeOccurred', 'type': 'string'},
            {'name': 'data',
                'type': {
                    'type': 'record',
                    'name': 'data',
                    'fields': [
                        {'name': 'sourceFarmId', 'type': 'string'},
                        {'name': 'sourceUserId', 'type': 'string'},
                        {'name': 'clientCode', 'type': 'string'}
                    ]
                }
            },
            {'name': 'eventSource', 'type': 'string'},
            {'name': 'eventType', 'type': 'string'},
            {'name': 'eventId', 'type': 'string'}
        ]
    }
    
    #set the dataframe as per the avro schema structure
    user_farm_details['data'] = user_farm_details.apply(lambda row: {'sourceFarmId': row['sourceFarmId'], 'sourceUserId': row['sourceUserId'], 'clientCode': row['clientCode']}, axis=1)

    # Drop the unnecessary columns (as sourceFarmId, sourceUserId is combined in data column)
    user_farm_details.drop(columns=['sourceFarmId', 'sourceUserId','clientCode'], inplace=True)
                
    logger.info(log_former.get_message(f"user_farm_details count {user_farm_details.count()}")) 

    # Write DataFrame to Avro format and save to S3
    avro_bytes = BytesIO()
    fastavro.writer(avro_bytes, avro_schema, user_farm_details.to_dict(orient='records'),codec='null')

    # Reset buffer position
    avro_bytes.seek(0)

    # Uploads the farm data as an avro file to S3 Bucket
    bucket_name = output_avro_bucket
    key = key
    s3_client.upload_fileobj(avro_bytes, bucket_name, key)

    logger.info(log_former.get_message(f"successfully added cascading avro files to the S3 bucket"))