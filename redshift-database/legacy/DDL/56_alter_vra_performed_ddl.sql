-- Altering VRA table attibute varchar too 65535

ALTER TABLE curated_schema.polaris_vra_performed ALTER COLUMN request_featureCollection TYPE VARCHAR(65535); 

ALTER TABLE curated_schema.polaris_vra_performed ALTER COLUMN response_featureCollection TYPE VARCHAR(65535); 

ALTER TABLE ffdp2_0.polaris_vra_performed ALTER COLUMN request_featureCollection TYPE VARCHAR(65535); 

ALTER TABLE ffdp2_0.polaris_vra_performed ALTER COLUMN response_featureCollection TYPE VARCHAR(65535); 