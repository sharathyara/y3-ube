DROP TABLE IF EXISTS yarahive.GrowthStagesApplications;

CREATE TABLE IF NOT EXISTS yarahive.GrowthStagesApplications (
    Id VARCHAR(36) NOT NULL,
    treatmentId VARCHAR(36),
    stage VARCHAR(255),
    applications_product VARCHAR(MAX),
    applications_rate VARCHAR(MAX), --TODO: fix to valid type as of now it is ["20.0","34.0"], ==> it should be 20.0,34.0
    applications_unit VARCHAR(MAX),
    applications_productcost VARCHAR(MAX), --TODO
    applications_applicationdate VARCHAR(MAX), --TODO
    applications_applicationmethodid VARCHAR(MAX),
    applications_productpolarisid VARCHAR(MAX),
    expectedHarvestDate VARCHAR(1000),
    unit VARCHAR(3000)
);

COMMENT ON TABLE yarahive.GrowthStagesApplications IS 'Table to store growth stages and applications information';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.Id IS 'Unique identifier for the growth stage application entry';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.treatmentId IS 'Identifier for the associated treatment';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.stage IS 'Growth stage';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.applications_product IS 'Applied product';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.applications_rate IS 'Application rate';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.applications_unit IS 'Unit of application (struct with id and name)';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.applications_productcost IS 'Cost of the applied product';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.applications_applicationdate IS 'Date of application';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.applications_applicationmethodid IS 'Identifier for the application method';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.applications_productpolarisid IS 'Polaris ID of the product';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.expectedHarvestDate IS 'Expected harvest date';
COMMENT ON COLUMN yarahive.GrowthStagesApplications.unit IS 'Unit information (struct with id and name)';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.GrowthStagesApplications TO gluejob;