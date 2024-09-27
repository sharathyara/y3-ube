from behave import given, when, then
from tenacity import retry, stop_after_attempt, wait_fixed
import os
import boto3
from steps.airflow_cli import AirflowCLI


@given("MWAA is live and CLI token can be obtained")
def step_func_1(context):
    """Obtain Airflow CLI token, test MWAA API functionality."""
    # For local testing only.
    aws_profile = os.environ.get("AWS_PROFILE")

    if aws_profile:
        session = boto3.Session(profile_name=aws_profile)

    else:
        session = boto3.Session()

    # This class sets up a connection to MWAA and has methods for interacting with
    # the API.
    config = context.variables["config"]

    context.AirflowCLI = AirflowCLI(
        session=session,
        region_name=config["AWS_REGION"],
        mwaa_env_name=config["MWAA_ENVIRONMENT"],
    )

    # Request Airflow version from MWAA API, to confirm that MWAA is live and
    # the CLI token is valid.
    response = context.AirflowCLI.mwaa_api_post("version")

    assert response.status_code == 200

    return None


@when("the smoke test dag is triggered")
def step_func_2(context):
    """Trigger smoke test dag, store api code and timestamp."""
    api_code, timestamp = context.AirflowCLI.trigger_dag("smoke_test")

    context.smoke_dag_api_code = api_code

    context.smoke_dag_run_timestamp = timestamp

    return None


@then("MWAA API returns code 200")
def step_func_3(context):
    """Check if dag trigger request was successful."""
    assert context.smoke_dag_api_code == 200


@given("smoke test dag has been triggered")
def step_func_4(context):
    """Check if dag trigger request was successful."""
    assert context.smoke_dag_api_code == 200


@retry(stop=stop_after_attempt(10), wait=wait_fixed(30))
def dag_status_checker(context):
    """Check if dag run until the end, retry if it is running."""
    status = context.AirflowCLI.get_dag_status(
        "smoke_test", context.smoke_dag_run_timestamp
    )

    context.smoke_dag_status = status
    if status != "success\n":
        raise ValueError("DAG still running")

    return None


@when("dag status is requested from MWAA API")
def step_func_5(context):
    """Behave wrapper function."""
    dag_status_checker(context)


@then('MWAA API returns status "success"')
def step_func_6(context):
    """Check if dag ran until the end."""
    assert context.smoke_dag_status == "success\n"


@given("smoke test dag has completed its run")
def step_func_7(context):
    """Check if dag ran until the end."""
    assert context.smoke_dag_status == "success\n"


@when("the status of all tasks is requested from MWAA API")
def step_func_8(context):
    """Get dag task statuses, store in dictionary."""
    tasks = context.AirflowCLI.get_dag_tasks_status(
        "smoke_test", context.smoke_dag_run_timestamp
    )

    for x in tasks:
        context.task_dict[x["task_id"]] = x["state"]

    return None


@then("the status is recorded")
def step_func_9(context):
    """Confirm that task statuses have been stored."""
    assert len(context.task_dict) > 0


@when('the status of a task is queried')
def step_func_10(context):
    """Storyteller function, does nothing."""
    pass


@then('the status of task {task_id} is listed as "success"')
def step_func_11(context, task_id):
    """Check status of each task."""
    assert context.task_dict[task_id] == "success"
