-- liquibase formatted sql

--changeset sandeep_c:ATI-6508-resolution-of-cnp-data-being-extracted-from-one-21_external_schema_creation splitStatements:true failOnError:false
--comment: ATI-6508 create external Schema for CNP


CREATE EXTERNAL SCHEMA IF NOT EXISTS polaris_productrecommendation
FROM DATA CATALOG DATABASE '${CNP_GLUE_DATABASE_NAME}'
IAM_ROLE '${FFDP_REDSHIFT_CROSS_ACCOUNT_ROLE},${ONE21_GLUE_S3_CROSS_ACCOUNT_ROLE}';

-- rollback DROP SCHEMA IF EXISTS polaris_productrecommendation RESTRICT;



--changeset sandeep_c:ATI-6508-resolution-of-cnp-data-being-extracted-from-one-21_VIEW_creation splitStatements:true failOnError:false
--comment: dropping the existing cnp table and creating a view on data from the external table

DROP table IF EXISTS ffdp2_0.crop_nutrition_plan;

CREATE VIEW ffdp2_0.crop_nutrition_plan AS
    SELECT 
        id::VARCHAR AS id,
        uploaddate::TIMESTAMP AS uploadedat,
        request_location_countryid::VARCHAR AS countryid,
        request_location_regionid::VARCHAR AS regionid,
        request_field_id::VARCHAR AS fieldid,
        request_field_boundaries::VARCHAR AS boundaries,
        request_field_size AS fieldsize,
        request_field_sizeunitid::VARCHAR AS fieldsizeunitid,
        request_cropping_cropid::VARCHAR AS cropid,
        request_cropping_yield AS yield,
        request_cropping_yieldunit::VARCHAR AS yieldunit,
        request_cropping_croppableareaunit::VARCHAR AS croppableareaunit,
        request_cropping_additionalparameters_name::VARCHAR AS additionalparametersname,
        request_cropping_additionalparameters_value::VARCHAR AS additionalparametersvalue,
        request_rotation_precropid::varchar AS precropid,
        request_rotation_precropyield::varchar AS precropyield,
        request_rotation_precropyieldunit::varchar AS precropyieldunit,
        request_rotation_postcropid::varchar AS postcropid,
        request_rotation_postcropyield::varchar AS postcropyield,
        request_rotation_postcropyieldunit::varchar AS postcropyieldunit,
        request_insight_locale AS locale,
        request_analysis_classes::super AS analysisclass,
        request_analysis_values::super AS analysisvalue,
        request_demand_crop::super AS demandcrop,
        request_demand_soil::super AS demandsoil,
        request_demand_unit::super AS demandunit,
        request_userdefinedproducts::super AS userdefinedproduct,
        request_userappliedproducts::super AS userappliedproduct,
        request_config_recommendaftersplitapplication::varchar AS recommendaftersplitapplication,
        request_config_checkcropchloridesensitivity::varchar AS checkcropchloridesensitivity,
        request_config_useyarapreferredproducts::varchar AS useyarapreferredproduct,
        request_config_capability::varchar AS capability,
        request_requestdetails_id::varchar AS requestdetailsid,
        request_requestdetails_date::timestamp AS requestdetailsdate,
        request_requestdetails_rulesetversion::varchar AS requestdetailsrulesetversion,
        response_begin::timestamp AS begin,
        response_end::timestamp AS end,
        response_success::varchar AS success,
        response_errordata::super AS errordata,
        response_payload_recommendationdata_items::super AS recommendationdataitems,
        response_payload_splitdata_items::super AS splitdataitems,
        response_payload_fertilizerneed_items::super AS fertilizerneeditems,
        response_payload_organicsupply_items::super AS organicsupplyitems,
        response_payload_soilimprovementdemand_items::super AS soilimprovementdemanditems,
        request_field_boundaries_json::super AS fieldboundariesjson,
        geometry::super AS geometry,
        request_field_boundaries_wkt::super AS fieldboundarieswkt,
        configuration::super AS configuration,
        partition_0::varchar AS partitions,
        'ONE21_CNP' AS source
    FROM polaris_productrecommendation.${CNP_EXTERNAL_SCHEMA_TABLE_NAME}
    WITH NO SCHEMA BINDING;


-- rollback DROP VIEW IF EXISTS ffdp2_0.crop_nutrition_plan;
-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.crop_nutrition_plan
-- rollback (
-- rollback 	id VARCHAR(60) NOT NULL,
-- rollback 	status VARCHAR(255),
-- rollback 	cnpowner VARCHAR(255),
-- rollback 	fieldid VARCHAR(60),
-- rollback 	cropid VARCHAR(60),
-- rollback 	userid VARCHAR(60),
-- rollback 	countryid VARCHAR(60),
-- rollback 	regionid VARCHAR(60),
-- rollback 	targetyield DOUBLE PRECISION,
-- rollback 	targetyielduomid VARCHAR(60),
-- rollback 	yieldsource VARCHAR(60),
-- rollback 	fieldsize DOUBLE PRECISION,
-- rollback 	fieldsizeuomid VARCHAR(60),
-- rollback 	soiltypeid VARCHAR(60),
-- rollback 	cropresiduemanagementid VARCHAR(60),
-- rollback 	demandunitid VARCHAR(60),
-- rollback 	additionalparameters SUPER,
-- rollback 	precrop SUPER,
-- rollback 	postcrop SUPER,
-- rollback 	analysis SUPER,
-- rollback 	customproducts SUPER,
-- rollback 	appliedproducts SUPER,
-- rollback 	recommendationdata SUPER,
-- rollback 	planbalance SUPER,
-- rollback 	soilanalysiscalculationv2requested SUPER,
-- rollback 	soilanalysiscalculationv2performed SUPER,
-- rollback 	soilproductrecommendationv2requested SUPER,
-- rollback 	soilproductrecommendationv2performed SUPER,
-- rollback 	eventid VARCHAR(60),
-- rollback 	createdat TIMESTAMP WITHOUT TIME ZONE, 
-- rollback 	createdby VARCHAR(600),  
-- rollback	    updatedat TIMESTAMP WITHOUT TIME ZONE,   
-- rollback 	updatedby VARCHAR(600), 
-- rollback	    deletedat TIMESTAMP WITHOUT TIME ZONE,  
-- rollback	    deletedby VARCHAR(600),
-- rollback     version INTEGER,
-- rollback     source VARCHAR(60)
-- rollback );