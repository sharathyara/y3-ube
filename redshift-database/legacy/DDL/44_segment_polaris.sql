DROP TABLE IF EXISTS ffdp2_0.segment_product_recommendation_performed_v2;


CREATE TABLE ffdp2_0.segment_product_recommendation_performed_v2
(
    id VARCHAR(512), 
    received_at TIMESTAMP WITHOUT TIME ZONE, 
    uuid BIGINT, 
    crop_region_id  VARCHAR(512), 
    event_id  VARCHAR(512), 
    region VARCHAR(512), 
    crop VARCHAR(512), 
    size_unit_id VARCHAR(512), 
    solution VARCHAR(512), 
    uuid_ts TIMESTAMP WITHOUT TIME ZONE, 
    yield DOUBLE PRECISION, 
    event_text VARCHAR(512), 
    event VARCHAR(512), 
    timestamp TIMESTAMP WITHOUT TIME ZONE, 
    context_library_version VARCHAR(512), 
    country VARCHAR(512), 
    email VARCHAR(512), 
    original_timestamp TIMESTAMP WITHOUT TIME ZONE, 
    sent_at VARCHAR(512), 
    size DOUBLE PRECISION, 
    context_library_name VARCHAR(512),
    yield_unit_id VARCHAR(512), 
    user_id VARCHAR(512), 
    context_event_transformed  VARCHAR(512)
);

ALTER TABLE ffdp2_0.segment_product_recommendation_performed_v2 OWNER TO "IAM:ffdp-airflow";


DROP TABLE IF EXISTS ffdp2_0.segment_vra_performed;

CREATE TABLE ffdp2_0.segment_vra_performed
(
    id VARCHAR(512),
    received_at TIMESTAMP WITHOUT TIME ZONE, 
    uuid BIGINT, 
    context_library_version VARCHAR(512), 
    crop VARCHAR(512), 
    sent_at TIMESTAMP WITHOUT TIME ZONE, 
    solution VARCHAR(512), 
    user_id VARCHAR(512), 
    crop_region_id VARCHAR(512), 
    email VARCHAR(512), 
    event VARCHAR(512), 
    region VARCHAR(512), 
    size_unit_id VARCHAR(512), 
    context_library_name VARCHAR(512), 
    event_text VARCHAR(512), 
    size DOUBLE PRECISION, 
    timestamp TIMESTAMP WITHOUT TIME ZONE, 
    uuid_ts TIMESTAMP WITHOUT TIME ZONE, 
    country VARCHAR(512), 
    event_id VARCHAR(512), 
    original_timestamp TIMESTAMP WITHOUT TIME ZONE, 
    extrapolation BOOLEAN, 
    context_event_transformed VARCHAR(512)
);


ALTER TABLE ffdp2_0.segment_vra_performed OWNER TO "IAM:ffdp-airflow";


DROP TABLE IF EXISTS ffdp2_0.segment_yield_estimation_performed;

CREATE TABLE ffdp2_0.segment_yield_estimation_performed

(
      id VARCHAR(512), 
      received_at TIMESTAMP WITHOUT TIME ZONE,
      uuid BIGINT,
      country VARCHAR(512), 
      crop VARCHAR(512), 
      event_text VARCHAR(512), 
      sent_at TIMESTAMP WITHOUT TIME ZONE, 
      size_unit_id VARCHAR(512), 
      context_library_name VARCHAR(512), 
      event VARCHAR(512), 
      solution VARCHAR(512),
      context_library_version VARCHAR(512),
      email VARCHAR(512),
      size DOUBLE PRECISION, 
      user_id VARCHAR(512), 
      crop_region_id VARCHAR(512), 
      event_id VARCHAR(512), 
      original_timestamp TIMESTAMP WITHOUT TIME ZONE, 
      uuid_ts TIMESTAMP WITHOUT TIME ZONE, 
      extrapolation BOOLEAN, 
      region VARCHAR(512), 
      context_event_transformed VARCHAR(512)
);

ALTER TABLE ffdp2_0.segment_yield_estimation_performed OWNER TO "IAM:ffdp-airflow";



DROP TABLE IF EXISTS ffdp2_0.segment_soil_demand_performed_v2;

CREATE TABLE ffdp2_0.segment_soil_demand_performed_v2
(
    id VARCHAR(512), 
    received_at TIMESTAMP WITHOUT TIME ZONE, 
    uuid BIGINT, 
    event_text  VARCHAR(512),
    solution VARCHAR(512), 
    yield DOUBLE PRECISION, 
    yield_unit_id VARCHAR(512), 
    event_id VARCHAR(512), 
    region VARCHAR(512), 
    size_unit_id VARCHAR(512), 
    user_id VARCHAR(512), 
    uuid_ts TIMESTAMP WITHOUT TIME ZONE, 
    event VARCHAR(512), 
    email VARCHAR(512), 
    original_timestamp TIMESTAMP WITHOUT TIME ZONE, 
    timestamp TIMESTAMP WITHOUT TIME ZONE, 
    context_library_name VARCHAR(512), 
    country VARCHAR(512), 
    crop VARCHAR(512), 
    crop_region_id VARCHAR(512), 
    sent_at TIMESTAMP WITHOUT TIME ZONE, 
    size DOUBLE PRECISION, 
    context_library_version VARCHAR(512), 
    context_event_transformed VARCHAR(512)
    );

    ALTER TABLE ffdp2_0.segment_soil_demand_performed_v2 OWNER TO "IAM:ffdp-airflow";

