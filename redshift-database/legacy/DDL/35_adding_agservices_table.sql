-- Adding AgServices table in FFDP2_0 schema

--polaris_NDVI_performed

DROP TABLE IF EXISTS ffdp2_0.polaris_ndvi_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.polaris_ndvi_performed
(
  datetimeoccurred TIMESTAMP WITHOUT TIME ZONE,
  request_boundaries SUPER,
  request_cropregionid VARCHAR(255),
  request_date DATE,
  area DOUBLE PRECISION,
  areaunitid VARCHAR(255),
  requesttype VARCHAR(255),
  callbackurl VARCHAR(255),
  success BOOLEAN,
  "message" VARCHAR(10000),
  imageurl VARCHAR(2048),
  cloudcoverage DOUBLE PRECISION,
  snowcoverage DOUBLE PRECISION,
  "valid" BOOLEAN,
  image_date TIMESTAMP WITHOUT TIME ZONE,
  solution VARCHAR(255),
  eventsource VARCHAR(255),
  eventtype VARCHAR(255),
  eventid VARCHAR(255),
  created_at DATE
);

ALTER TABLE ffdp2_0.polaris_ndvi_performed OWNER TO "IAM:ffdp-airflow";


-- polaris_VRA_performed

DROP TABLE IF EXISTS ffdp2_0.polaris_vra_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.polaris_vra_performed
(
  datetimeoccurred TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  request_boundaries SUPER NOT NULL,
  request_cropregionid VARCHAR(255) NOT NULL,
  request_date DATE,
  request_field_area DOUBLE PRECISION NOT NULL,
  request_field_areaunitid VARCHAR(255) NOT NULL,
  request_requesttype VARCHAR(255),
  request_callbackurl VARCHAR(255),
  request_dmax DOUBLE PRECISION,
  request_dmin DOUBLE PRECISION,
  request_dtarget DOUBLE PRECISION,
  request_growthstage INTEGER,
  request_vratype VARCHAR(255),
  request_protein BOOLEAN,
  request_featurecollection VARCHAR(50000),
  request_valuekey VARCHAR(255),
  request_extrapolation BOOLEAN,
  response_success BOOLEAN NOT NULL,
  response_message VARCHAR(255),
  response_date TIMESTAMP WITHOUT TIME ZONE,
  response_cloudcoverage DOUBLE PRECISION,
  response_snowcoverage DOUBLE PRECISION,
  response_valid BOOLEAN,
  response_cellsize DOUBLE PRECISION,
  response_bucketzones SUPER,
  response_zonedzones SUPER,
  response_indices SUPER,
  response_bucketmean DOUBLE PRECISION,
  response_bucketmin DOUBLE PRECISION,
  response_bucketmax DOUBLE PRECISION,
  response_bucketstd DOUBLE PRECISION,
  response_zonedmean DOUBLE PRECISION,
  response_zonedmin DOUBLE PRECISION,
  response_zonedmax DOUBLE PRECISION,
  response_zonedstd DOUBLE PRECISION,
  response_featurecollection VARCHAR(50000),
  solution VARCHAR(255),
  eventsource VARCHAR(255) NOT NULL,
  eventtype VARCHAR(255) NOT NULL,
  eventid VARCHAR(255) NOT NULL,
  created_at DATE NOT NULL
);

ALTER TABLE ffdp2_0.polaris_vra_performed OWNER TO "IAM:ffdp-airflow";


--polaris_YIELD_ESTIMATION_performed

DROP TABLE IF EXISTS ffdp2_0.polaris_yield_estimation_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.polaris_yield_estimation_performed
(
  datetimeoccurred TIMESTAMP WITHOUT TIME ZONE,
  boundaries SUPER,
  cropregionid VARCHAR(255),
  request_date DATE,
  area DOUBLE PRECISION,
  areaunitid VARCHAR(255),
  requesttype VARCHAR(255),
  callbackurl VARCHAR(255),
  extrapolation BOOLEAN,
  id VARCHAR(255),
  success BOOLEAN,
  "begin" TIMESTAMP WITHOUT TIME ZONE,
  "end" TIMESTAMP WITHOUT TIME ZONE,
  message VARCHAR(10000),
  min DOUBLE PRECISION,
  "max" DOUBLE PRECISION,
  mean DOUBLE PRECISION,
  std DOUBLE PRECISION,
  cloudcoverage DOUBLE PRECISION,
  snowcoverage DOUBLE PRECISION,
  "valid" BOOLEAN,
  image_date TIMESTAMP WITHOUT TIME ZONE,
  solution VARCHAR(255),
  eventsource VARCHAR(255),
  eventtype VARCHAR(255),
  eventid VARCHAR(255),
  created_at DATE
);

ALTER TABLE ffdp2_0.polaris_yield_estimation_performed OWNER TO "IAM:ffdp-airflow";


--polaris_NUE_performed

DROP TABLE IF EXISTS ffdp2_0.polaris_nue_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.polaris_nue_performed
(
  datetimeoccurred TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  request_location_countryid VARCHAR(255) NOT NULL,
  request_location_regionid VARCHAR(255) NOT NULL,
  request_field_latitude DOUBLE PRECISION,
  request_field_longitude DOUBLE PRECISION,
  request_cropregionid VARCHAR(255) NOT NULL,
  request_yield DOUBLE PRECISION NOT NULL,
  request_yieldunitid VARCHAR(255) NOT NULL,
  request_nexport DOUBLE PRECISION NOT NULL,
  request_climate_ndeposition DOUBLE PRECISION,
  request_appliedproducts VARCHAR(6500),
  request_configuration_requesttype VARCHAR(255),
  request_configuration_callbackurl VARCHAR(255),
  response_success BOOLEAN NOT NULL,
  response_message VARCHAR(255),
  response_ninput_value DOUBLE PRECISION,
  response_ninput_unitid VARCHAR(100),
  response_noutput_value DOUBLE PRECISION,
  response_noutput_unitid VARCHAR(100),
  response_nsurplus_value DOUBLE PRECISION,
  response_nsurplus_unitid VARCHAR(100),
  response_nue_value DOUBLE PRECISION,
  response_nue_unitid VARCHAR(100),
  response_ndeposition_value DOUBLE PRECISION,
  response_ndeposition_unitid VARCHAR(100),
  response_ndepositioninfo_drydepositionoxidized DOUBLE PRECISION,
  response_ndepositioninfo_wetdepositionoxidized DOUBLE PRECISION,
  response_ndepositioninfo_drydepositionreduced DOUBLE PRECISION,
  response_ndepositioninfo_wetdepositionreduced DOUBLE PRECISION,
  response_ndepositioninfo_defaultdeposition DOUBLE PRECISION,
  response_ndepositioninfo_requestdeposition DOUBLE PRECISION,
  response_type VARCHAR(100),
  configuration_solution VARCHAR(255),
  eventsource VARCHAR(255) NOT NULL,
  eventtype VARCHAR(255) NOT NULL,
  eventid VARCHAR(255) NOT NULL,
  created_at DATE NOT NULL
);

ALTER TABLE ffdp2_0.polaris_nue_performed OWNER TO "IAM:ffdp-airflow";


-- polaris_N_SENSOR_BIOMASS_performed

DROP TABLE IF EXISTS ffdp2_0.polaris_n_sensor_biomass_performed;

CREATE TABLE IF NOT EXISTS ffdp2_0.polaris_n_sensor_biomass_performed
(
  datetimeoccurred TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  eventid VARCHAR(256) NOT NULL,
  request_boundaries SUPER NOT NULL,
  request_field_area DOUBLE PRECISION NOT NULL,
  request_field_areaunitid VARCHAR(256),
  request_configuration VARCHAR(1000),
  request_cropregionid VARCHAR(256),
  request_date DATE,
  request_extrapolation BOOLEAN,
  response_success BOOLEAN NOT NULL,
  response_message VARCHAR(3000),
  response_payload_imageurl VARCHAR(3000),
  response_payload_cloudcoverage DOUBLE PRECISION,
  response_payload_snowcoverage DOUBLE PRECISION,
  response_payload_valid BOOLEAN,
  response_payload_s1max DOUBLE PRECISION,
  response_payload_growthscaleid VARCHAR(256),
  response_payload_fromgrowthstageid VARCHAR(256),
  response_payload_togrowthstageid VARCHAR(256),
  response_payload_date DATE,
  configuration_solution VARCHAR(1000) NOT NULL,
  eventsource VARCHAR(256) NOT NULL,
  eventtype VARCHAR(256) NOT NULL,
  created_at DATE
);

ALTER TABLE ffdp2_0.polaris_n_sensor_biomass_performed OWNER TO "IAM:ffdp-airflow";
