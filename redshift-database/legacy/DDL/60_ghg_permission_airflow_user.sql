-- Granting permission to ffdp-airflow role for polaris_ghg_performed in curated_schema
GRANT SELECT ON TABLE curated_schema.polaris_ghg_performed TO "IAM:ffdp-airflow";