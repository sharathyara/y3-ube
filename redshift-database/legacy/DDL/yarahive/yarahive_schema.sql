-- Create schema yarahive
CREATE SCHEMA IF NOT EXISTS yarahive;

-- Grant usage access on schema
GRANT CREATE ON SCHEMA yarahive TO gluejob;
GRANT USAGE ON SCHEMA yarahive TO gluejob;