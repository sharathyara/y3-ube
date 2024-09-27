CREATE SCHEMA IF NOT EXISTS curated_schema;

GRANT CREATE ON SCHEMA curated_schema TO gluejob;
GRANT USAGE ON SCHEMA curated_schema TO gluejob;

CREATE TABLE IF NOT EXISTS curated_schema.user
(
  datetimeoccurred TIMESTAMP, 
  userid VARCHAR(255), 
  username VARCHAR(255), 
  createdby VARCHAR(255),  
  createddatetime VARCHAR(255), 
  modifiedby VARCHAR(255),  
  modifieddatetime VARCHAR(255),  
  eventtype VARCHAR(255),
  created_at VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS curated_schema.farm
(
  datetimeoccurred TIMESTAMP, 
  farmid VARCHAR(255),
  farmname VARCHAR(255),
  userid VARCHAR(255), 
  organizationId VARCHAR(255), 
  regionId VARCHAR(255), 
  countryId VARCHAR(255), 
  address VARCHAR(255), 
  zipcode VARCHAR(255), 
  noOfFarmHands INT,
  farmSizeUOMId VARCHAR(255), 
  eventId VARCHAR(255), 
  createdby VARCHAR(255),  
  createddatetime VARCHAR(255), 
  modifiedby VARCHAR(255),  
  modifieddatetime VARCHAR(255),
  eventSource VARCHAR(255),  
  eventtype VARCHAR(255),
  created_at VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS curated_schema.field
(
  datetimeoccurred TIMESTAMP, 
  fieldid VARCHAR(255),
  farmid VARCHAR(255),
  fieldname VARCHAR(255),
  userid VARCHAR(255), 
  organizationId VARCHAR(255), 
  regionId VARCHAR(255), 
  countryId VARCHAR(255), 
  fieldsize FLOAT8,
  changedfieldsize FLOAT8,
  fieldsizeuomid VARCHAR(255),
  feature VARCHAR(6500),
  center VARCHAR(255),
  geohash VARCHAR(255),
  geometryhash VARCHAR(255),
  eventId VARCHAR(255), 
  createdby VARCHAR(255),  
  createddatetime VARCHAR(255), 
  modifiedby VARCHAR(255),  
  modifieddatetime VARCHAR(255),
  eventSource VARCHAR(255),  
  eventtype VARCHAR(255),
  created_at VARCHAR(255)
);

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
  feature VARCHAR(6500), 
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

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.user TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.farm TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.field TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.season TO gluejob;

CREATE TABLE IF NOT EXISTS curated_schema.audit (
    table_name varchar(64),
    execution_ts timestamp,
    table_row_count int,
    hudi_row_count int,
    glue_job_id varchar(255)
    );

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.audit TO gluejob;

-- Third party data 
CREATE TABLE IF NOT EXISTS curated_schema.di_field
(
  datetimeoccurred TIMESTAMP, 
  sourcefile_name VARCHAR(255),
  sourcefile_receiveddate VARCHAR(255),
  sourcefieldid VARCHAR(255),
  sourcefarmid VARCHAR(255),
  fieldname VARCHAR(255),
  regionId VARCHAR(255), 
  countryId VARCHAR(255), 
  eventid VARCHAR(255), 
  eventsource VARCHAR(255),  
  eventtype VARCHAR(255),
  created_at VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS curated_schema.di_farm
(
  datetimeoccurred TIMESTAMP, 
  sourcefile_name VARCHAR(255),
  sourcefile_receiveddate VARCHAR(255),
  sourcefarmid VARCHAR(255),
  sourceuserid VARCHAR(255),
  farmname VARCHAR(255),
  regionId VARCHAR(255), 
  countryId VARCHAR(255), 
  address VARCHAR(255), 
  zipcode VARCHAR(255), 
  noOfFarmHands INT,
  nooffields INT,
  farmsize FLOAT8,
  farmSizeUOMId VARCHAR(255), 
  eventid VARCHAR(255), 
  eventsource VARCHAR(255),  
  eventtype VARCHAR(255),
  created_at VARCHAR(255)
);

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

CREATE TABLE IF NOT EXISTS curated_schema.di_user
(
  datetimeoccurred TIMESTAMP, 
  sourcefile_name VARCHAR(255),
  sourcefile_receiveddate VARCHAR(255),
  sourceuserid VARCHAR(255),
  name VARCHAR(255), 
  email VARCHAR(255), 
  phone VARCHAR(255),
  countryid VARCHAR(255),
  regionid VARCHAR(255),
  languagepreference VARCHAR(255),
  timezone VARCHAR(255),
  marketingconsent VARCHAR(255),
  dataconsent VARCHAR(255), 
  otherconsent VARCHAR(6500),
  businessentity VARCHAR(255),
  postaladdress VARCHAR(255),
  role VARCHAR(255),   
  eventid VARCHAR(255),
  eventsource VARCHAR(255),
  eventtype VARCHAR(255),
  created_at VARCHAR(255)
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_farm TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_field TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_season TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_user TO gluejob;


-- Stored procedure 
CREATE OR REPLACE PROCEDURE curated_schema.currated_redshift_postaction(INOUT schemaname character varying(256), INOUT tablename character varying(256), INOUT stagetablename character varying(256), INOUT sourcerowcount bigint, INOUT glue_job_id character varying(256), INOUT unique_key character varying(256))
AS $$
DECLARE
    table_row_count bigint;
    table_name varchar := schemaname || '.' || tablename;
    stage_table_name varchar := schemaname || '.' || stagetablename;
   	temp_audit_table_name varchar := 'temp_audit_' || glue_job_id;
BEGIN
    EXECUTE 'DELETE FROM ' || stage_table_name || ' USING ' || table_name || ' WHERE ' || table_name || '.' || quote_ident(unique_key) || ' = ' || stage_table_name || '.' || quote_ident(unique_key) || ' AND ' || table_name || '.dateTimeOccurred >= ' || stage_table_name || '.dateTimeOccurred';
    EXECUTE 'DELETE FROM ' || table_name || ' USING ' || stage_table_name || ' WHERE ' || table_name || '.' || quote_ident(unique_key) || ' = ' || stage_table_name || '.' || quote_ident(unique_key) || ' AND ' || table_name || '.dateTimeOccurred < ' || stage_table_name || '.dateTimeOccurred';
    EXECUTE 'INSERT INTO ' || table_name || ' SELECT * FROM ' || stage_table_name;
	EXECUTE 'SELECT COUNT(*) FROM ' || stage_table_name INTO table_row_count;
    RAISE INFO ' 1.Completed 3 trnx: ';
	RAISE INFO '1.1.table_row_count in stage table: %', table_row_count;
    EXECUTE 'SELECT COUNT(*) FROM ' || table_name INTO table_row_count;
    RAISE INFO '2. assigned to variable:';
    RAISE INFO '3.table_row_count in table: %', table_row_count;

    IF table_row_count != sourcerowcount THEN 
        RAISE EXCEPTION 'VALIDATION CHECK: Row count does not match: table (%), source(%)', table_row_count, sourcerowcount;
    END IF;

    EXECUTE '
        CREATE TEMPORARY TABLE ' || temp_audit_table_name || ' AS
        SELECT
            ' || quote_literal(tablename) || ' AS audittablename,
            ' || sourcerowcount || ' AS hudi_row_count,
            current_timestamp AS execution_ts,
            ' || quote_literal(glue_job_id) || ' AS glue_job_id,
            COUNT(*) AS table_row_count
        FROM
            ' || table_name;

    EXECUTE 'INSERT INTO ' || schemaname || '.audit (
        table_name,
        hudi_row_count,
        execution_ts,
        glue_job_id,
        table_row_count
    )
    SELECT
        ta.audittablename,
        hudi_row_count,
        execution_ts,
        glue_job_id,
        table_row_count
    FROM
        ' || temp_audit_table_name || ' ta';
	
    
    EXECUTE 'SELECT COUNT(*) FROM ' || stage_table_name INTO table_row_count;
  	RAISE INFO '1.1.table_row_count in stage table: %', table_row_count;
    EXECUTE 'DROP TABLE '|| temp_audit_table_name || ',' || stage_table_name;
END;
$$
LANGUAGE plpgsql;

GRANT ALL PRIVILEGES ON PROCEDURE curated_schema.currated_redshift_postaction(
    schemaname INOUT varchar,
    tablename INOUT varchar,
    stagetablename INOUT varchar,
    sourcerowcount INOUT int8,
    glue_job_id INOUT varchar,
    unique_key INOUT varchar
) TO gluejob;
