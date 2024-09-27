-- liquibase formatted sql

--changeset Sharath_S:ATI-6693-updating-di-field-table splitStatements:true runOnChange:true
--comment: ATI-6693 changing schema for di-field to include clientcode

DROP TABLE IF EXISTS curated_schema.di_field_old;
ALTER TABLE curated_schema.di_field RENAME TO di_field_old;

CREATE TABLE curated_schema.di_field (
    datetimeoccurred timestamp without time zone ENCODE az64,
    sourcefile_name character varying(255) ENCODE lzo,
    sourcefile_receiveddate character varying(255) ENCODE lzo,
    sourcefieldid character varying(255) ENCODE lzo,
    sourcefarmid character varying(255) ENCODE lzo,
    fieldname character varying(255) ENCODE lzo,
    regionid character varying(255) ENCODE lzo,
    countryid character varying(255) ENCODE lzo,
    clientCode character varying(255) ENCODE lzo,
    eventid character varying(255) ENCODE lzo,
    eventsource character varying(255) ENCODE lzo,
    eventtype character varying(255) ENCODE lzo,
    created_at character varying(255) ENCODE lzo
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_field TO gluejob;

GRANT SELECT ON TABLE curated_schema.di_field TO "IAM:ffdp-airflow";

INSERT INTO curated_schema.di_field
    (
     datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    sourcefieldid,
    sourcefarmid,
    fieldname,
    regionid,
    countryid,
    eventid,
    eventsource,
    eventtype,
    created_at
    )
select  datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    sourcefieldid,
    sourcefarmid,
    fieldname,
    regionid,
    countryid,
    eventid,
    eventsource,
    eventtype,
    created_at
from curated_schema.di_field_old;

DROP TABLE curated_schema.di_field_old CASCADE;


--rollback DROP TABLE IF EXISTS curated_schema.di_field_old;
--rollback ALTER TABLE curated_schema.di_field RENAME TO di_field_old;
--rollback
--rollback CREATE TABLE curated_schema.di_field (
--rollback     datetimeoccurred timestamp without time zone ENCODE az64,
--rollback     sourcefile_name character varying(255) ENCODE lzo,
--rollback     sourcefile_receiveddate character varying(255) ENCODE lzo,
--rollback     sourcefieldid character varying(255) ENCODE lzo,
--rollback     sourcefarmid character varying(255) ENCODE lzo,
--rollback     fieldname character varying(255) ENCODE lzo,
--rollback     regionid character varying(255) ENCODE lzo,
--rollback     countryid character varying(255) ENCODE lzo,
--rollback     eventid character varying(255) ENCODE lzo,
--rollback     eventsource character varying(255) ENCODE lzo,
--rollback     eventtype character varying(255) ENCODE lzo,
--rollback     created_at character varying(255) ENCODE lzo
--rollback );
--rollback
--rollback GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_field TO gluejob;
--rollback
--rollback GRANT SELECT ON TABLE curated_schema.di_field TO "IAM:ffdp-airflow";

--rollback INSERT INTO curated_schema.di_field
--rollback     (
--rollback      datetimeoccurred,
--rollback     sourcefile_name,
--rollback     sourcefile_receiveddate,
--rollback     sourcefieldid,
--rollback     sourcefarmid,
--rollback     fieldname,
--rollback     regionid,
--rollback     countryid,
--rollback     eventid,
--rollback     eventsource,
--rollback     eventtype,
--rollback     created_at
--rollback     )
--rollback select  datetimeoccurred,
--rollback     sourcefile_name,
--rollback     sourcefile_receiveddate,
--rollback     sourcefieldid,
--rollback     sourcefarmid,
--rollback     fieldname,
--rollback     regionid,
--rollback     countryid,
--rollback     eventid,
--rollback     eventsource,
--rollback     eventtype,
--rollback     created_at
--rollback from curated_schema.di_field_old;
--rollback
--rollback DROP TABLE curated_schema.di_field_old CASCADE;