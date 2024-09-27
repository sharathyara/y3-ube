/* MAKE SURE TO EXECUTE THE UPLOAD STATEMENT IN ONE21 BEFORE EXECUTING THIS FILE */

/* hoh_datamart.corporate_reporting_solution_field_monthly */

TRUNCATE TABLE hoh_datamart.corporate_reporting_solution_field_monthly;

COPY hoh_datamart.corporate_reporting_solution_field_monthly 
FROM 's3://%S3_BUCKET_NAME%/one21/corporate_reporting_solution_field_monthly_manifest' 
IAM_ROLE '%S3_TO_REDSHIFT_COPY_ROLE%' 
FORMAT AS PARQUET SERIALIZETOJSON 
MANIFEST;