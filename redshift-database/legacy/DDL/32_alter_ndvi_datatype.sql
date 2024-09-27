-- Altering NDVI table attibute varchar from 225 to 2048

ALTER TABLE curated_schema.polaris_ndvi_performed ALTER COLUMN "message" TYPE VARCHAR(10000); 