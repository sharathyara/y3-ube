--adding new attribute feature_createdat to field table
ALTER TABLE ffdp2_0.field
DROP COLUMN feature_createdat;

ALTER TABLE ffdp2_0.field
ADD COLUMN feature_createdat TIMESTAMP WITHOUT TIME ZONE;

ALTER TABLE ffdp2_0.field OWNER TO "IAM:ffdp-airflow";