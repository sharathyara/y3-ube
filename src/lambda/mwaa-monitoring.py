import json
import boto3
import os
from datetime import datetime
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    
    client_mwaa = boto3.client('mwaa')
    client_sns = boto3.client('sns')
    client_s3 = boto3.client('s3')
    
    bucket_name = os.environ['bucket_name']
    object_key = os.environ['object_key']
    sns_topic_arn = os.environ['sns_topic_arn']
    environment_name = os.environ['environment_name']
    
    #try to fetch data from S3
    try:
        s3_data = ''
        s3_response = client_s3.get_object(Bucket = bucket_name, Key = object_key)
        s3_data = s3_response["Body"].read().decode('utf')
        s3_data_json = json.loads(s3_data)
        
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            print(f"File was not found")
        
    mwaa_environment_list = client_mwaa.list_environments()
    mwaa_available_environment = mwaa_environment_list['Environments']
    print(f"The environments available: {mwaa_available_environment}")
    
    for mwaa_environment in mwaa_available_environment:
        
        environment_details = client_mwaa.get_environment(Name = mwaa_environment)
        environment_state = environment_details['Environment']['Status']
        
        for s3_environment in range(len(s3_data_json)):
            
            if(environment_state != s3_data_json[s3_environment]['environmentStatus'] and mwaa_environment == s3_data_json[s3_environment]['environmentName']):
        
                # Note: the datetime has been formatted, so that it is aligned to the teams notification
                time= environment_details['ResponseMetadata']['HTTPHeaders']['date']
                date_time = datetime.strptime(time, '%a, %d %b %Y %H:%M:%S %Z')
                date_time_format = str(date_time.date())+"T"+str(date_time.time())+"Z"
            
                message = f"The state of the environment has been changed from {s3_data_json[s3_environment]['environmentStatus']} to {environment_details['Environment']['Status']}"
        
                response = {
                    "StateChangeTime": date_time_format,
                    "AlarmName": environment_details['Environment']['Name'],
                    "AlarmDescription": None,
                    "NewStateReason": message,
                    "jobRunId":environment_details['ResponseMetadata']['RequestId'],
                    "state":environment_details['Environment']['Status'],
                    "Trigger":{
                        "Dimensions":[{
                            "value":environment_details['Environment']['Name'],
                            "name":"EnvironmentName"
                        }]
                    }
                }
    
                #send notificatio to SNS
                environment_change_json = json.dumps(response)
                client_sns.publish(TopicArn = sns_topic_arn, Message = environment_change_json, Subject='Alarm')
                
                #upload current state to the S3 bucket
                s3_data_json[s3_environment]['environmentStatus'] = environment_state
                current_utc_time = str(datetime.utcnow())
                s3_data_json[s3_environment]['lastStatusChange'] = current_utc_time
                s3_upload = json.dumps(s3_data_json)
                client_s3.put_object(Bucket=bucket_name, Key=object_key, Body=s3_upload)
