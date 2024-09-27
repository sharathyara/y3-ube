-- liquibase formatted sql

--changeset ramesh:ATI-7142-nsensor-biomass-performed-ddl splitStatements:true
--comment: ATI-7142 - create table ddl of polaris Calculation N-Sensor-Biomass performed
DROP TABLE IF EXISTS curated_schema.polaris_n_sensor_biomass_performed;

CREATE TABLE curated_schema.polaris_n_sensor_biomass_performed(
    dateTimeOccurred TIMESTAMP NOT NULL,
    eventId VARCHAR(256) NOT NULL,
    request_boundaries SUPER NOT NULL,
    request_field_area FLOAT NOT NULL,
    request_field_areaUnitId VARCHAR(256) NOT NULL,
    request_configuration VARCHAR(1000),
    request_cropRegionId VARCHAR(256),
    request_date VARCHAR(255),
    request_extrapolation BOOLEAN,
    response_success BOOLEAN NOT NULL,
    response_message VARCHAR(3000),
    response_payload_imageUrl VARCHAR(3000),
    response_payload_cloudCoverage FLOAT,
    response_payload_snowCoverage FLOAT,
    response_payload_valid BOOLEAN,
    response_payload_s1Max FLOAT,
    response_payload_growthScaleId VARCHAR(256),
    response_payload_fromGrowthStageId VARCHAR(256),
    response_payload_toGrowthStageId VARCHAR(256),
    response_payload_date DATE,
    configuration_solution VARCHAR(1000) NOT NULL,
    eventSource VARCHAR(256) NOT NULL,
    eventType VARCHAR(256) NOT NULL,
    created_at VARCHAR(255)
);

COMMENT ON TABLE curated_schema.polaris_n_sensor_biomass_performed IS 'Table to store N sensor Biomass Calculation data';

COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.dateTimeOccurred IS 'The Time when Event/Log generated';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.eventId IS 'N sensor Biomass Calculation unique identifier';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.request_boundaries IS 'Request field boundary';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.request_field_area IS 'request field area';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.request_field_areaUnitId IS 'request field area unit ID';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.request_configuration IS 'request configuration';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.request_cropRegionId IS 'the corp region ID';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.request_date IS 'The date should be in the format of YYYY-MM-DD or ~YYYY-MM-DD in GMT, CEST-2 timezone (service searches for the last clear day (cloud free, snow free = 0% of coverage) within 30 days)';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.request_extrapolation IS 'Whether or not to use the extrapolated index (defaults to false)';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_success IS 'Outcome of the calculation.';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_message IS 'Calculation error message.';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_payload_imageUrl IS 'Link to the generated image of type JPG or TIFF or JSON. The link is valid for 6 hours';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_payload_cloudCoverage IS 'Numeric representation of the cloud coverage for the corresponding date where 0 means no clouds. The range is 0 to 1, where 1.0 - > 10% of the area is covered by clouds.';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_payload_snowCoverage IS 'Numeric representation of the snow coverage for the corresponding date where 0 means no snow. The range is 0 to 1, where 1.0 - > 10% of the area is covered by snow';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_payload_valid IS 'Validity.';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_payload_s1Max IS 'S1_MAX value';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_payload_growthScaleId IS 'Growth scale unique identifier';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_payload_fromGrowthStageId IS 'From growth scale stage unique identifier';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_payload_toGrowthStageId IS 'To growth scale stage unique identifier';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.response_payload_date IS 'The date when the image was captured';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.configuration_solution IS 'The solution which requested the calcualtion';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.eventSource IS 'The Kafka NameSpace where this message was generated';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.eventType IS 'The Name of the Event';
COMMENT ON COLUMN curated_schema.polaris_n_sensor_biomass_performed.created_at IS 'HUDI partition key';

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_n_sensor_biomass_performed TO gluejob;

--rollback DROP TABLE IF EXISTS curated_schema.polaris_n_sensor_biomass_performed CASCADE;