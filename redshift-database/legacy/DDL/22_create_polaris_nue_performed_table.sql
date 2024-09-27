/******* polaris_nue_performed DDL ********/

DROP TABLE IF EXISTS curated_schema.polaris_nue_performed;

CREATE TABLE curated_schema.polaris_nue_performed (
    datetimeoccurred timestamp without time zone NOT NULL ENCODE az64,
    request_location_countryid character varying(255) NOT NULL ENCODE lzo,
    request_location_regionid character varying(255) NOT NULL ENCODE lzo,
    request_field_latitude double precision ENCODE raw,
    request_field_longitude double precision ENCODE raw,
    request_cropregionid character varying(255) NOT NULL ENCODE lzo,
    request_yield double precision NOT NULL ENCODE raw,
    request_yieldunitid character varying(255) NOT NULL ENCODE lzo,
    request_nexport double precision NOT NULL ENCODE raw,
    request_climate_ndeposition double precision ENCODE raw,
    request_appliedproducts character varying(6500) ENCODE lzo,
    request_configuration_requesttype character varying(255) ENCODE lzo,
    request_configuration_callbackurl character varying(255) ENCODE lzo,
    response_success boolean NOT NULL ENCODE raw,
    response_message character varying(255) ENCODE lzo,
    response_nInput_value double precision ENCODE raw,
    response_nInput_unitId character varying(100) ENCODE lzo,
    response_nOutput_value double precision ENCODE raw,
    response_nOutput_unitId character varying(100) ENCODE lzo,
    response_nSurplus_value double precision ENCODE raw,
    response_nSurplus_unitId character varying(100) ENCODE lzo,
    response_nue_value double precision ENCODE raw,
    response_nue_unitId character varying(100) ENCODE lzo,
    response_nDeposition_value double precision ENCODE raw,
    response_nDeposition_unitId character varying(100) ENCODE lzo,
    response_nDepositionInfo_dryDepositionOxidized double precision ENCODE raw,
    response_nDepositionInfo_wetDepositionOxidized double precision ENCODE raw,
    response_nDepositionInfo_dryDepositionReduced double precision ENCODE raw,
    response_nDepositionInfo_wetDepositionReduced double precision ENCODE raw,
    response_nDepositionInfo_defaultDeposition double precision ENCODE raw,
    response_nDepositionInfo_requestDeposition double precision ENCODE raw,
    response_type character varying(100) ENCODE lzo,
    configuration_solution character varying(255) ENCODE lzo,
    eventsource character varying(255) NOT NULL ENCODE lzo,
    eventtype character varying(255) NOT NULL ENCODE lzo,
    eventid character varying(255) NOT NULL ENCODE lzo,
    created_at character varying(255) NOT NULL ENCODE lzo
) DISTSTYLE AUTO;

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.polaris_nue_performed TO gluejob;