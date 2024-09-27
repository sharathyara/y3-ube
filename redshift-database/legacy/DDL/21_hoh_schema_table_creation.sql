---- CREATING HOH SCHEMA ----

CREATE SCHEMA IF NOT EXISTS hoh_datamart;
 
GRANT ALL ON SCHEMA hoh_datamart TO "IAM:ffdp-airflow";

----- CREATING HOH TABLES AND GRANTING PERMISSIONS TO ffdp-airflow user-----

-- hoh_datamart.atfarm_user_activity_daily_agg

DROP TABLE IF EXISTS hoh_datamart.atfarm_user_activity_daily_agg;

CREATE TABLE IF NOT EXISTS hoh_datamart.atfarm_user_activity_daily_agg (
    user_id VARCHAR(60),
    event_date DATE,
    source VARCHAR(100),
    schema VARCHAR(60),
    type VARCHAR(60),
    event_name VARCHAR(256),
    include_active_user BOOLEAN,
    event_cnt_1d BIGINT
) DISTSTYLE AUTO;

ALTER TABLE hoh_datamart.atfarm_user_activity_daily_agg OWNER TO "IAM:ffdp-airflow";

-- hoh_datamart.atfarm_user_monthly_weekly_ss

DROP TABLE IF EXISTS hoh_datamart.atfarm_user_monthly_weekly_ss;

CREATE TABLE IF NOT EXISTS hoh_datamart.atfarm_user_monthly_weekly_ss (
    snapshot_date DATE,
    user_id Varchar(200),
    country_name VARCHAR(600),
    region_name VARCHAR(600),
    created_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    is_email_verified BOOLEAN,
    is_archieved BOOLEAN,
    archived_at TIMESTAMP WITHOUT TIME ZONE,
    is_internal_user BOOLEAN,
    is_active_l12m BOOLEAN,
    is_active_l36m BOOLEAN, 
    last_user_active_date DATE
) DISTSTYLE AUTO;

ALTER TABLE hoh_datamart.atfarm_user_monthly_weekly_ss OWNER TO "IAM:ffdp-airflow";

-- hoh_datamart.atfarm_field_monthly_weekly_ss

DROP TABLE IF EXISTS hoh_datamart.atfarm_field_monthly_weekly_ss;

CREATE TABLE IF NOT EXISTS hoh_datamart.atfarm_field_monthly_weekly_ss (
    snapshot_date DATE,
    field_id Varchar(60),
    farm_id VARCHAR(60),
    country_name VARCHAR(600),
    region_name VARCHAR(600),
    field_created_at TIMESTAMP WITHOUT TIME ZONE,
    field_updated_at TIMESTAMP WITHOUT TIME ZONE,
    is_field_archived BOOLEAN,
    field_archived_at TIMESTAMP WITHOUT TIME ZONE,
    has_boundary_data BOOLEAN,
    is_user_archived BOOLEAN,
    is_internal_user BOOLEAN,
    boundary_md5_hash VARCHAR(60), 
    is_unique_hash BOOLEAN,
    crop_type VARCHAR(65535),
    polaris_crop_description VARCHAR(65535),
    polaris_crop_subclass VARCHAR(65535),
    polaris_crop_class VARCHAR(65535),
    polaris_crop_group VARCHAR(65535),
    hectare NUMERIC(18,6),
    feature_data_id VARCHAR(60),
    boundary_geometry VARCHAR(65535),
    is_active_l12m BOOLEAN,
    is_active_l36m BOOLEAN,
    last_user_active_date DATE,
    last_active_user_id VARCHAR(60),
    created_by VARCHAR(60),
    is_cnp_l12m BOOLEAN,
    is_cnp_l36m BOOLEAN,
    is_cnp_td BOOLEAN,
    is_vra_l12m BOOLEAN,
    is_vra_l36m BOOLEAN,
    is_vra_td BOOLEAN
) DISTSTYLE AUTO;

ALTER TABLE hoh_datamart.atfarm_field_monthly_weekly_ss OWNER TO "IAM:ffdp-airflow";

-- hoh_datamart.atfarm_country_crop_farm_user_monthly_weekly_agg

DROP TABLE IF EXISTS hoh_datamart.atfarm_country_crop_farm_user_monthly_weekly_agg;

CREATE TABLE IF NOT EXISTS hoh_datamart.atfarm_country_crop_farm_user_monthly_weekly_agg (
    snapshot_date DATE,
    user_id Varchar(100),
    farm_id VARCHAR(100),
    crop_type VARCHAR(65535),
    polaris_crop_description VARCHAR(65535),
    polaris_crop_subclass VARCHAR(65535),
    polaris_crop_class VARCHAR(65535),
    polaris_crop_group VARCHAR(65535),
    country_name VARCHAR(600),
    region_name VARCHAR(600),
    is_active_l12m BOOLEAN,
    is_active_l36m BOOLEAN
) DISTSTYLE AUTO;

ALTER TABLE hoh_datamart.atfarm_country_crop_farm_user_monthly_weekly_agg OWNER TO "IAM:ffdp-airflow";

-- hoh_datamart.atfarm_country_crop_monthly_agg_log

DROP TABLE IF EXISTS hoh_datamart.atfarm_country_crop_monthly_agg_log;

CREATE TABLE IF NOT EXISTS hoh_datamart.atfarm_country_crop_monthly_agg_log (
    update_timestamp TIMESTAMP WITHOUT TIME ZONE,
    update_date DATE,
    snapshot_date DATE,
    solution VARCHAR(60),
    region_name VARCHAR(600),
    country_name VARCHAR(600),
    crop_type VARCHAR(65535),
    polaris_crop_description VARCHAR(65535),
    polaris_crop_subclass VARCHAR(65535),
    polaris_crop_class VARCHAR(65535),
    polaris_crop_group VARCHAR(65535),
    active_hectare_boundary_cnt_td NUMERIC(18,6),
    active_hectare_overlaid_cnt_td NUMERIC(18,6), 
    active_hectare_no_boundary_cnt_td NUMERIC(18,6),
    digitized_hectare_boundary_cnt_td NUMERIC(18,6),
    digitized_hectare_overlaid_cnt_td NUMERIC(18,6),
    digitized_hectare_no_boundary_cnt_td NUMERIC(18,6),
    total_hectare_boundary_cnt_td NUMERIC(18,6),
    total_hectare_overlaid_cnt_td NUMERIC(18,6),
    total_hectare_no_boundary_cnt_td NUMERIC(18,6),
    active_field_boundary_cnt_td BIGINT,
    active_field_overlaid_cnt_td BIGINT,
    active_field_no_boundary_cnt_td BIGINT,
    digitized_field_boundary_cnt_td BIGINT,
    digitized_field_overlaid_cnt_td BIGINT,
    digitized_field_no_boundary_cnt_td BIGINT,
    total_field_boundary_cnt_td BIGINT,
    total_field_overlaid_cnt_td BIGINT,
    total_field_no_boundary_cnt_td BIGINT,
    new_user_active_field_hectare_cnt_1m NUMERIC(18,6),
    new_user_digitized_field_hectare_cnt_1m NUMERIC(18,6),
    existing_user_new_active_field_hectare_cnt_1m NUMERIC(18,6),
    existing_user_new_digitized_field_hectare_cnt_1m NUMERIC(18,6),
    existing_user_field_increase_active_hectare_cnt_1m NUMERIC(18,6),
    existing_user_field_increase_digitized_hectare_cnt_1m NUMERIC(18,6),
    reactivated_hectare_cnt_1m NUMERIC(18,6),
    redigitized_hectare_cnt_1m NUMERIC(18,6),
    l12m_inactive_churn_hectare_cnt_1m NUMERIC(18,6),
    l36m_inactive_churn_hectare_cnt_1m NUMERIC(18,6),
    existing_user_field_decrease_active_hectare_cnt_1m NUMERIC(18,6),
    existing_user_field_decrease_digitized_hectare_cnt_1m NUMERIC(18,6),
    deleted_active_hectare_cnt_1m NUMERIC(18,6),
    deleted_digitized_hectare_cnt_1m NUMERIC(18,6),
    new_user_active_field_cnt_1m BIGINT,
    new_user_digitized_field_cnt_1m BIGINT,
    existing_user_new_active_field_cnt_1m BIGINT,
    existing_user_new_digitized_field_cnt_1m BIGINT,
    existing_user_field_increase_active_field_cnt_1m BIGINT,
    existing_user_field_increase_digitized_field_cnt_1m BIGINT,
    reactivated_field_cnt_1m BIGINT,
    redigitized_field_cnt_1m BIGINT,
    l12m_inactive_churn_field_cnt_1m BIGINT,
    l36m_inactive_churn_field_cnt_1m BIGINT,
    existing_user_field_decrease_active_field_cnt_1m BIGINT,
    existing_user_field_decrease_digitized_field_cnt_1m BIGINT,
    deleted_active_field_cnt_1m BIGINT,
    deleted_digitized_field_cnt_1m BIGINT
) DISTSTYLE AUTO;

ALTER TABLE hoh_datamart.atfarm_country_crop_monthly_agg_log OWNER TO "IAM:ffdp-airflow";

-- hoh_datamart.atfarm_country_crop_quarterly_agg_log

DROP TABLE IF EXISTS hoh_datamart.atfarm_country_crop_quarterly_agg_log;

CREATE TABLE IF NOT EXISTS hoh_datamart.atfarm_country_crop_quarterly_agg_log (
    update_timestamp TIMESTAMP WITHOUT TIME ZONE,
    update_date DATE,
    snapshot_date DATE,
    solution VARCHAR(60),
    region_name VARCHAR(600),
    country_name VARCHAR(600),
    crop_type VARCHAR(65535),
    polaris_crop_description VARCHAR(65535),
    polaris_crop_subclass VARCHAR(65535),
    polaris_crop_class VARCHAR(65535),
    polaris_crop_group VARCHAR(65535),
    active_hectare_boundary_cnt_td NUMERIC(18,6),
    active_hectare_overlaid_cnt_td NUMERIC(18,6), 
    active_hectare_no_boundary_cnt_td NUMERIC(18,6),
    digitized_hectare_boundary_cnt_td NUMERIC(18,6),
    digitized_hectare_overlaid_cnt_td NUMERIC(18,6),
    digitized_hectare_no_boundary_cnt_td NUMERIC(18,6),
    total_hectare_boundary_cnt_td NUMERIC(18,6),
    total_hectare_overlaid_cnt_td NUMERIC(18,6),
    total_hectare_no_boundary_cnt_td NUMERIC(18,6),
    active_field_boundary_cnt_td BIGINT,
    active_field_overlaid_cnt_td BIGINT,
    active_field_no_boundary_cnt_td BIGINT,
    digitized_field_boundary_cnt_td BIGINT,
    digitized_field_overlaid_cnt_td BIGINT,
    digitized_field_no_boundary_cnt_td BIGINT,
    total_field_boundary_cnt_td BIGINT,
    total_field_overlaid_cnt_td BIGINT,
    total_field_no_boundary_cnt_td BIGINT,
    new_user_active_field_hectare_cnt_3m NUMERIC(18,6),
    new_user_digitized_field_hectare_cnt_3m NUMERIC(18,6),
    existing_user_new_active_field_hectare_cnt_3m NUMERIC(18,6),
    existing_user_new_digitized_field_hectare_cnt_3m NUMERIC(18,6),
    existing_user_field_increase_active_hectare_cnt_3m NUMERIC(18,6),
    existing_user_field_increase_digitized_hectare_cnt_3m NUMERIC(18,6),
    reactivated_hectare_cnt_3m NUMERIC(18,6),
    redigitized_hectare_cnt_3m NUMERIC(18,6),
    l12m_inactive_churn_hectare_cnt_3m NUMERIC(18,6),
    l36m_inactive_churn_hectare_cnt_3m NUMERIC(18,6),
    existing_user_field_decrease_active_hectare_cnt_3m NUMERIC(18,6),
    existing_user_field_decrease_digitized_hectare_cnt_3m NUMERIC(18,6),
    deleted_active_hectare_cnt_3m NUMERIC(18,6),
    deleted_digitized_hectare_cnt_3m NUMERIC(18,6),
    new_user_active_field_cnt_3m BIGINT,
    new_user_digitized_field_cnt_3m BIGINT,
    existing_user_new_active_field_cnt_3m BIGINT,
    existing_user_new_digitized_field_cnt_3m BIGINT,
    existing_user_field_increase_active_field_cnt_3m BIGINT,
    existing_user_field_increase_digitized_field_cnt_3m BIGINT,
    reactivated_field_cnt_3m BIGINT,
    redigitized_field_cnt_3m BIGINT,
    l12m_inactive_churn_field_cnt_3m BIGINT,
    l36m_inactive_churn_field_cnt_3m BIGINT,
    existing_user_field_decrease_active_field_cnt_3m BIGINT,
    existing_user_field_decrease_digitized_field_cnt_3m BIGINT,
    deleted_active_field_cnt_3m BIGINT,
    deleted_digitized_field_cnt_3m BIGINT
) DISTSTYLE AUTO;

ALTER TABLE hoh_datamart.atfarm_country_crop_quarterly_agg_log OWNER TO "IAM:ffdp-airflow";
