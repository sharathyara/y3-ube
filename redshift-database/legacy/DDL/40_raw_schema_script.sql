---- CREATING RAW SCHEMA FOR ATFARM DATA----

DROP SCHEMA IF EXISTS raw_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS raw_schema;
 
GRANT ALL ON SCHEMA raw_schema TO "IAM:ffdp-airflow";

-- raw_schema.users_last_active

DROP TABLE IF EXISTS raw_schema.users_last_active;

CREATE TABLE IF NOT EXISTS raw_schema.users_last_active
(
  d_user_orig_id VARCHAR(512),
  last_activity_date TIMESTAMP WITH TIME ZONE
) DISTSTYLE AUTO;

ALTER TABLE raw_schema.users_last_active OWNER TO "IAM:ffdp-airflow";
