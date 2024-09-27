-- Altering NDVI table attibute varchar too 65535

ALTER TABLE curated_schema.polaris_ndvi_performed ALTER COLUMN imageurl TYPE VARCHAR(65535); 

ALTER TABLE ffdp2_0.polaris_ndvi_performed ALTER COLUMN imageurl TYPE VARCHAR(65535); 