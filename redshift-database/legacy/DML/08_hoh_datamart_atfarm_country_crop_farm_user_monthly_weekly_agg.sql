/* MAKE SURE TO EXECUTE THE UPLOAD STATEMENT IN ONE21 BEFORE EXECUTING THIS FILE */

/* hoh_datamart.atfarm_country_crop_farm_user_monthly_weekly_agg */

TRUNCATE TABLE hoh_datamart.atfarm_country_crop_farm_user_monthly_weekly_agg;

COPY hoh_datamart.atfarm_country_crop_farm_user_monthly_weekly_agg 
FROM 's3://%S3_BUCKET_NAME%/one21/atfarm_country_crop_farm_user_monthly_weekly_agg_manifest' 
IAM_ROLE '%S3_TO_REDSHIFT_COPY_ROLE%' 
FORMAT AS PARQUET SERIALIZETOJSON 
MANIFEST;