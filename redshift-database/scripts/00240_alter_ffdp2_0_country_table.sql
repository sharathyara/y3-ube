-- liquibase formatted sql

--changeset sandeep_c:ATI-7098-alter-country-backfill splitStatements:true runOnChange:true
--comment: ATI-7098 Altering country table to backfill the data

DROP TABLE IF EXISTS ffdp2_0.country_old;
ALTER TABLE ffdp2_0.country RENAME TO country_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.country (
    id VARCHAR(60) NOT NULL,
    countryid VARCHAR(60),
    name VARCHAR(600),
    yara_business_region VARCHAR(600),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    country_iso_code VARCHAR(60),
    country_iso3_code VARCHAR(60),
    valid_from TIMESTAMP WITHOUT TIME ZONE,
    valid_to TIMESTAMP WITHOUT TIME ZONE,
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.country (
    id, countryid, name, createdat, createdby, updatedat, updatedby,
    deletedat, deletedby, country_iso_code, country_iso3_code,
    source
)
SELECT
    id, countryid, name, createdat, createdby, updatedat, updatedby,
    deletedat, deletedby, country_iso_code, country_iso3_code,
    source
FROM
    ffdp2_0.country_old;

ALTER TABLE ffdp2_0.country OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.country_old CASCADE;


--rollback DROP TABLE IF EXISTS ffdp2_0.country_old;
--rollback ALTER TABLE ffdp2_0.country RENAME TO country_old;

--rollback CREATE TABLE IF NOT EXISTS ffdp2_0.country (
--rollback     id VARCHAR(60) NOT NULL,
--rollback     countryid VARCHAR(60),
--rollback     name VARCHAR(600),
--rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
--rollback     createdby VARCHAR(600),
--rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     updatedby VARCHAR(600),
--rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     deletedby VARCHAR(600),
--rollback     country_iso_code VARCHAR(60),
--rollback     country_iso3_code VARCHAR(60),
--rollback     version INTEGER,
--rollback     source VARCHAR(60),
--rollback     PRIMARY KEY(id)
--rollback ) DISTSTYLE AUTO;

--rollback INSERT INTO ffdp2_0.country (
--rollback     id, countryid, name, createdat, createdby, updatedat, updatedby,
--rollback     deletedat, deletedby, country_iso_code, country_iso3_code, version,
--rollback     source
--rollback )
--rollback SELECT
--rollback     id, countryid, name, createdat, createdby, updatedat, updatedby,
--rollback     deletedat, deletedby, country_iso_code, country_iso3_code, version,
--rollback     source
--rollback FROM
--rollback     ffdp2_0.country_old;

--rollback ALTER TABLE ffdp2_0.country OWNER TO "IAM:ffdp-airflow";
--rollback DROP TABLE IF EXISTS ffdp2_0.country_old CASCADE;