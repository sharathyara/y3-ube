-- corporate_reporting_solution_country_crop_nd_agg_long

CREATE TABLE IF NOT EXISTS hoh_datamart.corporate_reporting_solution_country_crop_nd_agg_long (
	snapshot_date DATE,
	updated_at TIMESTAMP,
	periodicity VARCHAR(50),
	solution VARCHAR(50),
	region_name VARCHAR(256),
	subregion_name VARCHAR(256),
	country_name VARCHAR(600),
	crop_type VARCHAR(512),
	polaris_crop_description VARCHAR(512),
	polaris_crop_subclass VARCHAR(512),
	polaris_crop_class VARCHAR(512),
	polaris_crop_group VARCHAR(512),
	kpi_metric_name VARCHAR(100),
	kpi_metric_rename VARCHAR(100),
	kpi_metric_rank BIGINT,
	kpi_value NUMERIC(18,6)
);

ALTER TABLE hoh_datamart.corporate_reporting_solution_country_crop_nd_agg_long OWNER TO "IAM:ffdp-airflow";


-- corporate_reporting_solution_field_monthly

CREATE TABLE IF NOT EXISTS hoh_datamart.corporate_reporting_solution_field_monthly (
    snapshot_date DATE,
    updated_at TIMESTAMP,
    solution VARCHAR(50),
    field_id VARCHAR(512), 
    farm_id VARCHAR(50),
    boundary_id VARCHAR(32),
    country_name VARCHAR(600),
	region_name VARCHAR(256),
    crop_type VARCHAR(512),
    polaris_crop_description VARCHAR(512),
    polaris_crop_subclass VARCHAR(512),
    polaris_crop_class VARCHAR(512),
    polaris_crop_group VARCHAR(512),
    field_created_at TIMESTAMP,
    has_boundary_data BOOLEAN,
    is_unique_field BOOLEAN,
    is_active_l12m BOOLEAN,
    is_active_l36m BOOLEAN,
    created_by_user_id VARCHAR(50),
    created_by_user_created_at TIMESTAMP,
    last_active_user_id VARCHAR(50),
    last_user_active_date DATE,
    last_user_active_created_at TIMESTAMP,
    hectare NUMERIC(18,6)
);

ALTER TABLE hoh_datamart.corporate_reporting_solution_field_monthly OWNER TO "IAM:ffdp-airflow";


-- solution_country_crop_farm_user_nd_agg

CREATE TABLE IF NOT EXISTS hoh_datamart.solution_country_crop_farm_user_nd_agg(
    snapshot_date DATE,
	periodicity VARCHAR(50),
    solution VARCHAR(50),
    user_id VARCHAR(50),
    farm_id VARCHAR(50),
    crop_type VARCHAR(512),
    polaris_crop_description VARCHAR(512),
    polaris_crop_subclass VARCHAR(512),
    polaris_crop_class VARCHAR(512),
    polaris_crop_group VARCHAR(512),
    country_name VARCHAR(600),
    region_name VARCHAR(256),
    subregion_name VARCHAR(256),
    is_active_l12m BOOLEAN,
    is_active_l36m BOOLEAN
);

ALTER TABLE hoh_datamart.solution_country_crop_farm_user_nd_agg OWNER TO "IAM:ffdp-airflow";


-- solution_country_crop_monthly_agg

CREATE TABLE IF NOT EXISTS hoh_datamart.solution_country_crop_monthly_agg(
    snapshot_date DATE,
    solution VARCHAR(50),
    region_name VARCHAR(256),
    subregion_name VARCHAR(256),
    country_name VARCHAR(600),
    crop_type VARCHAR(512),
    polaris_crop_description VARCHAR(512),
    polaris_crop_subclass VARCHAR(512),
    polaris_crop_class VARCHAR(512),
    polaris_crop_group VARCHAR(512),
    active_hectare_boundary_cnt_td NUMERIC(18,6),
    active_hectare_overlaid_cnt_td NUMERIC(18,6),
    active_hectare_no_boundary_cnt_td NUMERIC(18,6),
    total_active_hectare_cnt_td NUMERIC(18,6),
    digitized_hectare_boundary_cnt_td NUMERIC(18,6),
    digitized_hectare_overlaid_cnt_td NUMERIC(18,6),
    digitized_hectare_no_boundary_cnt_td NUMERIC(18,6),
    total_digitized_hectare_cnt_td NUMERIC(18,6),
    total_hectare_boundary_cnt_td NUMERIC(18,6),
    total_hectare_overlaid_cnt_td NUMERIC(18,6),
    total_hectare_no_boundary_cnt_td NUMERIC(18,6),
    total_total_hectare_cnt_td NUMERIC(18,6),
    active_field_boundary_cnt_td BIGINT,
    active_field_overlaid_cnt_td BIGINT,
    active_field_no_boundary_cnt_td BIGINT,
    total_active_field_cnt_td BIGINT,
    digitized_field_boundary_cnt_td BIGINT,
    digitized_field_overlaid_cnt_td BIGINT,
    digitized_field_no_boundary_cnt_td BIGINT,
    total_digitized_field_cnt_td BIGINT,
    total_field_boundary_cnt_td BIGINT,
    total_field_overlaid_cnt_td BIGINT,
    total_field_no_boundary_cnt_td BIGINT,
    total_total_field_cnt_td BIGINT,
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
    deleted_digitized_field_cnt_1m BIGINT,
    active_hectare_cropwise_adj_cnt_td NUMERIC(18,6),
    digitized_hectare_cropwise_adj_cnt_td NUMERIC(18,6),
    total_hectare_cropwise_adj_cnt_td NUMERIC(18,6),
    active_hectare_geospatial_dedup_adj_cnt_td NUMERIC(18,6),
    digitized_hectare_geospatial_dedup_adj_cnt_td NUMERIC(18,6),
    total_hectare_geospatial_dedup_adj_cnt_td NUMERIC(18,6)
);

ALTER TABLE hoh_datamart.solution_country_crop_monthly_agg OWNER TO "IAM:ffdp-airflow";


-- solution_country_crop_nd_agg_long

CREATE TABLE IF NOT EXISTS hoh_datamart.solution_country_crop_nd_agg_long(
	snapshot_date DATE,
	periodicity VARCHAR(50),
	solution VARCHAR(50),
	region_name VARCHAR(256),
	subregion_name VARCHAR(256),
	country_name VARCHAR(600),
	crop_type VARCHAR(512),
	polaris_crop_description VARCHAR(512),
	polaris_crop_subclass VARCHAR(512),
	polaris_crop_class VARCHAR(512),
	polaris_crop_group VARCHAR(512),
	kpi_metric_name VARCHAR(100),
	kpi_metric_rename VARCHAR(100),
	kpi_metric_rank BIGINT,
	kpi_value NUMERIC(18,6)
);

ALTER TABLE hoh_datamart.solution_country_crop_nd_agg_long OWNER TO "IAM:ffdp-airflow";


-- solution_country_crop_quarterly_agg

CREATE TABLE IF NOT EXISTS hoh_datamart.solution_country_crop_quarterly_agg(
    snapshot_date DATE,
    solution VARCHAR(50),
    region_name VARCHAR(256),
    subregion_name VARCHAR(256),
    country_name VARCHAR(600),
    crop_type VARCHAR(512),
    polaris_crop_description VARCHAR(512),
    polaris_crop_subclass VARCHAR(512),
    polaris_crop_class VARCHAR(512),
    polaris_crop_group VARCHAR(512),
    active_hectare_boundary_cnt_td NUMERIC(18,6),
    active_hectare_overlaid_cnt_td NUMERIC(18,6),
    active_hectare_no_boundary_cnt_td NUMERIC(18,6),
    total_active_hectare_cnt_td NUMERIC(18,6),
    digitized_hectare_boundary_cnt_td NUMERIC(18,6),
    digitized_hectare_overlaid_cnt_td NUMERIC(18,6),
    digitized_hectare_no_boundary_cnt_td NUMERIC(18,6),
    total_digitized_hectare_cnt_td NUMERIC(18,6),
    total_hectare_boundary_cnt_td NUMERIC(18,6),
    total_hectare_overlaid_cnt_td NUMERIC(18,6),
    total_hectare_no_boundary_cnt_td NUMERIC(18,6),
    total_total_hectare_cnt_td NUMERIC(18,6),
    active_field_boundary_cnt_td BIGINT,
    active_field_overlaid_cnt_td BIGINT,
    active_field_no_boundary_cnt_td BIGINT,
    total_active_field_cnt_td BIGINT,
    digitized_field_boundary_cnt_td BIGINT,
    digitized_field_overlaid_cnt_td BIGINT,
    digitized_field_no_boundary_cnt_td BIGINT,
    total_digitized_field_cnt_td BIGINT,
    total_field_boundary_cnt_td BIGINT,
    total_field_overlaid_cnt_td BIGINT,
    total_field_no_boundary_cnt_td BIGINT,
    total_total_field_cnt_td BIGINT,
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
    deleted_digitized_field_cnt_3m BIGINT,
    active_hectare_cropwise_adj_cnt_td NUMERIC(18,6),
    digitized_hectare_cropwise_adj_cnt_td NUMERIC(18,6),
    total_hectare_cropwise_adj_cnt_td NUMERIC(18,6),
    active_hectare_geospatial_dedup_adj_cnt_td NUMERIC(18,6),
    digitized_hectare_geospatial_dedup_adj_cnt_td NUMERIC(18,6),
    total_hectare_geospatial_dedup_adj_cnt_td NUMERIC(18,6)
);

ALTER TABLE hoh_datamart.solution_country_crop_quarterly_agg OWNER TO "IAM:ffdp-airflow";



-- ALter column name

ALTER TABLE hoh_datamart.atfarm_user_monthly_weekly_ss
RENAME COLUMN is_archieved to is_archived;