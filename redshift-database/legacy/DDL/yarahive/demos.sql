-- Create table yarahive.Demos
DROP table if exists yarahive.Demos;

CREATE TABLE IF NOT EXISTS yarahive.Demos (
    Id VARCHAR(5000) NOT NULL,
    demoName VARCHAR(1000),
    countryId VARCHAR(1000),
    regionId VARCHAR(1000),
    yaraLocalContact VARCHAR(5000),
    approverId VARCHAR(5000),
    budgetYear INT,
    cropId VARCHAR(5000),
    subcropId VARCHAR(5000),
    farmId Varchar(60),
    farmerId Varchar(60),
    detailedObjectives VARCHAR(5000),
    growthStageDuration SUPER,
    status VARCHAR(5000),
    isTemplate BOOLEAN,
    isReadOnly BOOLEAN,
    tools VARCHAR(1000),
    brands VARCHAR(1000),
    currency SUPER,
    createdAt TIMESTAMP WITHOUT TIME ZONE,
    createdBy VARCHAR(2000),
    updatedAt TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(2000),
    permissionDocument SUPER
);

COMMENT ON TABLE yarahive.Demos IS 'Table to store yarhive demo information';
COMMENT ON COLUMN yarahive.Demos.Id IS 'Unique identifier for the demo';
COMMENT ON COLUMN yarahive.Demos.demoName IS 'Name of the demo';
COMMENT ON COLUMN yarahive.Demos.countryId IS 'Identifier for the country';
COMMENT ON COLUMN yarahive.Demos.regionId IS 'Identifier for the region';
COMMENT ON COLUMN yarahive.Demos.yaraLocalContact IS 'Yara local the language preference';
COMMENT ON COLUMN yarahive.Demos.approverId IS 'Identifier for the approver( agronomist ID)';
COMMENT ON COLUMN yarahive.Demos.budgetYear IS 'Budget year for the demo';
COMMENT ON COLUMN yarahive.Demos.cropId IS 'Identifier for the crop';
COMMENT ON COLUMN yarahive.Demos.subcropId IS 'Identifier for the subcrop';
COMMENT ON COLUMN yarahive.Demos.farmId IS 'Identifier for the farm';
COMMENT ON COLUMN yarahive.Demos.farmerId IS 'Identifier for the farmer';
COMMENT ON COLUMN yarahive.Demos.detailedObjectives IS 'Detailed objectives of the demo';
COMMENT ON COLUMN yarahive.Demos.growthStageDuration IS 'Growth stage duration of the demo';
COMMENT ON COLUMN yarahive.Demos.status IS 'Status of the demo enum like DRAFT,SUBMITTED,APPROVED,ACTIVE etc';
COMMENT ON COLUMN yarahive.Demos.isTemplate IS 'Flag to indicate if it is a template';
COMMENT ON COLUMN yarahive.Demos.isReadOnly IS 'Flag to indicate if it is read-only';
COMMENT ON COLUMN yarahive.Demos.tools IS 'Tools used in the demo';
COMMENT ON COLUMN yarahive.Demos.brands IS 'Brands associated with the demo';
COMMENT ON COLUMN yarahive.Demos.currency IS 'Currency type';
COMMENT ON COLUMN yarahive.Demos.createdAt IS 'Timestamp of when the demo was created';
COMMENT ON COLUMN yarahive.Demos.createdBy IS 'User(agronominst) who created the demo';
COMMENT ON COLUMN yarahive.Demos.updatedAt IS 'Timestamp of when the demo was last updated';
COMMENT ON COLUMN yarahive.Demos.updatedby IS 'User(agronominst) who last updated the demo';
COMMENT ON COLUMN yarahive.Demos.permissionDocument IS 'Permission document associated with the demo provided from Farmer';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.Demos TO gluejob;
