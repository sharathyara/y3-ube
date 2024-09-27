-- liquibase formatted sql

--changeset Sharath_S:ATI-6693-updating-di-season-table splitStatements:true runOnChange:true
--comment: ATI-6693 changing schema for di-season to include clientcode

DROP TABLE IF EXISTS curated_schema.di_season_old;
ALTER TABLE curated_schema.di_season RENAME TO di_season_old;

CREATE TABLE curated_schema.di_season (
    datetimeoccurred timestamp without time zone ENCODE az64,
    sourcefile_name character varying(255) ENCODE lzo,
    sourcefile_receiveddate character varying(255) ENCODE lzo,
    sourceseasonid character varying(255) ENCODE lzo,
    sourcefieldid character varying(255) ENCODE lzo,
    seasonname character varying(255) ENCODE lzo,
    cropregionid character varying(255) ENCODE lzo,
    growthstageid character varying(255) ENCODE lzo,
    growthstagesystem character varying(255) ENCODE lzo,
    startdate character varying(255) ENCODE lzo,
    enddate character varying(255) ENCODE lzo,
    plantingdate character varying(100) ENCODE lzo,
    fieldsize double precision ENCODE raw,
    expectedyielddetails character varying(6500) ENCODE lzo,
    additionalparameters character varying(6500) ENCODE lzo,
    fieldsizeuomid character varying(255) ENCODE lzo,
    feature character varying(6500) ENCODE lzo,
    center character varying(255) ENCODE lzo,
    geohash character varying(255) ENCODE lzo,
    geometryhash character varying(255) ENCODE lzo,
    clientCode character varying(6500) ENCODE lzo,
    eventid character varying(255) ENCODE lzo,
    eventsource character varying(255) ENCODE lzo,
    eventtype character varying(255) ENCODE lzo,
    created_at character varying(255) ENCODE lzo
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_season TO gluejob;

GRANT SELECT ON TABLE curated_schema.di_season TO "IAM:ffdp-airflow";

INSERT INTO curated_schema.di_season
    (
    datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    sourceseasonid,
    sourcefieldid,
    seasonname,
    cropregionid,
    growthstageid,
    growthstagesystem,
    startdate,
    enddate,
    plantingdate,
    fieldsize,
    expectedyielddetails,
    additionalparameters,
    fieldsizeuomid,
    feature,
    center,
    geohash,
    geometryhash,
    eventid,
    eventsource,
    eventtype,
    created_at
    )
select datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    sourceseasonid,
    sourcefieldid,
    seasonname,
    cropregionid,
    growthstageid,
    growthstagesystem,
    startdate,
    enddate,
    plantingdate,
    fieldsize,
    expectedyielddetails,
    additionalparameters,
    fieldsizeuomid,
    feature,
    center,
    geohash,
    geometryhash,
    eventid,
    eventsource,
    eventtype,
    created_at
from curated_schema.di_season_old;

DROP TABLE curated_schema.di_season_old CASCADE;

--rollback DROP TABLE IF EXISTS curated_schema.di_season_old;
--rollback ALTER TABLE curated_schema.di_season RENAME TO di_season_old;

--rollback CREATE TABLE curated_schema.di_season (
--rollback     datetimeoccurred timestamp without time zone ENCODE az64,
--rollback     sourcefile_name character varying(255) ENCODE lzo,
--rollback     sourcefile_receiveddate character varying(255) ENCODE lzo,
--rollback     sourceseasonid character varying(255) ENCODE lzo,
--rollback     sourcefieldid character varying(255) ENCODE lzo,
--rollback     seasonname character varying(255) ENCODE lzo,
--rollback     cropregionid character varying(255) ENCODE lzo,
--rollback     growthstageid character varying(255) ENCODE lzo,
--rollback     growthstagesystem character varying(255) ENCODE lzo,
--rollback     startdate character varying(255) ENCODE lzo,
--rollback     enddate character varying(255) ENCODE lzo,
--rollback     plantingdate character varying(100) ENCODE lzo,
--rollback     fieldsize double precision ENCODE raw,
--rollback     expectedyielddetails character varying(6500) ENCODE lzo,
--rollback     additionalparameters character varying(6500) ENCODE lzo,
--rollback     fieldsizeuomid character varying(255) ENCODE lzo,
--rollback     feature character varying(6500) ENCODE lzo,
--rollback     center character varying(255) ENCODE lzo,
--rollback     geohash character varying(255) ENCODE lzo,
--rollback     geometryhash character varying(255) ENCODE lzo,
--rollback     eventid character varying(255) ENCODE lzo,
--rollback     eventsource character varying(255) ENCODE lzo,
--rollback     eventtype character varying(255) ENCODE lzo,
--rollback     created_at character varying(255) ENCODE lzo
--rollback );

--rollback GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_season TO gluejob;

--rollback GRANT SELECT ON TABLE curated_schema.di_season TO "IAM:ffdp-airflow";

--rollback INSERT INTO curated_schema.di_season
--rollback     (
--rollback     datetimeoccurred,
--rollback     sourcefile_name,
--rollback     sourcefile_receiveddate,
--rollback     sourceseasonid,
--rollback     sourcefieldid,
--rollback     seasonname,
--rollback     cropregionid,
--rollback     growthstageid,
--rollback     growthstagesystem,
--rollback     startdate,
--rollback     enddate,
--rollback     plantingdate,
--rollback     fieldsize,
--rollback     expectedyielddetails,
--rollback     additionalparameters,
--rollback     fieldsizeuomid,
--rollback     feature,
--rollback     center,
--rollback     geohash,
--rollback     geometryhash,
--rollback     eventid,
--rollback     eventsource,
--rollback     eventtype,
--rollback     created_at
--rollback     )
--rollback select datetimeoccurred,
--rollback     sourcefile_name,
--rollback     sourcefile_receiveddate,
--rollback     sourceseasonid,
--rollback     sourcefieldid,
--rollback     seasonname,
--rollback     cropregionid,
--rollback     growthstageid,
--rollback     growthstagesystem,
--rollback     startdate,
--rollback     enddate,
--rollback     plantingdate,
--rollback     fieldsize,
--rollback     expectedyielddetails,
--rollback     additionalparameters,
--rollback     fieldsizeuomid,
--rollback     feature,
--rollback     center,
--rollback     geohash,
--rollback     geometryhash,
--rollback     eventid,
--rollback     eventsource,
--rollback     eventtype,
--rollback     created_at
--rollback from curated_schema.di_season_old;

--rollback DROP TABLE curated_schema.di_season_old CASCADE;