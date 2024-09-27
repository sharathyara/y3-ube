DROP TABLE IF EXISTS yarahive.powerBrands;

CREATE TABLE IF NOT EXISTS yarahive.powerBrands (
    Id VARCHAR(50) NOT NULL, -- Unique identifier for the tool
    name VARCHAR(1000), -- Name of the tool
    Countries VARCHAR(10000) -- Countries where the tool is available
);

COMMENT ON TABLE yarahive.powerBrands IS 'Table to store yarahive tool data';
COMMENT ON COLUMN yarahive.powerBrands.Id IS 'Unique identifier for the tool';
COMMENT ON COLUMN yarahive.powerBrands.name IS 'Name of the tool';
COMMENT ON COLUMN yarahive.powerBrands.Countries IS 'list of Countries Id where the tool is available';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.powerBrands TO gluejob;
