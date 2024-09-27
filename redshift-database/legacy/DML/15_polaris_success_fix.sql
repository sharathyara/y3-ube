-- fixing Success Boolean Issue

-- NDVI

UPDATE curated_schema.polaris_ndvi_performed 
SET success = false 
WHERE (message IS NOT NULL AND message <> 'None') AND success = true;

-- Yield Estimation

UPDATE curated_schema.polaris_yield_estimation_performed 
SET success = false 
WHERE (message IS NOT NULL AND message <> 'None') AND success = true;

-- NUE

UPDATE curated_schema.polaris_nue_performed 
SET response_success = false 
WHERE (response_message IS NOT NULL AND response_message <> 'None') AND response_success = true;

-- GHG

UPDATE curated_schema.polaris_ghg_performed 
SET response_success = false 
WHERE (response_message IS NOT NULL AND response_message <> 'None') AND response_success = true;

-- NUptake

UPDATE curated_schema.polaris_n_uptake_performed 
SET response_success = false 
WHERE (response_message IS NOT NULL AND response_message <> 'None') AND response_success = true;