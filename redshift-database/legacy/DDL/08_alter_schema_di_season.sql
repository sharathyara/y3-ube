DROP TABLE IF EXISTS curated_schema.di_season_old;
ALTER TABLE curated_schema.di_season RENAME TO di_season_old;

CREATE TABLE IF NOT EXISTS curated_schema.di_season
(
  datetimeoccurred TIMESTAMP,
  sourcefile_name VARCHAR(255),
  sourcefile_receiveddate VARCHAR(255),
  sourceseasonid VARCHAR(255),
  sourcefieldid VARCHAR(255),
  seasonname VARCHAR(255),
  cropregionid VARCHAR(255),
  growthstageid VARCHAR(255),
  growthstagesystem VARCHAR(255),
  startdate VARCHAR(255),
  enddate VARCHAR(255),
  plantingdate varchar(100),
  fieldsize  FLOAT8,
  expectedyielddetails VARCHAR(6500),
  additionalparameters VARCHAR(6500),
  fieldsizeuomid VARCHAR(255),
  feature VARCHAR(6500),
  center VARCHAR(255),
  geohash VARCHAR(255),
  geometryHash VARCHAR(255),
  eventid VARCHAR(255),
  eventsource VARCHAR(255),
  eventtype VARCHAR(255),
  created_at VARCHAR(255)
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_season TO gluejob;

