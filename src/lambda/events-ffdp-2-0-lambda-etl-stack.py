import urllib.parse
import boto3
from botocore.exceptions import ClientError
import random as rnd
import json
import time
import os


def register_file(s3, bucket_name, prefix, new_object_name, s3_full_path):
     object = s3.Object(bucket_name, (prefix + new_object_name))
     object.put(Body=s3_full_path)


def set_processing_lock(s3, bucket_name, prefix, lock_file_name, \
    new_object_name):
    try:
        print(bucket_name, prefix, lock_file_name)
        s3.Object(bucket_name, (prefix + lock_file_name)).load()
        print("failing to lock as lock is already present")
        return False
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("Requesting a lock")
            object = s3.Object(bucket_name, (prefix + lock_file_name))
            object.put(Body = new_object_name)
            print("The lock requested.")
            print("Approving the lock")
            time.sleep(2)
            for obj in s3.Bucket(bucket_name).objects\
                .filter(Prefix = (prefix + lock_file_name)):
                body = obj.get()['Body'].read()
                if body != new_object_name.encode('ascii'):
                    print(f"The lock was not approved!")
                    return False        
                else:
                    print("The lock approved.")
            return True


def lambda_handler(event, context):

    client = boto3.client('glue')
    s3 = boto3.resource('s3')   
    
    parameters_bucket = os.environ['PARAMETERSBUCKET']

    message_count = len(event['Records'])
    print(f"Event got {message_count} message(s) to process")

    for msg in event['Records']:
        event_body = json.loads(msg['body']) 
        s3_full_path = "s3://%s/%s" % \
            (event_body['Records'][0]['s3']['bucket']['name'], \
                urllib.parse.unquote_plus(event_body['Records'][0]['s3']['object']['key'], \
                    encoding = 'utf-8'))
        entity_name = urllib.parse.unquote_plus(event_body['Records'][0]['s3']['object']['key'], \
                    encoding = 'utf-8').split('/')[0]
        
        try:
            body = ""
            for obj in s3.Bucket(parameters_bucket).objects.filter(Prefix=f"parameters/{entity_name}_parameters.json"):
                body = obj.get()['Body'].read().decode('utf8')
        except ClientError as e:
            if e.response['Error']['Code'] == "404":
                print(f"File {entity_name}_parameters.json was not found")
                raise(f"File {entity_name}_parameters.json was not found")
                
        entity_parameters = json.loads(body)

        bucket_name = entity_parameters["entity_source_bucket_name"]
        glue_job_name = entity_parameters["glue_job_name"]       
        processing_concurrency = entity_parameters["glue_concurrency"]
        processing_lists = list(range(1, (int(processing_concurrency) + 1)))
        processing_list_no = rnd.choice(processing_lists)
        processing_list_folder_name = entity_parameters["entity_processing_list_folder_name"]
        
        hudi_table_name = entity_parameters["hudi_table_name"]
        prefix = f"{processing_list_folder_name}/processing-list{processing_list_no}/"
            
        new_object_name = s3_full_path.split("/")[-1]
        print(s3_full_path)
    
        s3 = boto3.resource('s3')
        register_file(s3, bucket_name, prefix, new_object_name, s3_full_path)
    
        s3_full_notification_path = "s3://" + bucket_name + "/" + prefix
        if set_processing_lock(s3, bucket_name, prefix, entity_parameters["entity_lock_file_name"], \
            new_object_name):
            myNewJobRun = client.start_job_run(JobName = glue_job_name, \
                Arguments = {'--s3_object': s3_full_notification_path, \
                '--hudi_table_name': hudi_table_name, '--message_event_types': entity_parameters["entity_event_types"], \
                '--hudi_record_key': entity_parameters["hudi_record_key"], '--hudi_precombine_field': entity_parameters["hudi_precombine_field"], \
                '--hudi_partition_field': entity_parameters["hudi_partition_field"], "--metastore_table_name": entity_parameters["metastore_table_name"], \
                '--batch_max_limit': str(entity_parameters["glue_batch_max_limit"]), '--data_schema_location': entity_parameters["entity_schema_location"]})
            print('success')
        
    return {
        'statusCode': 200,
        'body': json.dumps(f'message_count Glue Job(s) "{glue_job_name}" triggered')
    }