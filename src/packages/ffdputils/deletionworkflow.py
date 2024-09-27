from pyspark.sql.functions import lit, col, transform
from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError
from awsglue.transforms import Filter
from datetime import datetime
import json

def getSchema(s3, schemaBucket, schemaKey):
    bucket = schemaBucket
    key = schemaKey
    obj = s3.Object(bucket, key)
    body = obj.get()['Body'].read().decode('utf8')
    schema_obj = json.loads(body)
    return schema_obj


def getEntityDictForDeletion(entityTable, indexName, hudiTableName, timestamp_window, logger, log_former):
    entityDc = {} 
    itemList = [] 
    
    filterExpression = Attr("hudiTableName").eq(hudiTableName)

    if timestamp_window:
        logger.info(log_former.get_message(f"Filtering using date timestamp: {timestamp_window}"))
        filterExpression = Attr("cdcProcessedTs").gte(timestamp_window) & filterExpression 
            
    # Filtering using cdcProcessedDate/ALL and hudiTableName
    deleteEntityResponse = entityTable.query(
        IndexName=indexName,
        KeyConditionExpression=Key('isDeleteRequest').eq('x'), 
        FilterExpression=filterExpression
    )
    logger.info(log_former.get_message(str(deleteEntityResponse)))
    
    if 'Items' in deleteEntityResponse:
        for item in deleteEntityResponse['Items']:
            entityId = item['entityId']
            cdcProcessedTs = item['cdcProcessedTs']
            itemList.append(entityId)
            entityDc[entityId] = cdcProcessedTs
            
    # Checking if more data needs to be retrieved
    if 'LastEvaluatedKey' in deleteEntityResponse:
        exclusiveStartKey = deleteEntityResponse['LastEvaluatedKey']
            
        while True:
            deleteEntityResponse = entityTable.query(
                IndexName=indexName,
                KeyConditionExpression=Key('isDeleteRequest').eq('x'), 
                FilterExpression=filterExpression,
                ExclusiveStartKey = exclusiveStartKey
            )
            logger.info(log_former.get_message(str(deleteEntityResponse)))
        
            if 'Items' in deleteEntityResponse:
                for item in deleteEntityResponse['Items']:
                    entityId = item['entityId']
                    cdcProcessedTs = item['cdcProcessedTs']
                    itemList.append(entityId)
                    entityDc[entityId] = cdcProcessedTs
        
            if 'LastEvaluatedKey' in deleteEntityResponse:
                exclusiveStartKey = deleteEntityResponse['LastEvaluatedKey']
            else:
                break
            
    logger.info(log_former.get_message(f"Final list of entities for deletion '{itemList}'"))
    return entityDc


def getEntityFileDictForDeletion(entityTable, itemList, logger, log_former):
    """Retrieve filepaths"""

    entityFileDict = {}
    fileCount = 0
    
    for key in itemList:
        logger.info(log_former.get_message('Querying entityId '+ key))
        
        queryResult = entityTable.query(
            KeyConditionExpression=Key('entityId').eq(key)
        )
    
        if 'Items' in queryResult:
            itemResult = queryResult['Items']
            for item in itemResult:
                entityId = item['entityId']
                
                if ('eventTypeList') in item:
                    eventType = item['eventTypeList']
                if ('eventType') in item:
                    eventType = item['eventType']
                
                if 'Deleted' in eventType:
                    continue    # filtering out deleted - this does not contain PII data

                if (entityId in entityFileDict):
                    # prevent duplicates
                    filePathList = entityFileDict[entityId]
                    if (item['rawFile'] not in filePathList):
                        fileCount +=1
                        entityFileDict[entityId].append(item['rawFile']) 
                else:
                    fileCount +=1
                    itemFile = []
                    itemFile.append(item['rawFile'])
                    entityFileDict[entityId] = itemFile
    
    logger.info(log_former.get_message(f"Loaded raw file list: '{entityFileDict}'"))
    logger.info(log_former.get_message(f"Total count of files: '{fileCount}'"))
    return entityFileDict


def updateProcessedRecords(entityTable, entityId, cdcProcessedTs, logger, log_former):
    updateItem = entityTable.update_item(
        Key={ 
            'entityId' : entityId,
            'cdcProcessedTs': cdcProcessedTs
        },
        UpdateExpression="set #status=:s REMOVE isDeleteRequest",
        ExpressionAttributeNames={
            '#status': 'isDeletePerformed'
        },
        ExpressionAttributeValues={
            ':s': True
        },
        ReturnValues="UPDATED_NEW"
    )
    logger.info(log_former.get_message(f"Metastore updated for: '{entityId}' - '{cdcProcessedTs}'"))

    return updateItem


def anonymizePIIRecords(schemaObj, listedFields, sparkDeleteDF):
    # Allow / dismiss modification of raw file
    dataSoftDeleted = False

    for schemaItem in schemaObj:
        if schemaItem["isPIIData"]:
            fieldName = schemaItem["fieldName"]
            fieldType = schemaItem["type"]
            dataSoftDeleted = True

            if ("ArrayType" in fieldType):
                contentOfArray = schemaItem["contentOfArray"]
                contentOfArraySplit = contentOfArray.split("|")

                for contentOfArrayItem in contentOfArraySplit:
                    withFieldNameSplit = contentOfArrayItem.split(",")
                    withFieldName = withFieldNameSplit[0]
                	
                    # Apply soft-delete
                    sparkDeleteDF = sparkDeleteDF.withColumn("data",
                        col("data").withField(fieldName,
                            transform(
                                col("data."+fieldName),
                                lambda x: x.withField(withFieldName, lit("*****")))))
                continue # End ArrayType processing                

            # Process with soft-delete at 'data' level
            if (fieldName in listedFields):
                if ("ArrayType" in fieldType):
                    contentOfArray = schemaItem["contentOfArray"]
                    contentOfArraySplit = contentOfArray.split("|")
    
                    for contentOfArrayItem in contentOfArraySplit:
                        withFieldNameSplit = contentOfArrayItem.split(",")
                        withFieldName = withFieldNameSplit[0]
                    	
                    	# Apply soft-delete
                        sparkDeleteDF = sparkDeleteDF.withColumn("data",
                            col("data").withField(fieldName,
                                transform(
                                    col("data."+fieldName),
                                    lambda x: x.withField(withFieldName, lit("*****")))))
                    continue # End ArrayType processing   
                else:
                    sparkDeleteDF = sparkDeleteDF.withColumn("data",
                    col("data")
                      .withField(fieldName, lit("*****"))  
                      )
            # Apply soft-delete for the nested fields in 'data'      
            else:
                parent = schemaItem["parent"]
                parent = parent.replace("data.", "")
                fieldName = parent + "." + fieldName
                sparkDeleteDF = sparkDeleteDF.withColumn("data",
                col("data")
                  .withField(fieldName, lit("*****"))
                  )
    return dataSoftDeleted, sparkDeleteDF


def outputProcessedDF(glueContext, dynamicFrame, sparkDeleteDF, entityFieldIdName, entityId, filePath, bucketName, jobOutputRootFolder, dataSoftDeleted, logger, log_former):
    if dataSoftDeleted:
        # Filter rest of records
        filteredDynamicFrame = Filter.apply(
            frame = dynamicFrame,
            f = lambda x:x["data"][entityFieldIdName] not in [entityId]
            )
        
        sparkDataFrame = filteredDynamicFrame.toDF()

        # Merge dataframe
        if filteredDynamicFrame.count() > 0:
            sparkDataFrame = sparkDataFrame.union(sparkDeleteDF)
        else:
            sparkDataFrame = sparkDeleteDF
    
        # Reduce partitions
        outputDataFrame = sparkDataFrame.coalesce(1)
        
        # Construct target folder output 
        filePathSplit = filePath.split('/')

        targetKey = 's3a://' + bucketName + "/" + jobOutputRootFolder + "/" + entityId + "/" + filePathSplit[-5] + "/" + \
            filePathSplit[-4] + "/" +filePathSplit[-3] + "/" +filePathSplit[-2] + "/" + filePathSplit[-1]
        logger.info(log_former.get_message('Data change - writing to: ' + targetKey))
        
        # Store as avro
        glueContext.write_dynamic_frame.from_options(
            frame=dynamicFrame.fromDF(outputDataFrame, glueContext,"fromDF"),
            connection_type="s3",
            format="avro",
            connection_options={
                "path": targetKey
            }
        )
    
        logger.info(log_former.get_message('Data change - saved: ' + targetKey))
    else:
        logger.info(log_former.get_message('No data change for file: ' + filePath))
    return


def softDeleteRecord(glueContext, filePath, schemaObj, entityId, entityFieldIdName, bucketName, jobOutputRootFolder, logger, log_former):
    dynamicFrame = glueContext.create_dynamic_frame.from_options(
        connection_type="s3",
        connection_options={"paths": [filePath]},
        format="avro"
    )

    filteredDynamicFrame = dynamicFrame.filter(
        f=lambda x:x["data"][entityFieldIdName] in [entityId]
    )
    if filteredDynamicFrame.count() == 0:
        logger.info(log_former.get_message('Skipping, no record found, no change in file '+ filePath))
        return
    else:
        logger.info(log_former.get_message(f"STATS: Events count in file: '{dynamicFrame.count()}'"))
    
    sparkDeleteDF = filteredDynamicFrame.toDF()
    listedFields = sparkDeleteDF.schema['data'].dataType.names
    logger.info(log_former.get_message(f"Listed fields in data struct: '{listedFields}'"))

    dataSoftDeleted, sparkDeleteDF = anonymizePIIRecords(schemaObj, listedFields, sparkDeleteDF)

    outputProcessedDF(glueContext, dynamicFrame, sparkDeleteDF, entityFieldIdName, entityId, filePath, bucketName, jobOutputRootFolder, dataSoftDeleted, logger, log_former)
         
    return


####### METHODS FOR FILE DELETION  #######
def getFilePathKeys(entityTable, key):
    sortKeyList = {}
    queryResult = entityTable.query(
            KeyConditionExpression=Key('entityId').eq(key)
        )
    
    if 'Items' in queryResult:
        itemResult = queryResult['Items']
        for item in itemResult:
            sortKey = item['cdcProcessedTs']
            filePath = item['rawFile']
            sortKeyList[filePath] = sortKey
            
    return sortKeyList


def updateDeletedItemMoved(entityTable, entityId, cdcProcessedTs, logger, log_former):
    updateItem = entityTable.update_item(
        Key={ 
            'entityId' : entityId,
            'cdcProcessedTs': cdcProcessedTs
        },
        UpdateExpression="set #updated=:u",
        ExpressionAttributeNames={
            '#updated': 'deleteJobDate'
        },
        ExpressionAttributeValues={
            ':u' : str(datetime.now())[0:10]
        },
        ReturnValues="UPDATED_NEW"
    )
    
    logger.info(log_former.get_message(f"Metastore updated for composite key: '{entityId}' - '{cdcProcessedTs}'"))
    
    return updateItem


def addS3ObjectTag(s3_client, bucketName, source_object_key, entityId, jobName, jobRunId):
    """Set tags on S3 object""" 
    tagging = {
            'TagSet': [
                {
                    'Key': 'updatedEntityId',
                    'Value': entityId
                },
                {
                    'Key': 'updateSource',
                    'Value': jobName +" - "+ jobRunId
                },
            ]
        }
    
    put_tags_response = s3_client.put_object_tagging(
        Bucket=bucketName,
        Key=source_object_key,    
        Tagging=tagging
    )
    return


def copyFileWithTags(s3, s3_client, bucketName, source_object_key, target_object_key, entityTable, entityId, jobName, jobRunId, logger, log_former):
    try:
        # Making sure both version of avro file exist
        sourceAvroObject = s3.Object(bucketName, source_object_key)
        targetAvroObject = s3.Object(bucketName, target_object_key)
        
        filePathKeys = getFilePathKeys(entityTable, entityId)
        
        targetS3UriCalculated = 's3://' + bucketName + "/" + target_object_key
        if (targetS3UriCalculated in filePathKeys):
            updateDeletedItemMoved(entityTable, entityId, filePathKeys[targetS3UriCalculated], logger, log_former)
        
        # Get Entity Tag of object
        response = s3_client.head_object(
            Bucket=bucketName,
            Key=target_object_key
        )
        initial_target_ETag = response['ETag']
        
        addS3ObjectTag(s3_client, bucketName, source_object_key, entityId, jobName, jobRunId)
        
        # Copy avro file
        response = s3_client.copy_object(
            CopySource=bucketName + '/' + source_object_key,    # Bucket-name/path/filename
            Bucket=bucketName,                                  # Destination bucket
            Key=target_object_key                               # Destination path/filename
        )
        
        response = s3_client.head_object(
            Bucket=bucketName, 
            Key=target_object_key
        )
        altered_target_ETag = response['ETag']
        
        if altered_target_ETag == initial_target_ETag:
            logger.error(log_former.get_message('ETag from header has not been changed'))
            logger.error(log_former.get_message(str(response['ResponseMetadata']['HTTPHeaders']['content-length'])))
        
        # Delete source object 
        s3_client.delete_object(Bucket=bucketName, Key=source_object_key)
        return
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            logger.error(log_former.get_message('Object does not exists - skipping'))
        else:
            # Informing something else has gone wrong
            raise Exception("There is an issue copying updated avro files with tags")    


def moveTmpFilesToTarget(s3, s3_client, entityTable, bucketName, source_folder_root, target_raw_avro_folder, jobName, jobRunId, logger, log_former):

    bucket = s3.Bucket(bucketName)
    objectList = []
    for objects in bucket.objects.filter(Prefix=source_folder_root):
        objectList.append(objects.key)
    logger.info(log_former.get_message(f"List of S3 objects to move to target: '{objectList}'"))
    
    for source_object_key in objectList:
        object_key_split = source_object_key.split('/')
    
        target_object_key = target_raw_avro_folder + object_key_split[-6] + "/" + object_key_split[-5] + "/" + \
            object_key_split[-4] + "/" +object_key_split[-3] + "/" + object_key_split[-2] 
    
        entityId = object_key_split[-7]
    
        logger.info(log_former.get_message('Source object: ' + source_object_key))
        logger.info(log_former.get_message('Target object: ' + target_object_key))

        copyFileWithTags(s3, s3_client, bucketName, source_object_key, target_object_key, entityTable, entityId, jobName, jobRunId, logger, log_former)
