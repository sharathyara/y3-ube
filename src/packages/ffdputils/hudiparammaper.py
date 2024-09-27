def get_hudi_config(destination_bucket_name, hudi_target_db_name, hudi_target_table_name, hive_target_table_name, hudi_record_key_name, hudi_precombine_field, hudi_partition_field):
    additional_options={
            "hoodie.table.name": f"{hudi_target_table_name}",
            "hoodie.datasource.write.storage.type": "COPY_ON_WRITE",
            "hoodie.datasource.write.operation": "upsert",
            "hoodie.datasource.write.recordkey.field": f"{hudi_record_key_name}",
            "hoodie.datasource.write.precombine.field": f"{hudi_precombine_field}",
            "hoodie.datasource.write.partitionpath.field": f"{hudi_partition_field}", 
            "hoodie.datasource.write.payload.class": "org.apache.hudi.common.model.DefaultHoodieRecordPayload",
            "hoodie.datasource.write.hive_style_partitioning": "false",
            "hoodie.datasource.hive_sync.enable": "true",
            "hoodie.datasource.hive_sync.database": f"{hudi_target_db_name}",
            "hoodie.datasource.hive_sync.table": f"{hive_target_table_name}",
            "hoodie.datasource.hive_sync.partition_fields": f"{hudi_partition_field}",
            "hoodie.datasource.hive_sync.partition_extractor_class": "org.apache.hudi.hive.MultiPartKeysValueExtractor",
            "hoodie.datasource.hive_sync.use_jdbc": "false",
            "hoodie.datasource.hive_sync.mode": "hms",
            "hoodie.payload.ordering.field": f"{hudi_precombine_field}",
            "hoodie.index.type":"GLOBAL_BLOOM",
            "hoodie.cleaner.policy": "KEEP_LATEST_FILE_VERSIONS", 
            "hoodie.cleaner.fileversions.retained": 1,
            "path": f"s3://{destination_bucket_name}/hudi-cdc-tables/{hudi_target_table_name}"
        }
    return additional_options