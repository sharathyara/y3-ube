-- liquibase formatted sql

--changeset viktoras_c:ATI-6223-adding-segment-user-table splitStatements:true runOnChange:true
--comment: ATI-6223 - create user table with schema
CREATE SCHEMA IF NOT EXISTS segment_map;

DROP TABLE IF EXISTS segment_map.segment_user;

CREATE TABLE IF NOT EXISTS segment_map.segment_user
(
     anonymous_id VARCHAR(255),
     user_id VARCHAR(255),
     segment_id VARCHAR(255),
     received_at_date DATE, 
     event VARCHAR(255)
);

GRANT USAGE ON SCHEMA segment_map TO "IAM:ffdp-airflow";

GRANT ALL ON SCHEMA segment_map TO "IAM:ffdp-airflow";

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE segment_map.segment_user TO "IAM:ffdp-airflow";


-- rollback DROP TABLE IF EXISTS segment_map.segment_user;
-- rollback DROP SCHEMA IF EXISTS segment_map;