/******* DDL ********/

DROP TABLE IF EXISTS curated_schema.user_old;
ALTER TABLE curated_schema.user RENAME TO user_old;

CREATE TABLE IF NOT EXISTS curated_schema.user
(
  datetimeoccurred TIMESTAMP,
  userid VARCHAR(255),
  username VARCHAR(255),
  createdby VARCHAR(255),
  onboarded bool,
  clientCode varchar(50),
  createddatetime VARCHAR(255),
  modifiedby VARCHAR(255),
  modifieddatetime VARCHAR(255),
  eventSource varchar(200),
  eventtype VARCHAR(255),
  eventId varchar(200),
  created_at VARCHAR(255)
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.user TO gluejob;