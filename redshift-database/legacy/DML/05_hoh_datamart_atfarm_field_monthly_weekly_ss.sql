/* MAKE SURE TO EXECUTE THE UPLOAD STATEMENT IN ONE21 BEFORE EXECUTING THIS FILE */

/* hoh_datamart.atfarm_field_monthly_weekly_ss */

TRUNCATE TABLE hoh_datamart.atfarm_field_monthly_weekly_ss;

COPY hoh_datamart.atfarm_field_monthly_weekly_ss 
FROM 's3://%S3_BUCKET_NAME%/one21/atfarm_field_monthly_weekly_ss_manifest' 
IAM_ROLE '%S3_TO_REDSHIFT_COPY_ROLE%' 
FORMAT AS PARQUET SERIALIZETOJSON 
MANIFEST; 
