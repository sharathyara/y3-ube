-- liquibase formatted sql

--changeset Sharath_S:ATI-6693-updating-di-farm-table splitStatements:true runOnChange:true
--comment: ATI-6693 changing schema for di-farm to include clientcode

DROP TABLE IF EXISTS curated_schema.di_farm_old;
ALTER TABLE curated_schema.di_farm RENAME TO di_farm_old;

CREATE TABLE curated_schema.di_farm (
    datetimeoccurred timestamp without time zone ENCODE az64,
    sourcefile_name character varying(255) ENCODE lzo,
    sourcefile_receiveddate character varying(255) ENCODE lzo,
    sourcefarmid character varying(255) ENCODE lzo,
    sourceuserid character varying(255) ENCODE lzo,
    farmname character varying(255) ENCODE lzo,
    regionid character varying(255) ENCODE lzo,
    countryid character varying(255) ENCODE lzo,
    address character varying(255) ENCODE lzo,
    zipcode character varying(255) ENCODE lzo,
    nooffarmhands integer ENCODE az64,
    nooffields integer ENCODE az64,
    farmsize double precision ENCODE raw,
    farmsizeuomid character varying(255) ENCODE lzo,
    clientCode character varying(255) ENCODE lzo,
    eventid character varying(255) ENCODE lzo,
    eventsource character varying(255) ENCODE lzo,
    eventtype character varying(255) ENCODE lzo,
    created_at character varying(255) ENCODE lzo
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_farm TO gluejob;

GRANT SELECT ON TABLE curated_schema.di_farm TO "IAM:ffdp-airflow";


INSERT INTO curated_schema.di_farm
    (
    datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    sourcefarmid,
    sourceuserid,
    farmname,
    regionid,
    countryid,
    address,
    zipcode,
    nooffarmhands,
    nooffields,
    farmsize,
    farmsizeuomid,
    eventid,
    eventsource,
    eventtype,
    created_at
    )
select   datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    sourcefarmid,
    sourceuserid,
    farmname,
    regionid,
    countryid,
    address,
    zipcode,
    nooffarmhands,
    nooffields,
    farmsize,
    farmsizeuomid,
    eventid,
    eventsource,
    eventtype,
    created_at
from curated_schema.di_farm_old;

DROP TABLE curated_schema.di_farm_old CASCADE;

--rollback DROP TABLE IF EXISTS curated_schema.di_farm_old;
--rollback ALTER TABLE curated_schema.di_farm RENAME TO di_farm_old;

--rollback CREATE TABLE curated_schema.di_farm (
--rollback     datetimeoccurred timestamp without time zone ENCODE az64,
--rollback     sourcefile_name character varying(255) ENCODE lzo,
--rollback     sourcefile_receiveddate character varying(255) ENCODE lzo,
--rollback     sourcefarmid character varying(255) ENCODE lzo,
--rollback     sourceuserid character varying(255) ENCODE lzo,
--rollback     farmname character varying(255) ENCODE lzo,
--rollback     regionid character varying(255) ENCODE lzo,
--rollback     countryid character varying(255) ENCODE lzo,
--rollback     address character varying(255) ENCODE lzo,
--rollback     zipcode character varying(255) ENCODE lzo,
--rollback     nooffarmhands integer ENCODE az64,
--rollback     nooffields integer ENCODE az64,
--rollback     farmsize double precision ENCODE raw,
--rollback     farmsizeuomid character varying(255) ENCODE lzo,
--rollback     eventid character varying(255) ENCODE lzo,
--rollback     eventsource character varying(255) ENCODE lzo,
--rollback     eventtype character varying(255) ENCODE lzo,
--rollback     created_at character varying(255) ENCODE lzo
--rollback );

--rollback GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_farm TO gluejob;

--rollback GRANT SELECT ON TABLE curated_schema.di_farm TO "IAM:ffdp-airflow";


--rollback INSERT INTO curated_schema.di_farm
--rollback    (
--rollback    datetimeoccurred,
--rollback    sourcefile_name,
--rollback    sourcefile_receiveddate,
--rollback     sourcefarmid,
--rollback     sourceuserid,
--rollback     farmname,
--rollback     regionid,
--rollback     countryid,
--rollback     address,
--rollback     zipcode,
--rollback     nooffarmhands,
--rollback     nooffields,
--rollback     farmsize,
--rollback     farmsizeuomid,
--rollback     eventid,
--rollback     eventsource,
--rollback     eventtype,
--rollback     created_at
--rollback     )
--rollback select   datetimeoccurred,
--rollback     sourcefile_name,
--rollback     sourcefile_receiveddate,
--rollback     sourcefarmid,
--rollback     sourceuserid,
--rollback     farmname,
--rollback     regionid,
--rollback     countryid,
--rollback     address,
--rollback     zipcode,
--rollback     nooffarmhands,
--rollback     nooffields,
--rollback     farmsize,
--rollback     farmsizeuomid,
--rollback     eventid,
--rollback     eventsource,
--rollback     eventtype,
--rollback     created_at
--rollback from curated_schema.di_farm_old;

--rollback DROP TABLE curated_schema.di_farm_old CASCADE;