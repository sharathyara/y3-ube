/******* DDL to create n_tester table  ********/


DROP TABLE IF EXISTS curated_schema.n_tester;

CREATE TABLE curated_schema.n_tester(
    dateTimeOccurred TIMESTAMP,
    farmId VARCHAR(60),
    fieldId VARCHAR(60),
    location VARCHAR(255),
    seasonId VARCHAR(255),
    resultDate VARCHAR(255) ,
    cropId VARCHAR(255) ,
    expectedYield FLOAT,
    expectedyieldUOMId VARCHAR(255) ,
    cropDescriptionId VARCHAR(255),
    calculationType VARCHAR(255) ,
    value DOUBLE PRECISION,
    valuetype VARCHAR(255),
    createdBy VARCHAR(255),
    createdAt TIMESTAMP,
    listOfReadings SUPER ,
    listOfAnswers SUPER ,
    notes VARCHAR(255),
    message VARCHAR(255),
    messageKey VARCHAR(255),
    warningMessage VARCHAR(255),
    warningMessageKey VARCHAR(255),
    productRecommendation VARCHAR(255),
    pdfURL VARCHAR(255),
    nitrogenSufficiencyIndex VARCHAR(255),
    id VARCHAR(60),
    data SUPER ,
    eventsource VARCHAR(255),
    eventtype VARCHAR(255),
    eventid VARCHAR(255) NOT NULL,
    recommendationType VARCHAR(255),
    fieldname VARCHAR(255),
    fieldarea DOUBLE PRECISION,
    countryid VARCHAR(60),
    updatedat TIMESTAMP,
    deletedat TIMESTAMP,
    recommendationvalue DOUBLE PRECISION,
    updatedby VARCHAR(255)
);

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.n_tester TO gluejob;