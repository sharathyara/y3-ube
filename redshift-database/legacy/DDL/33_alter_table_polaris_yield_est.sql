ALTER TABLE curated_schema.polaris_yield_estimation_performed ALTER COLUMN message TYPE VARCHAR(10000);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_yield_estimation_performed TO gluejob;