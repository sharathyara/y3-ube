-- liquibase formatted sql

--changeset Sharath_S:ATI-6378-updating-di-user-table splitStatements:true runOnChange:true
--comment: ATI-6378 changing schema for di-user

DROP TABLE IF EXISTS curated_schema.di_user_old;
ALTER TABLE curated_schema.di_user RENAME TO di_user_old;

CREATE TABLE IF NOT EXISTS curated_schema.di_user
(
    datetimeoccurred timestamp without time zone ENCODE az64,
    sourcefile_name character varying(255) ENCODE lzo,
    sourcefile_receiveddate character varying(255) ENCODE lzo,
    sourceuserid character varying(255) ENCODE lzo,
    name character varying(255) ENCODE lzo,
    email character varying(255) ENCODE lzo,
    phone character varying(255) ENCODE lzo,
    type character varying(100) ENCODE lzo,
    clientCode character varying(255) ENCODE lzo,
    deletionRequestId character varying(255) ENCODE lzo,
    countryid character varying(255) ENCODE lzo,
    regionid character varying(255) ENCODE lzo,
    languagepreference character varying(255) ENCODE lzo,
    timezone character varying(255) ENCODE lzo,
    marketingconsent character varying(255) ENCODE lzo,
    dataconsent character varying(255) ENCODE lzo,
    otherconsent character varying(6500) ENCODE lzo,
    businessentity character varying(255) ENCODE lzo,
    postaladdress character varying(255) ENCODE lzo,
    role character varying(255) ENCODE lzo,
    eventid character varying(255) ENCODE lzo,
    eventsource character varying(255) ENCODE lzo,
    eventtype character varying(255) ENCODE lzo,
    created_at character varying(255) ENCODE lzo
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_user TO gluejob;

GRANT SELECT ON TABLE curated_schema.di_user TO "IAM:ffdp-airflow";


INSERT INTO curated_schema.di_user
    (
    datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    sourceuserid,
    name,
    email,
    phone,
    countryid,
    regionid,
    languagepreference,
    timezone,
    marketingconsent,
    dataconsent,
    otherconsent,
    businessentity,
    postaladdress,
    role,
    eventid,
    eventsource,
    eventtype,
    created_at
    )
select   datetimeoccurred,
    sourcefile_name,
    sourcefile_receiveddate,
    sourceuserid,
    name,
    email,
    phone,
    countryid,
    regionid,
    languagepreference,
    timezone,
    marketingconsent,
    dataconsent,
    otherconsent,
    businessentity,
    postaladdress,
    role,
    eventid,
    eventsource,
    eventtype,
    created_at
from curated_schema.di_user_old;

DROP TABLE curated_schema.di_user_old CASCADE;

--rollback DROP TABLE IF EXISTS curated_schema.di_user_old;
--rollback ALTER TABLE curated_schema.di_user RENAME TO di_user_old;

--rollback CREATE TABLE IF NOT EXISTS curated_schema.di_user (
--rollback     datetimeoccurred timestamp without time zone ENCODE az64,
--rollback     sourcefile_name character varying(255) ENCODE lzo,
--rollback     sourcefile_receiveddate character varying(255) ENCODE lzo,
--rollback     sourceuserid character varying(255) ENCODE lzo,
--rollback     name character varying(255) ENCODE lzo,
--rollback     email character varying(255) ENCODE lzo,
--rollback     phone character varying(255) ENCODE lzo,
--rollback     countryid character varying(255) ENCODE lzo,
--rollback     regionid character varying(255) ENCODE lzo,
--rollback     languagepreference character varying(255) ENCODE lzo,
--rollback     timezone character varying(255) ENCODE lzo,
--rollback     marketingconsent character varying(255) ENCODE lzo,
--rollback     dataconsent character varying(255) ENCODE lzo,
--rollback     otherconsent character varying(6500) ENCODE lzo,
--rollback     businessentity character varying(255) ENCODE lzo,
--rollback     postaladdress character varying(255) ENCODE lzo,
--rollback     role character varying(255) ENCODE lzo,
--rollback     eventid character varying(255) ENCODE lzo,
--rollback     eventsource character varying(255) ENCODE lzo,
--rollback     eventtype character varying(255) ENCODE lzo,
--rollback     created_at character varying(255) ENCODE lzo
--rollback );

--rollback GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_user TO gluejob;

--rollback GRANT SELECT ON TABLE curated_schema.di_user TO "IAM:ffdp-airflow";

-- rollback insert into curated_schema.di_user(datetimeoccurred,
-- rollback    sourcefile_name,
-- rollback    sourcefile_receiveddate,
-- rollback    sourceuserid,
-- rollback    name,
-- rollback    email,
-- rollback    phone,
-- rollback    countryid,
-- rollback    regionid,
-- rollback    languagepreference,
-- rollback    timezone,
-- rollback    marketingconsent,
-- rollback    dataconsent,
-- rollback    otherconsent,
-- rollback    businessentity,
-- rollback    postaladdress,
-- rollback    role,
-- rollback    eventid,
-- rollback    eventsource,
-- rollback    eventtype,
-- rollback    created_at
-- rollback    )
-- rollback select
-- rollback    datetimeoccurred,
-- rollback    sourcefile_name,
-- rollback    sourcefile_receiveddate,
-- rollback    sourceuserid,
-- rollback    name,
-- rollback    email,
-- rollback    phone,
-- rollback    countryid,
-- rollback    regionid,
-- rollback    languagepreference,
-- rollback    timezone,
-- rollback    marketingconsent,
-- rollback    dataconsent,
-- rollback    otherconsent,
-- rollback    businessentity,
-- rollback    postaladdress,
-- rollback    role,
-- rollback    eventid,
-- rollback    eventsource,
-- rollback    eventtype,
-- rollback    created_at
-- rollback from curated_schema.di_user_old;

-- rollback DROP TABLE curated_schema.di_user_old CASCADE;