--FFDP2_0 Atfarm user table script

DROP TABLE IF EXISTS ffdp2_0.atfarm_users;

CREATE TABLE ffdp2_0.atfarm_users (
  d_user_bid VARCHAR(32),
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
  valid_from TIMESTAMP WITHOUT TIME ZONE,
  is_valid BOOLEAN,
  valid_to TIMESTAMP WITHOUT TIME ZONE,
  f_migration_timestamp VARCHAR(150),
  f_is_atfarm_migrated BOOLEAN,
  f_is_irix_migrated BOOLEAN,
  f_is_new_user BOOLEAN,
  f_archived BOOLEAN,
  f_archived_at TIMESTAMP WITH TIME ZONE
) DISTSTYLE AUTO;

ALTER TABLE ffdp2_0.atfarm_users OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm farm table script

DROP TABLE IF EXISTS ffdp2_0.atfarm_farms;

CREATE TABLE ffdp2_0.atfarm_farms (
  d_farm_bid VARCHAR(32),
  d_farm_orig_id VARCHAR(108),
  f_created_at TIMESTAMP WITHOUT TIME ZONE,
  f_updated_at TIMESTAMP WITHOUT TIME ZONE,
  d_user_orig_id VARCHAR(108),
  f_user_qty BIGINT,
  f_field_qty BIGINT,
  f_farm_size INTEGER,
  d_farm_country_name VARCHAR(600),
  d_farm_country_bid VARCHAR(32),
  valid_from TIMESTAMP WITHOUT TIME ZONE,
  is_valid BOOLEAN,
  valid_to TIMESTAMP WITHOUT TIME ZONE
) DISTSTYLE AUTO;

ALTER TABLE ffdp2_0.atfarm_farms OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm field table script

DROP TABLE IF EXISTS ffdp2_0.atfarm_fields;

CREATE TABLE ffdp2_0.atfarm_fields (
  d_field_bid VARCHAR(32),
  d_field_orig_id VARCHAR(50),
  d_farm_orig_id VARCHAR(50),
  d_farm_bid VARCHAR(32),
  d_field_name VARCHAR(65535),
  d_crop_type VARCHAR(65535),
  d_field_country_name VARCHAR(600),
  d_field_country_bid VARCHAR(32),
  f_area DOUBLE PRECISION,
  d_geohash VARCHAR(65535),
  f_archived BOOLEAN,
  f_created_at TIMESTAMP WITH TIME ZONE,
  f_updated_at TIMESTAMP WITH TIME ZONE,
  d_user_orig_id VARCHAR(50),
  f_boundary_id VARCHAR(32),
  polaris_crop_region_id VARCHAR(50),
  has_boundary_data BOOLEAN,
  d_feature_data_id VARCHAR(50),
  valid_from TIMESTAMP WITHOUT TIME ZONE,
  is_valid BOOLEAN,
  valid_to TIMESTAMP WITHOUT TIME ZONE,
  d_region_id VARCHAR(108),
  d_region_name VARCHAR(600),
  d_region_translation_key VARCHAR(600),
  varda_field_id VARCHAR(500),
  varda_boundary_id VARCHAR(500),
  iou_score VARCHAR(500),
  input_based_intersection VARCHAR(500),
  output_based_intersection VARCHAR(500)
) DISTSTYLE AUTO;

ALTER TABLE ffdp2_0.atfarm_fields OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm farm table script

DROP TABLE IF EXISTS ffdp2_0.feature_data;

CREATE TABLE ffdp2_0.feature_data (
  d_feature_bid VARCHAR(32),
  d_feature_orig_id VARCHAR(50),
  f_created_at TIMESTAMP WITH TIME ZONE,
  f_updated_at TIMESTAMP WITH TIME ZONE,
  f_feature VARCHAR(65535),
  f_geo_hash VARCHAR(65535),
  d_created_by VARCHAR(50),
  d_last_updated_by VARCHAR(50),
  valid_from TIMESTAMP WITHOUT TIME ZONE,
  is_valid BOOLEAN,
  valid_to TIMESTAMP WITHOUT TIME ZONE
) DISTSTYLE AUTO;

ALTER TABLE ffdp2_0.feature_data OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm user farm table script

DROP TABLE IF EXISTS ffdp2_0.atfarm_users_farms;

CREATE TABLE ffdp2_0.atfarm_users_farms (
  d_user_farm_orig_id VARCHAR(108),
  "role" VARCHAR(96),
  f_created_at TIMESTAMP WITHOUT TIME ZONE,
  f_updated_at TIMESTAMP WITHOUT TIME ZONE,
  d_farm_bid VARCHAR(32),
  d_farm_orig_id VARCHAR(108),
  f_field_qty BIGINT,
  d_farm_country_name VARCHAR(600),
  d_farm_country_bid VARCHAR(32),
  farm_is_valid BOOLEAN,
  farm_valid_to TIMESTAMP WITHOUT TIME ZONE,
  d_user_bid VARCHAR(32),
  d_user_orig_id VARCHAR(108),
  f_user_hashed_email VARCHAR(32),
  d_user_type_bid INTEGER,
  f_is_internal_user BOOLEAN,
  d_user_country_bid VARCHAR(32),
  d_user_country_name VARCHAR(600),
  user_valid_from TIMESTAMP WITHOUT TIME ZONE,
  f_migration_timestamp VARCHAR(150),
  f_is_atfarm_migrated BOOLEAN,
  f_is_irix_migrated BOOLEAN,
  f_is_new_user BOOLEAN,
  f_is_user_archived BOOLEAN,
  f_user_archived_at TIMESTAMP WITH TIME ZONE,
  f_user_last_activity_date TIMESTAMP WITH TIME ZONE,
  f_user_is_valid BOOLEAN,
  is_valid BOOLEAN,
  valid_from TIMESTAMP WITHOUT TIME ZONE,
  d_user_farm_bid VARCHAR(32),
  valid_to TIMESTAMP WITHOUT TIME ZONE
) DISTSTYLE AUTO;

ALTER TABLE ffdp2_0.atfarm_users_farms OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm farm table script

DROP TABLE IF EXISTS ffdp2_0.country_data;

CREATE TABLE ffdp2_0.country_data (
  d_country_orig_id VARCHAR(108),
  d_country_name VARCHAR(600),
  d_country_iso_code VARCHAR(9),
  d_continent_name VARCHAR(300),
  f_in_europe_union VARCHAR(300),
  d_country_iso3_code VARCHAR(10),
  d_country_iso_standard VARCHAR(400),
  d_yara_region VARCHAR(256),
  d_yara_global_region VARCHAR(256),
  d_yara_region_new VARCHAR(256),
  valid_from TIMESTAMP WITHOUT TIME ZONE,
  d_country_bid VARCHAR(32),
  f_deleted_at TIMESTAMP WITHOUT TIME ZONE,
  is_valid BOOLEAN,
  valid_to TIMESTAMP WITHOUT TIME ZONE
) DISTSTYLE AUTO;

ALTER TABLE ffdp2_0.country_data OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm user last active script

DROP TABLE IF EXISTS ffdp2_0.user_last_active_date;

CREATE TABLE ffdp2_0.user_last_active_date (
  d_user_orig_id VARCHAR(512),
  last_activity_date TIMESTAMP WITH TIME ZONE,
  is_active_in_last_12months BOOLEAN,
  is_active_in_last_36months BOOLEAN
) DISTSTYLE AUTO;

ALTER TABLE ffdp2_0.user_last_active_date OWNER TO "IAM:ffdp-airflow";