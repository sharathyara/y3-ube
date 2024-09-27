import boto3
import os
import json
import logging
from datetime import datetime
import time
from jsonmerge import merge

LOG_LEVEL = os.environ.get("LOG_LEVEL")
ENVIRONMENT = os.environ.get("ENVIRONMENT")


# set logging from workflow
def set_logging_level(level_str):
    levels = {
        "debug": logging.DEBUG,
        "info": logging.INFO,
        "warning": logging.WARNING,
        "error": logging.ERROR,
        "critical": logging.CRITICAL,
    }

    level = logging.ERROR  # DEFAULT

    if level_str is None:
        logging.basicConfig(level=level)
        logging.warn(f"Logging level set to '{level_str}'.")
    else:
        level = levels.get(level_str.lower())

    if level is not None:
        logging.basicConfig(level=level)
        logging.info(f"Logging level set to '{level_str}'.")
    else:
        logging.error(
            f"""
Invalid logging level: {level_str}. Available levels are debug,
info, warning, error, and critical.
"""
        )


# init clients
s3_client = boto3.client("s3", region_name="eu-central-1", endpoint_url=os.environ.get("S3_VPC_ENDPOINT"))
glue_client = boto3.client("glue", region_name="eu-central-1")
dynamodb_client = boto3.client("dynamodb", region_name="eu-central-1")
redshift_data = boto3.client("redshift-data", region_name="eu-central-1")


# Custom methods
def clean_s3_objects(context, s3_resources_to_cleanup, bucket_name):
    logging.info(f"S3 Resources to cleanup in bucket {bucket_name}: {s3_resources_to_cleanup}")
    for object_key in s3_resources_to_cleanup:
        logging.info(f"Deleting S3 object: {object_key}")
        s3_client.delete_object(Bucket=bucket_name, Key=object_key)
        # s3_client.put_object(Bucket=bucket_name, Key=object_key, Body='')


def clean_dynamoDB_resources(context, tableName):
    dynamo_resources_to_cleanup = context.variables.get("dynamo_resources_to_cleanup")

    # Specify the table name and the key of the item you want to delete
    logging.info(f"Dynamo Resources to cleanup: {dynamo_resources_to_cleanup}")
    for partition_key_value in dynamo_resources_to_cleanup:
        # Perform the query for sorted keys
        response = dynamodb_client.query(
            TableName=tableName,
            KeyConditionExpression="entityId = :entityId",
            ExpressionAttributeValues={":entityId": {"S": partition_key_value}},
        )

        # Iterate through the results to get the sort keys
        sort_keys = [item["cdcProcessedTs"] for item in response["Items"]]

        logging.info(
            f"Sort keys for partition key '{partition_key_value}': {sort_keys}"
        )

        for sort_key_value in sort_keys:
            # Define the primary key for the item to delete
            key = {
                "entityId": {"S": partition_key_value},
                "cdcProcessedTs": {"N": sort_key_value["N"]},
            }

            logging.debug(
                f"""
Deleting key '{partition_key_value}' sort key '{sort_key_value['N']}'.
"""
            )
            # Delete the item
            dynamodb_client.delete_item(TableName=tableName, Key=key)

    logging.info(
        f"Items with key '{partition_key_value}' deleted from '{tableName}' table."
    )


def clean_redshift(context, entityName, ident):
    config = context.variables.get("config")

    # Provide the SQL DELETE statement with a LIKE condition.
    sql_statement = (
        'DELETE FROM "curated_schema"."'
        + entityName
        + '" WHERE '
        + ident
        + " LIKE 'smoke-test%';"
    )

    logging.info(f"Executing SQL statement: '{sql_statement}'")

    CLUSTER_ID = os.environ.get("REDSHIFT_CLUSTER_ID")
    DATABASE = os.environ.get("REDSHIFT_DB")
    DB_USER = config["REDSHIFT_USER"]

    try:
        response = redshift_data.execute_statement(
            ClusterIdentifier=CLUSTER_ID,
            Database=DATABASE,
            DbUser=DB_USER,
            Sql=sql_statement,
        )

        # Get the query ID for monitoring.
        query_id = response["Id"]

        # Define the maximum number of polling attempts.
        max_attempts = 10
        poll_interval_seconds = 5  # Adjust the polling interval as needed.

        for attempt in range(max_attempts):
            response = redshift_data.describe_statement(Id=query_id)
            status = response["Status"]

            if status == "FINISHED":
                logging.debug(f"Response received '{response}'")

                break  # Query has finished, exit the loop.
            elif status == "FAILED":
                logging.debug(f"Response received '{response}'")
                break  # Query has failed, exit the loop.

            if attempt < max_attempts - 1:
                # Sleep before the next polling attempt.
                time.sleep(poll_interval_seconds)
            else:
                logging.error(
                    "Query did not complete within the specified number of attempts."
                )
                assert False
    except Exception as e:
        print(f"Error executing SQL statement: {str(e)}")


# before all
def before_all(context):
    # init context variables
    context.variables = {}

    # Read the configuration from the JSON file
    with open("config/" + ENVIRONMENT + ".json") as config_file:
        config_env = json.load(config_file)

    with open("config/base.json") as config_file:
        config_base = json.load(config_file)

    # Merge the data from both files
    config = merge(config_env, config_base)
    # config to context
    context.variables["config"] = config

    # set logging level and put into context
    set_logging_level(LOG_LEVEL)
    context.variables["log_level"] = logging.getLogger().getEffectiveLevel()

    logging.info("Before all executed")
    logging.info(f"Environment set: '{ENVIRONMENT}'")

    # To store variables, which can be shared among different behave scenarios.
    context.task_dict = {}


# before every scenario
def before_scenario(context, scenario):
    logging.info(f"Before scenario start: {scenario.name}")

    current_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    logging.info(f"Scenario: {scenario.name} - Started at {current_datetime}")

    # clean redshift with smoke data - only relevant stream data - CDC stack, Map Data
    if 'CDC' in scenario.name:
        entity_name = context.active_outline.cells[0]
        identifier = context.active_outline.cells[2]
        clean_redshift(context, entity_name, identifier)

    if 'Map Data' in scenario.name:
        entity_name = context.active_outline.cells[2]
        identifier = 'eventid'
        clean_redshift(context, entity_name, identifier)

def after_scenario(context, scenario):
    # Access the context and scenario objects here
    logging.info(f"After scenario start: {scenario.name}")

    if hasattr(context, "variables"):
        config = context.variables.get("config")

        # Clean S3 Resources WARN : Deleting of objects is denied as per bucket policy as of now
        #if context.variables.get("s3_raw_resources_to_cleanup") is not None:
        #    clean_s3_objects(
        #        context,
        #        context.variables.get("s3_raw_resources_to_cleanup"),
        #        config["RAW_ZONE_BUCKET_NAME"],
        #    )

        # if context.variables.get('s3_conformed_resources_to_cleanup') != None:
        #    clean_s3_objects(context, context.variables.get(
        #        's3_conformed_resources_to_cleanup'),
        #        config["CONFORMED_ZONE_BUCKET_NAME"]
        #     )

        # Clean DynamoDB Resources
        #if context.variables.get("dynamo_resources_to_cleanup") is not None:
        #    clean_dynamoDB_resources(context, config["METASTORE_DYNAMODB"])

        # Clean Redshift Resources - This should be enough to remove smoke test data
        if context.variables.get("redshift") is not None:
            if 'CDC' in scenario.name:
                # retrieve values from outline scenario cells
                entity_name = context.active_outline.cells[0]
                identifier = context.active_outline.cells[2]
                clean_redshift(context, entity_name, identifier)
            if 'Map Data' in scenario.name:
                entity_name = context.active_outline.cells[2]
                identifier = 'eventid'
                clean_redshift(context, entity_name, identifier)    
            
    logging.info(f"After scenario finished: {scenario.name}")


def before_step(context, step):
    # sleep to let asynchronous tasks to be completed meanwhile
    time.sleep(2)


# after every feature
def after_feature(scenario, context):
    logging.info("After feature executed")


# after all
def after_all(context):
    logging.info("After all")
