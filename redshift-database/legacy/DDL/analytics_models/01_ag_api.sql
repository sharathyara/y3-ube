CREATE SCHEMA IF NOT EXISTS l1_ag_api;

GRANT ALL ON SCHEMA l1_ag_api TO "IAM:ffdp-airflow";

CREATE TABLE IF NOT EXISTS l1_ag_api.fact_polaris_ghg_performed (
  event_date_time TIMESTAMP,
  event_type VARCHAR(256),
  event_id VARCHAR(256),
  country_id VARCHAR(256),
  country_name VARCHAR(256),
  region_id VARCHAR(256),
  region_name VARCHAR(256),
  field_size DOUBLE PRECISION,
  field_size_unit_id VARCHAR(256),
  standardized_field_area DOUBLE PRECISION,
  field_soil_type_id VARCHAR(256),
  field_soil_organic_matter INT,
  field_drainage_boolean BOOLEAN,
  field_ph_level DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  latitude DOUBLE PRECISION,
  crop_region_id VARCHAR(256),
  crop_type VARCHAR(256),
  crop_name VARCHAR(256),
  crop_description VARCHAR(256),
  crop_class_name VARCHAR(256),
  crop_sub_class_name VARCHAR(256),
  crop_group_name VARCHAR(256),
  crop_yield VARCHAR(256),
  crop_yield_unit_id VARCHAR(256),
  standardized_yield DOUBLE PRECISION,
  region_climate VARCHAR(256),
  region_average_temperature DOUBLE PRECISION,
  applied_products VARCHAR(10000),
  direct_energy_use VARCHAR(10000),
  machinery_use VARCHAR(10000),
  transport_use VARCHAR(10000),
  crop_protection_applications_applied VARCHAR(10000),
  emissions_co2_total DOUBLE PRECISION,
  emissions_co2_per_area DOUBLE PRECISION,
  emissions_co2_per_product DOUBLE PRECISION,
  response_success_boolean BOOLEAN,
  error_message VARCHAR(256),
  event_source VARCHAR(256)
);

ALTER TABLE l1_ag_api.fact_polaris_ghg_performed OWNER TO "IAM:ffdp-airflow";