-- Granting permission to ffdp-airflow role

-- polaris_n_sensor_biomass_performed
GRANT SELECT ON TABLE curated_schema.polaris_n_sensor_biomass_performed TO "IAM:ffdp-airflow";

-- polaris_ndvi_performed
GRANT SELECT ON TABLE curated_schema.polaris_ndvi_performed TO "IAM:ffdp-airflow";

-- polaris_nue_performed
GRANT SELECT ON TABLE curated_schema.polaris_nue_performed TO "IAM:ffdp-airflow";

-- polaris_vra_performed
GRANT SELECT ON TABLE curated_schema.polaris_vra_performed TO "IAM:ffdp-airflow";

-- polaris_yield_estimation_performed
GRANT SELECT ON TABLE curated_schema.polaris_yield_estimation_performed TO "IAM:ffdp-airflow";