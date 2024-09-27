-- liquibase formatted sql

--changeset SaveethaAnnamalai:ATI-6230-adding-cropregionid-to-field-entity splitStatements:true
--comment: ATI-6230 - Adding cropregionid to field entity 
DROP TABLE IF EXISTS ffdp2_0.field_old;
ALTER TABLE ffdp2_0.field RENAME TO field_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.field
(
    id VARCHAR(60),
    organizationid VARCHAR(60),
    userid VARCHAR(60),
    countryid VARCHAR(60),
    regionid VARCHAR(60),
    farmid VARCHAR(60),
    fieldname VARCHAR(600),
    fieldsize DOUBLE PRECISION,
    fieldsizeuomid VARCHAR(60),
    --new column
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
    version INTEGER,
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO
    ffdp2_0.field (
        id,
        organizationid,
        userid,
        countryid,
        regionid,
        farmid,
        fieldname,
        fieldsize,
        fieldsizeuomid,
        vardafieldid,
        vardaboundaryid,
        iouscore,
        inputbasedintersection,
        outputbasedintersection,
        featuredataid,
        feature,
        center,
        geohash,
        geometryhash,
        ewkt,
        createdat,
        createdby,
        updatedat,
        updatedby,
        deletedat,
        deletedby,
        additional_parameters,
        version,
        source
    )
SELECT
    id,
    organizationid,
    userid,
    countryid,
    regionid,
    farmid,
    fieldname,
    fieldsize,
    fieldsizeuomid,
    vardafieldid,
    vardaboundaryid,
    iouscore,
    inputbasedintersection,
    outputbasedintersection,
    featuredataid,
    feature,
    center,
    geohash,
    geometryhash,
    ewkt,
    createdat,
    createdby,
    updatedat,
    updatedby,
    deletedat,
    deletedby,
    additional_parameters,
    version,
    source
FROM
    ffdp2_0.field_old;


-- Changing the ownership of the 'field' table to an IAM role named "ffdp-airflow"
ALTER TABLE
    ffdp2_0.field OWNER TO "IAM:ffdp-airflow";

DROP TABLE ffdp2_0.field_old CASCADE;

-- rollback DROP TABLE IF EXISTS ffdp2_0.field_old;
-- rollback ALTER TABLE ffdp2_0.field RENAME TO field_old;

-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.field
-- rollback (
-- rollback    id VARCHAR(60) NOT NULL,
-- rollback    organizationid VARCHAR(60),
-- rollback    userid VARCHAR(60),
-- rollback    countryid VARCHAR(60),
-- rollback    regionid VARCHAR(60),
-- rollback    farmid VARCHAR(60),
-- rollback    fieldname VARCHAR(600),
-- rollback    fieldsize DOUBLE PRECISION,
-- rollback    fieldsizeuomid VARCHAR(60),
-- rollback    vardafieldid VARCHAR(60),
-- rollback    vardaboundaryid VARCHAR(60),
-- rollback    iouscore VARCHAR(1000),
-- rollback    inputbasedintersection VARCHAR(1000),
-- rollback    outputbasedintersection VARCHAR(1000),
-- rollback    featuredataid VARCHAR(600),
-- rollback    feature SUPER,
-- rollback    center VARCHAR(600),
-- rollback    geohash VARCHAR(600),
-- rollback    geometryhash VARCHAR(600),
-- rollback    ewkt VARCHAR(600),
-- rollback    createdat TIMESTAMP WITHOUT TIME ZONE,
-- rollback    createdby VARCHAR(600),
-- rollback    updatedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback    updatedby VARCHAR(600),
-- rollback    deletedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback    deletedby VARCHAR(600),
-- rollback    additional_parameters SUPER,
-- rollback    version INTEGER,
-- rollback    source VARCHAR(60),
-- rollback    PRIMARY KEY(id),
-- rollback    FOREIGN KEY(organizationid) REFERENCES ffdp2_0.organization(id),
-- rollback    FOREIGN KEY(userid) REFERENCES ffdp2_0.user(id),
-- rollback    FOREIGN KEY(countryid) REFERENCES ffdp2_0.country(id),
-- rollback    FOREIGN KEY(regionid) REFERENCES ffdp2_0.region(id),
-- rollback    FOREIGN KEY(farmid) REFERENCES ffdp2_0.farm(id)
-- rollback ) DISTSTYLE AUTO;
 
-- rollback   ALTER TABLE ffdp2_0.analysisorder_result
-- rollback   ADD CONSTRAINT analysisorder_result_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field(id);

-- rollback   ALTER TABLE ffdp2_0.crop_nutrition_plan
-- rollback   ADD CONSTRAINT crop_nutrition_plan_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field(id);

-- rollback   ALTER TABLE ffdp2_0.n_tester
-- rollback   ADD CONSTRAINT n_tester_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field(id);

-- rollback   ALTER TABLE ffdp2_0.photo_analysis
-- rollback   ADD CONSTRAINT photo_analysis_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field(id);

-- rollback   ALTER TABLE ffdp2_0.season
-- rollback   ADD CONSTRAINT season_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field(id);

-- rollback   ALTER TABLE ffdp2_0.vra
-- rollback   ADD CONSTRAINT vra_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field(id);

-- rollback   ALTER TABLE ffdp2_0.field OWNER TO "IAM:ffdp-airflow";

-- rollback INSERT INTO ffdp2_0.field (
-- rollback        id,
-- rollback        organizationid,
-- rollback        userid,
-- rollback        countryid,
-- rollback        regionid,
-- rollback        farmid,
-- rollback        fieldname,
-- rollback        fieldsize,
-- rollback        fieldsizeuomid,
-- rollback        vardafieldid,
-- rollback        vardaboundaryid,
-- rollback        iouscore,
-- rollback        inputbasedintersection,
-- rollback        outputbasedintersection,
-- rollback        featuredataid,
-- rollback        feature,
-- rollback        center,
-- rollback        geohash,
-- rollback        geometryhash,
-- rollback        ewkt,
-- rollback        createdat,
-- rollback        createdby,
-- rollback        updatedat,
-- rollback        updatedby,
-- rollback        deletedat,
-- rollback        deletedby,
-- rollback        additional_parameters,
-- rollback        version,
-- rollback        source)
-- rollback SELECT
-- rollback    id,
-- rollback    organizationid,
-- rollback    userid,
-- rollback    countryid,
-- rollback    regionid,
-- rollback    farmid,
-- rollback    fieldname,
-- rollback    fieldsize,
-- rollback    fieldsizeuomid,
-- rollback    vardafieldid,
-- rollback    vardaboundaryid,
-- rollback    iouscore,
-- rollback    inputbasedintersection,
-- rollback    outputbasedintersection,
-- rollback    featuredataid,
-- rollback    feature,
-- rollback    center,
-- rollback    geohash,
-- rollback    geometryhash,
-- rollback    ewkt,
-- rollback    createdat,
-- rollback    createdby,
-- rollback    updatedat,
-- rollback    updatedby,
-- rollback    deletedat,
-- rollback    deletedby,
-- rollback    additional_parameters,
-- rollback    version,
-- rollback    source
-- rollback FROM
-- rollback    ffdp2_0.field_old;
-- rollback DROP TABLE ffdp2_0.field_old CASCADE;


 
