CREATE TABLE IF NOT EXISTS yarahive.CropMetadata (
    Id VARCHAR(36) NOT NULL,
    key VARCHAR(255),
    value VARCHAR(MAX)
);

COMMENT ON TABLE yarahive.CropMetadata IS 'Table to store crop metadata information';
COMMENT ON COLUMN yarahive.CropMetadata.Id IS 'Unique identifier for the crop metadata entry';
COMMENT ON COLUMN yarahive.CropMetadata.key IS 'Key of the metadata';
COMMENT ON COLUMN yarahive.CropMetadata.value IS 'Value of the metadata';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.CropMetadata TO gluejob;