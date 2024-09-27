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