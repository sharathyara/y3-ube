-- Dropping n_tester and photo_analysis table and creating n_recommendation table

-- Dropping n_tester table

DROP TABLE IF EXISTS ffdp2_0.n_tester;

-- Dropping photo_analysis table

DROP TABLE IF EXISTS ffdp2_0.photo_analysis;

--Creating n_recommendation table

CREATE TABLE IF NOT EXISTS ffdp2_0.n_recommendation (
    id VARCHAR(60),
    nrecommendationid VARCHAR(60),
    seasonid VARCHAR(60),
    fieldid VARCHAR(60),
    cropid VARCHAR(60),
    resultdate TIMESTAMP WITHOUT TIME ZONE,
    expectedyield DOUBLE PRECISION,
    expectedyielduomid VARCHAR(60),
    cropdescriptionid VARCHAR(255),
    calculationtype VARCHAR(255),
    value DOUBLE PRECISION,
    valuetype VARCHAR(255),
    listofreadings SUPER,
    listofanswers SUPER,
    notes SUPER,
    data SUPER,
    messages VARCHAR(1000),
    messagekey VARCHAR(1000),
    warningmessage VARCHAR(1000),
    warningmessagekey VARCHAR(1000),
    productrecommendation VARCHAR(1000),
    recommendationtype VARCHAR(255),
    recommendationvalue DOUBLE PRECISION,
    pdfurl VARCHAR(1000),
    nitrogensufficiencyindex DOUBLE PRECISION,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    source VARCHAR(60)
) DISTSTYLE AUTO;

COMMENT ON TABLE ffdp2_0.n_recommendation IS 'Table holds all the NRecommendationid activity performed on the field';

COMMENT ON COLUMN ffdp2_0.n_recommendation.id IS 'The primany key of N Recommendationid table';

COMMENT ON COLUMN ffdp2_0.n_recommendation.nrecommendationid IS 'ID of N Recommendationid fact table';

COMMENT ON COLUMN ffdp2_0.n_recommendation.seasonid IS 'ID of the Season';

COMMENT ON COLUMN ffdp2_0.n_recommendation.fieldid IS 'ID of the Field';

COMMENT ON COLUMN ffdp2_0.n_recommendation.cropid IS 'ID of the Crop';

COMMENT ON COLUMN ffdp2_0.n_recommendation.resultdate IS 'The datetime when the recommendation was created.';

COMMENT ON COLUMN ffdp2_0.n_recommendation.expectedyield IS 'Expected Yield input value for recommendation';

COMMENT ON COLUMN ffdp2_0.n_recommendation.expectedyielduomid IS 'The unit of measure  for expectedyield.';

COMMENT ON COLUMN ffdp2_0.n_recommendation.cropdescriptionid IS 'ID of the crop description.';

COMMENT ON COLUMN ffdp2_0.n_recommendation.calculationtype IS 'Calculation type';

COMMENT ON COLUMN ffdp2_0.n_recommendation.value IS 'Recommendation value';

COMMENT ON COLUMN ffdp2_0.n_recommendation.valuetype IS 'Value type';

COMMENT ON COLUMN ffdp2_0.n_recommendation.listofreadings IS 'Input parameters requried for N tester recommendation';

COMMENT ON COLUMN ffdp2_0.n_recommendation.listofanswers IS 'Response payload';

COMMENT ON COLUMN ffdp2_0.n_recommendation.notes IS 'notes';

COMMENT ON COLUMN ffdp2_0.n_recommendation.data IS 'additional data in json format';

COMMENT ON COLUMN ffdp2_0.n_recommendation.messages IS 'Messages';

COMMENT ON COLUMN ffdp2_0.n_recommendation.messagekey IS 'Message key';

COMMENT ON COLUMN ffdp2_0.n_recommendation.warningmessage IS 'Warning message';

COMMENT ON COLUMN ffdp2_0.n_recommendation.warningmessagekey IS 'Warning message key';

COMMENT ON COLUMN ffdp2_0.n_recommendation.productrecommendation IS 'Product recommendation';

COMMENT ON COLUMN ffdp2_0.n_recommendation.recommendationtype IS 'Recommendation Type';

COMMENT ON COLUMN ffdp2_0.n_recommendation.recommendationvalue IS 'Recommendation Value';

COMMENT ON COLUMN ffdp2_0.n_recommendation.pdfurl IS 'Pdf URL';

COMMENT ON COLUMN ffdp2_0.n_recommendation.nitrogensufficiencyindex IS 'Nitrogen sufficiency index';

COMMENT ON COLUMN ffdp2_0.n_recommendation.createdat IS 'The created timestamp of user';

COMMENT ON COLUMN ffdp2_0.n_recommendation.createdby IS 'It refers to the ID of the person who created the record';

COMMENT ON COLUMN ffdp2_0.n_recommendation.updatedat IS 'The updated timestamp of user';

COMMENT ON COLUMN ffdp2_0.n_recommendation.updatedby IS 'It refers to the ID of the person who updated the record';

COMMENT ON COLUMN ffdp2_0.n_recommendation.deletedat IS 'The deleted timestamp of user';

COMMENT ON COLUMN ffdp2_0.n_recommendation.deletedby IS 'It refers to the ID of the person who deleted  the record';

COMMENT ON COLUMN ffdp2_0.n_recommendation.source IS 'Source of the data';


ALTER TABLE ffdp2_0.n_recommendation OWNER TO "IAM:ffdp-airflow";
