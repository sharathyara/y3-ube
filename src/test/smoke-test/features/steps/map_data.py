import boto3
import time
import os
import json
import random
import logging
import uuid
import zipfile
from datetime import datetime, timedelta
from fastavro import writer, reader
from behave import given, when, then

# init clients
s3_client = boto3.client("s3", region_name="eu-central-1", endpoint_url=os.environ.get("S3_VPC_ENDPOINT"))
glue_client = boto3.client("glue", region_name="eu-central-1")

# Utilities
def create_tags():
    tags = [
        {"Key": "Purpose", "Value": "ffdp-smoke-test"},
        {"Key": "Owner", "Value": "ffdp"},
        {"Key": "Creator", "Value": "ffdp"},
        {"Key": "Workflow", "Value": os.environ.get("WORKFLOW_RUN")},
    ]

    return tags

def zip_pdf(pdf_file_path, zip_file_path, file_arcname):
    with zipfile.ZipFile(zip_file_path, 'w') as zipf:
        # Add the PDF file to the zip file
        zipf.write(pdf_file_path, arcname=file_arcname)
    

@given('A bucket for map upload')
def a_bucket(context):
    config = context.variables.get("config")
    bucket_name = config["MAPS_DATA_BUCKET_NAME"]
    assert bucket_name is not None

@given('A new season')
def new_season(context):
    unique_id = str(uuid.uuid4())
    context.variables["season_id"] = unique_id
    file_name = 'test_data_map_' + unique_id + '.pdf'
    context.variables["file_name"] = file_name
    context.variables["identifier"] = file_name
    
@when('map file "{data_file_name}" is created for new season')
def prepare_map_file(context, data_file_name):
    season_id = context.variables.get("season_id")
    file_arcname = context.variables.get("file_name")
    
    pdf_file_path = 'test-records/' + data_file_name
    zip_file_path = 'test_data_map_' + season_id + '.zip'
    
    zip_pdf(pdf_file_path, zip_file_path, file_arcname)
    context.variables["local_file_path"] = zip_file_path

@then('file is ready for upload')
def ready_upload(context):
    local_file_path = context.variables.get("local_file_path")
    assert os.path.exists(
        local_file_path
    ), f"The file '{local_file_path}' does not exist"


@when('map file with entity "{entity_name}" is uploaded in "{s3_object_key_prefix}" folder')
def upload_file(context, entity_name, s3_object_key_prefix):
    config = context.variables.get("config")
    
    file_name = context.variables.get("local_file_path")
    bucket_name = config["MAPS_DATA_BUCKET_NAME"]

    s3_object_key = s3_object_key_prefix + '/' + context.variables["local_file_path"]

    context.variables["s3_map_file_key"] = s3_object_key

    # Get the tags
    tags = create_tags()
    s3_client.upload_file(
        file_name,
        bucket_name,
        s3_object_key,
        ExtraArgs={
            "Tagging": "&".join([f'{tag["Key"]}={tag["Value"]}' for tag in tags])
        },
    )
    
    context.variables["map_data_resources_to_cleanup"] = []
    context.variables["map_data_resources_to_cleanup"].append(s3_object_key)


@then("the data file will be present in bucket")
def validate_map_object_exists(context):
    config = context.variables.get("config")
    bucket_name = config["MAPS_DATA_BUCKET_NAME"]

    for object_key in context.variables.get("map_data_resources_to_cleanup"):
        try:
            response = s3_client.head_object(Bucket=bucket_name, Key=object_key)
            assert (
                response["ResponseMetadata"]["HTTPStatusCode"] == 200
            ), f"Object '{object_key}' is missing in bucket '{bucket_name}'."

            logging.info(f"Object '{object_key}' exists in bucket '{bucket_name}'.")
        except Exception as e:
            # If an exception is raised, the object does not exist
            if e.response["Error"]["Code"] == "404":
                raise Exception(
                    f"Object '{object_key}' does not exist in bucket '{bucket_name}'."
                )
            else:
                # Handle other exceptions
                raise Exception(f"An error occurred: {str(e)}")

@when('map file event "{file_name}" with entity "{entity_name}" and "{ident}" got updated on "{update_date}"')
def step_update_entity_for_smoke_test(
    context, file_name, entity_name, ident, update_date
):
    context.variables["entity_name"] = entity_name
    context.variables["update_date"] = update_date

    random_string = str(random.randint(1, 100))
    random_identifier = "smoke-test-dummy-record-" + entity_name + "-" + random_string
    random_eventId = "smoke-test-dummy-event-" + random_string
    context.variables["eventId"] = random_eventId

    # Avro schema
    with open("test-records/" + file_name, "rb") as fo:
        writer_schema = reader(fo).writer_schema

    out_records = []
    # Update entity attribute
    with open("test-records/" + file_name, "rb") as fo:
        for record in reader(fo):
            logging.debug(record)

            # map file location
            record["data"]["sourceFile"]["name"] = context.variables.get("s3_map_file_key")
            record["data"]["mapFile"] =  context.variables.get("file_name")
            record["data"]["seasonId"] = context.variables.get("season_id")
    
            # generated eventId
            record["eventId"] = random_eventId
            logging.debug(record["eventId"])

            # update dates
            record["dateTimeOccurred"] = update_date + "T09:34:15.719Z"
            record["modifiedDateTime"] = update_date + "T09:34:15.719Z"
            out_records.append(record)

    # Writing tmp file
    local_file_path = "smoke-test-data-" + entity_name + ".avro"
    context.variables["local_file_path"] = local_file_path
    with open(local_file_path, "wb") as out:
        writer(out, writer_schema, out_records)
        
@then("map file is extracted in bucket")
def extracted_map_file_object(context):
    config = context.variables.get("config")
    bucket_name = config["MAPS_DATA_BUCKET_NAME"]
    
    map_upload = context.variables.get("s3_map_file_key")

    s3_object_key = map_upload.replace('raw-map-uploads','map-extracted').replace('.zip','') + '/' + context.variables.get("file_name")

    try:
        response = s3_client.head_object(Bucket=bucket_name, Key=s3_object_key)
        assert (
            response["ResponseMetadata"]["HTTPStatusCode"] == 200
        ), f"Object '{s3_object_key}' is missing in bucket '{bucket_name}'."

        logging.info(f"Object '{s3_object_key}' exists in bucket '{bucket_name}'.")
        
        context.variables["map_data_resources_to_cleanup"].append(s3_object_key)
        
    except Exception as e:
        # If an exception is raised, the object does not exist
        if e.response["Error"]["Code"] == "404":
            raise Exception(
                f"Object '{s3_object_key}' does not exist in bucket '{bucket_name}'."
            )
        else:
            # Handle other exceptions
            raise Exception(f"An error occurred: {str(e)}")