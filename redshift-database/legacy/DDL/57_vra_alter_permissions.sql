-- Altering VRA table permissions

GRANT SELECT, INSERT, UPDATE, ALTER ON TABLE curated_schema.polaris_vra_performed TO "IAM:ffdp-airflow";

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_vra_performed TO gluejob;
