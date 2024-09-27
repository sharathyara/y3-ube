-- liquibase formatted sql

--changeset PeterBradac:ATI-6238 splitStatements:true
--comment: ATI-6238 - New schema for ingestion of fbm service
DROP TABLE IF EXISTS curated_schema.fbm_field;

CREATE TABLE IF NOT EXISTS curated_schema.fbm_field
(
  bbox VARCHAR(255),
  email VARCHAR(255),
  ewkt VARCHAR(255),
  point VARCHAR(255),
  fieldid VARCHAR(255),
  phone VARCHAR(255),
  center VARCHAR(255),
  eventid VARCHAR(255),
  regionid VARCHAR(255),
  feature SUPER,
  fieldsize DOUBLE PRECISION,
  geohash VARCHAR(255),
  iouscore VARCHAR(255),
  clientcode VARCHAR(255),
  countryid VARCHAR(255),
  boundaryid VARCHAR(255),
  eventtype VARCHAR(255),
  fieldsizeuom VARCHAR(255),
  eventsource VARCHAR(255),
  sourcefarmid VARCHAR(255),
  sourcefieldid VARCHAR(255),
  sourceuserid VARCHAR(255),
  geometryhash VARCHAR(255),
  organizationid VARCHAR(255),
  listoffeatures SUPER,
  datetimeoccurred TIMESTAMP,
  id VARCHAR(255),
  inputbasedintersection VARCHAR(255),
  outputbasedintersection VARCHAR(255),
  created_at VARCHAR(255)
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.fbm_field TO gluejob;

--rollback DROP TABLE curated_schema.fbm_field CASCADE;