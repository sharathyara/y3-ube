-- Segment table migration

-- FFDP2_0.segment_combined_soil_calculation_performed

DROP TABLE IF EXISTS ffdp2_0.segment_combined_soil_calculation_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.segment_combined_soil_calculation_performed
(
  id VARCHAR(512) NOT NULL,
  received_at TIMESTAMP WITHOUT TIME ZONE,
  uuid BIGINT,
  "timestamp" TIMESTAMP WITHOUT TIME ZONE,
  uuid_ts TIMESTAMP WITHOUT TIME ZONE,
  yield DOUBLE PRECISION,
  country VARCHAR(512),
  email VARCHAR(512),
  size_unit_id VARCHAR(512),
  solution VARCHAR(512),
  event_text VARCHAR(512),
  "region" VARCHAR(512),
  size DOUBLE PRECISION,
  yield_unit_id VARCHAR(512),
  crop_region_id VARCHAR(512),
  event_id VARCHAR(512),
  sent_at TIMESTAMP WITHOUT TIME ZONE,
  user_id VARCHAR(512),
  original_timestamp TIMESTAMP WITHOUT TIME ZONE,
  context_library_name VARCHAR(512),
  context_library_version VARCHAR(512),
  crop VARCHAR(512),
  event VARCHAR(512),
  context_event_transformed VARCHAR(512) 
);

COMMENT ON TABLE ffdp2_0.segment_combined_soil_calculation_performed IS 'This Table has the Segment Data of the Combined soil calculation Performed.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.id IS 'ID of Combined soil calculation Performed.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.received_at IS 'Segment - When Segment received the identify call.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.uuid IS 'Segment - The UUID column is used to prevent duplicates.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.timestamp IS 'Segment - The timestamp column is the UTC-converted timestamp which is set by the Segment library.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.uuid_ts IS 'Segment - The uuid_ts column is used to keep track of when the specific event was last processed by our connector, specifically for deduping and debugging purposes.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.yield IS 'yield.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.country IS 'Name of the Country.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.email IS 'email ID.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.size_unit_id IS 'size unit ID';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.solution IS 'Solution in which the Combined soil calculation performed.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.event_text IS 'Segment - The name of the event.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.region IS 'Region.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.size IS 'size of the field.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.yield_unit_id IS 'yield unit.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.crop_region_id IS 'ID of the CropRegion.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.event_id IS 'Segment - The unique ID of the track call itself.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.sent_at IS 'Segment - When a user triggered the track call.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.user_id IS 'Segment - The unique ID of the user.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.original_timestamp IS 'Segment - The original_timestamp column is the original timestamp set by the Segment library at the time the event is created.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.context_library_name IS 'Segment - element in library object, Name of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.context_library_version IS 'Segment - element in library object, Version of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.crop IS 'Name of the crop.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.event IS 'Segment - The slug of the event name, so you can join the tracks table.';

COMMENT ON COLUMN ffdp2_0.segment_combined_soil_calculation_performed.context_event_transformed IS 'context event transformed.';

ALTER TABLE ffdp2_0.segment_combined_soil_calculation_performed OWNER TO "IAM:ffdp-airflow";

----------------------------------------------------

-- FFDP2_0.segment_ghg_performed

DROP TABLE IF EXISTS ffdp2_0.segment_ghg_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.segment_ghg_performed
(
  id VARCHAR(512) NOT NULL,
  received_at TIMESTAMP WITHOUT TIME ZONE,
  uuid BIGINT,
  context_library_version VARCHAR(512),
  solution VARCHAR(512),
  uuid_ts TIMESTAMP WITHOUT TIME ZONE,
  email VARCHAR(512),
  "region" VARCHAR(512),
  "timestamp" TIMESTAMP WITHOUT TIME ZONE,
  user_id VARCHAR(512),
  event_text VARCHAR(512),
  original_timestamp TIMESTAMP WITHOUT TIME ZONE,
  sent_at TIMESTAMP WITHOUT TIME ZONE,
  context_library_name VARCHAR(512),
  country VARCHAR(512),
  crop VARCHAR(512),
  event VARCHAR(512),
  event_id VARCHAR(512),
  crop_region_id VARCHAR(512),
  context_event_transformed VARCHAR(512)
);

COMMENT ON TABLE ffdp2_0.segment_ghg_performed IS 'This Table has the Segment Data of the GHG Performed.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.id IS 'ID of GHG Performed.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.received_at IS 'Segment - When Segment received the identify call.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.uuid IS 'Segment - The UUID column is used to prevent duplicates.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.context_library_version IS 'Segment - element in library object, Version of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.solution IS 'Solution in which the GHG is Performed.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.uuid_ts IS 'Segment - The uuid_ts column is used to keep track of when the specific event was last processed by our connector, specifically for deduping and debugging purposes.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.email IS 'email ID.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.region IS 'region.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.timestamp IS 'Segment - The timestamp column is the UTC-converted timestamp which is set by the Segment library.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.user_id IS 'Segment - The unique ID of the user.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.event_text IS 'Segment - The name of the event.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.original_timestamp IS 'Segment - The original_timestamp column is the original timestamp set by the Segment library at the time the event is created.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.sent_at IS 'Segment - When a user triggered the track call.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.context_library_name IS 'Segment - element in library object, Name of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.country IS 'Name of the Country.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.crop IS 'Name of the crop.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.event IS 'Segment - The slug of the event name, so you can join the tracks table.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.event_id IS 'Segment - The unique ID of the track call itself.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.crop_region_id IS 'ID of the CropRegion.';

COMMENT ON COLUMN ffdp2_0.segment_ghg_performed.context_event_transformed IS 'context event transformed.';

ALTER TABLE ffdp2_0.segment_ghg_performed OWNER TO "IAM:ffdp-airflow";

----------------------------------------------------

-- FFDP2_0.segment_n_sensor_biomass_performed

DROP TABLE IF EXISTS ffdp2_0.segment_n_sensor_biomass_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.segment_n_sensor_biomass_performed
(
  id VARCHAR(512) NOT NULL,
  received_at TIMESTAMP WITHOUT TIME ZONE,
  uuid BIGINT,
  context_library_name VARCHAR(512),
  crop VARCHAR(512),
  event_text VARCHAR(512),
  sent_at TIMESTAMP WITHOUT TIME ZONE,
  size_unit_id VARCHAR(512),
  email VARCHAR(512),
  original_timestamp TIMESTAMP WITHOUT TIME ZONE,
  size DOUBLE PRECISION,
  "timestamp" TIMESTAMP WITHOUT TIME ZONE,
  user_id VARCHAR(512),
  uuid_ts TIMESTAMP WITHOUT TIME ZONE,
  country VARCHAR(512),
  event_id VARCHAR(512),
  context_library_version VARCHAR(512),
  crop_region_id VARCHAR(512),
  event VARCHAR(512),
  "region" VARCHAR(512),
  solution VARCHAR(512),
  extrapolation BOOLEAN,
  context_event_transformed VARCHAR(512)
);

COMMENT ON TABLE ffdp2_0.segment_n_sensor_biomass_performed IS 'This Table has the Segment Data of the N Sensor BioMass Performed.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.id IS 'ID of N Sensor BioMass Performed.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.received_at IS 'Segment - When Segment received the identify call.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.uuid IS 'Segment - The UUID column is used to prevent duplicates.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.context_library_name IS 'Segment - element in library object, Name of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.crop IS 'Name of the crop.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.event_text IS 'Segment - The name of the event.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.sent_at IS 'Segment - When a user triggered the track call.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.size_unit_id IS 'size unit ID.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.email IS 'Email ID.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.original_timestamp IS 'Segment - The original_timestamp column is the original timestamp set by the Segment library at the time the event is created.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.size IS 'size of the field.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.timestamp IS 'Segment - The timestamp column is the UTC-converted timestamp which is set by the Segment library.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.user_id IS 'Segment - The unique ID of the user.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.uuid_ts IS 'Segment - The uuid_ts column is used to keep track of when the specific event was last processed by our connector, specifically for deduping and debugging purposes.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.country IS 'Name of the Country.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.event_id IS 'Segment - The unique ID of the track call itself.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.context_library_version IS 'Segment - element in library object, Version of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.crop_region_id IS 'ID of the CropRegion.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.event IS 'Segment - The slug of the event name, so you can join the tracks table.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.region IS 'Region';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.solution IS 'Solution in which the N Sensor BioMass is Performed.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.extrapolation IS 'extrapolation.';

COMMENT ON COLUMN ffdp2_0.segment_n_sensor_biomass_performed.context_event_transformed IS 'context event transformed.';

ALTER TABLE ffdp2_0.segment_n_sensor_biomass_performed OWNER TO "IAM:ffdp-airflow";

----------------------------------------------------

-- FFDP2_0.segment_n_uptake_performed

DROP TABLE IF EXISTS ffdp2_0.segment_n_uptake_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.segment_n_uptake_performed
(
  id VARCHAR(512) NOT NULL,
  received_at TIMESTAMP WITHOUT TIME ZONE,
  uuid BIGINT,
  context_library_name VARCHAR(512),
  crop VARCHAR(512),
  sent_at TIMESTAMP WITHOUT TIME ZONE,
  size_unit_id VARCHAR(512),
  user_id VARCHAR(512),
  email VARCHAR(512),
  "region" VARCHAR(512),
  context_library_version VARCHAR(512),
  country VARCHAR(512),
  crop_region_id VARCHAR(512),
  event_text VARCHAR(512),
  size DOUBLE PRECISION,
  event VARCHAR(512),
  event_id VARCHAR(512),
  original_timestamp TIMESTAMP WITHOUT TIME ZONE,
  solution VARCHAR(512),
  "timestamp" TIMESTAMP WITHOUT TIME ZONE,
  uuid_ts TIMESTAMP WITHOUT TIME ZONE,
  extrapolation BOOLEAN,
  context_event_transformed VARCHAR(512)
);

COMMENT ON TABLE ffdp2_0.segment_n_uptake_performed IS 'This Table has the Segment Data of the N Uptake Performed.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.id IS 'ID of N uptake Performed.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.received_at IS 'Segment - When Segment received the identify call.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.uuid IS 'Segment - The UUID column is used to prevent duplicates.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.context_library_name IS 'Segment - element in library object, Name of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.crop IS 'Name of the crop.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.sent_at IS 'Segment - When a user triggered the track call.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.size_unit_id IS 'size unit ID.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.user_id IS 'Segment - The unique ID of the user.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.email IS 'Email ID.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.region IS 'Region.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.context_library_version IS 'Segment - element in library object, Version of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.country IS 'Name of the Country.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.crop_region_id IS 'ID of the CropRegion.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.event_text IS 'Segment - The name of the event.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.size IS 'size of the field.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.event IS 'Segment - The slug of the event name, so you can join the tracks table.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.event_id IS 'Segment - The unique ID of the track call itself.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.original_timestamp IS 'Segment - The original_timestamp column is the original timestamp set by the Segment library at the time the event is created.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.solution IS 'Solution in which the N Uptake performed.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.timestamp IS 'Segment - The timestamp column is the UTC-converted timestamp which is set by the Segment library.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.uuid_ts IS 'Segment - The uuid_ts column is used to keep track of when the specific event was last processed by our connector, specifically for deduping and debugging purposes.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.extrapolation IS 'Extrapolation.';

COMMENT ON COLUMN ffdp2_0.segment_n_uptake_performed.context_event_transformed IS 'context event transformed.';

ALTER TABLE ffdp2_0.segment_n_uptake_performed OWNER TO "IAM:ffdp-airflow";

----------------------------------------------------

-- FFDP2_0.segment_ndvi_performed

DROP TABLE IF EXISTS ffdp2_0.segment_ndvi_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.segment_ndvi_performed
(
  id VARCHAR(512) NOT NULL,
  received_at TIMESTAMP WITHOUT TIME ZONE,
  uuid BIGINT,
  context_library_name VARCHAR(512),
  email VARCHAR(512),
  event VARCHAR(512),
  event_text VARCHAR(512),
  original_timestamp TIMESTAMP WITHOUT TIME ZONE,
  crop VARCHAR(512),
  event_id VARCHAR(512),
  size DOUBLE PRECISION,
  "timestamp" TIMESTAMP WITHOUT TIME ZONE,
  uuid_ts TIMESTAMP WITHOUT TIME ZONE,
  country VARCHAR(512),
  "region" VARCHAR(512),
  solution VARCHAR(512),
  user_id VARCHAR(512),
  context_library_version VARCHAR(512),
  crop_region_id VARCHAR(512),
  sent_at TIMESTAMP WITHOUT TIME ZONE,
  size_unit_id VARCHAR(512),
  context_event_transformed VARCHAR(512)
);

COMMENT ON TABLE ffdp2_0.segment_ndvi_performed IS 'This Table has the Segment Data of the NDVI Performed.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.id IS 'ID of NDVI Performed.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.received_at IS 'Segment - When Segment received the identify call.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.uuid IS 'Segment - The UUID column is used to prevent duplicates.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.context_library_name IS 'Segment - element in library object, Name of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.email IS 'email ID.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.event IS 'Segment - The slug of the event name, so you can join the tracks table.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.event_text IS 'Segment - The name of the event.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.original_timestamp IS 'Segment - The original_timestamp column is the original timestamp set by the Segment library at the time the event is created.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.crop IS 'Name of the crop.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.event_id IS 'Segment - The unique ID of the track call itself.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.size IS 'size of the field.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.timestamp IS 'Segment - The timestamp column is the UTC-converted timestamp which is set by the Segment library.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.uuid_ts IS 'Segment - The uuid_ts column is used to keep track of when the specific event was last processed by our connector, specifically for deduping and debugging purposes.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.country IS 'Name of the Country';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.region IS 'Region.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.solution IS 'Solution in which the NDVI performed.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.user_id IS 'Segment - The unique ID of the user.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.context_library_version IS 'Segment - element in library object, Version of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.crop_region_id IS 'ID of the CropRegion.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.sent_at IS 'Segment - When a user triggered the track call.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.size_unit_id IS 'size unit ID.';

COMMENT ON COLUMN ffdp2_0.segment_ndvi_performed.context_event_transformed IS 'context event transformed.';

ALTER TABLE ffdp2_0.segment_ndvi_performed OWNER TO "IAM:ffdp-airflow";

----------------------------------------------------

-- FFDP2_0.segment_nue_performed

DROP TABLE IF EXISTS ffdp2_0.segment_nue_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.segment_nue_performed
(
  id VARCHAR(512) NOT NULL,
  received_at TIMESTAMP WITHOUT TIME ZONE,
  uuid BIGINT,
  context_library_name VARCHAR(512),
  context_library_version VARCHAR(512),
  "region" VARCHAR(512),
  sent_at TIMESTAMP WITHOUT TIME ZONE,
  "timestamp" TIMESTAMP WITHOUT TIME ZONE,
  crop VARCHAR(512),
  event VARCHAR(512),
  event_id VARCHAR(512),
  user_id VARCHAR(512),
  country VARCHAR(512),
  crop_region_id VARCHAR(512),
  event_text VARCHAR(512),
  solution VARCHAR(512),
  uuid_ts TIMESTAMP WITHOUT TIME ZONE,
  email VARCHAR(512),
  original_timestamp TIMESTAMP WITHOUT TIME ZONE,
  context_event_transformed VARCHAR(512)
);

COMMENT ON TABLE ffdp2_0.segment_nue_performed IS 'This Table has the Segment Data of the NUE Performed.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.id IS 'ID of NUE Performed.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.received_at IS 'Segment - When Segment received the identify call.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.uuid IS 'Segment - The UUID column is used to prevent duplicates.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.context_library_name IS 'Segment - element in library object, Name of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.context_library_version IS 'Segment - element in library object, Version of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.region IS 'Region.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.sent_at IS 'Segment - When a user triggered the track call.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.timestamp IS 'Segment - The timestamp column is the UTC-converted timestamp which is set by the Segment library.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.crop IS 'Name of the crop.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.event IS 'Segment - The slug of the event name, so you can join the tracks table.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.event_id IS 'Segment - The unique ID of the track call itself.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.user_id IS 'Segment - The unique ID of the user.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.country IS 'Name of the Country.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.crop_region_id IS 'ID of the CropRegion.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.event_text IS 'Segment - The name of the event.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.solution IS 'Solution in which the NUE performed.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.uuid_ts IS 'Segment - The uuid_ts column is used to keep track of when the specific event was last processed by our connector, specifically for deduping and debugging purposes.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.email IS 'email ID.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.original_timestamp IS 'Segment - The original_timestamp column is the original timestamp set by the Segment library at the time the event is created.';

COMMENT ON COLUMN ffdp2_0.segment_nue_performed.context_event_transformed IS 'context event transformed.';

ALTER TABLE ffdp2_0.segment_nue_performed OWNER TO "IAM:ffdp-airflow";

------------------------------------

-- FFDP2_0.segment_product_recommendation_performed 
-- This table is already available in FFDP2_0, with yield as BIGINT, To change the format, We drop and recreate the table with proper name

DROP TABLE IF EXISTS ffdp2_0.product_recommendation_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.segment_product_recommendation_performed(
    id VARCHAR(512),
    received_at TIMESTAMP WITHOUT TIME ZONE,
    uuid BIGINT,
    crop_id VARCHAR(512),
    email VARCHAR(512),
    event_id VARCHAR(512),
    region_id VARCHAR(512),
    uuid_ts TIMESTAMP WITHOUT TIME ZONE,
    country_id VARCHAR(512),
    event VARCHAR(512),
    event_text VARCHAR(512),
    original_timestamp TIMESTAMP WITHOUT TIME ZONE,
    sent_at TIMESTAMP WITHOUT TIME ZONE,
    context_library_name VARCHAR(512),
    "timestamp" TIMESTAMP WITHOUT TIME ZONE,
    context_library_version VARCHAR(512),
    user_id VARCHAR(512),
    yield DOUBLE PRECISION,
    yield_unit VARCHAR(512),
    anonymous_id VARCHAR(512),
    solution VARCHAR(512),
    size DOUBLE PRECISION,
    size_unit_id VARCHAR(512),
    field_id VARCHAR(512),
    context_event_transformed VARCHAR(512)
);

COMMENT ON TABLE ffdp2_0.segment_product_recommendation_performed IS 'This Table has the Segment Data of the Product Recommendation Performed.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.id IS 'ID of Product Recommendation Performed.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.received_at IS 'Segment - When Segment received the identify call.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.uuid IS 'Segment - The uuid column is used to prevent duplicates.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.crop_id IS 'ID of the crop.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.email IS 'Email ID.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.event_id IS 'Segment - The unique ID of the track call itself.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.region_id IS 'ID of the Region.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.uuid_ts IS 'Segment - The uuid_ts column is used to keep track of when the specific event was last processed by our connector, specifically for deduping and debugging purposes.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.country_id IS 'ID of the Country.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.event IS 'Segment - The slug of the event name, so you can join the tracks table.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.event_text IS 'Segment - The name of the event.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.original_timestamp IS 'Segment - The original_timestamp column is the original timestamp set by the Segment library at the time the event is created.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.sent_at IS 'Segment - When a user triggered the track call.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.context_library_name IS 'Segment - element in library object, Name of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.timestamp IS 'Segment - The timestamp column is the UTC-converted timestamp which is set by the Segment library.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.context_library_version IS 'Segment - element in library object, Version of library making the requests to the API.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.user_id IS 'Segment - The unique ID of the user.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.yield IS 'yield.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.yield_unit IS 'yield unit.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.anonymous_id IS 'Segment - The anonymous ID of the user.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.solution IS 'Solution in which the product recommendation performed.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.size IS 'size of the field.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.size_unit_id IS 'size unit ID.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.field_id IS 'ID of the field.';

COMMENT ON COLUMN ffdp2_0.segment_product_recommendation_performed.context_event_transformed IS 'context event transformed.';

ALTER TABLE ffdp2_0.segment_product_recommendation_performed OWNER TO "IAM:ffdp-airflow";
