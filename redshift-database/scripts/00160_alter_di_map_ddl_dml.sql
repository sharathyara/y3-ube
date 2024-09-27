-- liquibase formatted sql

--changeset Sharath_S:ATI-6693-updating-di-map-table splitStatements:true runOnChange:true
--comment: ATI-6693 changing schema for di-map to include clientcode

DROP TABLE IF EXISTS curated_schema.di_map_old;
ALTER TABLE curated_schema.di_map RENAME TO di_map_old;

CREATE TABLE curated_schema.di_map (
    datetimeoccurred timestamp without time zone ENCODE az64,
    sourcefile_name character varying(255) ENCODE lzo,
    sourcefile_receiveddate character varying(255) ENCODE lzo,
    mapfile character varying(255) ENCODE lzo,
    seasonid character varying(255) ENCODE lzo,
    filescountinzip integer ENCODE az64,
    clientCode character varying(255) ENCODE lzo,
    eventsource character varying(255) ENCODE lzo,
    eventtype character varying(255) ENCODE lzo,
    eventid character varying(255) ENCODE lzo,
    created_at character varying(255) ENCODE lzo,
    filelocation character varying(1000) ENCODE lzo,
    filesize integer ENCODE az64
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_map TO gluejob;

GRANT SELECT ON TABLE curated_schema.di_map TO "IAM:ffdp-airflow";

INSERT INTO curated_schema.di_map
    (
    datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    mapfile,
    seasonid,
    filescountinzip,
    eventsource,
    eventtype,
    eventid,
    created_at,
    filelocation,
    filesize
    )
select datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    mapfile,
    seasonid,
    filescountinzip,
    eventsource,
    eventtype,
    eventid,
    created_at,
    filelocation,
    filesize
from curated_schema.di_map_old;

DROP TABLE curated_schema.di_map_old CASCADE;

--rollback DROP TABLE IF EXISTS curated_schema.di_map_old;
--rollback ALTER TABLE curated_schema.di_map RENAME TO di_map_old;

--rollback CREATE TABLE curated_schema.di_map (
--rollback     datetimeoccurred timestamp without time zone ENCODE az64,
--rollback     sourcefile_name character varying(255) ENCODE lzo,
--rollback     sourcefile_receiveddate character varying(255) ENCODE lzo,
--rollback     mapfile character varying(255) ENCODE lzo,
--rollback     seasonid character varying(255) ENCODE lzo,
--rollback     filescountinzip integer ENCODE az64,
--rollback     eventsource character varying(255) ENCODE lzo,
--rollback     eventtype character varying(255) ENCODE lzo,
--rollback     eventid character varying(255) ENCODE lzo,
--rollback     created_at character varying(255) ENCODE lzo,
--rollback     filelocation character varying(1000) ENCODE lzo,
--rollback     filesize integer ENCODE az64
--rollback );

--rollback GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_map TO gluejob;

--rollback GRANT SELECT ON TABLE curated_schema.di_map TO "IAM:ffdp-airflow";

--rollback INSERT INTO curated_schema.di_map
--rollback     (
--rollback     datetimeoccurred,
--rollback     sourcefile_name,
--rollback     sourcefile_receiveddate,
--rollback     mapfile,
--rollback     seasonid,
--rollback     filescountinzip,
--rollback     eventsource,
--rollback     eventtype,
--rollback     eventid,
--rollback     created_at,
--rollback     filelocation,
--rollback     filesize
--rollback     )
--rollback select datetimeoccurred,
--rollback     sourcefile_name,
--rollback     sourcefile_receiveddate,
--rollback     mapfile,
--rollback     seasonid,
--rollback     filescountinzip,
--rollback     eventsource,
--rollback     eventtype,
--rollback     eventid,
--rollback     created_at,
--rollback     filelocation,
--rollback     filesize
--rollback from curated_schema.di_map_old;

--rollback DROP TABLE curated_schema.di_map_old CASCADE;