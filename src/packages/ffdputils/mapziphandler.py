from botocore.exceptions import ClientError
from datetime import datetime
from zipfile import ZipFile
from io import BytesIO
import time


def lock_extracted(s3, bucket_name, zip_file_key, lock_file_key, glue_job_run_id, logger, log_former):
    try:
        sleep_time = 3
        is_zip_present = False
        s3.Object(bucket_name, zip_file_key).load()
        is_zip_present = True
        logger.info(log_former.get_message(f"The Zip is present for Map Event"))
        
        s3.Object(bucket_name, lock_file_key).load()
        logger.info(log_former.get_message(f"The lock is present for Zip"))
        return "Present"
    except ClientError as e:
        if e.response['Error']['Code'] == "404" and is_zip_present:
            logger.info(log_former.get_message("Requesting a lock for zip folder"))
            object = s3.Object(bucket_name, lock_file_key)
            logger.info(log_former.get_message(f"Requesting a lock in {bucket_name}/{lock_file_key}"))
            object.put(Body=glue_job_run_id)
            logger.info(log_former.get_message("The lock requested."))
            logger.info(log_former.get_message("Approving the lock for zip folder"))
            time.sleep(sleep_time)
            for obj in s3.Bucket(bucket_name).objects.filter(Prefix=lock_file_key):
                body = obj.get()['Body'].read()
                if body != glue_job_run_id.encode('ascii'):
                    logger.info(log_former.get_message(f"The lock was not approved! The job '{glue_job_run_id}' to be considered for retry"))
                    return "Retry"        
                else:
                    logger.info(log_former.get_message("The lock approved."))
            return "Success"
        else:
            logger.info(log_former.get_message(f"No Zip found"))
            return "NoZip"


def extract_map_zip(s3, map_bucket_name, map_extraction_folder, lock_file_name, zip_source_attribute_name, mapRecordsDF, glue_job_run_id, logger, log_former):
    zip_extension = ".zip" 
    mapRecordsPDF = mapRecordsDF.toPandas()
    for idx in range(mapRecordsPDF.shape[0]):
        map_zip_file_name = mapRecordsPDF[zip_source_attribute_name][idx]
        logger.info(log_former.get_message(f"The 'sourceFile_name' is '{map_zip_file_name}'"))
        if map_zip_file_name is not None:
            zip_file_path_list = map_zip_file_name.split("/")
            zip_file_key = map_zip_file_name
            
            map_files_path_prefix = f"{map_extraction_folder}{(map_zip_file_name.replace(zip_file_path_list[0], '')).replace(zip_extension, '')}"
            lock_file_key = f"{map_files_path_prefix}/{lock_file_name}"
            if lock_extracted(s3, map_bucket_name, zip_file_key, lock_file_key, glue_job_run_id, logger, log_former) == 'Success':
                logger.info(log_former.get_message(f"Unzipping '{zip_file_path_list[-1]}' file"))
                zip_obj = s3.Object(bucket_name=map_bucket_name, key=zip_file_key)
                buffer = BytesIO(zip_obj.get()["Body"].read())
                
                z = ZipFile(buffer)
                for filename in z.namelist():
                    s3.meta.client.upload_fileobj(
                        z.open(filename),
                        Bucket=map_bucket_name,
                        Key=f"{map_files_path_prefix}/{filename}"
                    )   


def validate_map_files(spark, s3_client, map_bucket_name, map_extraction_folder_name, map_source_attribute_name, map_file_attribute_name, file_location_label, file_size_label, mapRecordsDF, logger, log_former):
    zip_extension = '.zip'
    tag_validation_key = "is_validated_by_map_event"
    tag_validation_value = "True"
    tag_timestamp_key = "tag_created_timestamp"
    
    mapRecordsPDF = mapRecordsDF.toPandas()
    mapRecordsPDF[file_location_label] = mapRecordsPDF[file_location_label].astype(str)
    mapRecordsPDF[file_size_label] = mapRecordsPDF[file_size_label].astype(int)  
    for idx in range(mapRecordsPDF.shape[0]):
        map_source_file_name = mapRecordsPDF[map_source_attribute_name][idx]
        logger.info(log_former.get_message(f"The map source file name is '{map_source_file_name}'"))
        if map_source_file_name is not None:
            map_file_name = mapRecordsPDF[map_file_attribute_name][idx]
            map_file_key = f"{map_extraction_folder_name}/{(map_source_file_name.split('/'))[-3]}/{(map_source_file_name.split('/'))[-2]}/{(map_source_file_name.split('/'))[-1].replace(zip_extension, '')}/{map_file_name}"
            try:
                response = s3_client.head_object(Bucket=map_bucket_name, Key=map_file_key)
                mapRecordsPDF.at[idx, file_location_label] = f"s3://{map_bucket_name}/{map_file_key}"
                mapRecordsPDF.at[idx, file_size_label] = response['ContentLength']
                logger.info(log_former.get_message(f" The map file located in 's3://{map_bucket_name}/{map_file_key}' was validated"))
                current_timestamp = datetime.now().isoformat()
                s3_client.put_object_tagging(
                    Bucket=map_bucket_name,
                    Key=map_file_key,
                    Tagging={
                        'TagSet': [
                            {
                                'Key': tag_validation_key,
                                'Value': tag_validation_value
                            },
                            {
                                'Key': tag_timestamp_key,
                                'Value': current_timestamp 
                            }
                        ]
                    }
                )
                logger.info(log_former.get_message(f" The map file was tagged"))
            except ClientError as e:
                if e.response['Error']['Code'] == "404":
                    logger.info(log_former.get_message(f"The map file not found for the file key: 's3://{map_bucket_name}/{map_file_key}'!"))
            map_file_name = ""
            map_file_key = ""
        map_source_file_name = None  
    mapRecordsValidatedDF = spark.createDataFrame(mapRecordsPDF)  
    return mapRecordsValidatedDF