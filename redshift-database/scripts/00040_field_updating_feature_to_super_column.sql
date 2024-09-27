-- liquibase formatted sql

--changeset ViktorasCiumanovas:ATI-5962-apply-code-optimization-and-fix-field-structure splitStatements:true
--comment: ATI-5962 - Apply code optimization and fix issue in deletion workflow module with feature data type column
DROP TABLE IF EXISTS curated_schema.field_old;
ALTER TABLE curated_schema.field RENAME TO field_old;

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
  feature SUPER,
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

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.field TO gluejob;


INSERT INTO curated_schema.field(datetimeoccurred,
    fieldid,
    farmid,
    fieldname,
    userid, 
    organizationId, 
    regionId, 
    countryId, 
    fieldsize,
    changedfieldsize,
    fieldsizeuomid,
    feature,
    center,
    geohash,
    geometryhash,
    eventId, 
    createdby,  
    createddatetime, 
    modifiedby,  
    modifieddatetime,
    eventSource,  
    eventtype,
    created_at)
SELECT datetimeoccurred,
        fieldid,
        farmid,
        fieldname,
        userid, 
        organizationId, 
        regionId, 
        countryId, 
        fieldsize,
        changedfieldsize,
        fieldsizeuomid,
        feature,
        center,
        geohash,
        geometryhash,
        eventId, 
        createdby,  
        createddatetime, 
        modifiedby,  
        modifieddatetime,
        eventSource,  
        eventtype,
        created_at
FROM curated_schema.field_old;

DROP TABLE curated_schema.field_old CASCADE;


--rollback DROP TABLE IF EXISTS curated_schema.field_old;
--rollback ALTER TABLE curated_schema.field RENAME TO field_old;

--rollback CREATE TABLE IF NOT EXISTS curated_schema.field
--rollback (
--rollback   datetimeoccurred TIMESTAMP, 
--rollback   fieldid VARCHAR(255),
--rollback   farmid VARCHAR(255),
--rollback   fieldname VARCHAR(255),
--rollback   userid VARCHAR(255), 
--rollback   organizationId VARCHAR(255), 
--rollback   regionId VARCHAR(255), 
--rollback   countryId VARCHAR(255), 
--rollback   fieldsize FLOAT8,
--rollback   changedfieldsize FLOAT8,
--rollback   fieldsizeuomid VARCHAR(255),
--rollback   feature VARCHAR(6500),
--rollback   center VARCHAR(255),
--rollback   geohash VARCHAR(255),
--rollback   geometryhash VARCHAR(255),
--rollback   eventId VARCHAR(255), 
--rollback   createdby VARCHAR(255),  
--rollback   createddatetime VARCHAR(255), 
--rollback   modifiedby VARCHAR(255),  
--rollback   modifieddatetime VARCHAR(255),
--rollback   eventSource VARCHAR(255),  
--rollback   eventtype VARCHAR(255),
--rollback   created_at VARCHAR(255)
--rollback );

--rollback GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.field TO gluejob;

--rollback INSERT INTO curated_schema.field(datetimeoccurred,
--rollback     fieldid,
--rollback     farmid,
--rollback     fieldname,
--rollback     userid, 
--rollback     organizationId, 
--rollback     regionId, 
--rollback     countryId, 
--rollback     fieldsize,
--rollback     changedfieldsize,
--rollback     fieldsizeuomid,
--rollback     feature,
--rollback     center,
--rollback     geohash,
--rollback     geometryhash,
--rollback     eventId, 
--rollback     createdby,  
--rollback     createddatetime, 
--rollback     modifiedby,  
--rollback     modifieddatetime,
--rollback     eventSource,  
--rollback     eventtype,
--rollback     created_at)
--rollback SELECT datetimeoccurred,
--rollback         fieldid,
--rollback         farmid,
--rollback         fieldname,
--rollback         userid, 
--rollback         organizationId, 
--rollback         regionId, 
--rollback         countryId, 
--rollback         fieldsize,
--rollback         changedfieldsize,
--rollback         fieldsizeuomid,
--rollback         feature,
--rollback         center,
--rollback         geohash,
--rollback         geometryhash,
--rollback         eventId, 
--rollback         createdby,  
--rollback         createddatetime, 
--rollback         modifiedby,  
--rollback         modifieddatetime,
--rollback         eventSource,  
--rollback         eventtype,
--rollback         created_at
--rollback FROM curated_schema.field_old;

--rollback DROP TABLE curated_schema.field_old CASCADE;