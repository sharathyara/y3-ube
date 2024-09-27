/******* DDL to create polaris soil analysis v2 performed table  ********/

DROP TABLE IF EXISTS curated_schema.polaris_soil_analysis_v2_performed;

CREATE TABLE curated_schema.polaris_soil_analysis_v2_performed(
    dateTimeOccurred TIMESTAMP NOT NULL,
    request_countryId VARCHAR(255),
    request_regionId VARCHAR(255),
    request_field_id VARCHAR(255),
    request_field_boundaries SUPER,
    request_field_area DOUBLE PRECISION,
    request_field_areaUnitId VARCHAR(255),
    request_field_soilTypeId VARCHAR(255),
    request_cropRegionId VARCHAR(255),
    request_yield DOUBLE PRECISION,
    request_yieldUnitId VARCHAR(255),
    request_cropResidueManagementId VARCHAR(255),
    request_additionalParameters SUPER,
    request_precrop_cropDescriptionId VARCHAR(255),
    request_precrop_yield DOUBLE PRECISION,
    request_precrop_yieldUnitId VARCHAR(255),
    request_precrop_cropResidueManagementId DOUBLE PRECISION,
    request_postcrop_cropDescriptionId VARCHAR(255),
    request_postcrop_yield DOUBLE PRECISION,
    request_postcrop_yieldUnitId VARCHAR(255),
    request_postcrop_cropResidueManagementId DOUBLE PRECISION,
    request_analysis SUPER,
    request_requestType VARCHAR(255),
    request_callbackUrl VARCHAR(255),
    request_soilAnalysisType VARCHAR(255),
    request_useDefaultData BOOLEAN,
    request_organicProducts SUPER,
    response_id VARCHAR(255),
    response_success BOOLEAN,
    response_begin VARCHAR(255),
    response_end VARCHAR(255),
    response_message VARCHAR(255),
    response_baseData SUPER,
    response_demandData SUPER,
    response_organicSupply SUPER,
    solution VARCHAR(255),
    eventSource VARCHAR(255) NOT NULL,
    eventType VARCHAR(255)NOT NULL,
    eventId VARCHAR(255) NOT NULL,
    created_at VARCHAR(255) NOT NULL
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_soil_analysis_v2_performed TO gluejob;

GRANT SELECT ON TABLE curated_schema.polaris_soil_analysis_v2_performed TO "IAM:ffdp-airflow";