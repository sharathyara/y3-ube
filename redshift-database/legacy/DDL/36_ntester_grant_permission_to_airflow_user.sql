-- Granting permission to ffdp-airflow role to read n_tester curated schema

GRANT SELECT ON TABLE curated_schema.n_tester TO "IAM:ffdp-airflow";