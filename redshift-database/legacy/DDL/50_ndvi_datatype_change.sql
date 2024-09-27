-- Changing Image URL datatype to Super

ALTER TABLE curated_schema.polaris_ndvi_performed
rename To polaris_ndvi_performed_backup;

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
    message VARCHAR(10000),
    imageurl Super,
    cloudCoverage DOUBLE PRECISION,
    snowCoverage DOUBLE PRECISION,
    valid BOOLEAN,
    image_date VARCHAR(255),
    solution VARCHAR(255),
    eventSource VARCHAR(255),
    eventType VARCHAR(255),
    eventId VARCHAR(255),
    created_at VARCHAR(255)
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_ndvi_performed TO gluejob;

GRANT INSERT, SELECT ON TABLE curated_schema.polaris_ndvi_performed TO "IAM:ffdp-airflow";

INSERT INTO curated_schema.polaris_ndvi_performed SELECT * from curated_schema.polaris_ndvi_performed_backup;