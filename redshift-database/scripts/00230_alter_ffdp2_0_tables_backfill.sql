-- liquibase formatted sql

--changeset sandeep_c:ATI-7098-alter-fields-backfill splitStatements:true runOnChange:true
--comment: ATI-7098 Altering fields table to backfill the data

DROP TABLE IF EXISTS ffdp2_0.field_old;
ALTER TABLE ffdp2_0.field RENAME TO field_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.field (
    id VARCHAR(60) NOT NULL,
    organizationid varchar(60),
    userid varchar(60),
    countryid VARCHAR(60),
    regionid VARCHAR(60),
    farmid VARCHAR(60),
    fieldname VARCHAR(600),
    fieldsize DOUBLE PRECISION,
    fieldsizeuomid VARCHAR(60),
    cropregionid VARCHAR(60),
    vardafieldid VARCHAR(60),
    vardaboundaryid VARCHAR(60),
    iouscore VARCHAR(1000),
    inputbasedintersection VARCHAR(1000),
    outputbasedintersection VARCHAR(1000),
    featuredataid VARCHAR(600),
    feature SUPER,
    center VARCHAR(600),
    geohash VARCHAR(600),
    geometryhash VARCHAR(600),
    ewkt VARCHAR(600),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    additional_parameters SUPER,
    valid_from TIMESTAMP WITHOUT TIME ZONE,
    valid_to TIMESTAMP WITHOUT TIME ZONE,
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.field (
    id, organizationid, userid, countryid, regionid, farmid, fieldname, fieldsize, fieldsizeuomid,
    cropregionid, vardafieldid, vardaboundaryid, iouscore, inputbasedintersection, outputbasedintersection, 
    featuredataid, feature, center, geohash, geometryhash, ewkt, createdat, createdby, updatedat, updatedby,
    deletedat, deletedby, additional_parameters, source
)
SELECT
    id, organizationid, userid, countryid, regionid, farmid, fieldname, fieldsize, fieldsizeuomid,
    cropregionid, vardafieldid, vardaboundaryid, iouscore, inputbasedintersection, outputbasedintersection, 
    featuredataid, feature, center, geohash, geometryhash, ewkt, createdat, createdby, updatedat, updatedby,
    deletedat, deletedby, additional_parameters, source
FROM
    ffdp2_0.field_old;

ALTER TABLE ffdp2_0.field OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.field_old CASCADE;


--rollback DROP TABLE IF EXISTS ffdp2_0.field_old;
--rollback ALTER TABLE ffdp2_0.field RENAME TO field_old;

--rollback CREATE TABLE IF NOT EXISTS ffdp2_0.field (
--rollback     id VARCHAR(60) NOT NULL,
--rollback     organizationid varchar(60),
--rollback     userid varchar(60),
--rollback     countryid VARCHAR(60),
--rollback     regionid VARCHAR(60),
--rollback     farmid VARCHAR(60),
--rollback     fieldname VARCHAR(600),
--rollback     fieldsize DOUBLE PRECISION,
--rollback     fieldsizeuomid VARCHAR(60),
--rollback     cropregionid VARCHAR(60),
--rollback     vardafieldid VARCHAR(60),
--rollback     vardaboundaryid VARCHAR(60),
--rollback     iouscore VARCHAR(1000),
--rollback     inputbasedintersection VARCHAR(1000),
--rollback     outputbasedintersection VARCHAR(1000),
--rollback     featuredataid VARCHAR(600),
--rollback     feature SUPER,
--rollback     center VARCHAR(600),
--rollback     geohash VARCHAR(600),
--rollback     geometryhash VARCHAR(600),
--rollback     ewkt VARCHAR(600),
--rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
--rollback     createdby VARCHAR(600),
--rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     updatedby VARCHAR(600),
--rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     deletedby VARCHAR(600),
--rollback     additional_parameters SUPER,
--rollback     version INTEGER,
--rollback     source VARCHAR(60)
--rollback ) DISTSTYLE AUTO;

--rollback INSERT INTO ffdp2_0.field (
--rollback     id, organizationid, userid, countryid, regionid, farmid, fieldname, fieldsize, fieldsizeuomid,
--rollback     cropregionid, vardafieldid, vardaboundaryid, iouscore, inputbasedintersection, outputbasedintersection, 
--rollback     featuredataid, feature, center, geohash, geometryhash, ewkt, createdat, createdby, updatedat, updatedby,
--rollback     deletedat, deletedby, additional_parameters, source
--rollback )
--rollback SELECT
--rollback     id, organizationid, userid, countryid, regionid, farmid, fieldname, fieldsize, fieldsizeuomid,
--rollback     cropregionid, vardafieldid, vardaboundaryid, iouscore, inputbasedintersection, outputbasedintersection, 
--rollback     featuredataid, feature, center, geohash, geometryhash, ewkt, createdat, createdby, updatedat, updatedby,
--rollback     deletedat, deletedby, additional_parameters, source
--rollback FROM
--rollback     ffdp2_0.field_old;

--rollback ALTER TABLE ffdp2_0.field OWNER TO "IAM:ffdp-airflow";
--rollback DROP TABLE IF EXISTS ffdp2_0.field_old CASCADE;



--changeset sandeep_c:ATI-7098-alter-user-backfill splitStatements:true runOnChange:true
--comment: ATI-7098 Altering user table to backfill the data

DROP TABLE IF EXISTS ffdp2_0.user_old;
ALTER TABLE ffdp2_0.user RENAME TO user_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.user (
    id VARCHAR(60),
    name VARCHAR(600),
    email VARCHAR(600),
    phone VARCHAR(60),
    auth0id VARCHAR(60),
    countryid VARCHAR(60),
    zipcode VARCHAR(60),
    regionid VARCHAR(60),
    languagepreference VARCHAR(600),
    timezone VARCHAR(600),
    umopreference VARCHAR(600),
    source VARCHAR(60),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    consent BOOLEAN,
    newsletteroptin BOOLEAN,
    is_internal_user BOOLEAN,
    email_verified BOOLEAN,
    additional_parameters SUPER,
    valid_from TIMESTAMP WITHOUT TIME ZONE,
    valid_to TIMESTAMP WITHOUT TIME ZONE
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.user (
    id, name, email, phone, auth0id, countryid, zipcode, regionid, languagepreference,
    timezone, umopreference, source, createdat, createdby, updatedat, updatedby,
    deletedat, deletedby, consent, newsletteroptin, is_internal_user, email_verified,
    additional_parameters
)
SELECT
    id, name, email, phone, auth0id, countryid, zipcode, regionid, languagepreference,
    timezone, umopreference, source, createdat, createdby, updatedat, updatedby,
    deletedat, deletedby, consent, newsletteroptin, is_internal_user, email_verified,
    additional_parameters
FROM
    ffdp2_0.user_old;

ALTER TABLE ffdp2_0.user OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.user_old CASCADE;


--rollback DROP TABLE IF EXISTS ffdp2_0.user_old;
--rollback ALTER TABLE ffdp2_0.user RENAME TO user_old;

--rollback CREATE TABLE IF NOT EXISTS ffdp2_0.user (
--rollback     id VARCHAR(60),
--rollback     name VARCHAR(600),
--rollback     email VARCHAR(600),
--rollback     phone VARCHAR(60),
--rollback     auth0id VARCHAR(60),
--rollback     countryid VARCHAR(60),
--rollback     zipcode VARCHAR(60),
--rollback     regionid VARCHAR(60),
--rollback     languagepreference VARCHAR(600),
--rollback     timezone VARCHAR(600),
--rollback     umopreference VARCHAR(600),
--rollback     source VARCHAR(60),
--rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
--rollback     createdby VARCHAR(600),
--rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     updatedby VARCHAR(600),
--rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     deletedby VARCHAR(600),
--rollback     consent BOOLEAN,
--rollback     newsletteroptin BOOLEAN,
--rollback     is_internal_user BOOLEAN,
--rollback     email_verified BOOLEAN,
--rollback     additional_parameters SUPER,
--rollback     version INTEGER
--rollback ) DISTSTYLE AUTO;

--rollback INSERT INTO ffdp2_0.user (
--rollback     id, name, email, phone, auth0id, countryid, zipcode, regionid, languagepreference,
--rollback     timezone, umopreference, source, createdat, createdby, updatedat, updatedby,
--rollback     deletedat, deletedby, consent, newsletteroptin, is_internal_user, email_verified,
--rollback     additional_parameters
--rollback )
--rollback SELECT
--rollback     id, name, email, phone, auth0id, countryid, zipcode, regionid, languagepreference,
--rollback     timezone, umopreference, source, createdat, createdby, updatedat, updatedby,
--rollback     deletedat, deletedby, consent, newsletteroptin, is_internal_user, email_verified,
--rollback     additional_parameters
--rollback FROM
--rollback     ffdp2_0.user_old;

--rollback ALTER TABLE ffdp2_0.user OWNER TO "IAM:ffdp-airflow";
--rollback DROP TABLE IF EXISTS ffdp2_0.user_old CASCADE;


--changeset sandeep_c:ATI-7098-alter-user-farm-backfill splitStatements:true runOnChange:true
--comment: ATI-7098 Altering user_farm table to backfill the data

DROP TABLE IF EXISTS ffdp2_0.user_farm_old;
ALTER TABLE ffdp2_0.user_farm RENAME TO user_farm_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.user_farm (
    id VARCHAR(60),
    farmid VARCHAR(60),
    organizationid VARCHAR(60),
    userid VARCHAR(60),
    roleid VARCHAR(60),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    valid_from TIMESTAMP WITHOUT TIME ZONE,
    valid_to TIMESTAMP WITHOUT TIME ZONE,
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.user_farm (
    id, farmid, organizationid, userid, roleid,
    createdat, createdby, updatedat, updatedby, deletedat,
    deletedby, source
)
SELECT
    id, farmid, organizationid, userid, roleid,
    createdat, createdby, updatedat, updatedby, deletedat,
    deletedby,source
FROM ffdp2_0.user_farm_old;

ALTER TABLE ffdp2_0.user_farm OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.user_farm_old CASCADE;

--rollback DROP TABLE IF EXISTS ffdp2_0.user_farm_old;
--rollback ALTER TABLE ffdp2_0.user_farm RENAME TO user_farm_old;

--rollback CREATE TABLE IF NOT EXISTS ffdp2_0.user_farm (
--rollback     id VARCHAR(60),
--rollback     farmid VARCHAR(60),
--rollback     organizationid VARCHAR(60),
--rollback     userid VARCHAR(60),
--rollback     roleid VARCHAR(60),
--rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
--rollback     createdby VARCHAR(600),
--rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     updatedby VARCHAR(600),
--rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     deletedby VARCHAR(600),
--rollback     version INTEGER,
--rollback     source VARCHAR(60)
--rollback ) DISTSTYLE AUTO;

--rollback INSERT INTO ffdp2_0.user_farm (
--rollback     id, farmid, organizationid, userid, roleid,
--rollback     createdat, createdby, updatedat, updatedby, deletedat,
--rollback     deletedby
--rollback )
--rollback SELECT
--rollback     id, farmid, organizationid, userid, roleid,
--rollback     createdat, createdby, updatedat, updatedby, deletedat,
--rollback     deletedby
--rollback FROM ffdp2_0.user_farm_old;

--rollback ALTER TABLE ffdp2_0.user_farm OWNER TO "IAM:ffdp-airflow";
--rollback DROP TABLE IF EXISTS ffdp2_0.user_farm_old CASCADE;


--changeset sandeep_c:ATI-7098-alter-farm-backfill splitStatements:true runOnChange:true
--comment: ATI-7098 Altering farm table to backfill the data

DROP TABLE IF EXISTS ffdp2_0.farm_old;
ALTER TABLE ffdp2_0.farm RENAME TO farm_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.farm (
    id VARCHAR(60),
    countryid VARCHAR(60),
    regionid VARCHAR(60),
    farmname VARCHAR(600),
    address VARCHAR(1000),
    zipcode VARCHAR(600),
    farmsize DOUBLE PRECISION,
    farmsizeuomid VARCHAR(60),
    farmsizeuomname VARCHAR(600),
    nooffarmhands INTEGER,
    nooffields INTEGER,
    additional_parameters SUPER,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    valid_from TIMESTAMP WITHOUT TIME ZONE,
    valid_to TIMESTAMP WITHOUT TIME ZONE,
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.farm (
    id, countryid, regionid, farmname, address, zipcode, farmsize, farmsizeuomid,
    farmsizeuomname, nooffarmhands, nooffields, additional_parameters,
    createdat, createdby, updatedat, updatedby, deletedat, deletedby, source
)
SELECT
    id, countryid, regionid, farmname, address, zipcode, farmsize, farmsizeuomid,
    farmsizeuomname, nooffarmhands, nooffields, additional_parameters,
    createdat, createdby, updatedat, updatedby, deletedat, deletedby, source
FROM ffdp2_0.farm_old;

ALTER TABLE ffdp2_0.farm OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.farm_old CASCADE;


--rollback DROP TABLE IF EXISTS ffdp2_0.farm_old;
--rollback ALTER TABLE ffdp2_0.farm RENAME TO farm_old;

--rollback CREATE TABLE IF NOT EXISTS ffdp2_0.farm (
--rollback     id VARCHAR(60),
--rollback     countryid VARCHAR(60),
--rollback     regionid VARCHAR(60),
--rollback     farmname VARCHAR(600),
--rollback     address VARCHAR(1000),
--rollback     zipcode VARCHAR(600),
--rollback     farmsize DOUBLE PRECISION,
--rollback     farmsizeuomid VARCHAR(60),
--rollback     farmsizeuomname VARCHAR(600),
--rollback     nooffarmhands INTEGER,
--rollback     nooffields INTEGER,
--rollback     additional_parameters SUPER,
--rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
--rollback     createdby VARCHAR(600),
--rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     updatedby VARCHAR(600),
--rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
--rollback     deletedby VARCHAR(600),
--rollback     version INTEGER,
--rollback     source VARCHAR(60)
--rollback ) DISTSTYLE AUTO;

--rollback INSERT INTO ffdp2_0.farm (
--rollback     id, countryid, regionid, farmname, address, zipcode, farmsize, farmsizeuomid,
--rollback     farmsizeuomname, nooffarmhands, nooffields, additional_parameters,
--rollback     createdat, createdby, updatedat, updatedby, deletedat, deletedby,
--rollback     source
--rollback )
--rollback SELECT
--rollback     id, countryid, regionid, farmname, address, zipcode, farmsize, farmsizeuomid,
--rollback     farmsizeuomname, nooffarmhands, nooffields, additional_parameters,
--rollback     createdat, createdby, updatedat, updatedby, deletedat, deletedby,
--rollback     source
--rollback FROM ffdp2_0.farm_old;

--rollback ALTER TABLE ffdp2_0.farm OWNER TO "IAM:ffdp-airflow";
--rollback DROP TABLE IF EXISTS ffdp2_0.farm_old CASCADE;
