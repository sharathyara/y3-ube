CREATE TABLE IF NOT EXISTS yarahive.Crops (
    Id VARCHAR(36) NOT NULL,
    name VARCHAR(255),
    code INTEGER,
    enabled BOOLEAN,
    subcrop VARCHAR(255),
    country VARCHAR(2000),
    regions VARCHAR(MAX),
    cultivationDetails SUPER,
    growthStageScale VARCHAR(255),
    growthStages VARCHAR(50000),
    applicationMethods VARCHAR(MAX),
    measurements SUPER,
    yieldUnit VARCHAR(255),
    cropPriceCalculatedPerUnit VARCHAR(255),
    costAndRevenueCalculatedPerUnit VARCHAR(255),
    insertedViaUpdateDemoCropsUsingCropsOfDemoCountryMigration BOOLEAN,
    defaultCommercializationUnitsPopulatedViaMigration BOOLEAN,
    createdAt TIMESTAMP,
    updatedAt TIMESTAMP
);

COMMENT ON TABLE yarahive.Crops IS 'Table to store crop information';
COMMENT ON COLUMN yarahive.Crops.Id IS 'Unique identifier for the crop';
COMMENT ON COLUMN yarahive.Crops.name IS 'Name of the crop';
COMMENT ON COLUMN yarahive.Crops.code IS 'Code of the crop';
COMMENT ON COLUMN yarahive.Crops.enabled IS 'Flag to indicate if the crop is enabled';
COMMENT ON COLUMN yarahive.Crops.subcrop IS 'Subcrop information';
COMMENT ON COLUMN yarahive.Crops.country IS 'Country associated with the crop';
COMMENT ON COLUMN yarahive.Crops.regions IS 'Array of regions associated with the crop';
COMMENT ON COLUMN yarahive.Crops.cultivationDetails IS 'Map of cultivation details';
COMMENT ON COLUMN yarahive.Crops.growthStageScale IS 'Growth stage scale for the crop';
COMMENT ON COLUMN yarahive.Crops.growthStages IS 'Array of growth stages';
COMMENT ON COLUMN yarahive.Crops.applicationMethods IS 'Array of application methods';
COMMENT ON COLUMN yarahive.Crops.measurements IS 'Map of measurements';
COMMENT ON COLUMN yarahive.Crops.yieldUnit IS 'Unit of yield measurement';
COMMENT ON COLUMN yarahive.Crops.cropPriceCalculatedPerUnit IS 'Unit for crop price calculation';
COMMENT ON COLUMN yarahive.Crops.costAndRevenueCalculatedPerUnit IS 'Unit for cost and revenue calculation';
COMMENT ON COLUMN yarahive.Crops.insertedViaUpdateDemoCropsUsingCropsOfDemoCountryMigration IS 'Flag indicating if inserted via migration';
COMMENT ON COLUMN yarahive.Crops.defaultCommercializationUnitsPopulatedViaMigration IS 'Flag indicating if commercialization units populated via migration';
COMMENT ON COLUMN yarahive.Crops.createdAt IS 'Timestamp of creation';
COMMENT ON COLUMN yarahive.Crops.updatedAt IS 'Timestamp of last update';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.Crops TO gluejob;