import boto3
import time
import os
import json
import random
import logging
from datetime import datetime, timedelta
from fastavro import writer, reader
from behave import given, when, then


# init clients
s3_client = boto3.client("s3", region_name="eu-central-1", endpoint_url=os.environ.get("S3_VPC_ENDPOINT"))
glue_client = boto3.client("glue", region_name="eu-central-1")
redshift_data = boto3.client("redshift-data", region_name="eu-central-1")


# Utilities
def create_tags():
    tags = [
        {"Key": "Purpose", "Value": "ffdp-smoke-test"},
        {"Key": "Owner", "Value": "ffdp"},
        {"Key": "Creator", "Value": "ffdp"},
        {"Key": "Workflow", "Value": os.environ.get("WORKFLOW_RUN")},
    ]

    return tags


@given('No running "{job_name}" process for entity "{entity_name}"')
def step_no_running_process(context, job_name, entity_name):
    # init config and loglevel
    config = context.variables.get("config")
    logging.basicConfig(level=context.variables.get("log_level"))

    # Get information about the most recent job run
    response = glue_client.get_job_runs(JobName=job_name, MaxResults=1)

    run_status = "UNKNOWN"

    # Process the response
    if "JobRuns" in response and len(response["JobRuns"]) > 0:
        most_recent_run = response["JobRuns"][0]
        run_status = most_recent_run["JobRunState"]
        logging.info(f"Job '{job_name}' is currently {run_status}")
    else:
        logging.warn(f"No job runs found for job '{job_name}'")

    # assert run_status != "RUNNING", "There is running glue job process"

    # validate there is no processing folder pending

    # Specify the S3 bucket name and the prefix to search for
    bucket_name = config["RAW_ZONE_BUCKET_NAME"]

    for index in range(1, 10):
        prefix_to_search = entity_name + "/processing-list" + str(index) + "/"

        # List objects in the bucket with the specified prefix
        response = s3_client.list_objects_v2(
            Bucket=bucket_name, Prefix=prefix_to_search
        )

        # Check if any objects were found with the given prefix
        if "Contents" in response:
            logging.warn(
                f"""
Objects with prefix '{prefix_to_search}' exist in the bucket '{bucket_name}'."""
            )
        else:
            logging.debug(
                f"""
No objects with prefix '{prefix_to_search}' found in the bucket '{bucket_name}'."""
            )

        assert (
            "Contents" not in response
        ), f"There is lock object presence in {prefix_to_search}"


@when('file "{file_name}" with entity "{entity_name}" and "{ident}" got updated on "{update_date}"')
def step_update_entity_for_smoke_test(
    context, file_name, entity_name, ident, update_date
):
    context.variables["entity_name"] = entity_name
    context.variables["update_date"] = update_date

    random_string = str(random.randint(1, 100))
    random_identifier = "smoke-test-dummy-record-" + entity_name + "-" + random_string
    random_eventId = "smoke-test-dummy-event-" + random_string
    context.variables["eventId"] = random_eventId
    context.variables["identifier"] = random_identifier

    # Avro schema
    with open("test-records/" + file_name, "rb") as fo:
        writer_schema = reader(fo).writer_schema

    out_records = []
    # Update entity attribute
    with open("test-records/" + file_name, "rb") as fo:
        for record in reader(fo):
            logging.debug(record)

            # set identifier of this record
            context.variables["identifier"] = record["data"][ident]

            # generated eventId
            record["eventId"] = random_eventId
            logging.debug(record["eventId"])

            # update dates
            record["dateTimeOccurred"] = update_date + "T09:34:15.719Z"
            record["modifiedDateTime"] = update_date + "T09:34:15.719Z"
            update_event_type = entity_name.capitalize() + "Updated"
            record["eventType"] = update_event_type
            out_records.append(record)

    # Writing tmp file
    local_file_path = "smoke-test-data-" + entity_name + ".avro"
    context.variables["local_file_path"] = local_file_path
    with open(local_file_path, "wb") as out:
        writer(out, writer_schema, out_records)


@then("this event is created in file")
def step_validate_avro_is_ready(context):
    local_file_path = context.variables.get("local_file_path")
    assert os.path.exists(
        local_file_path
    ), f"The file '{local_file_path}' does not exist"


@then("event is identified as smoke record")
def step_as_smoke_record(context):
    identifier = context.variables.get("identifier")
    assert identifier.lower().startswith(
        "smoke"
    ), "The identifier does not start with 'smoke' (case-insensitive)."


@given("event in a file")
def step_event_in_file(context):
    pass


@when('I manually push event into platform in "{raw_object_location}"')
def step_impl(context, raw_object_location):
    entity_name = context.variables.get("entity_name")
    config = context.variables.get("config")

    # Extract day, month, and year from the datetime object
    date_obj = datetime.strptime(context.variables.get("update_date"), "%Y-%m-%d")
    day = str(date_obj.day)
    month = str(date_obj.month)
    year = str(date_obj.year)

    # Upload to S3 bucket (simulating S3 Sink Connector)
    object_key = (
        raw_object_location
        + "/year="
        + year
        + "/month="
        + month
        + "/day="
        + day
        + "/smoke_test.avro"
    )
    file_name = context.variables.get("local_file_path")
    bucket_name = config["RAW_ZONE_BUCKET_NAME"]

    # Get the tags
    tags = create_tags()
    s3_client.upload_file(
        file_name,
        bucket_name,
        object_key,
        ExtraArgs={
            "Tagging": "&".join([f'{tag["Key"]}={tag["Value"]}' for tag in tags])
        },
    )

    context.variables["s3_raw_resources_to_cleanup"] = []
    context.variables["s3_raw_resources_to_cleanup"].append(object_key)


@then("the event object will be present in bucket")
def validate_object_exists(context):
    config = context.variables.get("config")
    bucket_name = config["RAW_ZONE_BUCKET_NAME"]

    for object_key in context.variables.get("s3_raw_resources_to_cleanup"):
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


@then('the job "{job_name}" should be running at most {num:d} minute(s)')
def validate_glue_job_processing(context, job_name, num):
    #initial sleep
    time.sleep(30)
    
    # Get information about the most recent job run
    response = glue_client.get_job_runs(JobName=job_name, MaxResults=1)

    # Process the response
    if "JobRuns" in response and len(response["JobRuns"]) > 0:
        most_recent_run = response["JobRuns"][0]
        context.variables["latest_job_run_id"] = most_recent_run["Id"]
    pass

    poll_interval_seconds = 15  # Adjust the polling interval as needed.
    max_attempts = int((num * 60) / poll_interval_seconds)

    run_id = context.variables.get("latest_job_run_id")

    for attempt in range(max_attempts):
        response = glue_client.get_job_run(
            JobName=job_name, RunId=run_id, PredecessorsIncluded=False
        )
        status = response["JobRun"]["JobRunState"]
        if status == "SUCCEEDED":
            assert True
            break  # Query has finished, exit the loop.
        elif status == "FAILED" or status == "ERROR":
            error_message = response["JobRun"]["ErrorMessage"]
            logging.error(
                "Glue job "
                + job_name
                + " with run id "
                + run_id
                + " has "
                + status
                + " reason : "
                + error_message
            )
            assert False
            break  # Query has failed, exit the loop.

        if attempt < max_attempts - 1:
            # Sleep before the next polling attempt.
            time.sleep(poll_interval_seconds)
        else:
            logging.error(
                "Glue job "
                + job_name
                + " with run id "
                + run_id
                + " did not finish running within the specified number of attempts."
            )
            assert False


@then('the record exists in "{zone_name}" zone')
def step_record_exists_in_zone(context, zone_name):
    config = context.variables.get("config")
    entity_name = context.variables.get("entity_name")
    smoke_event_id = context.variables.get("eventId")
    update_date = context.variables.get("update_date")

    # Validate zone and pick valid bucket from list
    valid_zone_name = {
        "curated": config["CURATED_ZONE_BUCKET_NAME"],
        "conformed": config["CONFORMED_ZONE_BUCKET_NAME"],
    }

    if zone_name not in valid_zone_name:
        raise Exception(
            f"""
Zone name {zone_name} is not valid. Valid Zones are {', '.join(valid_zone_name)}
"""
        )

    bucket_name = valid_zone_name[zone_name]

    # Set folder path
    folder_path = "hudi-cdc-tables/" + entity_name + "/" + update_date + "/"

    try:
        # List objects in the specified folder
        response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=folder_path)
        parquet_objects = [
            obj["Key"]
            for obj in response.get("Contents", [])
            if obj["Key"].endswith(".parquet")
        ]
    except Exception as e:
        logging.error(f"Error: {str(e)}")
        assert False

    object_key = parquet_objects[0]

    logging.info(f"Queried object key '{object_key}' in bucket '{bucket_name}'")

    # Specify the SQL query to run on the Parquet data
    query = "SELECT * FROM S3Object"

    # Expression type and input serialization format
    expression_type = "SQL"
    input_serialization = {"Parquet": {}}

    # Execute the select_object_content operation
    response = s3_client.select_object_content(
        Bucket=bucket_name,
        Key=object_key,
        ExpressionType=expression_type,
        Expression=query,
        InputSerialization=input_serialization,
        OutputSerialization={"JSON": {}},
    )

    # Process the response
    for event in response["Payload"]:
        if "Records" in event:
            # Convert the records to JSON and compare value
            records = event["Records"]["Payload"].decode("utf-8")
            json_record = json.loads(records)
            logging.debug(json_record)

            entityId = json_record["_hoodie_record_key"]

            # in conformed zone we can validate eventId
            if zone_name == "conformed":
                eventId = json_record["eventId"]
                logging.info(f"Event Id '{eventId}' found in parquet file")
                logging.info(f"Expected id: '{smoke_event_id}")

                assert (
                    eventId == smoke_event_id
                ), f"""
Generated eventId does not match '{eventId}', expected '{smoke_event_id}'
"""
            # in curated zone we can validate HUDI commit time
            # [alt] canditate - identifier, now it is constant, so no benefit
            else:
                timestamp_str = str(json_record["_hoodie_commit_time"])

                # Convert the timestamp string to a datetime object
                timestamp = datetime.strptime(timestamp_str, "%Y%m%d%H%M%S%f")

                # Calculate the current time
                current_time = datetime.now()

                # Calculate the time difference between the current time and 
                # the timestamp
                time_difference = current_time - timestamp

                # Check if the time difference is less than 12 hours
                assert time_difference <= timedelta(
                    hours=12
                ), "The timestamp is older than 12 hours."

            # if satisfied - then this record can be deleted in post-action
            context.variables["s3_conformed_resources_to_cleanup"] = []
            context.variables["s3_conformed_resources_to_cleanup"].append(object_key)

            context.variables["dynamo_resources_to_cleanup"] = []
            context.variables.get("dynamo_resources_to_cleanup").append(entityId)


@given('record in "{zone_name}" zone')
def step_record_in_zone(context, zone_name):
    pass


@when('I manually invoke job "{job_name}" to conformed zone for "{entity}" entity')
def step_manual_invoke_job(context, job_name, entity):
    try:
        # Start the Glue job
        response = glue_client.start_job_run(JobName=job_name)

        # Get the job run ID
        job_run_id = response["JobRunId"]

        logging.debug(f"Job run started with ID: {job_run_id}")
    except Exception as e:
        logging.info(f"Error starting Glue job: {e}")


@given("Redshift warehouse")
def step_given_redshift_warehouse(context):
    config = context.variables.get("config")
    context.variables["redshift"] = []
    pass


@when('the recent job "{job_name}" exists')
def step_when_job_starts(context, job_name):
    # Get information about the most recent job run
    response = glue_client.get_job_runs(JobName=job_name, MaxResults=1)

    # Process the response
    if "JobRuns" in response and len(response["JobRuns"]) > 0:
        most_recent_run = response["JobRuns"][0]
        context.variables["latest_job_run_id"] = most_recent_run["Id"]
    pass


@then('job "{job_name}" is processing "{entity}" entity table in "{zone}" zone')
def step_then_reading_entity_table(context, job_name, entity, zone):
    run_id = context.variables.get("latest_job_run_id")

    response = glue_client.get_job_run(
        JobName=job_name, RunId=run_id, PredecessorsIncluded=False
    )

    expected_value = entity

    # Process the response
    if "JobRun" in response:
        arguments = response["JobRun"]["Arguments"]
        # validate hudi table match entity name
        actual_value = arguments["--hudi_table_name"]
        assert (
            actual_value == expected_value
        ), f"Expected '{expected_value}' but got '{actual_value}'"
    else:
        logging.warn(f"No job runs found for job '{job_name}' run id '{run_id}'")
        assert False, f"No job runs found for job '{job_name}' run id '{run_id}'"


@then('the "{entity}" record exists in Redshift using "{query}"')
def step_then_record_exists_in_redshift(context, entity, query):
    config = context.variables.get("config")

    DB_USER = config["REDSHIFT_USER"]
    CLUSTER_ID = os.environ.get("REDSHIFT_CLUSTER_ID")
    DATABASE = os.environ.get("REDSHIFT_DB")
    sqlStatement = query.replace(
        "%IDENT%", "'" + context.variables.get("identifier") + "'"
    )

    logging.info(f"SQL Statement prepared: '{sqlStatement}'")

    response = redshift_data.execute_statement(
        ClusterIdentifier=CLUSTER_ID,
        Database=DATABASE,
        DbUser=DB_USER,
        Sql=sqlStatement,
        StatementName="redshiftStatement",
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
            results = redshift_data.get_statement_result(Id=query_id)
            assert results["TotalNumRows"] >= 1  # there is expected at least 1 record

            context.variables["redshift"].append(entity)
            break  # Query has finished, exit the loop.
        elif status == "FAILED":
            error_message = response["Error"]
            print(error_message)
            assert False
            break  # Query has failed, exit the loop.

        if attempt < max_attempts - 1:
            # Sleep before the next polling attempt.
            time.sleep(poll_interval_seconds)
        else:
            logging.error(
                "Query did not complete within the specified number of attempts."
            )
            assert False
