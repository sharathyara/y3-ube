-- Granting Permissions to FFDP airflow user for all segment tables

GRANT ALL ON SCHEMA segment_atfarm_mobile_app TO "IAM:ffdp-airflow";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA segment_atfarm_mobile_app TO "IAM:ffdp-airflow" WITH GRANT OPTION;

GRANT ALL ON SCHEMA segment_atfarm_web TO "IAM:ffdp-airflow";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA segment_atfarm_web TO "IAM:ffdp-airflow" WITH GRANT OPTION;

GRANT ALL ON SCHEMA segment_one21_backend_service TO "IAM:ffdp-airflow";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA segment_one21_backend_service TO "IAM:ffdp-airflow" WITH GRANT OPTION;

GRANT ALL ON SCHEMA segment_one21_web TO "IAM:ffdp-airflow";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA segment_one21_web TO "IAM:ffdp-airflow" WITH GRANT OPTION;
