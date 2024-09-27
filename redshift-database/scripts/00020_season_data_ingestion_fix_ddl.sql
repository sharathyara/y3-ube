-- liquibase formatted sql

--changeset ViktorasCiumanovas:ATI-6059-Fix-the-Season-data-ingestion-issue splitStatements:true
--comment: ATI-6059 - Fix the Season data ingestion issue for super data type column - DDL
DROP TABLE IF EXISTS curated_schema.season_old;
ALTER TABLE curated_schema.season RENAME TO season_old;

CREATE TABLE IF NOT EXISTS curated_schema.season
(
  datetimeoccurred TIMESTAMP, 
  id VARCHAR(255),
  seasonname VARCHAR(255),
  startdate VARCHAR(255),
  enddate VARCHAR(255), 
  cropid VARCHAR(255),
  fieldId VARCHAR(255),
  farmid VARCHAR(255), 
  fieldname VARCHAR(255), 
  fieldsize  FLOAT8,
  expectedyield FLOAT8, 
  expectedyielduomid VARCHAR(255), 
  cropdescriptionid VARCHAR(255),
  additionalparameters VARCHAR(255),
  fieldsizeuomid VARCHAR(255),
  feature SUPER,   
  geometryHash VARCHAR(255), 
  createdby VARCHAR(255),  
  createddatetime VARCHAR(255),
  modifiedby VARCHAR(255),  
  modifieddatetime VARCHAR(255),
  eventSource VARCHAR(255),  
  eventtype VARCHAR(255),
  eventId VARCHAR(255),
  created_at VARCHAR(255)
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.season TO gluejob;

--rollback INSERT INTO curated_schema.season(	datetimeoccurred, 
--rollback 									id,
--rollback 									seasonname,
--rollback 									startdate,
--rollback 									enddate, 
--rollback 									cropid,
--rollback 									fieldId,
--rollback 									farmid, 
--rollback 									fieldname, 
--rollback 									fieldsize,
--rollback 									expectedyield, 
--rollback 									expectedyielduomid, 
--rollback 									cropdescriptionid,
--rollback 									additionalparameters,
--rollback 									fieldsizeuomid,
--rollback 									feature, 
--rollback 									geometryHash,  
--rollback 									createdby,  
--rollback 									createddatetime, 
--rollback 									modifiedby,  
--rollback 									modifieddatetime,
--rollback 									eventSource,  
--rollback 									eventtype,
--rollback 									eventId,
--rollback 									created_at)
--rollback SELECT 	datetimeoccurred, 
--rollback 		id,
--rollback 		seasonname,
--rollback 		startdate,
--rollback 		enddate, 
--rollback 		cropid,
--rollback 		fieldId,
--rollback 		farmid, 
--rollback 		fieldname, 
--rollback 		fieldsize,
--rollback 		expectedyield, 
--rollback 		expectedyielduomid, 
--rollback 		cropdescriptionid,
--rollback 		additionalparameters,
--rollback 		fieldsizeuomid,
--rollback 		CAST(feature AS VARCHAR(6500)) AS feature, 
--rollback 		geometryHash,  
--rollback 		createdby,  
--rollback 		createddatetime, 
--rollback 		modifiedby,  
--rollback 		modifieddatetime,
--rollback 		eventSource,  
--rollback 		eventtype,
--rollback 		eventId,
--rollback 		created_at 
--rollback FROM curated_schema.season_old;

--rollback DROP TABLE curated_schema.season_old CASCADE;