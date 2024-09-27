CREATE TABLE IF NOT EXISTS yarahive.Media (
    Id VARCHAR(36) NOT NULL,
    demositesId VARCHAR(36) NOT NULL,
    fileId VARCHAR(10000),
    fileName VARCHAR(10000),
    name VARCHAR(2000),
    date DATE,
    growthStage VARCHAR(30000),
    measurementTypes VARCHAR(30000),
    legacyMeasurementTypes SUPER,
    thumbnailFileId VARCHAR(1000),
    treatments VARCHAR(MAX),
    comment VARCHAR(30000),
    addToReport BOOLEAN,
    createdAt TIMESTAMP,
    updatedAt TIMESTAMP
);

COMMENT ON TABLE yarahive.Media IS 'Table to store media information related to demo sites';
COMMENT ON COLUMN yarahive.Media.Id IS 'Unique identifier for the media entry';
COMMENT ON COLUMN yarahive.Media.demositesId IS 'Identifier for the associated demo site';
COMMENT ON COLUMN yarahive.Media.fileId IS 'Identifier for the associated file';
COMMENT ON COLUMN yarahive.Media.fileName IS 'Name of the file';
COMMENT ON COLUMN yarahive.Media.name IS 'Name of the media entry';
COMMENT ON COLUMN yarahive.Media.date IS 'Date associated with the media';
COMMENT ON COLUMN yarahive.Media.growthStage IS 'Growth stage information';
COMMENT ON COLUMN yarahive.Media.measurementTypes IS 'Types of measurements associated with the media';
COMMENT ON COLUMN yarahive.Media.legacyMeasurementTypes IS 'Legacy measurement types';
COMMENT ON COLUMN yarahive.Media.thumbnailFileId IS 'Identifier for the thumbnail file';
COMMENT ON COLUMN yarahive.Media.treatments IS 'Treatments associated with the media';
COMMENT ON COLUMN yarahive.Media.comment IS 'Comment on the media entry';
COMMENT ON COLUMN yarahive.Media.addToReport IS 'Flag indicating whether to add to report';
COMMENT ON COLUMN yarahive.Media.createdAt IS 'Timestamp of creation';
COMMENT ON COLUMN yarahive.Media.updatedAt IS 'Timestamp of last update';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.Media TO gluejob;