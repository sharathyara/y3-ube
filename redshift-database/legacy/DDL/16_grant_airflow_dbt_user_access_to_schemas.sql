/*
  This SQL script grants necessary permissions to the 'IAM:ffdp-airflow' user in Amazon Redshift
  to support data transformation tasks using DBT.
*/

-- Step 1: Grant USAGE permission on the 'curated_schema' schema to 'IAM:ffdp-airflow'.
-- This allows 'IAM:ffdp-airflow' to access the 'curated_schema', which serves as the source for DBT.
GRANT USAGE ON SCHEMA curated_schema TO "IAM:ffdp-airflow";
-- This allows 'IAM:ffdp-airflow' to read data from the tables in 'curated_schema'.
GRANT SELECT ON ALL TABLES IN SCHEMA curated_schema TO "IAM:ffdp-airflow";




-- Step 2: Grant CREATE and USAGE permissions on the 'ffdp2_0' schema to 'IAM:ffdp-airflow'.
-- This allows 'IAM:ffdp-airflow' to create objects in the 'ffdp2_0' schema.
GRANT CREATE ON SCHEMA ffdp2_0 TO "IAM:ffdp-airflow";
GRANT USAGE ON SCHEMA ffdp2_0 TO "IAM:ffdp-airflow";

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ffdp2_0 TO "IAM:ffdp-airflow";

-- Step 3: Change ownership for the tables in the ffdp2_0 schema to 'IAM:ffdp-airflow'.
-- This is necessary for DBT user to be the owner of tables to perform transformations.
ALTER TABLE ffdp2_0.growth_scale_stage OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.analysis_sample OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.user_active OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.role OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.subscription OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.country OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.analysis_group OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.persona OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.analysis_order_interpretation_result OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.sample_type OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.organization OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.region OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.user OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.organization_user OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.analysis_order OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.analysis_type OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.analysis_sample_group OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.farm OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.field OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.crop OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.crop_nutrition_plan OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.users_farms OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.season OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.photo_analysis OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.vra OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.analysisorder_result OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.n_tester OWNER TO "IAM:ffdp-airflow";
ALTER TABLE ffdp2_0.map OWNER TO "IAM:ffdp-airflow";

-- next step: In the MWAA dbt_ffdp DAG, add a task that executes the following grant statement
-- to grant permissions to github_actions_user with grant option, as after transferring the ownership
-- to IAM:ffdp-airflow user, the github_actions_user's permissions will be wiped out.
-- The grants have to be executed via the airflow user.
--GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ffdp2_0 TO github_actions_user WITH GRANT OPTION;
