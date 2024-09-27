CREATE TABLE IF NOT EXISTS yarahive.treatmentMeasurementMatrix (
    Id VARCHAR(36) NOT NULL,
    treatmentId VARCHAR(36),
    measurementId VARCHAR(36)
);

COMMENT ON TABLE yarahive.treatmentMeasurementMatrix IS 'Table to store the relationship between treatments and measurements';
COMMENT ON COLUMN yarahive.treatmentMeasurementMatrix.Id IS 'Unique identifier for the treatment measurement matrix entry';
COMMENT ON COLUMN yarahive.treatmentMeasurementMatrix.treatmentId IS 'Identifier for the treatment';
COMMENT ON COLUMN yarahive.treatmentMeasurementMatrix.measurementId IS 'Identifier for the measurement';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.treatmentMeasurementMatrix TO gluejob;
