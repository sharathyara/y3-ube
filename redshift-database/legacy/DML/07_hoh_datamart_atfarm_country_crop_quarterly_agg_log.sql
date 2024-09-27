/* MAKE SURE TO EXECUTE THE UPLOAD STATEMENT IN ONE21 BEFORE EXECUTING THIS FILE */

/* hoh_datamart.atfarm_country_crop_quarterly_agg_log */

TRUNCATE TABLE hoh_datamart.atfarm_country_crop_quarterly_agg_log;

COPY hoh_datamart.atfarm_country_crop_quarterly_agg_log 
FROM 's3://%S3_BUCKET_NAME%/one21/atfarm_country_crop_quarterly_agg_log/atfarm_country_crop_quarterly_agg_log_manifest' 
IAM_ROLE '%S3_TO_REDSHIFT_COPY_ROLE%' 
FORMAT AS PARQUET SERIALIZETOJSON 
MANIFEST;
