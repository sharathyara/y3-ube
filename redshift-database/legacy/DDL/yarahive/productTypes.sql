DROP TABLE IF EXISTS yarahive.productTypes;

CREATE TABLE IF NOT EXISTS yarahive.productTypes (
    Id VARCHAR(50) NOT NULL,
    name VARCHAR(1000),
    applicationNutrientUnit VARCHAR(100),
    applicationRateUnit VARCHAR(100)
);

COMMENT ON TABLE yarahive.productTypes IS 'Table to store yarahive product type data';
COMMENT ON COLUMN yarahive.productTypes.Id IS 'Unique identifier for the product type';
COMMENT ON COLUMN yarahive.productTypes.name IS 'Name of the product type';
COMMENT ON COLUMN yarahive.productTypes.applicationNutrientUnit IS 'UUID of the application nutrient unit';
COMMENT ON COLUMN yarahive.productTypes.applicationRateUnit IS 'UUID of the application rate unit';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.productTypes TO gluejob;
