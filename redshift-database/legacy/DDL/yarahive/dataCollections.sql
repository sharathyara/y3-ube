CREATE TABLE IF NOT EXISTS yarahive.DataCollections (
    Id VARCHAR(36) NOT NULL,
    demositesId VARCHAR(36) NOT NULL,
    measurementId VARCHAR(MAX), --TODO : from string get measurementID
    treatmentId VARCHAR(36),
    comment VARCHAR(MAX),
    measurementType VARCHAR(3000),
    measurementOfSample SUPER
);

COMMENT ON TABLE yarahive.DataCollections IS 'Table to store data collection information';
COMMENT ON COLUMN yarahive.DataCollections.Id IS 'Unique identifier for the data collection';
COMMENT ON COLUMN yarahive.DataCollections.demositesId IS 'Identifier for the associated demo site';
COMMENT ON COLUMN yarahive.DataCollections.measurementId IS 'Array of measurement identifiers';
COMMENT ON COLUMN yarahive.DataCollections.treatmentId IS 'Identifier for the associated treatment';
COMMENT ON COLUMN yarahive.DataCollections.comment IS 'Comment on the data collection';
COMMENT ON COLUMN yarahive.DataCollections.measurementType IS 'Type of measurement';
COMMENT ON COLUMN yarahive.DataCollections.measurementOfSample IS 'Map of measurement sample details';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.DataCollections TO gluejob;