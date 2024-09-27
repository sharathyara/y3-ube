from yarahiveutils.config import extractions, relationships

# Mappings imports
from yarahiveutils.config.mappings.applicationMethods import applicationMethods_mapping
from yarahiveutils.config.mappings.businessUnits import businessUnits_mapping
from yarahiveutils.config.mappings.countries import countries_mapping
from yarahiveutils.config.mappings.cropMetadata import cropMetadata_mapping
from yarahiveutils.config.mappings.crops import crops_mapping
from yarahiveutils.config.mappings.dataCollections import dataCollections_mapping
from yarahiveutils.config.mappings.demoSites import demoSites_mapping
from yarahiveutils.config.mappings.demos import demos_mapping
from yarahiveutils.config.mappings.demoStatusLog import demoStatusLog_mapping
from yarahiveutils.config.mappings.measurementTypes import measurementTypes_mapping
from yarahiveutils.config.mappings.measurements import measurements_mapping
from yarahiveutils.config.mappings.media import media_mapping
from yarahiveutils.config.mappings.results import results_mapping
from yarahiveutils.config.mappings.treatments import treatments_mapping
from yarahiveutils.config.mappings.units import units_mapping
from yarahiveutils.config.mappings.users import users_mapping
from yarahiveutils.config.mappings.assessments import assessments_mapping
from yarahiveutils.config.mappings.farmers import farmers_mapping
from yarahiveutils.config.mappings.products import products_mapping
from yarahiveutils.config.mappings.productTypes import productTypes_mapping
from yarahiveutils.config.mappings.farms import farms_mapping
from yarahiveutils.config.mappings.fields import fields_mapping
from yarahiveutils.config.mappings.tools import tools_mapping
from yarahiveutils.config.mappings.powerBrands import powerBrands_mapping
from yarahiveutils.config.mappings.grossMargin import grossMargin_mapping
from yarahiveutils.config.mappings.nitrogenUseEfficiency import nitrogenUseEfficiency_mapping
from yarahiveutils.config.mappings.regions import regions_mapping
from yarahiveutils.config.mappings.treatmentMeasurementMatrix import treatmentMeasurementMatrix_mapping
from yarahiveutils.config.mappings.growthStagesApplications import growthStagesApplications_mapping
from yarahiveutils.config.mappings.translations import translations_mapping


# Schemas imports
from yarahiveutils.config.schemas.applicationMethods import applicationMethods_schema
from yarahiveutils.config.schemas.businessUnits import businessUnits_schema
from yarahiveutils.config.schemas.countries import countries_schema
from yarahiveutils.config.schemas.cropMetadata import cropMetadata_schema
from yarahiveutils.config.schemas.crops import crops_schema
from yarahiveutils.config.schemas.dataCollections import dataCollections_schema
from yarahiveutils.config.schemas.demoSites import demoSites_schema
from yarahiveutils.config.schemas.demos import demos_schema
from yarahiveutils.config.schemas.demoStatusLog import demoStatusLog_schema
from yarahiveutils.config.schemas.measurementTypes import measurementTypes_schema
from yarahiveutils.config.schemas.measurements import measurements_schema
from yarahiveutils.config.schemas.media import media_schema
from yarahiveutils.config.schemas.results import results_schema
from yarahiveutils.config.schemas.treatments import treatments_schema
from yarahiveutils.config.schemas.units import units_schema
from yarahiveutils.config.schemas.users import users_schema
from yarahiveutils.config.schemas.assessments import assessments_schema
from yarahiveutils.config.schemas.farmers import farmers_schema
from yarahiveutils.config.schemas.products import products_schema
from yarahiveutils.config.schemas.productTypes import productTypes_schema
from yarahiveutils.config.schemas.farms import farms_schema
from yarahiveutils.config.schemas.fields import fields_schema
from yarahiveutils.config.schemas.tools import tools_schema
from yarahiveutils.config.schemas.powerBrands import powerBrands_schema
from yarahiveutils.config.schemas.grossMargin import grossMargin_schema
from yarahiveutils.config.schemas.nitrogenUseEfficiency import nitrogenUseEfficiency_schema
from yarahiveutils.config.schemas.regions import regions_schema
from yarahiveutils.config.schemas.treatmentMeasurementMatrix import treatmentMeasurementMatrix_schema
from yarahiveutils.config.schemas.growthStagesApplications import growthStagesApplications_schema
from yarahiveutils.config.schemas.translations import translations_schema



# Define your target schemas in the specified order
target_schemas = {
    "applicationMethods": applicationMethods_schema,
    "businessUnits": businessUnits_schema,
    "countries": countries_schema,
    "cropMetadata": cropMetadata_schema,
    "crops": crops_schema,
    "dataCollections": dataCollections_schema,
    "demoSites": demoSites_schema,
    "demos": demos_schema,
    "demoStatusLog": demoStatusLog_schema,
    "measurementTypes": measurementTypes_schema,
    "measurements": measurements_schema,
    "media": media_schema,
    "powerBrands": powerBrands_schema,
    "productTypes": productTypes_schema,
    "products": products_schema,
    "results": results_schema,
    "tools": tools_schema,
    "translations": translations_schema,
    "treatments": treatments_schema,
    "units": units_schema,
    "users": users_schema,
    "assessments": assessments_schema,
    "farmers":farmers_schema,
    "fields":fields_schema,
    "farms": farms_schema,
    "grossMargin":grossMargin_schema,
    "nitrogenUseEfficiency": nitrogenUseEfficiency_schema,
    "regions":regions_schema,
    "treatmentMeasurementMatrix": treatmentMeasurementMatrix_schema,
    "growthStagesApplications":growthStagesApplications_schema,
}

# Define your column mappings in the specified order
column_mappings = {
    "applicationMethods": applicationMethods_mapping,
    "businessUnits": businessUnits_mapping,
    "countries": countries_mapping,
    "cropMetadata": cropMetadata_mapping,
    "crops": crops_mapping,
    "dataCollections": dataCollections_mapping,
    "demoSites": demoSites_mapping,
    "demos": demos_mapping,
    "demoStatusLog": demoStatusLog_mapping,
    "measurementTypes": measurementTypes_mapping,
    "measurements": measurements_mapping,
    "media": media_mapping,
    "powerBrands": powerBrands_mapping,
    "productTypes": productTypes_mapping,
    "products": products_mapping,
    "results": results_mapping,
    "tools": tools_mapping,
    "translations": translations_mapping,
    "treatments": treatments_mapping,
    "units": units_mapping,
    "users": users_mapping,
    "assessments": assessments_mapping,
    "farmers":farmers_mapping,
    "fields":fields_mapping,
    "farms":farms_mapping,
    "grossMargin":grossMargin_mapping,
    "nitrogenUseEfficiency": nitrogenUseEfficiency_mapping,
    "regions":regions_mapping,
    "treatmentMeasurementMatrix": treatmentMeasurementMatrix_mapping,
    "growthStagesApplications":growthStagesApplications_mapping,
}

tables_to_be_extracted = extractions.tables_to_be_extracted
tables_relationship_configs = relationships.tables_relationship_configs

redshift_table_reference_to_mongodb_collection={
    "demoStatusLog" : "eventLogs",
}