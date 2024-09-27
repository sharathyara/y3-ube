-- liquibase formatted sql

--changeset ViktorasCiumanovas:ATI-6059-Fix-the-Season-data-ingestion-issue splitStatements:true
--comment: ATI-6059 - Fix the Season data ingestion issue for super data type column - DML
INSERT INTO curated_schema.season(	datetimeoccurred, 
									id,
									seasonname,
									startdate,
									enddate, 
									cropid,
									fieldId,
									farmid, 
									fieldname, 
									fieldsize,
									expectedyield, 
									expectedyielduomid, 
									cropdescriptionid,
									additionalparameters,
									fieldsizeuomid,
									feature, 
									geometryHash,  
									createdby,  
									createddatetime, 
									modifiedby,  
									modifieddatetime,
									eventSource,  
									eventtype,
									eventId,
									created_at)
SELECT 	datetimeoccurred, 
		id,
		seasonname,
		startdate,
		enddate, 
		cropid,
		fieldId,
		farmid, 
		fieldname, 
		fieldsize,
		expectedyield, 
		expectedyielduomid, 
		cropdescriptionid,
		additionalparameters,
		fieldsizeuomid,
		CASE WHEN IS_VALID_JSON(CAST(feature AS VARCHAR(6500))) THEN JSON_PARSE(CAST(feature AS VARCHAR(6500))) ELSE feature END AS feature, 
		geometryHash,  
		createdby,  
		createddatetime, 
		modifiedby,  
		modifieddatetime,
		eventSource,  
		eventtype,
		eventId,
		created_at 
FROM curated_schema.season_old;

DROP TABLE curated_schema.season_old CASCADE;

--rollback DROP TABLE IF EXISTS curated_schema.season_old;
--rollback ALTER TABLE curated_schema.season RENAME TO season_old;
--rollback 
--rollback CREATE TABLE IF NOT EXISTS curated_schema.season
--rollback (
--rollback   datetimeoccurred TIMESTAMP, 
--rollback   id VARCHAR(255),
--rollback   seasonname VARCHAR(255),
--rollback   startdate VARCHAR(255),
--rollback   enddate VARCHAR(255), 
--rollback   cropid VARCHAR(255),
--rollback   fieldId VARCHAR(255),
--rollback   farmid VARCHAR(255), 
--rollback   fieldname VARCHAR(255), 
--rollback   fieldsize  FLOAT8,
--rollback   expectedyield FLOAT8, 
--rollback   expectedyielduomid VARCHAR(255), 
--rollback   cropdescriptionid VARCHAR(255),
--rollback   additionalparameters VARCHAR(255),
--rollback   fieldsizeuomid VARCHAR(255),
--rollback   feature VARCHAR(6500),   
--rollback   geometryHash VARCHAR(255), 
--rollback   createdby VARCHAR(255),  
--rollback   createddatetime VARCHAR(255),
--rollback   modifiedby VARCHAR(255),  
--rollback   modifieddatetime VARCHAR(255),
--rollback   eventSource VARCHAR(255),  
--rollback   eventtype VARCHAR(255),
--rollback   eventId VARCHAR(255),
--rollback   created_at VARCHAR(255)
--rollback );
--rollback 
--rollback GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.season TO gluejob;