-- liquibase formatted sql
 
--changeset sandeep_c:ATI-6926-hoh-datamart-schema-creation splitStatements:true
--comment: ATI-6926 - hoh datamart schema creation
 
CREATE SCHEMA IF NOT EXISTS hoh_datamart;
 
GRANT ALL ON SCHEMA hoh_datamart TO "IAM:ffdp-airflow";
 
-- rollback DROP SCHEMA IF EXISTS hoh_datamart;