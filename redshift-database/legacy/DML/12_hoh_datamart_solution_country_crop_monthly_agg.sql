/* MAKE SURE TO EXECUTE THE UPLOAD STATEMENT IN ONE21 BEFORE EXECUTING THIS FILE */

/* hoh_datamart.solution_country_crop_monthly_agg */

TRUNCATE TABLE hoh_datamart.solution_country_crop_monthly_agg;

COPY hoh_datamart.solution_country_crop_monthly_agg 
FROM 's3://%S3_BUCKET_NAME%/one21/solution_country_crop_monthly_agg_manifest' 
IAM_ROLE '%S3_TO_REDSHIFT_COPY_ROLE%' 
FORMAT AS PARQUET SERIALIZETOJSON 
MANIFEST;