-- liquibase formatted sql

--changeset sandeep_c:ATI-7144-creating-polaris-ndvi-performed-table splitStatements:true
--comment: ATI-7144 - table creation for polaris ndvi performed table
DROP TABLE IF EXISTS curated_schema.polaris_ndvi_performed;

CREATE TABLE curated_schema.polaris_ndvi_performed(
    dateTimeOccurred TIMESTAMP,
    request_boundaries SUPER,
    request_cropRegionId VARCHAR(255),
    request_date VARCHAR(255),
    area DOUBLE PRECISION,
    areaUnitId VARCHAR(255),
    requestType VARCHAR(255),
    callbackUrl VARCHAR(255),
    success BOOLEAN,
    message VARCHAR(255),
    imageUrl VARCHAR(510),
    cloudCoverage DOUBLE PRECISION,
    snowCoverage DOUBLE PRECISION,
    valid BOOLEAN,
    image_date VARCHAR(255),
    solution VARCHAR(255),
    generatedId VARCHAR(255),
    eventSource VARCHAR(255),
    eventType VARCHAR(255),
    eventId VARCHAR(255),
    created_at VARCHAR(255)
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_ndvi_performed TO gluejob;

--rollback DROP TABLE curated_schema.polaris_ndvi_performed CASCADE;