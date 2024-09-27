"""A collection of functions for interacting with Airflow CLI on MWAA.

from boto3 import Session
from steps.airflow_cli import AirflowCLI

SESSION = Session(profile_name='dev-test')

AAPI = AirflowCLI(
    session=SESSION,
    region_name='eu-central-1',
    mwaa_env_name='ffdp-mwaa-test'
)
print(AAPI.set_variable(key='temp_1', value='aaa'))
print(AAPI.set_variable(key='temp_2', value='bbb'))

print(AAPI.get_variable('temp_1',))
print(AAPI.get_variable('temp_2',))

print(AAPI.import_variables('mwaa_example.json'))

var_key_list = AAPI.list_variables()

print(var_key_list)
print(AAPI.delete_variables(key_list=var_key_list, re_pattern='^temp'))
"""
import base64
from datetime import datetime
import json
import re
from itertools import compress

from boto3 import Session
import requests


class AirflowCLI:
    def __init__(self, session, region_name, mwaa_env_name):
        self.session = session
        self.region_name = region_name  # MWAA Envioronment's region.
        self.mwaa_env_name = mwaa_env_name
        self.client = self.session.client(
            service_name="mwaa", region_name=self.region_name
        )

    def get_web_ui_url(self):
        """Obtain a url to access the MWAA Airflow UI in a webbrowser.
        Parameters:
            None

        Returns:
            (string) URL to airflow Webserver UI.
        """
        login_token = self.client.create_web_login_token(Name=self.mwaa_env_name)

        host_name = login_token["WebServerHostname"]

        web_token = login_token["WebToken"]

        web_ui_url = "https://{0}/aws_mwaa/aws-console-sso?login=true#{1}".format(
            host_name, web_token
        )

        return web_ui_url

    def mwaa_api_post(self, data):
        """Send a post request to MWAA Airflow CLI.
        Parameters:
            (string) command passed to the Airflow CLI.

        Returns:
            (requests.models.Response) Response object.
        """
        cli_token = self.client.create_cli_token(Name=self.mwaa_env_name)

        auth_token = "Bearer " + cli_token["CliToken"]

        api_endpoint = "https://{0}/aws_mwaa/cli".format(cli_token["WebServerHostname"])


        mwaa_response = requests.post(
            url=api_endpoint,
            headers={"Authorization": auth_token, "Content-Type": "text/plain"},
            data=data,
        )

        if mwaa_response.status_code != 200:
            error = """Airflow API returned status code {0}.
            """.format(
                mwaa_response.status_code,
            )

            raise ValueError(error)

        else:
            return mwaa_response

    def decode_and_extract_api_response(self, response):
        """Decode data received from the MWAA Airflow CLI.
        Parameters:
            (requests.models.Response) Response object.

        Returns:
            (dict) Standard Output and Error from the Airlow CLI, in UTF-8 encoding.
        """
        output = base64.b64decode(response.json()["stdout"]).decode("utf8")
        
        # Remove ANSI escape codes
        ansi_escape = re.compile(r'\x1b\[[0-9;]*m')
        cleaned_json = ansi_escape.sub('', output)

        # Extract and parse the JSON part
        json_start = cleaned_json.find('[{')
        json_end = cleaned_json.find('}]') + 2
        json_part = cleaned_json[json_start:json_end]
        
        error = base64.b64decode(response.json()["stderr"]).decode("utf8")

        result = {"output": json_part, "error": error}

        return result

    def decode_api_response(self, response):
        """Decode data received from the MWAA Airflow CLI.
        Parameters:
            (requests.models.Response) Response object.

        Returns:
            (dict) Standard Output and Error from the Airlow CLI, in UTF-8 encoding.
        """
        output = base64.b64decode(response.json()["stdout"]).decode("utf8")  
        error = base64.b64decode(response.json()["stderr"]).decode("utf8")

        result = {"output": output, "error": error}

        return result

    def trigger_dag(self, dag_name):
        """Trigger a given airflow DAG.
        Parameters:
            (string) Name of the DAG in question.

        Returns:
            (int) 200 Status of a successful API call.
        """
        data = "dags trigger {0} -o json".format(dag_name)

        response = self.mwaa_api_post(data)

        result = self.decode_and_extract_api_response(response)

        result_json = json.loads(result["output"])

        dag_run_timestamp = result_json[0]["logical_date"]

        return response.status_code, dag_run_timestamp

    def format_timestamp(self, time_string):
        date = datetime.strptime(time_string, "%Y-%m-%dT%H:%M:%S+00:00")

        result = date.strftime("%Y-%m-%dT%H:%M:%SZ")

        return result

    def get_dag_status(self, dag_name, dag_run_timestamp):
        """Gets the status of a given runtime of a single DAG.
        Parameters:
            (string) Name of the DAG in question.
            (string) Timestamp of the DAG run, UTC timezone.
            Here is an example: '2023-10-19T06:23:59Z'.

        Returns:
            (string) Status of a given runtime of a single DAG.
        """
        data = "dags state {0} {1}".format(
            dag_name, self.format_timestamp(dag_run_timestamp)
        )

        response = self.mwaa_api_post(data)

        result = self.decode_api_response(response)

        return result["output"]

    def get_dag_tasks_status(self, dag_name, dag_run_timestamp):
        """Gets the status of all tasks for a given dag run timestamp.
        Parameters:
            (string) Name of the DAG in question.
            (string) Timestamp of the DAG run, UTC timezone.
            Here is an example: '2023-10-19T06:23:59Z'.

        Returns:
            (dict) Status of all tasks in a given dag run.
        """
        data = "tasks states-for-dag-run {0} {1} -o json".format(
            dag_name, self.format_timestamp(dag_run_timestamp)
        )

        response = self.mwaa_api_post(data)

        result = self.decode_api_response(response)

        result_json = json.loads(result["output"])

        return result_json

    def set_variable(self, key, value):
        """Set an airflow variable.
        Parameters:
            (string) Variable key.
            (string) Variable value.

        Returns:
            (dict) Confirmation that a variable has been set.
        """
        data = f"variables set {key} {value}"

        response = self.mwaa_api_post(data)

        result = self.decode_api_response(response)

        return result

    def import_variables(self, json_path):
        """Read variables from a json file, set them in airflow.
        Parameters:
            (string) Path to local, flat json file (no nesting).

        Returns:
            (list) Responses from individual API calls.

        """
        with open(json_path, 'r') as file:
            var_dict = json.load(file)

        final = []

        for key, value in var_dict.items():
            result = self.set_variable(key, value)

            final.append(result)

        return final

    def get_variable(self, key):
        """Get an airflow variable.
        Parameters:
            (string) Variable key

        Returns:
            (dict) Value assigned to the key.
            Example:
                {'output': 'test_val\n', 'error': ''}
        """
        data = f"variables get {key}"

        response = self.mwaa_api_post(data)

        result = self.decode_api_response(response)

        return result

    def list_variables(self):
        """List all current airflow variables.
        Parameters:

        Returns:
            (list) List of value keys.
        """
        data = "variables list -o plain"

        response = self.mwaa_api_post(data)

        decoded = self.decode_api_response(response)

        result = decoded['output'].split('\n')

        return result

    def delete_variable(self, key):
        """Delete an airflow variable.
        Parameters:
            (string) Variable key

        Returns:
            (dict) Confirmation that a variable was deleted.
        """
        data = f"variables delete {key}"

        response = self.mwaa_api_post(data)

        result = self.decode_api_response(response)

        return result

    def delete_variables(self, key_list, re_pattern=None):
        """Delete a list of airflow variables.
        Parameters:
            (string) Variable key

        Returns:
            (dict) Confirmation that a variable was deleted.
        """
        final = []

        if re_pattern:
            # Generate a list of match objects and None, where no match is found.
            match_list = [re.match(re_pattern, key) for key in key_list]

            # Convert match list to boolean list, where match is True and None is False
            boolean = [match is not None for match in match_list]

            # Subset key list based on the boolean values.
            key_list = list(compress(key_list, boolean))

        for key in key_list:
            result = self.delete_variable(key)

            final.append(result)

        return final


if __name__ == "main":
    SESSION = Session(profile_name="dev-test")

    AAPI = AirflowCLI(
        session=SESSION, region_name="eu-central-1", mwaa_env_name="ffdp-mwaa-dev"
    )

    AAPI.trigger_dag("smoke_test")

    print("DAG successfully triggered.")

    DAG_DICT = AAPI.get_dag_runtimes("smoke_test")

    get_dag_tasks_status("smoke_test_dag", context.smoke_dag_run_timestamp)

    print(DAG_DICT)
