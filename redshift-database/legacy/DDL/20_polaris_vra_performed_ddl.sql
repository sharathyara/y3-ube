/******* DDL to create polaris vra perfomred table  ********/


DROP TABLE IF EXISTS curated_schema.polaris_vra_performed;

CREATE TABLE curated_schema.polaris_vra_performed(
    dateTimeOccurred TIMESTAMP NOT NULL,
    request_boundaries SUPER NOT NULL,
    request_cropRegionId VARCHAR(255) NOT NULL,
    request_date VARCHAR(255),
    request_field_area FLOAT NOT NULL,
    request_field_areaUnitId VARCHAR(255) NOT NULL,
    request_requestType VARCHAR(255),
    request_callbackUrl VARCHAR(255),
    request_dmax FLOAT,
    request_dmin FLOAT,
    request_dTarget FLOAT,
    request_growthStage INTEGER,
    request_vraType VARCHAR(255),
    request_protein BOOLEAN,
    request_featureCollection VARCHAR(50000),
    request_valueKey VARCHAR(255),
    request_extrapolation BOOLEAN,
    response_success BOOLEAN NOT NULL,
    response_message VARCHAR(255),
    response_date VARCHAR(255),
    response_cloudCoverage FLOAT,
    response_snowCoverage FLOAT,
    response_valid BOOLEAN,
    response_cellSize FLOAT,
    response_bucketZones SUPER,
    response_zonedZones SUPER,
    response_indices SUPER,
    response_bucketMean FLOAT,
    response_bucketMin FLOAT,
    response_bucketMax FLOAT,
    response_bucketStd FLOAT,
    response_zonedMean FLOAT,
    response_zonedMin FLOAT,
    response_zonedMax FLOAT,
    response_zonedStd FLOAT,
    response_featureCollection VARCHAR(50000),
    solution VARCHAR(255),
    eventSource VARCHAR(255) NOT NULL,
    eventType VARCHAR(255)NOT NULL,
    eventId VARCHAR(255) NOT NULL,
    created_at VARCHAR(255) NOT NULL
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_vra_performed TO gluejob;

