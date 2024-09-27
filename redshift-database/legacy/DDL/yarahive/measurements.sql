CREATE TABLE IF NOT EXISTS yarahive.Measurements (
    Id VARCHAR(36) NOT NULL,
    name VARCHAR(255),
    description VARCHAR(30000),
    measurementType VARCHAR(5000),
    measurementTypeId VARCHAR(36),
    measurementUnit VARCHAR(3000),
    growthstage VARCHAR(4000),
    sampleSize VARCHAR(4000)
);

COMMENT ON TABLE yarahive.Measurements IS 'Table to store measurement information';
COMMENT ON COLUMN yarahive.Measurements.Id IS 'Unique identifier for the measurement';
COMMENT ON COLUMN yarahive.Measurements.name IS 'Name of the measurement';
COMMENT ON COLUMN yarahive.Measurements.description IS 'Description of the measurement';
COMMENT ON COLUMN yarahive.Measurements.measurementType IS 'Type of measurement';
COMMENT ON COLUMN yarahive.Measurements.measurementTypeId IS 'Identifier for the measurement type';
COMMENT ON COLUMN yarahive.Measurements.measurementUnit IS 'Unit of measurement';
COMMENT ON COLUMN yarahive.Measurements.growthstage IS 'Growth stage information (struct with stage and unit)';
COMMENT ON COLUMN yarahive.Measurements.sampleSize IS 'Sample size information (struct with size, unit, and legacyUnit)';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.Measurements TO gluejob;