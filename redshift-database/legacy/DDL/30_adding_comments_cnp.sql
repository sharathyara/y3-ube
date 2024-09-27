-- view : crop_nutrition_plan
COMMENT ON VIEW ffdp2_0.crop_nutrition_plan IS 'The table contains all the CNP activity performed on the field including input details such as field conditions, crop information, yield data, rotation schedule, residue management, organic fertilizer application, soil analysis results, as well as responses such as product recommendations and soil analysis.';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.id IS 'Event id';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.uploadedat IS 'Date the event was uploaded';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.countryid IS 'Polaris country id';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.regionid IS 'Polaris region id ';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.fieldid IS 'Id for field';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.boundaries IS 'Field boundaries in JSON format';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.fieldsize IS 'Field size in hectares';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.fieldsizeunitid IS 'Field size unit id';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.cropid IS 'Polaris crop id';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.yield IS 'Calculated yield for crop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.yieldunit IS 'Unit id for yield';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.croppableareaunit IS 'Field unit for crop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.additionalparametersname IS 'Additional Parameters Name';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.additionalparametersvalue IS 'Additional Parameters value';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.precropid IS ' Id of Precrop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.precropyield IS 'Yield of Precrop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.precropyieldunit IS 'Yield unit of Precrop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.postcropid IS 'Id of post crop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.postcropyield IS 'Yield of post crop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.postcropyieldunit IS 'Yield unit of post crop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.locale IS 'Language';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.analysisclass IS 'Class of demand';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.analysisvalue IS 'Analysis value';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.demandcrop IS 'Values of fertiliser needed per crop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.demandsoil IS 'Values of fertiliser needed for soil';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.demandunit IS 'Unit of chemicals in fertiliser needed per crop';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.userdefinedproduct IS 'User defined product';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.userappliedproduct IS 'User applied product';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.recommendaftersplitapplication IS 'Recommend after split application';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.checkcropchloridesensitivity IS 'It is a flag to check crop chloride sensitivity';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.useyarapreferredproduct IS 'It is a flag to identify whether the product preferred by yara is used or not';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.capability IS 'Partner name';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.requestdetailsid IS 'Request id';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.requestdetailsdate IS 'Request date';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.requestdetailsrulesetversion IS 'Request details rule set version';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.begin IS 'Event start time';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.end IS 'Event end time';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.success IS 'Success of event';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.errordata IS 'Error response';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.recommendationdataitems IS 'Recommended products from Yara';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.splitdataitems IS 'Recommendation per growth stage';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.fertilizerneeditems IS 'Fertilizer need items';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.organicsupplyitems IS 'Organic fertiliser added by farmer';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.soilimprovementdemanditems IS 'Soil Improvement data items';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.fieldboundariesjson IS 'Boundaries in JSON format';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.geometry IS 'Geometry';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.fieldboundariesewkt IS 'Boundaries in WKT format';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.configuration IS 'Configuration';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.partitions IS 'S3 Partition key';

COMMENT ON COLUMN ffdp2_0.crop_nutrition_plan.source IS 'Source';
