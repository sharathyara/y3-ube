CREATE SCHEMA IF NOT EXISTS l1_polaris_attributes;

GRANT ALL ON SCHEMA l1_polaris_attributes TO "IAM:ffdp-airflow";

CREATE TABLE IF NOT EXISTS l1_polaris_attributes.dim_crop (
  crop_region_id VARCHAR(256),
  crop_description_id VARCHAR(256),
  country_id VARCHAR(256),
  region_id VARCHAR(256),
  crop_type VARCHAR(256),
  crop_name VARCHAR(256),
  crop_description VARCHAR(256),
  crop_class_id VARCHAR(256),
  crop_class_name VARCHAR(256),
  crop_sub_class_id VARCHAR(256),
  crop_sub_class_name VARCHAR(256),
  crop_group_id VARCHAR(256),
  crop_group_name VARCHAR(256)
);

ALTER TABLE l1_polaris_attributes.dim_crop OWNER TO "IAM:ffdp-airflow";

CREATE TABLE IF NOT EXISTS l1_polaris_attributes.dim_country (
  country_id VARCHAR(256),
  country_name VARCHAR(256) 
);

ALTER TABLE l1_polaris_attributes.dim_country OWNER TO "IAM:ffdp-airflow";

CREATE TABLE IF NOT EXISTS l1_polaris_attributes.dim_region (
  region_id VARCHAR(256),
  region_name VARCHAR(256)
);

ALTER TABLE l1_polaris_attributes.dim_region OWNER TO "IAM:ffdp-airflow";

CREATE TABLE IF NOT EXISTS l1_polaris_attributes.dim_unit (
  unit_id VARCHAR(256),
  unit_name VARCHAR(256),
  convert_to_unit_id VARCHAR(256),
  unit_size_multiplier DECIMAL(18, 6)    
);

ALTER TABLE l1_polaris_attributes.dim_unit OWNER TO "IAM:ffdp-airflow";
