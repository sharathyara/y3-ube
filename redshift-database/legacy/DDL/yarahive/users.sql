CREATE TABLE IF NOT EXISTS yarahive.users (
    Id VARCHAR(36) NOT NULL,
    name VARCHAR(1000),
    email VARCHAR(1000),
    roles VARCHAR(3000), -- ArrayType can be represented as a JSON string
    language VARCHAR(256),
    businessUnits VARCHAR(256),
    countries VARCHAR(3000), -- ArrayType can be represented as a JSON string
    regions VARCHAR(5000), -- ArrayType can be represented as a JSON string
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ,
    deletedAt TIMESTAMPTZ,
    deletedBy VARCHAR(1000)
);

COMMENT ON TABLE yarahive.users IS 'Table to store user information';
COMMENT ON COLUMN yarahive.users.Id IS 'Unique identifier for the user';
COMMENT ON COLUMN yarahive.users.name IS 'Name of the user';
COMMENT ON COLUMN yarahive.users.email IS 'Email of the user';
COMMENT ON COLUMN yarahive.users.roles IS 'Roles assigned to the user as JSON string';
COMMENT ON COLUMN yarahive.users.language IS 'Preferred language of the user';
COMMENT ON COLUMN yarahive.users.businessUnits IS 'Business units associated with the user';
COMMENT ON COLUMN yarahive.users.countries IS 'Countries associated with the user as JSON string';
COMMENT ON COLUMN yarahive.users.regions IS 'Regions associated with the user as JSON string';
COMMENT ON COLUMN yarahive.users.createdAt IS 'Timestamp when the user was created';
COMMENT ON COLUMN yarahive.users.updatedAt IS 'Timestamp when the user was last updated';
COMMENT ON COLUMN yarahive.users.deletedAt IS 'Timestamp when the user was deleted';
COMMENT ON COLUMN yarahive.users.deletedBy IS 'Identifier of the user who performed the deletion';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.users TO gluejob;
