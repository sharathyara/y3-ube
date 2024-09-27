CREATE TABLE IF NOT EXISTS yarahive.units (
    Id VARCHAR(36) NOT NULL,
    name VARCHAR(1000),
    category VARCHAR(1000),
    countries VARCHAR(MAX), -- ArrayType can be represented as a JSON string
    legacyId VARCHAR(1000),
    legacyCategory VARCHAR(1000),
    legacySampleSizeUnit VARCHAR(MAX) -- MapType can be represented as a JSON string
);

COMMENT ON TABLE yarahive.units IS 'Table to store unit information';
COMMENT ON COLUMN yarahive.units.Id IS 'Unique identifier for the unit';
COMMENT ON COLUMN yarahive.units.name IS 'Name of the unit';
COMMENT ON COLUMN yarahive.units.category IS 'Category of the unit';
COMMENT ON COLUMN yarahive.units.countries IS 'List of countries as JSON string';
COMMENT ON COLUMN yarahive.units.legacyId IS 'Legacy identifier for the unit';
COMMENT ON COLUMN yarahive.units.legacyCategory IS 'Legacy category of the unit';
COMMENT ON COLUMN yarahive.units.legacySampleSizeUnit IS 'Legacy sample size unit as JSON string';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.units TO gluejob;
