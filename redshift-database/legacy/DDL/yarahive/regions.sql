CREATE TABLE IF NOT EXISTS yarahive.Regions (
    Id VARCHAR(36) NOT NULL,
    code VARCHAR(255),
    name VARCHAR(255),
    enabled BOOLEAN,
    countryId VARCHAR(36)
);

COMMENT ON TABLE yarahive.Regions IS 'Table to store region information';
COMMENT ON COLUMN yarahive.Regions.Id IS 'Unique identifier for the region';
COMMENT ON COLUMN yarahive.Regions.code IS 'Code of the region';
COMMENT ON COLUMN yarahive.Regions.name IS 'Name of the region';
COMMENT ON COLUMN yarahive.Regions.enabled IS 'Flag to indicate if the region is enabled';
COMMENT ON COLUMN yarahive.Regions.countryId IS 'Identifier for the country';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.Regions TO gluejob;