/* MAKE SURE TO EXECUTE THE UPLOAD STATEMENT IN ONE21 BEFORE EXECUTING THIS FILE */

/* hoh_datamart.solution_country_crop_nd_agg_long */

TRUNCATE TABLE hoh_datamart.solution_country_crop_nd_agg_long;

COPY hoh_datamart.solution_country_crop_nd_agg_long 
FROM 's3://%S3_BUCKET_NAME%/one21/solution_country_crop_nd_agg_long_manifest' 
IAM_ROLE '%S3_TO_REDSHIFT_COPY_ROLE%' 
FORMAT AS PARQUET SERIALIZETOJSON 
MANIFEST;