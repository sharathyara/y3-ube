---- CREATING POLARIS MASTER DATA CROP SCHEMA ----

DROP SCHEMA IF EXISTS polaris_crop CASCADE;

CREATE SCHEMA IF NOT EXISTS polaris_crop;
 
GRANT USAGE ON SCHEMA polaris_crop TO "IAM:ffdp-airflow";

----- CREATING POLARIS CROP TABLES AND GRANTING PERMISSIONS TO ffdp-airflow user-----

-- polaris_crop.crop_class

DROP TABLE IF EXISTS polaris_crop.crop_class;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_class (
    id VARCHAR(60),
    defaultGrowthScaleId VARCHAR(60),
    faoId DOUBLE PRECISION,
    name VARCHAR(255),
    cropGroupId VARCHAR(60),
    translationkey VARCHAR(255),
    expressiveName VARCHAR(255),
    mediaUri SUPER,
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_class TO "IAM:ffdp-airflow";

--  polaris_crop.crop_description

DROP TABLE IF EXISTS  polaris_crop.crop_description;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_description (
    id VARCHAR(60),
    cropSubClassId VARCHAR(60),
    name VARCHAR(255),
    translationkey VARCHAR(255),
    expressiveName VARCHAR(255),
    atFarmCropType VARCHAR(255),
    chlorideSensitive BOOLEAN,
    mediaUri SUPER,
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ,
    grainProteinPercentage DOUBLE PRECISION
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_description TO "IAM:ffdp-airflow";

--  polaris_crop.crop_description_variety

DROP TABLE IF EXISTS  polaris_crop.crop_description_variety;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_description_variety (
    id VARCHAR(60),
    cropVarietyId VARCHAR(60),
    cropDescriptionId VARCHAR(60),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    deleted TIMESTAMPTZ,
    modifiedBy VARCHAR(255)
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_description_variety TO "IAM:ffdp-airflow";

-- polaris_crop.crop_group

DROP TABLE IF EXISTS polaris_crop.crop_group;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_group(
    id VARCHAR(60),
    faoId DOUBLE PRECISION,
    name VARCHAR(255),
    translationkey VARCHAR(255),
    expressiveName VARCHAR(255),
    mediaUri SUPER,
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_group TO "IAM:ffdp-airflow";

-- polaris_crop.crop_region

DROP TABLE IF EXISTS polaris_crop.crop_region;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_region(
    id VARCHAR(60),
    cropDescriptionId VARCHAR(60),
    countryId VARCHAR(60),
    regionId VARCHAR(60),
    growthScaleId VARCHAR(60),
    yieldBaseUnitId VARCHAR(60),
    demandBaseUnitId VARCHAR(60),
    defaultYield DOUBLE PRECISION,
    defaultSeedingDate TIMESTAMPTZ,
    defaultHarvestDate TIMESTAMPTZ,
    residuesRemovedN DOUBLE PRECISION,
    residuesLeftN DOUBLE PRECISION,
    residuesIncorporatedSpringN DOUBLE PRECISION,
    residueNUptake DOUBLE PRECISION,
    grainNUptake DOUBLE PRECISION,
    residueFactor DOUBLE PRECISION,
    nutrientUseEfficiency DOUBLE PRECISION,
    applicationTags VARCHAR(500),
    additionalProperties SUPER,
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ,
    agroCoreCode INTEGER,
    calculationParameters SUPER,
    tagsConfiguration SUPER
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_region TO "IAM:ffdp-airflow";

-- polaris_crop.crop_residue_management

DROP TABLE IF EXISTS polaris_crop.crop_residue_management;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_residue_management(
    id VARCHAR(60),
    name VARCHAR(255),
    translationkey VARCHAR(255),
    expressiveName VARCHAR(255),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_residue_management TO "IAM:ffdp-airflow";

-- polaris_crop.crop_residue_management_country

DROP TABLE IF EXISTS polaris_crop.crop_residue_management_country;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_residue_management_country(
    id VARCHAR(60),
    cropResidueManagementId VARCHAR(60),
    countryId VARCHAR(60),
    name VARCHAR(255),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_residue_management_country TO "IAM:ffdp-airflow";

-- polaris_crop.crop_sequence

DROP TABLE IF EXISTS polaris_crop.crop_sequence;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_sequence(
    id VARCHAR(60),
    cropRegionID VARCHAR(60),
    cropDescriptionId VARCHAR(60),
    isPreCrop BOOLEAN,
    isPostCrop BOOLEAN,
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    deleted TIMESTAMPTZ,
    modifiedBy VARCHAR(255)
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_sequence TO "IAM:ffdp-airflow";

-- polaris_crop.crop_sub_class

DROP TABLE IF EXISTS polaris_crop.crop_sub_class;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_sub_class(
    id VARCHAR(60),
    faoId DOUBLE PRECISION,
    name VARCHAR(255),
    cropClassId VARCHAR(60),
    translationkey VARCHAR(255),
    expressiveName VARCHAR(255),
    mediaUri SUPER,
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_sub_class TO "IAM:ffdp-airflow";

-- polaris_crop.crop_variety

DROP TABLE IF EXISTS polaris_crop.crop_variety;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_variety(
    id VARCHAR(60),
    cropSubClassId VARCHAR(60),
    name VARCHAR(255),
    mediaUri SUPER,
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    deleted TIMESTAMPTZ,
    modifiedBy VARCHAR(255)
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_variety TO "IAM:ffdp-airflow";

-- polaris_crop.crop_variety_country

DROP TABLE IF EXISTS polaris_crop.crop_variety_country;

CREATE TABLE IF NOT EXISTS polaris_crop.crop_variety_country(
    id VARCHAR(60),
    countryId VARCHAR(60),
    cropVarietyId VARCHAR(60),
    cropSubClassId VARCHAR(60),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_crop.crop_variety_country TO "IAM:ffdp-airflow";


