-- liquibase formatted sql

--changeset Sharath:ATI-7117 splitStatements:true runOnChange:true
--comment: ATI-7117 - New schema for ingestion of polaris yield estimation performed
DROP TABLE IF EXISTS curated_schema.polaris_yield_estimation_performed;

CREATE TABLE curated_schema.polaris_yield_estimation_performed(
    dateTimeOccurred TIMESTAMP,
    boundaries SUPER,
    cropRegionId VARCHAR(255),
    request_date VARCHAR(255),
    area FLOAT,
    areaUnitId VARCHAR(255),
    requestType VARCHAR(255),
    callbackUrl VARCHAR(255),
    extrapolation BOOLEAN,
    id VARCHAR(255),
    success BOOLEAN,
    begin VARCHAR(255),
    "end" VARCHAR(255),
    message VARCHAR(255),
    min FLOAT,
    max FLOAT,
    mean FLOAT,
    std FLOAT,
    cloudCoverage FLOAT,
    snowCoverage FLOAT,
    valid BOOLEAN,
    image_date VARCHAR(255),
    solution VARCHAR(255),
    eventSource VARCHAR(255),
    eventType VARCHAR(255),
    eventId VARCHAR(255),
    created_at VARCHAR(255)
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_yield_estimation_performed TO gluejob;

--rollback DROP TABLE curated_schema.polaris_yield_estimation_performed CASCADE;