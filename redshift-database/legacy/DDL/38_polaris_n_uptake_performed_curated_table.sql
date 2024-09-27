CREATE TABLE IF NOT EXISTS curated_schema.polaris_n_uptake_performed
(
  datetimeoccurred TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  request_boundaries SUPER,
  request_cropRegionId VARCHAR(256),
  request_date VARCHAR(255),
  request_extrapolation BOOLEAN,
  request_field_area DOUBLE PRECISION,
  request_field_areaUnitId VARCHAR(256),
  request_configuration_requestType VARCHAR(255),
  request_configuration_callbackUrl VARCHAR(255),
  response_success BOOLEAN,
  response_message VARCHAR(10000),
  response_payload_imageUrl VARCHAR(3000),
  response_payload_cloudCoverage DOUBLE PRECISION,
  response_payload_snowCoverage DOUBLE PRECISION,
  response_payload_valid BOOLEAN,
  response_payload_min DOUBLE PRECISION,
  response_payload_max DOUBLE PRECISION,
  response_payload_mean DOUBLE PRECISION,
  response_payload_std DOUBLE PRECISION,
  response_payload_growthScaleId VARCHAR(256),
  response_payload_fromGrowthStageId VARCHAR(256),
  response_payload_toGrowthStageId VARCHAR(256),
  configuration_solution VARCHAR(256),
  eventSource VARCHAR(256) NOT NULL,
  eventType VARCHAR(256) NOT NULL,
  eventId VARCHAR(256) NOT NULL,
  created_at VARCHAR(256) NOT NULL
);

-- polaris_n_uptake_performed
GRANT SELECT ON TABLE curated_schema.polaris_n_uptake_performed TO "IAM:ffdp-airflow";

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_n_uptake_performed TO gluejob;