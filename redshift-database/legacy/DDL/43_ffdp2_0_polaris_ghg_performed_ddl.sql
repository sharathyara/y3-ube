/******* polaris_ghg_performed DDL  (Green house gas calculator)********/

DROP TABLE IF EXISTS ffdp2_0.polaris_ghg_performed;

CREATE TABLE ffdp2_0.polaris_ghg_performed (
    datetimeoccurred timestamp without time zone NOT NULL ENCODE az64,
    request_location_countryid character varying(255) NOT NULL ENCODE lzo,
    request_location_regionid character varying(255) NOT NULL ENCODE lzo,
    request_field_fieldSize double precision NOT NULL ENCODE raw,
    request_field_fieldSizeUnitId character varying(255) NOT NULL ENCODE lzo,
    request_field_soil_soilTypeId character varying(255) NOT NULL ENCODE lzo,
    request_field_soil_organicMatter double precision NULL ENCODE raw,
    request_field_soil_goodDrainage boolean NULL ENCODE raw,
    request_field_soil_ph double precision NULL ENCODE raw,
    request_field_longitude double precision ENCODE raw,
    request_field_latitude double precision ENCODE raw,
    request_cropping_cropRegionId character varying(255) NOT NULL ENCODE lzo,
    request_cropping_yield double precision NOT NULL ENCODE raw,
    request_cropping_yieldUnitId character varying(255) NOT NULL ENCODE lzo,
    request_cropping_farmGateReadyAmount double precision NOT NULL ENCODE raw,
    request_cropping_farmGateReadyAmountUnitId character varying(255) NOT NULL ENCODE lzo,
    request_cropping_harvestingYear double precision NOT NULL ENCODE raw,
    request_cropping_coProducts character varying(10000) NULL ENCODE lzo,
    request_climate_name character varying(255) NULL ENCODE lzo,
    request_climate_averageTemperatureValue double precision NULL ENCODE raw,
    request_climate_averageTemperatureValueUnitId character varying(255) NULL ENCODE lzo,
    request_residues_amount double precision NULL ENCODE raw,
    request_residues_amountUnitId character varying(255) NULL ENCODE lzo,
    request_residues_cropResidueManagementId character varying(100) NOT NULL ENCODE lzo,
    request_appliedProducts character varying(10000) NULL ENCODE lzo,
    request_applied_products_directEnergyUse character varying(10000) NULL ENCODE lzo,
    request_applied_products_machineryUse character varying(10000) NULL ENCODE lzo,
    request_applied_products_transport character varying(10000) NULL ENCODE lzo,
    request_applied_products_cropProtectionApplications character varying(10000) NULL ENCODE lzo,
    response_success boolean NOT NULL ENCODE raw,
    response_message character varying(100) NULL ENCODE lzo,
    response_payload_summary_emissionsCO2eTotal double precision ENCODE raw,
    response_payload_summary_emissionsCO2eTotalUnitId character varying(100) NOT NULL ENCODE lzo,
    response_payload_summary_emissionsCO2ePerArea double precision ENCODE raw,
    response_payload_summary_emissionsCO2ePerAreaUnitId character varying(255) NOT NULL ENCODE lzo,
    response_payload_summary_emissionsCO2ePerProduct double precision NOT NULL ENCODE raw,
    response_payload_summary_emissionsCO2ePerProductUnitId character varying(255) NOT NULL ENCODE lzo,
    response_payload_summary_soilOrganicCarbon character varying(100) NULL ENCODE lzo,
    response_payload_totalEmissions character varying(10000) NULL ENCODE lzo,
    configuration_solution character varying(100) NULL ENCODE lzo,
    eventSource character varying(100) NOT NULL ENCODE lzo,
    eventType character varying(100) NOT NULL ENCODE lzo,
    eventid character varying(255) NOT NULL ENCODE lzo,
    created_at character varying(255) NOT NULL ENCODE lzo
) DISTSTYLE AUTO;

-- Granting permission to ffdp-airflow role for polaris_ghg_performed in curated_schema
GRANT SELECT ON TABLE curated_schema.polaris_ghg_performed TO "IAM:ffdp-airflow";

ALTER TABLE ffdp2_0.polaris_ghg_performed OWNER TO "IAM:ffdp-airflow";