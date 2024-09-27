-- liquibase formatted sql

--changeset sandeep_c:ATI-6327-altering-cnp-attribute-datatype splitStatements:true failOnError:false
--comment: ATI-6327 - dropping the exisitng CNP view and adding a is_json check and filtering only proper json data

DROP VIEW if exists ffdp2_0.crop_nutrition_plan;

CREATE VIEW ffdp2_0.crop_nutrition_plan AS
    SELECT 
        id::VARCHAR AS id,
        uploaddate::TIMESTAMP AS uploadedat,
        request_location_countryid::VARCHAR AS countryid,
        NULL AS regionid,
        request_field_id::VARCHAR AS fieldid,
        CASE 
            WHEN CAN_JSON_PARSE(request_field_boundaries) = TRUE THEN JSON_PARSE(request_field_boundaries)::SUPER
            ELSE NULL::SUPER
        END AS boundaries,
        request_field_size AS fieldsize,
        request_field_sizeunitid::VARCHAR AS fieldsizeunitid,
        request_cropping_cropid::VARCHAR AS cropid,
        request_cropping_yield::DOUBLE PRECISION AS yield,
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
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from request_analysis_classes), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from request_analysis_classes), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS analysisclass,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from request_analysis_values), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from request_analysis_values), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS analysisvalue,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from request_demand_crop), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from request_demand_crop), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS demandcrop,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from request_demand_soil), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from request_demand_soil), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS demandsoil,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from request_demand_unit), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from request_demand_unit), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS demandunit,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(replace(replace(trim(both '"' from request_userdefinedproducts), 'None', '"N/A"') ,'''','"'),'True','true'),'False','false')) = TRUE 
            THEN JSON_PARSE(replace(replace(replace(replace(trim(both '"' from request_userdefinedproducts), 'None', '"N/A"') ,'''','"'),'True','true'),'False','false'))::SUPER
            ELSE NULL::SUPER
        END AS userdefinedproduct,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from request_userappliedproducts), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from request_userappliedproducts), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS userappliedproduct,
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
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from response_errordata), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from response_errordata), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS errordata,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from response_payload_recommendationdata_items), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from response_payload_recommendationdata_items), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS recommendationdataitems,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from response_payload_splitdata_items), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from response_payload_splitdata_items), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS splitdataitems,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from response_payload_fertilizerneed_items), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from response_payload_fertilizerneed_items), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS fertilizerneeditems,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(replace(replace(trim(both '"' from response_payload_organicsupply_items), 'None', '"N/A"') ,'''','"'),'True','true'),'False','false')) = TRUE 
            THEN JSON_PARSE(replace(replace(replace(replace(trim(both '"' from response_payload_organicsupply_items), 'None', '"N/A"') ,'''','"'),'True','true'),'False','false'))::SUPER
            ELSE NULL::SUPER
        END AS organicsupplyitems,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from response_payload_soilimprovementdemand_items), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from response_payload_soilimprovementdemand_items), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS soilimprovementdemanditems,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from request_field_boundaries_json), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from request_field_boundaries_json), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS fieldboundariesjson,
        geometry AS geometry,
        request_field_boundaries_wkt AS fieldboundarieswkt,
        CASE 
            WHEN CAN_JSON_PARSE(replace(replace(trim(both '"' from configuration), 'None', '"N/A"') ,'''','"')) = TRUE 
            THEN JSON_PARSE(replace(replace(trim(both '"' from configuration), 'None', '"N/A"') ,'''','"'))::SUPER
            ELSE NULL::SUPER
        END AS configuration,
        partition_0::varchar AS partitions,
        'ONE21_CNP' AS source
    FROM polaris_productrecommendation.${CNP_EXTERNAL_SCHEMA_TABLE_NAME}
    WITH NO SCHEMA BINDING;


-- rollback DROP VIEW IF EXISTS ffdp2_0.crop_nutrition_plan;
-- rollback CREATE VIEW ffdp2_0.crop_nutrition_plan AS
-- rollback     SELECT 
-- rollback         id::VARCHAR AS id,
-- rollback         uploaddate::TIMESTAMP AS uploadedat,
-- rollback         request_location_countryid::VARCHAR AS countryid,
-- rollback         request_location_regionid::VARCHAR AS regionid,
-- rollback         request_field_id::VARCHAR AS fieldid,
-- rollback         request_field_boundaries::VARCHAR AS boundaries,
-- rollback         request_field_size AS fieldsize,
-- rollback         request_field_sizeunitid::VARCHAR AS fieldsizeunitid,
-- rollback         request_cropping_cropid::VARCHAR AS cropid,
-- rollback         request_cropping_yield AS yield,
-- rollback         request_cropping_yieldunit::VARCHAR AS yieldunit,
-- rollback         request_cropping_croppableareaunit::VARCHAR AS croppableareaunit,
-- rollback         request_cropping_additionalparameters_name::VARCHAR AS additionalparametersname,
-- rollback         request_cropping_additionalparameters_value::VARCHAR AS additionalparametersvalue,
-- rollback         request_rotation_precropid::varchar AS precropid,
-- rollback         request_rotation_precropyield::varchar AS precropyield,
-- rollback         request_rotation_precropyieldunit::varchar AS precropyieldunit,
-- rollback         request_rotation_postcropid::varchar AS postcropid,
-- rollback         request_rotation_postcropyield::varchar AS postcropyield,
-- rollback         request_rotation_postcropyieldunit::varchar AS postcropyieldunit,
-- rollback         request_insight_locale AS locale,
-- rollback         request_analysis_classes::super AS analysisclass,
-- rollback         request_analysis_values::super AS analysisvalue,
-- rollback         request_demand_crop::super AS demandcrop,
-- rollback         request_demand_soil::super AS demandsoil,
-- rollback         request_demand_unit::super AS demandunit,
-- rollback         request_userdefinedproducts::super AS userdefinedproduct,
-- rollback         request_userappliedproducts::super AS userappliedproduct,
-- rollback         request_config_recommendaftersplitapplication::varchar AS recommendaftersplitapplication,
-- rollback         request_config_checkcropchloridesensitivity::varchar AS checkcropchloridesensitivity,
-- rollback         request_config_useyarapreferredproducts::varchar AS useyarapreferredproduct,
-- rollback         request_config_capability::varchar AS capability,
-- rollback         request_requestdetails_id::varchar AS requestdetailsid,
-- rollback         request_requestdetails_date::timestamp AS requestdetailsdate,
-- rollback         request_requestdetails_rulesetversion::varchar AS requestdetailsrulesetversion,
-- rollback         response_begin::timestamp AS begin,
-- rollback         response_end::timestamp AS end,
-- rollback         response_success::varchar AS success,
-- rollback         response_errordata::super AS errordata,
-- rollback         response_payload_recommendationdata_items::super AS recommendationdataitems,
-- rollback         response_payload_splitdata_items::super AS splitdataitems,
-- rollback         response_payload_fertilizerneed_items::super AS fertilizerneeditems,
-- rollback         response_payload_organicsupply_items::super AS organicsupplyitems,
-- rollback         response_payload_soilimprovementdemand_items::super AS soilimprovementdemanditems,
-- rollback         request_field_boundaries_json::super AS fieldboundariesjson,
-- rollback         geometry::super AS geometry,
-- rollback         request_field_boundaries_wkt::super AS fieldboundarieswkt,
-- rollback         configuration::super AS configuration,
-- rollback         partition_0::varchar AS partitions,
-- rollback         'ONE21_CNP' AS source
-- rollback     FROM polaris_productrecommendation.${CNP_EXTERNAL_SCHEMA_TABLE_NAME}
-- rollback     WITH NO SCHEMA BINDING;