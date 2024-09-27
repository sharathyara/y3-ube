DROP TABLE IF EXISTS yarahive.fields;

CREATE TABLE IF NOT EXISTS yarahive.fields (
    Id VARCHAR(50) NOT NULL, -- Unique identifier for the field
    name VARCHAR(1000),
    demoSiteId VARCHAR(100),-- Name of the field
    latitude VARCHAR(100), -- Latitude of the field
    longitude VARCHAR(100), -- Longitude of the field
    boundary VARCHAR(MAX), -- Boundary information for the field
    directions VARCHAR(5000), -- Directions to the field
    totalarea DOUBLE PRECISION, -- Total area of the field
    totalareaunit VARCHAR(100) -- Unit of measurement for the total area
);

COMMENT ON TABLE yarahive.fields IS 'Table to store yarahive field data';
COMMENT ON COLUMN yarahive.fields.Id IS 'Unique identifier for the field';
COMMENT ON COLUMN yarahive.fields.name IS 'Name of the field';
COMMENT ON COLUMN yarahive.fields.demoSiteId IS 'Identitier of demosite';
COMMENT ON COLUMN yarahive.fields.latitude IS 'Latitude of the field';
COMMENT ON COLUMN yarahive.fields.longitude IS 'Longitude of the field';
COMMENT ON COLUMN yarahive.fields.boundary IS 'Boundary information for the field';
COMMENT ON COLUMN yarahive.fields.directions IS 'Directions to the field';
COMMENT ON COLUMN yarahive.fields.totalarea IS 'Total area of the field';
COMMENT ON COLUMN yarahive.fields.totalareaunit IS 'Unit of measurement for the total area';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.fields TO gluejob;
