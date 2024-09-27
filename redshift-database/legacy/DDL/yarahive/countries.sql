CREATE TABLE IF NOT EXISTS yarahive.Countries (
    Id VARCHAR(36) NOT NULL,
    code VARCHAR(255),
    name VARCHAR(255),
    enabled BOOLEAN,
    localCurrency SUPER,
    currency SUPER
);

COMMENT ON TABLE yarahive.Countries IS 'Table to store country information';
COMMENT ON COLUMN yarahive.Countries.Id IS 'Unique identifier for the country';
COMMENT ON COLUMN yarahive.Countries.code IS 'Code of the country';
COMMENT ON COLUMN yarahive.Countries.name IS 'Name of the country';
COMMENT ON COLUMN yarahive.Countries.enabled IS 'Flag to indicate if the country is enabled';
COMMENT ON COLUMN yarahive.Countries.localCurrency IS 'Local currency details';
COMMENT ON COLUMN yarahive.Countries.currency IS 'Currency details';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.Countries TO gluejob;