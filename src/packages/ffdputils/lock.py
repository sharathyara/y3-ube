from botocore.exceptions import ClientError
import time


def aquire_lock(s3, bucket_name, prefix, glue_job_run_id, glue_logger, log_former):
    try:    
        sleep_time = 3
        while True:
            s3.Object(bucket_name, prefix).load()
            glue_logger.info(log_former.get_message(f"Waiting for lock to be released... {sleep_time}s"))
            time.sleep(sleep_time)
        return "Failed"
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            glue_logger.info(log_former.get_message("Requesting a lock"))
            object = s3.Object(bucket_name, prefix)
            object.put(Body=glue_job_run_id)
            glue_logger.info(log_former.get_message("The lock requested."))
            glue_logger.info(log_former.get_message("Approving the lock"))
            time.sleep(sleep_time)
            for obj in s3.Bucket(bucket_name).objects.filter(Prefix=prefix):
                body = obj.get()['Body'].read()
                if body != glue_job_run_id.encode('ascii'):
                    glue_logger.info(log_former.get_message(f"The lock was not approved! The job '{glue_job_run_id}' to be considered for retry"))
                    return "Retry"        
                else:
                    glue_logger.info(log_former.get_message("The lock approved."))
            return "Success"


def is_hudi_locked(s3, bucket_name, prefix, glue_job_run_id, glue_logger):
    try:
        s3.Object(bucket_name, prefix).load()
        return True
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            return False 
        

def release_lock(s3, bucket_name, prefix, glue_logger, log_former):
    glue_logger.info(log_former.get_message("Removing the lock"))
    s3.Object(bucket_name, prefix).delete()
    glue_logger.info(log_former.get_message("The lock removed."))


def release_lock_if_exists(s3, bucket_name, prefix, glue_job_run_id, glue_logger, log_former):
    try:
        glue_logger.info(log_former.get_message(f"Checking if a lock file does exist in '{bucket_name}' bucket"))
        s3.Object(bucket_name, prefix).load()
        glue_logger.info(log_former.get_message("Removing the lock file if issued by the current job"))
        for obj in s3.Bucket(bucket_name).objects.filter(Prefix=prefix):
                body = obj.get()['Body'].read()
                if body == glue_job_run_id.encode('ascii'):
                    glue_logger.info(log_former.get_message("Removing the lock file"))
                    s3.Object(bucket_name, prefix).delete()
                    glue_logger.info(log_former.get_message("The lock file was removed."))
                    return "Success"
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            return "Success" 
        glue_logger.error(log_former.get_message(f"Error encountered operating with s3 objects: {str(e)}"))
        return "Failure"
    except Exception as e:
        glue_logger.error(log_former.get_message(f"Error encountered while removing lock file: {str(e)}"))
        return "Failure"

    
def release_notification_lock(s3, bucket_name, prefix, glue_logger, log_former):
    """
    This method is used to drop the processing.lock file created.
    Params:
    - s3: S3 boto client
    - bucket_name: S3 curated bucket name
    - prefix: The processing.lock file S3 path
    - glue_logger: The Glue Logger
    """
    glue_logger.info(log_former.get_message("Removing the notification lock"))
    s3.Object(bucket_name, prefix).delete()
    glue_logger.info(log_former.get_message("The notification lock removed."))


def remove_processed_notification(s3, bucket_name, prefix, reference_files_processed, glue_logger, log_former):
    for file in reference_files_processed:
        glue_logger.info(log_former.get_message(f'Removing the notification file: "{file}"'))
        s3.Object(bucket_name, (prefix + file)).delete()
        glue_logger.info(log_former.get_message("The notification file removed."))


def put_trigger_file(s3, bucket_name, prefix, glue_job_run_id, glue_logger, log_former):
    glue_logger.info(log_former.get_message(f'Creating a trigger file {prefix} in bucket {bucket_name}'))
    object = s3.Object(bucket_name, prefix)
    object.put(Body=glue_job_run_id)
    glue_logger.info(log_former.get_message("The trigger file created."))
    return "Success"
