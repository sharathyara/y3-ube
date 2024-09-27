-- Step 1: Alter the 'crop' table to change the data type of the 'applicationtags' column to VARCHAR(1000)
ALTER TABLE
    ffdp2_0.crop
ALTER COLUMN
    applicationtags TYPE VARCHAR(1000);

-- Step 2: Create a new table 'field_new' with the desired order of columns from the original 'field' table
CREATE TABLE ffdp2_0.field_new (
    id VARCHAR(60) NOT NULL,
    --new_columm
    organizationid VARCHAR(60),
    --new_columm
    userid VARCHAR(60),
    countryid VARCHAR(60),
    regionid VARCHAR(60),
    farmid VARCHAR(60),
    fieldname VARCHAR(600),
    fieldsize DOUBLE PRECISION,
    fieldsizeuomid VARCHAR(60),
    vardafieldid VARCHAR(60),
    vardaboundaryid VARCHAR(60),
    --new_columm
    iouscore VARCHAR(1000),
    --new_columm
    inputbasedintersection VARCHAR(1000),
    --new_columm
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
    source VARCHAR(60),
    PRIMARY KEY(id),
    FOREIGN KEY(countryid) REFERENCES ffdp2_0.country(id),
    FOREIGN KEY(regionid) REFERENCES ffdp2_0.region(id),
    FOREIGN KEY(farmid) REFERENCES ffdp2_0.farm(id)
) DISTSTYLE AUTO;

-- Step 3: Copy data from the old 'field' table to the new 'field_new' table
-- This step involves copying data from the old 'field' table to the new 'field_new' table, ensuring data integrity.
-- The new columns in 'field_new' that do not exist in the old 'field' table will be populated with NULL values.
INSERT INTO
    ffdp2_0.field_new (
        id,
        countryid,
        regionid,
        farmid,
        fieldname,
        fieldsize,
        fieldsizeuomid,
        vardafieldid,
        vardaboundaryid,
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
    countryid,
    regionid,
    farmid,
    fieldname,
    fieldsize,
    fieldsizeuomid,
    vardafieldid,
    vardaboundaryid,
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
    ffdp2_0.field;

-- Step 4: Update foreign key constraints in related tables, modifying them as needed
-- For each related table, update the foreign key constraints to reference the new 'field_new' table.
-- You may need to adjust the constraint names and specifications as necessary.
ALTER TABLE
    ffdp2_0.analysisorder_result DROP CONSTRAINT analysisorder_result_fieldid_fkey restrict;
ALTER TABLE
    ffdp2_0.analysisorder_result
ADD
    CONSTRAINT analysisorder_result_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field_new(id);


ALTER TABLE
    ffdp2_0.crop_nutrition_plan DROP CONSTRAINT crop_nutrition_plan_fieldid_fkey restrict;
ALTER TABLE
    ffdp2_0.crop_nutrition_plan
ADD
    CONSTRAINT crop_nutrition_plan_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field_new(id);


ALTER TABLE
    ffdp2_0.n_tester DROP CONSTRAINT n_tester_fieldid_fkey restrict;
ALTER TABLE
    ffdp2_0.n_tester
ADD
    CONSTRAINT n_tester_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field_new(id);


ALTER TABLE
    ffdp2_0.photo_analysis DROP CONSTRAINT photo_analysis_fieldid_fkey restrict;
ALTER TABLE
    ffdp2_0.photo_analysis
ADD
    CONSTRAINT photo_analysis_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field_new(id);


ALTER TABLE
    ffdp2_0.season DROP CONSTRAINT season_fieldid_fkey restrict;
ALTER TABLE
    ffdp2_0.season
ADD
    CONSTRAINT season_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field_new(id);


ALTER TABLE
    ffdp2_0.vra DROP CONSTRAINT vra_fieldid_fkey restrict;
ALTER TABLE
    ffdp2_0.vra
ADD
    CONSTRAINT vra_fieldid_fkey FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field_new(id);

-- Step 5: Drop the original 'field' table
DROP TABLE IF EXISTS ffdp2_0.field;

-- Step 6: Rename the new table 'field_new' to 'field'
-- When a table is renamed in Amazon Redshift, the database automatically updates references to the renamed identifier, including constraints such as foreign keys.
-- Renaming the table is a seamless operation that ensures data integrity and maintains the relationships between tables.
ALTER TABLE
    ffdp2_0.field_new RENAME TO field;

-- Step 7: Change the ownership of the 'field' table to an IAM role named "IAM:ffdp-airflow"
ALTER TABLE
    ffdp2_0.field OWNER TO "IAM:ffdp-airflow";