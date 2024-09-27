drop table if exists yarahive.businessUnit;

-- Create table yarahive.businessUnits
CREATE TABLE IF NOT EXISTS yarahive.businessUnits (
    Id varchar(36) NOT NULL,
    name VARCHAR(2000)
);

COMMENT ON TABLE yarahive.businessUnits IS 'Table to store business unit information';
COMMENT ON COLUMN yarahive.businessUnits.Id IS 'Unique identifier for the business unit';
COMMENT ON COLUMN yarahive.businessUnits.name IS 'Name of the business unit';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.businessUnits TO gluejob;