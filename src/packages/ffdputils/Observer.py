import json
import uuid
from datetime import datetime
from botocore.exceptions import ClientError
from jinja2 import Template
from boto3.dynamodb.conditions import Key

# Constants
DELETION_REQUEST_ATTRIBUTES_MAP = {
    'requestid': 'deletionRequestId',
    'requestcreatedts': 'deletionRequestCreatedTs',
    'sourceuserid': 'sourceUserId',
    'status': 'status',
    'statusreason': 'statusReason',
    'statuscreatedat': 'statusCreatedAt',
    'statusupdatedat': 'statusUpdatedAt',
    'clientcode': 'clientCode',
    'farmids': 'farmEntityList',
    'seasonids': 'seasonEntityList',
    'fieldids': 'fieldEntityList',
    'mapfilepaths': 'mapFilePaths'
}

DELETION_REQUEST_STATUS_MAP = {
    'received': 'Received',
    'inprogress': 'Inprogress',
    'completed': 'Completed',
    'failed': 'Failed'
}

KAFKA_MESSAGE_METADATA_VALUES = {
    'eventSource': 'FFDP',
    'eventType': 'DeletionRequestProcessed',
    'eventId': str(uuid.uuid4())
}

TEMPLATE_VERIFICATION_QUERY = {
    "entities": {
        "di_user": {
            "curated_schema": {
                "table": "di_user",
                "primary_key": "sourceUserId",
                "pii_columns": ["phone"]
            },
            "ffdp2_0": {
                "table": "user",
                "primary_key": "id",
                "pii_columns": ["email", "phone", "name", "zipcode"]
            }
        },
        "di_farm": {
            "curated_schema": {
                "table": "di_farm",
                "primary_key": "sourceFarmId",
                "pii_columns": ["address", "zipcode"]
            },
            "ffdp2_0": {
                "table": "farm",
                "primary_key": "id",
                "pii_columns": ["address", "zipcode"]
            }
        }
    },
    "verification_query_templates": {
        "curated_schema": "SELECT COUNT(*) FROM curated_schema.{{ table }} WHERE {{ primary_key }} IN ('{{ "
                          "primary_key_values }}') {% for column in pii_columns %} AND {{ column }} IS NULL {% endfor "
                          "%}",
        "ffdp2_0": "SELECT COUNT(*) FROM ffdp2_0.{{ table }} WHERE {{ primary_key }} IN ('{{ primary_key_values }}') "
                   "{% for column in pii_columns %} AND {{ column }} IS NULL {% endfor %}"
    }
}

# Helper functions

def get_deletion_requests_from_dynamodb(dynamodb_table, index_name, key_condition, key_value, logger, log_former):
    """
    Fetch deletion requests from DynamoDB table based on a specific key condition and value.

    Args:
        dynamodb_table (boto3.resources.factory.aws.DynamoDBTableResource): DynamoDB table resource.
        index_name (str): Name of the index to use for querying.
        key_condition (str): Key condition attribute name.
        key_value (str): Value of the key condition.
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
            'KeyConditionExpression': Key(key_condition).eq(key_value)
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

def generate_json_payload(client_code, deletion_request_id, status, event_source, event_type, event_id,
                          status_reason=None):
    """
    Generate JSON payload for Kafka messages.

    Args:
        client_code (str): The client code to use as Kafka message key.
        deletion_request_id (str): The unique ID of the deletion request.
        status (str): The status of the deletion request.
        event_source (str): The source of the event.
        event_type (str): The type of the event.
        event_id (str): The unique ID of the event.
        status_reason (str, optional): The reason for the status, if applicable.

    Returns:
        str: JSON payload for the Kafka message.

    Raises:
        ValueError: If required arguments are missing or if the status is invalid.
    """
    if not all([client_code, deletion_request_id, status, event_source, event_type, event_id]):
        raise ValueError("All arguments are required")

    if status.upper() not in [DELETION_REQUEST_STATUS_MAP['completed'].upper(), DELETION_REQUEST_STATUS_MAP['failed'].upper()]:
        raise ValueError("Invalid status. Status must be 'COMPLETED' or 'FAILED'")

    if status.upper() == DELETION_REQUEST_STATUS_MAP['failed'].upper() and not status_reason:
        raise ValueError("Status reason is required for FAILED status")

    current_time = datetime.utcnow().isoformat() + "Z"

    message = {
            "dateTimeOccurred": current_time,
            "data": {
                "deletionRequestId": deletion_request_id,
                "status": status,
                "statusReason": status_reason
            },
            "eventSource": event_source,
            "eventType": event_type,
            "eventId": event_id
    }
    return json.dumps(message)

def upload_to_s3(s3, bucket_name, object_key, json_data, logger, log_former):
    """
    Upload a JSON file to an S3 bucket.

    Args:
        s3 (boto3.resource): S3 resource.
        bucket_name (str): Name of the S3 bucket.
        object_key (str): Key of the object in the S3 bucket.
        json_data (str): JSON data to be uploaded.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.

    Returns:
        bool: True if the file was uploaded successfully, False otherwise.

    Raises:
        ClientError: If there was an error uploading the file to S3.
    """
    try:
        s3.Object(bucket_name, object_key).put(Body=json_data)
        logger.info(
            log_former.get_message(f"JSON file '{object_key}' uploaded successfully to S3 bucket '{bucket_name}'."))
        return True
    except ClientError as e:
        logger.error(log_former.get_message(f"Error uploading JSON file to S3 bucket: {e}"))
        raise

def generate_and_upload_kafka_message(s3, deletion_request, bucket_name, logger, log_former):
    """
    Generate and upload a Kafka message for a deletion request to an S3 bucket.

    Args:
        s3 (boto3.resource): S3 resource.
        deletion_request (dict): Deletion request item from DynamoDB.
        bucket_name (str): Name of the S3 bucket.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.

    Returns:
        bool: True if the Kafka message was uploaded successfully, False otherwise.

    Raises:
        ValueError: If there was an error generating the Kafka message.
        RuntimeError: If there was an error uploading the file to S3.
        ClientError: If there was an error uploading the file to S3.
    """
    try:
        client_code = deletion_request.get(DELETION_REQUEST_ATTRIBUTES_MAP['clientcode'], 'Others')
        deletion_request_id = deletion_request[DELETION_REQUEST_ATTRIBUTES_MAP['requestid']]
        status = deletion_request[DELETION_REQUEST_ATTRIBUTES_MAP['status']]
        event_source = KAFKA_MESSAGE_METADATA_VALUES['eventSource']
        event_type = KAFKA_MESSAGE_METADATA_VALUES['eventType']
        event_id = KAFKA_MESSAGE_METADATA_VALUES['eventId']
        status_reason = deletion_request.get(DELETION_REQUEST_ATTRIBUTES_MAP['statusreason'], None)
        status_updated_at = datetime.strptime(deletion_request[DELETION_REQUEST_ATTRIBUTES_MAP['statusupdatedat']],
                                              '%Y-%m-%dT%H:%M:%S.%fZ')

        # Generate Kafka message for the deletion request
        kafka_message = generate_json_payload(client_code, deletion_request_id, status, event_source, event_type,
                                              event_id, status_reason)
        logger.info(log_former.get_message(f"The Kafka message: {kafka_message}"))

        # Generate file name and path for the request
        year, month, day = status_updated_at.year, status_updated_at.month, status_updated_at.day
        file_name = f'{client_code}/eu-central-1/year={year}/month={month}/day={day}/{deletion_request_id}.json'

        # Upload the Kafka message to S3
        # TODO : good to have ->  add metadata with status for each object
        if not upload_to_s3(s3, bucket_name, file_name, kafka_message, logger, log_former):
            raise RuntimeError("Failed to upload to S3")
        logger.info(log_former.get_message(f"Uploaded successfully to S3"))
        return True
    except (ValueError, KeyError, RuntimeError, ClientError) as e:
        logger.error(log_former.get_message(f"Failed to generate and upload Kafka message: {e}"))
        raise

def mapfile_verification(s3, bucket_name, object_paths, logger, log_former):
    """
    Check if objects exist in the specified paths within an S3 bucket.

    Args:
        s3 (boto3.resource): S3 resource.
        bucket_name (str): Name of the S3 bucket.
        object_paths (list): List of object paths to check.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.

    Returns:
        bool: True if all object paths are valid (i.e., objects do not exist), False otherwise.

    Raises:
        RuntimeError: If there was an error checking object existence.
    """
    try:
        for object_path in object_paths:
            try:
                s3.Object(bucket_name, object_path).load()
                logger.info(log_former.get_message(f"The s3://{bucket_name}/{object_path} exists in map files"))
                return False
            except ClientError as e:
                if e.response['Error']['Code'] == "404":
                    logger.info(
                        log_former.get_message(f"The s3://{bucket_name}/{object_path} doesn't exist in map files"))
                    continue
                else:
                    error_msg = f"Error checking object existence for path '{object_path}': {e}"
                    logger.error(log_former.get_message(error_msg))
                    raise RuntimeError(error_msg)
        return True
    except RuntimeError as e:
        logger.error(log_former.get_message(f"Error checking objects existence: {e}"))
        raise

def generate_redshift_verification_queries(entity_name, entity_ids):
    """
    Generate Redshift verification queries for a given entity and its identifiers.

    Args:
        entity_name (str): Name of the entity.
        entity_ids (list): List of entity identifiers.

    Returns:
        dict: A dictionary containing verification queries for different schema types.

    Raises:
        ValueError: If the entity is not found in the configuration or if the template is missing.
    """
    entity_config = TEMPLATE_VERIFICATION_QUERY['entities'].get(entity_name)
    if not entity_config:
        raise ValueError(f"Entity '{entity_name}' not found in the config file")

    verification_query_templates = TEMPLATE_VERIFICATION_QUERY['verification_query_templates']

    verification_queries = {}
    for schema_type in verification_query_templates.keys():
        template_str = verification_query_templates.get(schema_type)
        if not template_str:
            raise ValueError(f"Template not found for schema type '{schema_type}'")

        template = Template(template_str)
        query_params = {
            'table': entity_config[schema_type]['table'],
            'primary_key': entity_config[schema_type]['primary_key'],
            'primary_key_values': "', '".join(entity_ids),
            'pii_columns': entity_config[schema_type]['pii_columns']
        }

        verification_query = template.render(query_params)
        verification_queries[schema_type] = verification_query

    return verification_queries


def verify_entity_in_redshift(entity, entity_ids, redshift_data_client, redshift_cluster_details, logger, log_former):
    """
    Verify if an entity's data is anonymized or nullified in Redshift.

    Args:
        entity (str): Name of the entity.
        entity_ids (list): List of entity identifiers.
        redshift_data_client (boto3.client): Redshift Data API client.
        redshift_cluster_details (dict): Dictionary containing Redshift cluster details.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.

    Returns:
        bool: True if the data is anonymized or nullified, False otherwise.

    Raises:
        RuntimeError: If there was an error verifying the entity in Redshift.
    """
    redshift_cluster_name = redshift_cluster_details['redshiftClusterName']
    redshift_db_name = redshift_cluster_details['redshiftDBName']
    redshift_user = redshift_cluster_details['redshiftUser']

    try:
        verification_queries_dict = generate_redshift_verification_queries(entity, entity_ids)
        logger.info(
            log_former.get_message(f"Verification queries: {verification_queries_dict}"))
        entity_ids_count = len(entity_ids)

        for schema, query_string in verification_queries_dict.items():
            result = execute_redshift_query(redshift_data_client, redshift_cluster_name, redshift_db_name,
                                            redshift_user, query_string, logger, log_former)
            logger.info(log_former.get_message(f"Query result: {result}"))
            if result != entity_ids_count:
                return False

        return True

    except Exception as e:
        raise RuntimeError(f"Error: {e}")

def execute_redshift_query(redshift_data_client, redshift_cluster_name, redshift_db_name, redshift_user, query_string,
                           logger, log_former):
    """
    Execute a query on Redshift using the Redshift Data API.

    Args:
        redshift_data_client (boto3.client): Redshift Data API client.
        redshift_cluster_name (str): Name of the Redshift cluster.
        redshift_db_name (str): Name of the Redshift database.
        redshift_user (str): Redshift user.
        query_string (str): SQL query to be executed.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.

    Returns:
        int: The result of the query (e.g., count).

    Raises:
        Exception: If there was an error executing the query.
    """
    try:
        response = redshift_data_client.execute_statement(
            ClusterIdentifier=redshift_cluster_name,
            Database=redshift_db_name,
            DbUser=redshift_user,
            Sql=query_string,
            StatementName='verificationQuery'
        )
        statement_id = response['Id']
        query_execution_response = redshift_data_client.describe_statement(Id=statement_id)
        status = query_execution_response['Status']
        while status == 'SUBMITTED' or status == 'PICKED' or status == 'STARTED':
            query_execution_response = redshift_data_client.describe_statement(Id=statement_id)
            status = query_execution_response['Status']
        # todo: if status='Aborted' etc
        if status == 'FAILED':
            error_message = query_execution_response['Error']
            logger.error(log_former.get_message(f"Error executing query: {error_message}"))
            raise Exception(error_message)
        else:
            response_metadata = redshift_data_client.get_statement_result(Id=statement_id)
            records = response_metadata['Records'][0][0]['longValue']
            logger.info(
                log_former.get_message(f"Redshift get_statement_result records: {records}"))
            return records
    except Exception as e:
        logger.error(log_former.get_message(f"Error executing Redshift query: {e}"))
        raise e

def get_entity_identifiers(deletion_request, entity):
    """
    Get entity identifiers from a DynamoDB item based on the specified entity.

    Args:
        deletion_request (dict): DynamoDB item representing a deletion request.
        entity (str): Name of the entity to get identifiers for.

    Returns:
        set or None: Entity identifiers or None if the entity is not supported.

    Raises:
        ValueError: If the specified entity is not supported.
    """
    supported_entities = {
        'di_farm': 'farmEntityList',
        'di_user': 'sourceUserId',
        'di_field': 'fieldEntityList',
        'di_map': 'mapFilePaths',
        'di_season': 'seasonEntityList'
    }

    if entity not in supported_entities:
        raise ValueError(f"Entity '{entity}' is not supported")

    attribute_name = supported_entities[entity]
    response = deletion_request.get(attribute_name, None)
    if isinstance(response, str):
        response = {response}
    return response

def verify_entities(s3, entity_list, deletion_request, maps_bucket_name, redshift_data_client, redshift_cluster_details,
                    logger, log_former):
    """
    Verify Maps files and other entities' data in Redshift if data is anonymized or nullified.

    Args:
        s3 (boto3.resource): S3 resource.
        entity_list (list): List of entities to verify.
        deletion_request (dict): Deletion request item from DynamoDB.
        maps_bucket_name (str): Name of the S3 bucket for map files.
        redshift_data_client (boto3.client): Redshift Data API client.
        redshift_cluster_details (dict): Dictionary containing Redshift cluster details.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.

    Returns:
        bool: True if all entities are verified, False otherwise.
    """
    for entity in entity_list:
        # Verify Maps files are deleted from the S3 bucket
        if entity == "di_map":
            maps_files_path = get_entity_identifiers(deletion_request, entity)
            logger.info(log_former.get_message(
                f"Map file paths to be verified in S3 bucket: {maps_files_path}"))
            if maps_files_path:
                if not mapfile_verification(s3, maps_bucket_name, maps_files_path, logger, log_former):
                    return False
        else:
            # For other entities, verification is done in Redshift (curated_schema and ffdp2_0)
            entity_ids = get_entity_identifiers(deletion_request, entity)
            logger.info(log_former.get_message(
                f"{entity} IDs to be verified in Redshift: {entity_ids}"))
            if entity_ids:
                if not verify_entity_in_redshift(entity, entity_ids, redshift_data_client, redshift_cluster_details,
                                                 logger, log_former):
                    return False
    return True

def update_dynamodb_table(dynamodb_table, items, logger, log_former):
    """
    Update the DynamoDB table with the provided items.

    Args:
        dynamodb_table (boto3.resources.factory.aws.DynamoDBTableResource): DynamoDB table resource.
        items (list): List of items to update in the DynamoDB table.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.

    Raises:
        KeyError: If a required key is missing in an item.
        ValueError: If the status reason is missing for a failed status.
        ClientError: If there was an error updating the DynamoDB table.
    """
    for item in items:
        try:
            request_id = item[DELETION_REQUEST_ATTRIBUTES_MAP['requestid']]
            request_created_ts = item[DELETION_REQUEST_ATTRIBUTES_MAP['requestcreatedts']]
            status = item[DELETION_REQUEST_ATTRIBUTES_MAP['status']]
            status_reason = item.get(DELETION_REQUEST_ATTRIBUTES_MAP['statusreason'], None)
            status_updated_at = item[DELETION_REQUEST_ATTRIBUTES_MAP['statusupdatedat']]

            update_expression = "SET #status = :status, #statusUpdatedAt = :statusUpdatedAt"
            expression_attribute_values = {
                ':status': status,
                ':statusUpdatedAt': status_updated_at
            }
            expression_attribute_names = {
                '#status': 'status',
                '#statusUpdatedAt': 'statusUpdatedAt'
            }

            if status.upper() == DELETION_REQUEST_STATUS_MAP['failed'].upper() and status_reason is None:
                raise ValueError("Status reason is required for FAILED status")

            if status_reason:
                update_expression += ", #statusReason = :statusReason"
                expression_attribute_values[':statusReason'] = status_reason
                expression_attribute_names['#statusReason'] = 'statusReason'

            key_condition_expression = {
                DELETION_REQUEST_ATTRIBUTES_MAP['requestid']: request_id,
                DELETION_REQUEST_ATTRIBUTES_MAP['requestcreatedts']: request_created_ts
            }

            try:
                response = dynamodb_table.update_item(
                    Key=key_condition_expression,
                    UpdateExpression=update_expression,
                    ExpressionAttributeValues=expression_attribute_values,
                    ExpressionAttributeNames=expression_attribute_names,
                    ReturnValues="UPDATED_NEW"
                )
                logger.info(log_former.get_message(f"DynamoDB table updated for: {request_id}"))
            except ClientError as e:
                logger.error(f"Error updating DynamoDB table: {e.response['Error']['Message']}")
                raise

        except KeyError as e:
            logger.error(f"Missing key in item: {e}")
            raise
        except ValueError as e:
            logger.error(str(e))
            raise

def process_kafka_notification(item_list, s3, bucket_name, dynamodb_table, logger, log_former):
    """
    Process a list of deletion requests, generate and upload Kafka messages, and update the DynamoDB table.

    Args:
        item_list (list): List of deletion request items from DynamoDB.
        s3 (boto3.resource): S3 resource.
        bucket_name (str): Name of the S3 bucket.
        dynamodb_table (boto3.resources.factory.aws.DynamoDBTableResource): DynamoDB table resource.
        logger (logging.Logger): Logger instance for logging.
        log_former (LogFormer): LogFormer instance for formatting log messages.

    Raises:
        Exception: If there was an error during the processing.
    """
    successfully_uploaded_to_s3_list = []
    try:
        for item in item_list:
            if generate_and_upload_kafka_message(s3, item, bucket_name, logger, log_former):
                logger.info(log_former.get_message(f"Successfully uploaded {item[DELETION_REQUEST_ATTRIBUTES_MAP['requestid']]} to S3"))
                successfully_uploaded_to_s3_list.append(item)

        update_dynamodb_table(dynamodb_table, item_list, logger, log_former)
    except Exception as e:
        logger.info(log_former.get_message(f"The length of successfully_uploaded_to_s3_list = {len(successfully_uploaded_to_s3_list)}"))
        logger.error(log_former.get_message(f"Error: {e}"))
        update_dynamodb_table(dynamodb_table, successfully_uploaded_to_s3_list, logger, log_former)
        raise
