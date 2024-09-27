-- liquibase formatted sql

--changeset sandeep_c:ATI-7166-creating-product-recommendation-performed-table splitStatements:true
--comment: ATI-7166 - table creation for product recommendation performed table
DROP TABLE IF EXISTS ffdp2_0.product_recommendation_performed;

CREATE TABLE ffdp2_0.product_recommendation_performed(
    id VARCHAR(512),
    received_at TIMESTAMP WITHOUT TIME ZONE,
    uuid BIGINT,
    crop_id VARCHAR(512),
    email VARCHAR(512),
    event_id VARCHAR(512),
    region_id VARCHAR(512),
    uuid_ts TIMESTAMP WITHOUT TIME ZONE,
    country_id VARCHAR(512),
    event VARCHAR(512),
    event_text VARCHAR(512),
    original_timestamp TIMESTAMP WITHOUT TIME ZONE,
    sent_at TIMESTAMP WITHOUT TIME ZONE,
    context_library_name VARCHAR(512),
    timestamp TIMESTAMP WITHOUT TIME ZONE,
    context_library_version VARCHAR(512),
    user_id VARCHAR(512),
    yield BIGINT,
    yield_unit VARCHAR(512),
    anonymous_id VARCHAR(512),
    solution VARCHAR(512),
    size BIGINT,
    size_unit_id VARCHAR(512),
    field_id VARCHAR(512),
    context_event_transformed VARCHAR(512)
);

ALTER TABLE ffdp2_0.product_recommendation_performed OWNER TO "IAM:ffdp-airflow";

--rollback DROP TABLE ffdp2_0.product_recommendation_performed CASCADE;