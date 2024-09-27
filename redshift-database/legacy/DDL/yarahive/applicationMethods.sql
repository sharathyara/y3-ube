drop table if exists yarahive.ApplicationMethod;

CREATE TABLE IF NOT EXISTS yarahive.ApplicationMethods (
    Id VARCHAR(24) NOT NULL,
    name VARCHAR(500),
    countries VARCHAR(10000)
);

COMMENT ON TABLE yarahive.ApplicationMethods IS 'Table to store application method details';
COMMENT ON COLUMN yarahive.ApplicationMethods.Id IS 'Unique identifier for the application method, this BSON objectID, not UUID';
COMMENT ON COLUMN yarahive.ApplicationMethods.name IS 'Application method name';
COMMENT ON COLUMN yarahive.ApplicationMethods.countries IS 'List of country IDs';

GRANT SELECT, INSERT, UPDATE, DELETE,TRUNCATE ON TABLE yarahive.ApplicationMethods TO gluejob;