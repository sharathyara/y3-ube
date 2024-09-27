-- liquibase formatted sql

--changeset Sharath:ATI-7182 splitStatements:true runOnChange:true
--comment: ATI-7182 - New schema for ingestion of polaris nue performed
DROP TABLE IF EXISTS curated_schema.polaris_nue_performed;

CREATE TABLE curated_schema.polaris_nue_performed(
    dateTimeOccurred TIMESTAMP NOT NULL,
    request_location_countryId VARCHAR(255) NOT NULL,
    request_location_regionId VARCHAR(255) NOT NULL,
    request_field_latitude FLOAT,
    request_field_longitude FLOAT,
    request_cropRegionId VARCHAR(255) NOT NULL,
    request_yield FLOAT NOT NULL,
    request_yieldUnitId VARCHAR(255) NOT NULL,
    request_nExport FLOAT NOT NULL,
    request_climate_nDeposition FLOAT,
    request_appliedProducts VARCHAR(6500),
    request_configuration_requestType VARCHAR(255),
    request_configuration_callbackUrl VARCHAR(255),
    response_success BOOLEAN NOT NULL,
    response_message VARCHAR(255),
    response_nInput VARCHAR(6500),
    response_nOutput VARCHAR(6500),
    response_nSurplus VARCHAR(6500),
    response_nue VARCHAR(6500),
    response_nDeposition VARCHAR(6500),
    response_nDepositionInfo VARCHAR(6500),
    configuration_solution VARCHAR(255),
    eventSource VARCHAR(255) NOT NULL,
    eventType VARCHAR(255) NOT NULL,
    eventId VARCHAR(255) NOT NULL,
    created_at VARCHAR(255) NOT NULL
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_nue_performed TO gluejob;

--rollback DROP TABLE curated_schema.polaris_nue_performed CASCADE;