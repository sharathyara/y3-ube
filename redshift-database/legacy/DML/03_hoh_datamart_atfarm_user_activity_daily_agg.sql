/* MAKE SURE TO EXECUTE THE UPLOAD STATEMENT IN ONE21 BEFORE EXECUTING THIS FILE */

/* hoh_datamart.atfarm_user_activity_daily_agg */

TRUNCATE TABLE hoh_datamart.atfarm_user_activity_daily_agg;

COPY hoh_datamart.atfarm_user_activity_daily_agg 
FROM 's3://%S3_BUCKET_NAME%/one21/atfarm_user_activity_daily_agg_manifest' 
IAM_ROLE '%S3_TO_REDSHIFT_COPY_ROLE%' 
FORMAT AS PARQUET SERIALIZETOJSON 
MANIFEST;
