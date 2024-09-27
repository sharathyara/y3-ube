DROP TABLE IF EXISTS yarahive.products;

CREATE TABLE IF NOT EXISTS yarahive.products (
    Id VARCHAR(50) NOT NULL, -- Unique identifier for the product
    name VARCHAR(1000), -- Name of the product
    productType VARCHAR(1000), -- UUID of the product type
    company VARCHAR(1000), -- Company associated with the product
    applicableCountries VARCHAR(10000), -- Array of UUIDs for applicable countries
    applicableRegions VARCHAR(10000), -- Array of UUIDs for applicable regions
    applicationNutrientUnit VARCHAR(1000), -- Unit for application nutrient
    applicationRateUnit VARCHAR(1000), -- Unit for application rate
    brand VARCHAR(1000), -- Brand of the product
    dhcode VARCHAR(1000), -- DH code of the product
    nutrients SUPER, -- Array of JSON for nutrients
    originCountry VARCHAR(1000), -- UUID for the origin country
    reportName VARCHAR(1000), -- Report name of the product
    density DOUBLE PRECISION, -- Density of the product
    images VARCHAR(MAX), -- Array for images
    createdBy VARCHAR(1000), -- UUID of the creator
    createdAt TIMESTAMP, -- Creation timestamp
    updatedBy VARCHAR(1000), -- UUID of the updater
    updatedAt TIMESTAMP, -- Update timestamp
    deletedBy VARCHAR(1000), -- UUID of the deleter
    deleteAt TIMESTAMP, -- Deletion timestamp
    legacy SUPER, -- Legacy JSON data
    ec DOUBLE PRECISION, -- Electrical conductivity
    insertedViaUpdateTreatmentProductsMigration BOOLEAN -- Indicates if inserted via update treatment products migration
);

COMMENT ON TABLE yarahive.products IS 'Table to store yarahive product data';
COMMENT ON COLUMN yarahive.products.Id IS 'Unique identifier for the product';
COMMENT ON COLUMN yarahive.products.name IS 'Name of the product';
COMMENT ON COLUMN yarahive.products.productType IS 'UUID of the product type';
COMMENT ON COLUMN yarahive.products.company IS 'Company associated with the product';
COMMENT ON COLUMN yarahive.products.applicableCountries IS 'Array of UUIDs for applicable countries';
COMMENT ON COLUMN yarahive.products.applicableRegions IS 'Array of UUIDs for applicable regions';
COMMENT ON COLUMN yarahive.products.applicationNutrientUnit IS 'Unit for application nutrient';
COMMENT ON COLUMN yarahive.products.applicationRateUnit IS 'Unit for application rate';
COMMENT ON COLUMN yarahive.products.brand IS 'Brand of the product';
COMMENT ON COLUMN yarahive.products.dhcode IS 'DH code of the product';
COMMENT ON COLUMN yarahive.products.nutrients IS 'Array of JSON for nutrients';
COMMENT ON COLUMN yarahive.products.originCountry IS 'UUID for the origin country';
COMMENT ON COLUMN yarahive.products.reportName IS 'Report name of the product';
COMMENT ON COLUMN yarahive.products.density IS 'Density of the product';
COMMENT ON COLUMN yarahive.products.images IS 'Array for images';
COMMENT ON COLUMN yarahive.products.createdBy IS 'UUID of the creator';
COMMENT ON COLUMN yarahive.products.createdAt IS 'Creation timestamp';
COMMENT ON COLUMN yarahive.products.updatedBy IS 'UUID of the updater';
COMMENT ON COLUMN yarahive.products.updatedAt IS 'Update timestamp';
COMMENT ON COLUMN yarahive.products.deletedBy IS 'UUID of the deleter';
COMMENT ON COLUMN yarahive.products.deleteAt IS 'Deletion timestamp';
COMMENT ON COLUMN yarahive.products.legacy IS 'Legacy JSON data';
COMMENT ON COLUMN yarahive.products.ec IS '';
COMMENT ON COLUMN yarahive.products.insertedViaUpdateTreatmentProductsMigration IS 'Indicates if inserted via update treatment products migration';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.products TO gluejob;
