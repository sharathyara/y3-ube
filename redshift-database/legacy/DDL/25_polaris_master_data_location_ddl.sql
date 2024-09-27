---- CREATING POLARIS MASTER DATA LOCATION SCHEMA ----

DROP SCHEMA IF EXISTS polaris_location CASCADE;

CREATE SCHEMA IF NOT EXISTS polaris_location;
 
GRANT USAGE ON SCHEMA polaris_location TO "IAM:ffdp-airflow";

----- CREATING POLARIS LOCATION TABLES AND GRANTING PERMISSIONS TO ffdp-airflow user-----

-- polaris_location.country

DROP TABLE IF EXISTS polaris_location.country;

CREATE TABLE IF NOT EXISTS polaris_location.country (
    id VARCHAR(60),
    name VARCHAR(255),
    translationkey VARCHAR(255),
    countryCode VARCHAR(255),
    productSetCode VARCHAR(255),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ,
    applicationTags VARCHAR(500),
    currencyId VARCHAR(60),
    isDefaultUnitSystemMetric BOOLEAN,
    windSpeedDefaultUnitId VARCHAR(60),
    precipitationAmountDefaultUnitId VARCHAR(60),
    evapotranspirationRefDefaultUnitId VARCHAR(60),
    qpfSnowAmountDefaultUnitId VARCHAR(60),
    dewPointDefaultUnitId VARCHAR(60),
    temperatureDefaultUnitId VARCHAR(60),
    availableNutrients SUPER,
    tagsConfiguration SUPER
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_location.country TO "IAM:ffdp-airflow";

-- polaris_location.currency

DROP TABLE IF EXISTS polaris_location.currency;

CREATE TABLE IF NOT EXISTS polaris_location.currency (
    id VARCHAR(60),
    name VARCHAR(255),
    code VARCHAR(255),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_location.currency TO "IAM:ffdp-airflow";

-- polaris_location.region

DROP TABLE IF EXISTS polaris_location.region;

CREATE TABLE IF NOT EXISTS polaris_location.region (
    id VARCHAR(60),
    countryId VARCHAR(60),
    name VARCHAR(255),
    translationkey VARCHAR(255),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ,
    geometryId VARCHAR(255),
    testRegion BOOLEAN,
    boundary GEOMETRY
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_location.region TO "IAM:ffdp-airflow";

-- polaris_location.spatial_ref_sys

DROP TABLE IF EXISTS polaris_location.spatial_ref_sys;

CREATE TABLE IF NOT EXISTS polaris_location.spatial_ref_sys (
    srid INTEGER,
    auth_name VARCHAR(500),
    auth_srid INTEGER,
    srtext VARCHAR(2048),
    proj4text VARCHAR(2048)
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_location.spatial_ref_sys TO "IAM:ffdp-airflow";

