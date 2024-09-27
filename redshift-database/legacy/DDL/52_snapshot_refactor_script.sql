---- CREATING ATFARM SCHEMA FOR ATFARM DATA----

DROP SCHEMA IF EXISTS atfarm_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS atfarm_schema;
 
GRANT ALL ON SCHEMA atfarm_schema TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm user table script

DROP TABLE IF EXISTS ffdp2_0.atfarm_users;

DROP TABLE IF EXISTS atfarm_schema.cdc_atfarm_user;

CREATE TABLE atfarm_schema.cdc_atfarm_user (
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

ALTER TABLE atfarm_schema.cdc_atfarm_user OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm farm table script

DROP TABLE IF EXISTS ffdp2_0.atfarm_farms;

DROP TABLE IF EXISTS atfarm_schema.cdc_atfarm_farm;

CREATE TABLE atfarm_schema.cdc_atfarm_farm (
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

ALTER TABLE atfarm_schema.cdc_atfarm_farm OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm field table script

DROP TABLE IF EXISTS ffdp2_0.atfarm_fields;

DROP TABLE IF EXISTS atfarm_schema.cdc_atfarm_field;

CREATE TABLE atfarm_schema.cdc_atfarm_field (
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

ALTER TABLE atfarm_schema.cdc_atfarm_field OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm farm table script

DROP TABLE IF EXISTS ffdp2_0.feature_data;

DROP TABLE IF EXISTS atfarm_schema.cdc_feature_data;

CREATE TABLE atfarm_schema.cdc_feature_data (
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

ALTER TABLE atfarm_schema.cdc_feature_data OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm user farm table script

DROP TABLE IF EXISTS ffdp2_0.atfarm_users_farms;

DROP TABLE IF EXISTS atfarm_schema.cdc_atfarm_user_farm;

CREATE TABLE atfarm_schema.cdc_atfarm_user_farm (
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

ALTER TABLE atfarm_schema.cdc_atfarm_user_farm OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm country table script

DROP TABLE IF EXISTS ffdp2_0.country_data;

DROP TABLE IF EXISTS atfarm_schema.cdc_country_data;

CREATE TABLE atfarm_schema.cdc_country_data (
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

ALTER TABLE atfarm_schema.cdc_country_data OWNER TO "IAM:ffdp-airflow";

--FFDP2_0 Atfarm user last active script

DROP TABLE IF EXISTS ffdp2_0.user_last_active_date;

DROP TABLE IF EXISTS atfarm_schema.user_last_active_date;

CREATE TABLE atfarm_schema.user_last_active_date (
  d_user_orig_id VARCHAR(512),
  last_activity_date TIMESTAMP WITH TIME ZONE,
  is_active_in_last_12months BOOLEAN,
  is_active_in_last_36months BOOLEAN
) DISTSTYLE AUTO;

ALTER TABLE atfarm_schema.user_last_active_date OWNER TO "IAM:ffdp-airflow";


---------------------------------

--create view for atfarm data

--Create View atfarm_schema.atfarm_farm

CREATE OR REPLACE VIEW atfarm_schema.atfarm_farm AS
  SELECT 
      l.id, 
      l.created, 
      l.updated, 
      l.name, 
      l.billing_contact_id, 
      l.notes, 
      l.farm_contact_id, 
      l.created_by, 
      l.last_updated_by
   FROM landing_schema.atfarm_farm l
   LEFT JOIN landing_schema.atfarm_tenant_farm n 
     ON l.id::text = n.id::text
   WHERE n.id IS NULL OR l.updated > n.updated_timestamp
 UNION ALL 
   SELECT 
     n.id, 
     n.created_timestamp AS created, 
     n.updated_timestamp AS updated, 
     n.name, 
     NULL::VARCHAR AS billing_contact_id, 
     n.notes, 
     n.farm_contact_id, 
     n.created_by, 
     n.updated_by AS last_updated_by
   FROM landing_schema.atfarm_tenant_farm n
   LEFT JOIN landing_schema.atfarm_farm l 
     ON n.id::text = l.id::text
   WHERE l.id IS NULL OR n.updated_timestamp >= l.updated
WITH NO SCHEMA BINDING;

GRANT ALL PRIVILEGES ON atfarm_schema.atfarm_farm TO "IAM:ffdp-airflow" WITH GRANT OPTION;


----------------------------------------------------------------

--Create View atfarm_schema.atfarm_user_farm

CREATE OR REPLACE VIEW atfarm_schema.atfarm_user_farm AS
  SELECT 
    l.id, 
    l.user_id, 
    l.farm_id, 
    l."role", 
    l.created, 
    l.updated, 
    CASE
      WHEN l.creator::text = 0::text THEN 'false'::character varying
      WHEN l.creator::text = 1::text THEN 'true'::character varying
      ELSE l.creator
    END AS creator, 
    NULL::VARCHAR AS created_by,
    NULL::VARCHAR AS last_updated_by
  FROM landing_schema.atfarm_user_farm l
  LEFT JOIN landing_schema.atfarm_tenant_user_farm n 
    ON l.id::text = n.id::text
  WHERE n.id IS NULL OR l.updated > n.updated_timestamp
  UNION ALL 
  SELECT 
    n.id, 
    n.user_id, 
    n.farm_id, 
    n."role", 
    n.created_timestamp AS created, 
    n.updated_timestamp AS updated, 
    n.is_user_creator AS creator, 
    n.created_by,
    n.updated_by AS last_updated_by
  FROM landing_schema.atfarm_tenant_user_farm n
  LEFT JOIN landing_schema.atfarm_user_farm l 
    ON n.id::text = l.id::text
  WHERE l.id IS NULL OR n.updated_timestamp >= l.updated
WITH NO SCHEMA BINDING;

GRANT ALL PRIVILEGES ON atfarm_schema.atfarm_user_farm TO "IAM:ffdp-airflow" WITH GRANT OPTION;

----------------------------------------------------------------

--Create View atfarm_schema.atfarm_field

CREATE OR REPLACE VIEW atfarm_schema.atfarm_field AS
  SELECT
  id::VARCHAR,
  created::TIMESTAMP WITH TIME ZONE,
  updated::TIMESTAMP WITH TIME ZONE,
  name::VARCHAR,
  farm::VARCHAR,
  country_code::VARCHAR,
  area::DOUBLE PRECISION,
  timeline_id::VARCHAR,
  archived::BOOLEAN,
  archived_at::TIMESTAMP WITH TIME ZONE,
  crop_type::VARCHAR,
  feature_data_id::VARCHAR,
  polaris_country_code_id::VARCHAR,
  polaris_crop_region_id::VARCHAR,
  created_by::VARCHAR,
  last_updated_by::VARCHAR,
  crop_type_last_updated_at::TIMESTAMP WITHOUT TIME ZONE
FROM landing_schema.atfarm_field
WITH NO SCHEMA BINDING;

GRANT ALL PRIVILEGES ON atfarm_schema.atfarm_field TO "IAM:ffdp-airflow" WITH GRANT OPTION;

----------------------------------------------------------------

--Create View atfarm_schema.atfarm_tenant_user

CREATE OR REPLACE VIEW atfarm_schema.atfarm_tenant_user AS
  SELECT
    id::VARCHAR,
    created_at::TIMESTAMP WITHOUT TIME ZONE,
    updated_at::TIMESTAMP WITHOUT TIME ZONE,
    deleted_at::TIMESTAMP WITHOUT TIME ZONE,
    country_code::VARCHAR,
    role::VARCHAR,
    farms_mapped::VARCHAR,
    yara_mkt_consent::VARCHAR,
    email::VARCHAR,
    first_name::VARCHAR,
    last_name::VARCHAR,
    migrationtimestamp::VARCHAR
FROM landing_schema.tenants_users
WITH NO SCHEMA BINDING;

GRANT ALL PRIVILEGES ON atfarm_schema.atfarm_tenant_user TO "IAM:ffdp-airflow" WITH GRANT OPTION;

----------------------------------------------------------------

--Create View atfarm_schema.atfarm_feature_data

CREATE OR REPLACE VIEW atfarm_schema.atfarm_feature_data AS
  SELECT
    id::VARCHAR,
    created::TIMESTAMP WITH TIME ZONE,
    updated::TIMESTAMP WITH TIME ZONE,
    feature::VARCHAR,
    geo_hash::VARCHAR,
    created_by::VARCHAR,
    last_updated_by::VARCHAR
  FROM landing_schema.atfarm_feature_data
  WITH NO SCHEMA BINDING;

GRANT ALL PRIVILEGES ON atfarm_schema.atfarm_feature_data TO "IAM:ffdp-airflow" WITH GRANT OPTION;

----------------------------------------------------------------

--Create View atfarm_schema.atfarm_user

CREATE OR REPLACE VIEW atfarm_schema.atfarm_user AS
  SELECT 
    derived_table1.id, 
    derived_table1.created, 
    derived_table1.updated, 
    derived_table1.cognito_identifier, 
    derived_table1.user_email,
    derived_table1.email_verified, 
    derived_table1.locale, 
    derived_table1.name, 
    derived_table1.newsletter_opt_in, 
    derived_table1.phone, 
    derived_table1.secret_access_token, 
    derived_table1.first_name, 
    derived_table1.last_name, 
    derived_table1.archived, 
    derived_table1.archived_at, 
    derived_table1."role", 
    derived_table1.created_by, 
    derived_table1.last_updated_by, 
    derived_table1.country_code, 
    CASE
        WHEN lower(derived_table1.farms_mapped::text) = 'true'::character varying::text THEN true
        WHEN lower(derived_table1.farms_mapped::text) = 'false'::character varying::text THEN false
        ELSE NULL::boolean
    END AS farms_mapped, 
    CASE
        WHEN lower(derived_table1.yara_mkt_consent::text) = 'true'::character varying::text THEN true
        WHEN lower(derived_table1.yara_mkt_consent::text) = 'false'::character varying::text THEN false
        ELSE NULL::boolean
    END AS yara_mkt_consent
  FROM ( 
    SELECT 
      l.id, 
      l.created, 
      l.updated, 
      l.cognito_identifier, 
      l.user_email, 
      l.email_verified, 
      l.locale, 
      l.name, 
      l.newsletter_opt_in, 
      l.phone, 
      l.secret_access_token, 
      l.first_name, 
      l.last_name, 
      l.archived, 
      l.archived_at, 
      CASE
        WHEN n.updated_timestamp IS NULL AND lu.updated_at IS NULL OR l.updated > GREATEST(n.updated_timestamp::timestamp with time zone, lu.updated_at::timestamp with time zone) THEN l."role"
        WHEN n.updated_timestamp IS NULL OR lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu."role"
        ELSE n."role"
      END AS "role", 
      l.created_by, 
      l.last_updated_by, 
      CASE
          WHEN n.updated_timestamp IS NULL OR lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.country_code
          ELSE n.country_code
      END AS country_code, 
      CASE
          WHEN n.updated_timestamp IS NULL OR lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.farms_mapped
          ELSE n.farms_mapped
      END AS farms_mapped, 
      CASE
          WHEN n.updated_timestamp IS NULL OR lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.yara_mkt_consent
          ELSE n.yara_mkt_consent
      END AS yara_mkt_consent
      FROM landing_schema.atfarm_user l
      LEFT JOIN landing_schema.atfarm_tenant_user n 
        ON l.id::text = n.id::text
      LEFT JOIN landing_schema.tenants_users lu 
        ON l.id::text = lu.id::text
      WHERE n.id IS NULL OR l.updated > n.updated_timestamp
    UNION ALL 
      SELECT n.id, 
        CASE
          WHEN lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.created_at::timestamp with time zone
            ELSE n.created_timestamp::timestamp with time zone
          END AS created, 
          CASE
            WHEN lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.updated_at::timestamp with time zone
            ELSE n.updated_timestamp::timestamp with time zone
          END AS updated, 
          n.cognito_identifier, 
          n.user_email, 
          CASE
            WHEN lower(n.email_verified::text) = 'true'::character varying::text THEN true
            WHEN lower(n.email_verified::text) = 'false'::character varying::text THEN false
            ELSE NULL::boolean
          END AS email_verified, 
          n.locale, 
          n.name, 
          CASE
            WHEN lower(n.newsletter_opt_in::text) = 'true'::character varying::text THEN true
            WHEN lower(n.newsletter_opt_in::text) = 'false'::character varying::text THEN false
            ELSE NULL::boolean
          END AS newsletter_opt_in, 
          n.phone, 
          n.secret_access_token, 
          n.first_name, 
          n.last_name, 
          CASE
            WHEN lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.deleted_at IS NOT NULL
            WHEN lower(n.archived::text) = 'true'::character varying::text THEN true
            WHEN lower(n.archived::text) = 'false'::character varying::text THEN false
            ELSE NULL::boolean
          END AS archived, 
          CASE
            WHEN lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.deleted_at::timestamp with time zone
            ELSE n.archived_timestamp::timestamp with time zone
          END AS archived_at, 
          CASE
            WHEN l.updated IS NULL AND lu.updated_at IS NULL OR n.updated_timestamp > GREATEST(l.updated::timestamp with time zone, lu.updated_at::timestamp with time zone) THEN n."role"
            WHEN l.updated IS NULL OR lu.updated_at IS NOT NULL AND lu.updated_at > l.updated THEN lu."role"
            ELSE l."role"
          END AS "role", 
          n.created_by, 
          n.updated_by AS last_updated_by, 
          CASE
            WHEN lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.country_code
            ELSE n.country_code
          END AS country_code, 
          CASE
            WHEN lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.farms_mapped
            ELSE n.farms_mapped
          END AS farms_mapped, 
          CASE
            WHEN lu.updated_at IS NOT NULL AND lu.updated_at > n.updated_timestamp THEN lu.yara_mkt_consent
            ELSE n.yara_mkt_consent
          END AS yara_mkt_consent
        FROM landing_schema.atfarm_tenant_user n
        LEFT JOIN landing_schema.atfarm_user l 
          ON n.id::text = l.id::text
        LEFT JOIN landing_schema.tenants_users lu 
          ON n.id::text = lu.id::text
  WHERE l.id IS NULL OR n.updated_timestamp >= l.updated
  ) derived_table1
  WITH NO SCHEMA BINDING;

GRANT ALL PRIVILEGES ON atfarm_schema.atfarm_user TO "IAM:ffdp-airflow" WITH GRANT OPTION;

-- Drop views in raw schema

DROP VIEW IF EXISTS raw_schema.atfarm_farm;

DROP VIEW IF EXISTS raw_schema.atfarm_feature_data;

DROP VIEW IF EXISTS raw_schema.atfarm_field;

DROP VIEW IF EXISTS raw_schema.atfarm_tenant_user;

DROP VIEW IF EXISTS raw_schema.atfarm_user;

DROP VIEW IF EXISTS raw_schema.atfarm_user_farm;

DROP TABLE IF EXISTS raw_schema.users_last_active;

DROP SCHEMA IF EXISTS raw_schema CASCADE;
