--Provide airflow user 

GRANT ALL PRIVILEGES ON raw_schema.atfarm_user TO "IAM:ffdp-airflow" WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON raw_schema.atfarm_farm TO "IAM:ffdp-airflow" WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON raw_schema.atfarm_feature_data TO "IAM:ffdp-airflow" WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON raw_schema.atfarm_field TO "IAM:ffdp-airflow" WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON raw_schema.atfarm_tenant_user TO "IAM:ffdp-airflow" WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON raw_schema.atfarm_user_farm TO "IAM:ffdp-airflow" WITH GRANT OPTION;