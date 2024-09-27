---- CREATING POLARIS MASTER DATA UNIT SCHEMA ----

DROP SCHEMA IF EXISTS polaris_unit CASCADE;

CREATE SCHEMA IF NOT EXISTS polaris_unit;
 
GRANT USAGE ON SCHEMA polaris_unit TO "IAM:ffdp-airflow";

----- CREATING POLARIS UNIT TABLES AND GRANTING PERMISSIONS TO ffdp-airflow user-----

-- polaris_unit.unit

DROP TABLE IF EXISTS polaris_unit.unit;

CREATE TABLE IF NOT EXISTS polaris_unit.unit (
    id VARCHAR(60),
    name VARCHAR(255),
    tags VARCHAR(600),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ,
    parentId VARCHAR(60),
    translationkey VARCHAR(255),
    precision DOUBLE PRECISION
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_unit.unit TO "IAM:ffdp-airflow";

-- polaris_unit.unit_conversion

DROP TABLE IF EXISTS polaris_unit.unit_conversion;

CREATE TABLE IF NOT EXISTS polaris_unit.unit_conversion(
    id VARCHAR(60),
    unitId VARCHAR(60),
    convertToUnitId VARCHAR(60),
    multiplier DOUBLE PRECISION,
    countryId VARCHAR(60),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ,
    conversionExpression VARCHAR(255),
    conversionExpressionTree SUPER
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_unit.unit_conversion TO "IAM:ffdp-airflow";

-- polaris_unit.unit_country

DROP TABLE IF EXISTS polaris_unit.unit_country;

CREATE TABLE IF NOT EXISTS polaris_unit.unit_country(
    id VARCHAR(60),
    unitId VARCHAR(60),
    countryId VARCHAR(60),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_unit.unit_country TO "IAM:ffdp-airflow";

-- polaris_unit.unit_tag

DROP TABLE IF EXISTS polaris_unit.unit_tag;

CREATE TABLE IF NOT EXISTS polaris_unit.unit_tag(
    id VARCHAR(60),
    name VARCHAR(255),
    created TIMESTAMPTZ,
    modified TIMESTAMPTZ,
    modifiedBy VARCHAR(255),
    deleted TIMESTAMPTZ
) DISTSTYLE AUTO;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON TABLE polaris_unit.unit_tag TO "IAM:ffdp-airflow";












