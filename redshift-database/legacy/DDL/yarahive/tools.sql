DROP TABLE IF EXISTS yarahive.tools;

CREATE TABLE IF NOT EXISTS yarahive.tools (
    Id VARCHAR(50) NOT NULL, -- Unique identifier for the tool
    name VARCHAR(1000), -- Name of the tool
    Countries VARCHAR(10000) -- Countries where the tool is available
);

COMMENT ON TABLE yarahive.tools IS 'Table to store yarahive tool data';
COMMENT ON COLUMN yarahive.tools.Id IS 'Unique identifier for the tool';
COMMENT ON COLUMN yarahive.tools.name IS 'Name of the tool';
COMMENT ON COLUMN yarahive.tools.Countries IS 'list of Countries Id where the tool is available';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.tools TO gluejob;
