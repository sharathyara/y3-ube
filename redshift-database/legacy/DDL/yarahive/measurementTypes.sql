CREATE TABLE IF NOT EXISTS yarahive.MeasurementTypes (
    Id VARCHAR(36) NOT NULL,
    name VARCHAR(1000)
);

COMMENT ON TABLE yarahive.MeasurementTypes IS 'Table to store measurement type information';
COMMENT ON COLUMN yarahive.MeasurementTypes.Id IS 'Unique identifier for the measurement type';
COMMENT ON COLUMN yarahive.MeasurementTypes.name IS 'Name of the measurement type';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.MeasurementTypes TO gluejob;