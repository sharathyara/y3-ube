from datetime import datetime as dt


def put_to_metastore(entityTable, metaDataDF, hudi_record_key, hudi_precombine_field, hudi_table_name, list_of_fields_flat, keyword_delete, glue_logger, log_former, zip_source_name=""):
    metaDataDF.show(1)
    metaDataPDF = metaDataDF.toPandas()
    metaDataPDF.head(1)

    for idx in range(metaDataPDF.shape[0]):
        eventTypeItem = metaDataPDF['eventType'][idx] 
        entityId = metaDataPDF[hudi_record_key][idx]
        
        putItem={
            'entityId' : entityId,
            'cdcProcessedTs' : int(dt.now().timestamp() * 1000000),
            'cdcProcessedDate' : str(dt.now().date()), 
            'entityName' : hudi_record_key, 
            'hudiTableName': hudi_table_name,
            'rawFile' : metaDataPDF[list_of_fields_flat[-1]][idx],
            'eventType' : eventTypeItem
        }

        if len(zip_source_name) > 0:
            putItem['zipSourceName'] = metaDataPDF[zip_source_name][idx]
    
        if eventTypeItem in keyword_delete:
            putItem['isDeleteRequest'] = 'x'
            putItem['eventOccurenceDateTime'] = str(metaDataPDF[hudi_precombine_field][idx].to_pydatetime())
            putItem['isDeletePerformed'] = False
        glue_logger.info(log_former.get_message(f"Ingesting the metadata for {hudi_record_key}: {entityId}"))
        
        entityTable.put_item(
            Item=putItem
            )


def put_to_datalink_metastore(entityTable, metaDataDF, hudi_record_key, hudi_precombine_field, hudi_table_name,
                               keyword_delete, glue_logger, log_former, zip_source_name=""):
    metaDataDF.show(1)
    metaDataPDF = metaDataDF.toPandas()
    metaDataPDF.head(1)

    for idx in range(metaDataPDF.shape[0]):
        eventTypeItem = metaDataPDF['eventType'][idx]
        deletionRequestIdItem = metaDataPDF['deletionrequestid'][idx]
        entityId = metaDataPDF[hudi_record_key][idx]
        clientcode = metaDataPDF['clientCode'][idx]

        putItem = {
            'sourceUserId': entityId,
            'deletionRequestCreatedTs': int(dt.now().timestamp() * 1000000),
            'statusCreatedAt': str(dt.now().date()),
            'hudiTableName': hudi_table_name,
            'deletionRequestId': deletionRequestIdItem,
            'clientcode': clientcode
        }

        if len(zip_source_name) > 0:
            putItem['zipSourceName'] = metaDataPDF[zip_source_name][idx]

        if eventTypeItem in keyword_delete:
            putItem['status'] = 'RECEIVED'
            putItem['eventOccurenceDateTime'] = str(metaDataPDF[hudi_precombine_field][idx].to_pydatetime())
        glue_logger.info(log_former.get_message(f"Ingesting the metadata for {hudi_record_key}: {entityId}"))

        entityTable.put_item(
            Item=putItem
        )