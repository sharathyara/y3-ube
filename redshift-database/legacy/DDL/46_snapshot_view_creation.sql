--Create View raw_schema.atfarm_farm

CREATE OR REPLACE VIEW raw_schema.atfarm_farm AS
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

GRANT SELECT ON raw_schema.atfarm_farm TO "IAM:ffdp-airflow";

----------------------------------------------------------------

--Create View raw_schema.atfarm_user_farm

CREATE OR REPLACE VIEW raw_schema.atfarm_user_farm AS
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

GRANT SELECT ON raw_schema.atfarm_user_farm TO "IAM:ffdp-airflow";

----------------------------------------------------------------

--Create View raw_schema.atfarm_field

CREATE OR REPLACE VIEW raw_schema.atfarm_field AS
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

GRANT SELECT ON raw_schema.atfarm_field TO "IAM:ffdp-airflow";

----------------------------------------------------------------

--Create View raw_schema.atfarm_tenant_user

CREATE OR REPLACE VIEW raw_schema.atfarm_tenant_user AS
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

GRANT SELECT ON raw_schema.atfarm_tenant_user TO "IAM:ffdp-airflow";

----------------------------------------------------------------

--Create View raw_schema.atfarm_feature_data

CREATE OR REPLACE VIEW raw_schema.atfarm_feature_data AS
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

GRANT SELECT ON raw_schema.atfarm_feature_data TO "IAM:ffdp-airflow";

----------------------------------------------------------------

--Create View raw_schema.atfarm_user

CREATE OR REPLACE VIEW raw_schema.atfarm_user AS
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

GRANT SELECT ON raw_schema.atfarm_user TO "IAM:ffdp-airflow";