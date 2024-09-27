DROP TABLE IF EXISTS yarahive.farmers;

-- Create the Farmers table
CREATE TABLE IF NOT EXISTS yarahive.farmers (
    Id VARCHAR(50) NOT NULL,
    name VARCHAR(1000),
    phone VARCHAR(100),
    email VARCHAR(200),
    salesforceAccount VARCHAR(1000),
    businessUnitId VARCHAR(1000),
    OtherContacts SUPER
);

COMMENT ON TABLE yarahive.farmers IS 'Table to store yarahive farmers';
COMMENT ON COLUMN yarahive.farmers.Id IS 'Unique identifier for the farmer';
COMMENT ON COLUMN yarahive.farmers.name IS 'Name of the farmer';
COMMENT ON COLUMN yarahive.farmers.phone IS 'Phone number of the farmer';
COMMENT ON COLUMN yarahive.farmers.email IS 'Email address of the farmer';
COMMENT ON COLUMN yarahive.farmers.salesforceAccount IS 'Salesforce account of the farmer';
COMMENT ON COLUMN yarahive.farmers.businessUnitId IS 'Business unit ID associated with the farmer';
COMMENT ON COLUMN yarahive.farmers.OtherContacts IS 'JSON array of other contacts (name, contact, email)';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.farmers TO gluejob;
