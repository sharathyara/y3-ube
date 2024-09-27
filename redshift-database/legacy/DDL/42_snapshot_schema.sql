---- CREATING SNAPSHOT SCHEMA FOR ATFARM DATA----

DROP SCHEMA IF EXISTS snapshot_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS snapshot_schema;
 
GRANT ALL ON SCHEMA snapshot_schema TO "IAM:ffdp-airflow";

-- snapshot_schema.snap_country

DROP TABLE IF EXISTS snapshot_schema.snap_country;

CREATE TABLE IF NOT EXISTS snapshot_schema.snap_country
(
  d_country_orig_id VARCHAR(108),
  d_country_name VARCHAR(600),
  d_country_iso_code VARCHAR(9),
  deleted TIMESTAMP WITHOUT TIME ZONE,
  d_continent_name VARCHAR(300),
  f_in_europe_union VARCHAR(300),
  d_country_iso3_code VARCHAR(10),
  d_country_iso_standard VARCHAR(400),
  d_yara_region VARCHAR(256),
  d_yara_global_region VARCHAR(256),
  dbt_scd_id VARCHAR(32),
  dbt_updated_at TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_from TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_to TIMESTAMP WITHOUT TIME ZONE,
  d_yara_region_new VARCHAR(256)
) DISTSTYLE AUTO;

ALTER TABLE snapshot_schema.snap_country OWNER TO "IAM:ffdp-airflow";


-- snapshot_schema.snap_farm

DROP TABLE IF EXISTS snapshot_schema.snap_farm;

CREATE TABLE IF NOT EXISTS snapshot_schema.snap_farm
(
  d_farm_orig_id VARCHAR(108),
  f_created_at TIMESTAMP WITHOUT TIME ZONE,
  f_updated_at TIMESTAMP WITHOUT TIME ZONE,
  d_user_orig_id VARCHAR(108),
  f_user_qty BIGINT,
  f_field_qty BIGINT,
  f_farm_size INTEGER,
  f_farm_size_rounded INTEGER,
  d_farm_country_name VARCHAR(600),
  d_farm_country_bid VARCHAR(32),
  dbt_scd_id VARCHAR(32),
  dbt_updated_at TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_from TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_to TIMESTAMP WITHOUT TIME ZONE
) DISTSTYLE AUTO;

ALTER TABLE snapshot_schema.snap_farm OWNER TO "IAM:ffdp-airflow";


-- snapshot_schema.snap_feature_data

DROP TABLE IF EXISTS snapshot_schema.snap_feature_data;

CREATE TABLE IF NOT EXISTS snapshot_schema.snap_feature_data
(
  d_feature_orig_id VARCHAR(50),
  f_created_at TIMESTAMP WITH TIME ZONE,
  f_updated_at TIMESTAMP WITH TIME ZONE,
  f_feature VARCHAR(65535),
  f_geo_hash VARCHAR(65535),
  d_created_by VARCHAR(50),
  d_last_updated_by VARCHAR(50),
  dbt_scd_id VARCHAR(32),
  dbt_updated_at TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_from TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_to TIMESTAMP WITHOUT TIME ZONE
) DISTSTYLE AUTO;

ALTER TABLE snapshot_schema.snap_feature_data OWNER TO "IAM:ffdp-airflow";


-- snapshot_schema.snap_field

DROP TABLE IF EXISTS snapshot_schema.snap_field;

CREATE TABLE IF NOT EXISTS snapshot_schema.snap_field
(
  d_field_orig_id VARCHAR(50),
  d_farm_orig_id VARCHAR(50),
  d_farm_bid VARCHAR(32),
  d_field_name VARCHAR(65535),
  d_crop_type VARCHAR(65535),
  d_field_country_bid VARCHAR(32),
  d_field_country_name VARCHAR(600),
  f_area DOUBLE PRECISION,
  d_geohash VARCHAR(65535),
  f_geojson VARCHAR(65535),
  f_archived BOOLEAN,
  f_created_at TIMESTAMP WITH TIME ZONE,
  f_updated_at TIMESTAMP WITH TIME ZONE,
  d_user_orig_id VARCHAR(50),
  dbt_scd_id VARCHAR(32),
  dbt_updated_at TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_from TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_to TIMESTAMP WITHOUT TIME ZONE,
  f_boundary_id VARCHAR(32),
  f_field_boundary VARCHAR(65535),
  d_feature_data_id VARCHAR(50),
  d_polaris_crop_region_id VARCHAR(50)
) DISTSTYLE AUTO;

ALTER TABLE snapshot_schema.snap_field OWNER TO "IAM:ffdp-airflow";


-- snapshot_schema.snap_user

DROP TABLE IF EXISTS snapshot_schema.snap_user;

CREATE TABLE IF NOT EXISTS snapshot_schema.snap_user
(
  d_user_orig_id VARCHAR(108),
  f_created_at TIMESTAMP WITH TIME ZONE,
  f_updated_at TIMESTAMP WITH TIME ZONE,
  f_newsletter_opt_in BOOLEAN,
  f_user_hashed_email VARCHAR(32),
  d_user_type_bid INTEGER,
  f_is_internal_user BOOLEAN,
  f_email_verified BOOLEAN,
  f_user_locale VARCHAR(105),
  d_user_country_bid VARCHAR(32),
  d_user_country_name VARCHAR(600),
  d_country_iso_code VARCHAR(24000),
  f_migration_timestamp VARCHAR(150),
  f_is_atfarm_migrated BOOLEAN,
  f_is_irix_migrated BOOLEAN,
  f_is_new_user BOOLEAN,
  f_archived BOOLEAN,
  f_archived_at TIMESTAMP WITH TIME ZONE,
  dbt_scd_id VARCHAR(32),
  dbt_updated_at TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_from TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_to TIMESTAMP WITHOUT TIME ZONE
) DISTSTYLE AUTO;

ALTER TABLE snapshot_schema.snap_user OWNER TO "IAM:ffdp-airflow";


-- snapshot_schema.snap_user_farm

DROP TABLE IF EXISTS snapshot_schema.snap_user_farm;

CREATE TABLE IF NOT EXISTS snapshot_schema.snap_user_farm
(
  user_id VARCHAR(108),
  farm_id VARCHAR(108),
  "role" VARCHAR(96),
  created TIMESTAMP WITHOUT TIME ZONE,
  updated TIMESTAMP WITHOUT TIME ZONE,
  creator BOOLEAN,
  created_by VARCHAR(108),
  last_updated_by VARCHAR(108),
  dbt_scd_id VARCHAR(32),
  dbt_updated_at TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_from TIMESTAMP WITHOUT TIME ZONE,
  dbt_valid_to TIMESTAMP WITHOUT TIME ZONE,
  id VARCHAR(108)
) DISTSTYLE AUTO;

ALTER TABLE snapshot_schema.snap_user_farm OWNER TO "IAM:ffdp-airflow";
