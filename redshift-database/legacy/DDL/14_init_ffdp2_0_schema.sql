CREATE SCHEMA IF NOT EXISTS ffdp2_0;

-- Create growth_scale_stage table
CREATE TABLE IF NOT EXISTS ffdp2_0.growth_scale_stage (
    id VARCHAR(60) NOT NULL,
    growthscalestageid VARCHAR(60),
    growthscaleid VARCHAR(60),
    name VARCHAR(600),
    translationkey VARCHAR(600),
    mediauri SUPER,
    ordinal DOUBLE PRECISION,
    baseordinal DOUBLE PRECISION,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY(id)
) DISTSTYLE AUTO;

-- Create analysis_sample table
CREATE TABLE IF NOT EXISTS ffdp2_0.analysis_sample (
    id VARCHAR(60) NOT NULL,
    analysisorderid VARCHAR(60),
    fieldid VARCHAR(60),
    plotid INTEGER,
    depthid DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    plantingdate TIMESTAMP WITHOUT TIME ZONE,
    isdeleted BOOLEAN,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY(id)
) DISTSTYLE AUTO;

-- Creating Fact table "user_active"
CREATE TABLE IF NOT EXISTS ffdp2_0.user_active (
    userid VARCHAR(60) NOT NULL,
    lastactivitydate TIMESTAMP WITH TIME ZONE,
    isactive BOOLEAN,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY(userid)
) DISTSTYLE AUTO DISTKEY (userid);

-- Creating Dimension table "role"
CREATE TABLE IF NOT EXISTS ffdp2_0.role (
    id VARCHAR(60) NOT NULL,
    name VARCHAR(600),
    description VARCHAR(60),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY(id)
) DISTSTYLE AUTO DISTKEY (id);

-- Creating Dimension table "subscription"
CREATE TABLE IF NOT EXISTS ffdp2_0.subscription (
    id VARCHAR(60) NOT NULL,
    name VARCHAR(600),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY(id)
) DISTSTYLE AUTO;

-- Creating Dimension table "country"
CREATE TABLE IF NOT EXISTS ffdp2_0.country (
    id VARCHAR(60) NOT NULL,
    countryid VARCHAR(60),
    name VARCHAR(600),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    country_iso_code VARCHAR(60),
    country_iso3_code VARCHAR(60),
    version INTEGER,
    source VARCHAR(60),
    PRIMARY KEY(id)
) DISTSTYLE AUTO;

-- Creating Fact table "analysis_group"
CREATE TABLE IF NOT EXISTS ffdp2_0.analysis_group (
    id VARCHAR(60) NOT NULL,
    megalabanalysisgroupid VARCHAR(60),
    sampletypeid VARCHAR(60),
    name VARCHAR(600),
    isdeleted BOOLEAN,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    source VARCHAR(60),
    PRIMARY KEY(id)
) DISTSTYLE AUTO;

--create dimension table persona
CREATE TABLE IF NOT EXISTS ffdp2_0.persona (
    id VARCHAR(60) NOT NULL,
    name VARCHAR(100),
    isactive BOOLEAN,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    source VARCHAR(60),
    PRIMARY KEY (id)
) DISTSTYLE AUTO DISTKEY (id);

--create dimension table analysisorderinterpretationresult
CREATE TABLE IF NOT EXISTS ffdp2_0.analysis_order_interpretation_result (
    id VARCHAR(60) NOT NULL,
    analysisorderresultid VARCHAR(60) NOT NULL,
    cropid VARCHAR(60) NOT NULL,
    shortdescription VARCHAR(100),
    element VARCHAR(100),
    resulttodisplay VARCHAR(100),
    guidelinestodisplay VARCHAR(100),
    interpretation VARCHAR(30),
    gl1 DOUBLE PRECISION,
    gl2 DOUBLE PRECISION,
    gl3 DOUBLE PRECISION,
    gl4 DOUBLE PRECISION,
    gl5 DOUBLE PRECISION,
    recommendation SUPER,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(100),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(100),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(100),
    version INTEGER,
    PRIMARY KEY (id)
) DISTSTYLE AUTO DISTKEY (id);

--create dimension table sampletype
CREATE TABLE IF NOT EXISTS ffdp2_0.sample_type (
    id VARCHAR(60) NOT NULL,
    megalabsampletypeid VARCHAR(60) NOT NULL,
    name VARCHAR(100),
    visible BOOLEAN,
    isdeleted BOOLEAN,
    createdby VARCHAR(100),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(100),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(100),
    version INTEGER,
    PRIMARY KEY (id)
) DISTSTYLE AUTO DISTKEY (id);

-- Create organization table
CREATE TABLE IF NOT EXISTS ffdp2_0.organization (
    id VARCHAR(60) NOT NULL,
    organizationname VARCHAR(600),
    subscriptionid VARCHAR(60) NOT NULL,
    subscriptionname VARCHAR(600),
    countryid VARCHAR(60) NOT NULL,
    address VARCHAR(60),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY(subscriptionid) references ffdp2_0.subscription(id),
    FOREIGN KEY(countryid) references ffdp2_0.country(id)
) DISTSTYLE AUTO;

-- Creating Dimension table "region"
CREATE TABLE IF NOT EXISTS ffdp2_0.region (
    id VARCHAR(60) NOT NULL,
    regionid VARCHAR(60) NOT NULL,
    name VARCHAR(600),
    translationkey VARCHAR(600),
    countryid VARCHAR(60) NOT NULL,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    source VARCHAR(60),
    PRIMARY KEY(id),
    FOREIGN KEY(countryid) references ffdp2_0.country(id)
) DISTSTYLE AUTO;

-- Create users table
CREATE TABLE IF NOT EXISTS ffdp2_0.user (
    id VARCHAR(60) NOT NULL,
    name VARCHAR(600),
    email VARCHAR(600),
    phone VARCHAR(60),
    auth0id VARCHAR(60),
    countryid VARCHAR(60),
    zipcode VARCHAR(60),
    regionid VARCHAR(60),
    languagepreference VARCHAR(600),
    timezone VARCHAR(600),
    umopreference VARCHAR(600),
    source VARCHAR(60),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    consent BOOLEAN,
    newsletteroptin BOOLEAN,
    is_internal_user BOOLEAN,
    email_verified BOOLEAN,
    additional_parameters SUPER,
    version INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY(countryid) references ffdp2_0.country(id),
    FOREIGN KEY(regionid) references ffdp2_0.region(id)
) DISTSTYLE AUTO;

-- organization_user (Fact)
-- Create organization_user table
CREATE TABLE IF NOT EXISTS ffdp2_0.organization_user (
    id VARCHAR(60) NOT NULL,
    organizationid VARCHAR(60) NOT NULL,
    userid VARCHAR(60) NOT NULL,
    roleid VARCHAR(60) NOT NULL,
    subscriptionid VARCHAR(60) NOT NULL,
    personaid VARCHAR(60) NOT NULL,
    organizationregionid VARCHAR(60) NOT NULL,
    organizationcountryid VARCHAR(60) NOT NULL,
    userregionid VARCHAR(60) NOT NULL,
    usercountryid VARCHAR(60) NOT NULL,
    isactive BOOLEAN,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY(id),
    FOREIGN KEY(organizationid) references ffdp2_0.organization(id),
    FOREIGN KEY(userid) references ffdp2_0.user(id),
    FOREIGN KEY(roleid) references ffdp2_0.role(id),
    FOREIGN KEY(subscriptionid) references ffdp2_0.subscription(id),
    FOREIGN KEY(personaid) references ffdp2_0.persona(id),
    FOREIGN KEY(organizationregionid) references ffdp2_0.region(id),
    FOREIGN KEY(organizationcountryid) references ffdp2_0.country(id),
    FOREIGN KEY(userregionid) references ffdp2_0.region(id),
    FOREIGN KEY(usercountryid) references ffdp2_0.country(id)
) DISTSTYLE AUTO;

-- Create analysis_order table
CREATE TABLE IF NOT EXISTS ffdp2_0.analysis_order (
    id VARCHAR(60) NOT NULL,
    organizationid VARCHAR(60) NOT NULL,
    userid VARCHAR(60) NOT NULL,
    datereceivedbylab TIMESTAMP WITHOUT TIME ZONE,
    orderinstructions VARCHAR(60) NOT NULL,
    samplingdate TIMESTAMP WITHOUT TIME ZONE,
    sampletypeid VARCHAR(60) NOT NULL,
    status VARCHAR(60) NOT NULL,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY(id),
    FOREIGN KEY(sampletypeid) references ffdp2_0.sample_type(id)
) DISTSTYLE AUTO;

-- Create analysis_type table
CREATE TABLE IF NOT EXISTS ffdp2_0.analysis_type (
    id VARCHAR(60) NOT NULL,
    megalabanalysistypeid VARCHAR(60),
    sampletypeid VARCHAR(60) NOT NULL,
    name VARCHAR(600),
    units VARCHAR(60),
    visible BOOLEAN,
    isdeleted BOOLEAN,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY(id),
    FOREIGN KEY(sampletypeid) references ffdp2_0.sample_type(id)
) DISTSTYLE AUTO;

-- Create analysis_sample_group table
CREATE TABLE IF NOT EXISTS ffdp2_0.analysis_sample_group (
    id VARCHAR(60) NOT NULL,
    analysissampleid VARCHAR(60) NOT NULL,
    analysisgroupid VARCHAR(60) NOT NULL,
    isdeleted BOOLEAN,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY(id),
    FOREIGN KEY(analysissampleid) references ffdp2_0.analysis_sample(id),
    FOREIGN KEY(analysisgroupid) references ffdp2_0.analysis_group(id)
) DISTSTYLE AUTO;

--create dimension table farms
CREATE TABLE IF NOT EXISTS ffdp2_0.farm (
    id VARCHAR(60) NOT NULL,
    countryid VARCHAR(60),
    regionid VARCHAR(60),
    farmname VARCHAR(600),
    address VARCHAR(1000),
    zipcode VARCHAR(600),
    farmsize DOUBLE PRECISION,
    farmsizeuomid VARCHAR(60),
    farmsizeuomname VARCHAR(600),
    nooffarmhands INTEGER,
    nooffields INTEGER,
    additional_parameters SUPER,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    source VARCHAR(60),
    PRIMARY KEY (id),
    FOREIGN KEY (countryid) REFERENCES ffdp2_0.country (id),
    FOREIGN KEY (regionid) REFERENCES ffdp2_0.region (id)
) DISTSTYLE AUTO DISTKEY (id);

-- Creating Dimension table "fields"
CREATE TABLE IF NOT EXISTS ffdp2_0.field (
    id VARCHAR(60) NOT NULL,
    countryid VARCHAR(60),
    regionid VARCHAR(60),
    farmid VARCHAR(60),
    fieldname VARCHAR(600),
    fieldsize DOUBLE PRECISION,
    fieldsizeuomid VARCHAR(60),
    vardafieldid VARCHAR(60),
    vardaboundaryid VARCHAR(60),
    featuredataid VARCHAR(600),
    feature SUPER,
    center VARCHAR(600),
    geohash VARCHAR(600),
    geometryhash VARCHAR(600),
    ewkt VARCHAR(600),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    additional_parameters SUPER,
    version INTEGER,
    source VARCHAR(60),
    PRIMARY KEY(id),
    FOREIGN KEY(countryid) references ffdp2_0.country(id),
    FOREIGN KEY(regionid) references ffdp2_0.region(id),
    FOREIGN KEY(farmid) references ffdp2_0.farm(id)
) DISTSTYLE AUTO;

-- Creating Dimension table "crop"
CREATE TABLE IF NOT EXISTS ffdp2_0.crop (
    id VARCHAR(60) NOT NULL,
    cropregionid VARCHAR(60),
    growthscaleid VARCHAR(60),
    cropdescriptionid VARCHAR(60),
    countryid VARCHAR(60),
    regionid VARCHAR(60),
    yield_base_unitid VARCHAR(60) ,
    demand_base_unitid VARCHAR(60) ,
    defaultHarvestDate TIMESTAMP WITHOUT TIME ZONE,
    defaultYield DOUBLE PRECISION,
    defaultSeedingDate TIMESTAMP WITHOUT TIME ZONE,
    residues_removed_n DOUBLE PRECISION,
    residues_left_n DOUBLE PRECISION,
    residues_incorporated_spring_n DOUBLE PRECISION,
    residueNUptake DOUBLE PRECISION,
    residueFactor DOUBLE PRECISION,
    nutrientUseEfficiency DOUBLE PRECISION,
    applicationTags VARCHAR(60),
    calculationParameters SUPER,
    additionalProperties SUPER,
    agroCoreCode INTEGER,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    source VARCHAR(60),
    PRIMARY KEY(id),
    FOREIGN KEY(countryId) references ffdp2_0.country(id),
    FOREIGN KEY(regionId) references ffdp2_0.region(id)
) DISTSTYLE AUTO;

-- Create crop_nutrition_plan table
CREATE TABLE IF NOT EXISTS ffdp2_0.crop_nutrition_plan (
    id VARCHAR(60) NOT NULL,
    status VARCHAR(255),
    cnpowner VARCHAR(255),
    fieldid VARCHAR(60),
    cropid VARCHAR(60),
    userid VARCHAR(60),
    countryid VARCHAR(60),
    regionid VARCHAR(60),
    yield DOUBLE PRECISION,
    yielduniomid VARCHAR(60),
    yieldsource VARCHAR(60),
    boundries VARCHAR(60),
    fieldsize DOUBLE PRECISION,
    fieldsizeuomid VARCHAR(60),
    soiltypeid VARCHAR(60),
    cropresiduemanagementid VARCHAR(60),
    demandunitid VARCHAR(60),
    additionalparameters SUPER,
    precrop SUPER,
    postcrop SUPER,
    analysis SUPER,
    customproducts SUPER,
    appliedproducts SUPER,
    recommendationdata SUPER,
    planbalance SUPER,
    soilanalysiscalculationv2requested SUPER,
    soilanalysiscalculationv2performed SUPER,
    soilproductrecommendationv2requested SUPER,
    soilproductrecommendationv2performed SUPER,
    eventid VARCHAR(60),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    PRIMARY KEY(id),
    FOREIGN KEY(fieldid) references ffdp2_0.field(id),
    FOREIGN KEY(cropid) references ffdp2_0.crop(id),
    FOREIGN KEY(userid) references ffdp2_0.user(id),
    FOREIGN KEY(countryid) references ffdp2_0.country(id),
    FOREIGN KEY(regionid) references ffdp2_0.region(id)
) DISTSTYLE AUTO;

-- create fact table usersfarms
CREATE TABLE IF NOT EXISTS ffdp2_0.users_farms (
    id VARCHAR(60) NOT NULL,
    farmid VARCHAR(60),
    organizationid VARCHAR(60),
    userid VARCHAR(60),
    roleid VARCHAR(60),
    userregionid VARCHAR(60),
    usercountryid VARCHAR(60),
    farmregionid VARCHAR(60),
    farmcountryid VARCHAR(60),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (farmid) REFERENCES ffdp2_0.farm (id),
    FOREIGN KEY (organizationid) REFERENCES ffdp2_0.organization (id),
    FOREIGN KEY (userid) REFERENCES ffdp2_0.user (id),
    FOREIGN KEY (roleid) REFERENCES ffdp2_0.role (id),
    FOREIGN KEY (userregionid) REFERENCES ffdp2_0.region (id),
    FOREIGN KEY (usercountryid) REFERENCES ffdp2_0.country (id),
    FOREIGN KEY (farmregionid) REFERENCES ffdp2_0.region (id),
    FOREIGN KEY (farmcountryid) REFERENCES ffdp2_0.country (id)
) DISTSTYLE AUTO DISTKEY (id);

--create fact table season
CREATE TABLE IF NOT EXISTS ffdp2_0.season (
    id VARCHAR(60) NOT NULL,
    seasonname VARCHAR(600),
    fieldid VARCHAR(60),
    farmid VARCHAR(60),
    cropid VARCHAR(60),
    growthscalestageid VARCHAR(60),
    fieldregionid VARCHAR(60),
    fieldcountryid VARCHAR(60),
    startdate TIMESTAMP WITHOUT TIME ZONE,
    enddate TIMESTAMP WITHOUT TIME ZONE,
    plantingdate TIMESTAMP WITHOUT TIME ZONE,
    expectedyield DOUBLE PRECISION,
    expectedyielduomid VARCHAR(60),
    additionalparameters SUPER,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    source VARCHAR(60),
    PRIMARY KEY (id),
    FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field (id),
    FOREIGN KEY (farmid) REFERENCES ffdp2_0.farm (id),
    FOREIGN KEY (cropid) REFERENCES ffdp2_0.crop (id),
    FOREIGN KEY (growthscalestageid) REFERENCES ffdp2_0.growth_scale_stage (id),
    FOREIGN KEY (fieldregionid) REFERENCES ffdp2_0.region (id),
    FOREIGN KEY (fieldcountryid) REFERENCES ffdp2_0.country (id)
) DISTSTYLE AUTO DISTKEY (id);

--create fact table photo_analysis
CREATE TABLE IF NOT EXISTS ffdp2_0.photo_analysis (
    id VARCHAR(60) NOT NULL,
    fieldid VARCHAR(60) NOT NULL,
    cropid VARCHAR(60) NOT NULL,
    resultdate TIMESTAMP WITHOUT TIME ZONE,
    expectedyield DOUBLE PRECISION,
    expectedyielduomid VARCHAR(60) NOT NULL,
    countryid VARCHAR(60) NOT NULL,
    regionid VARCHAR(60) NOT NULL,
    value DOUBLE PRECISION,
    valuetype VARCHAR(30),
    notes SUPER,
    data SUPER,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    additional_parameters VARCHAR(100),
    PRIMARY KEY (id),
    FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field (id),
    FOREIGN KEY (cropid) REFERENCES ffdp2_0.crop (id),
    FOREIGN KEY (countryid) REFERENCES ffdp2_0.country (id),
    FOREIGN KEY (regionid) REFERENCES ffdp2_0.region (id)
) DISTSTYLE AUTO DISTKEY (id);

--create fact table vra
CREATE TABLE IF NOT EXISTS ffdp2_0.vra (
    id VARCHAR(60) NOT NULL,
    fieldid VARCHAR(60) NOT NULL,
    seasonid VARCHAR(60) NOT NULL,
    growthstage INTEGER,
    fertilizer VARCHAR(100),
    cellsize DOUBLE PRECISION,
    edited BOOLEAN,
    product_region_id VARCHAR(60) NOT NULL,
    crop_region_id VARCHAR(60) NOT NULL,
    min_n DOUBLE PRECISION,
    max_n DOUBLE PRECISION,
    target_n DOUBLE PRECISION,
    protein BOOLEAN,
    application_date TIMESTAMP WITH TIME ZONE,
    exportedat TIMESTAMP WITHOUT TIME ZONE,
    imagedate DATE,
    generationalgorithm VARCHAR(100),
    lastselectedmode VARCHAR(100),
    plain_property_id VARCHAR(60) NOT NULL,
    zone_property_id VARCHAR(60) NOT NULL,
    croptype VARCHAR(100),
    total_fertilizer DOUBLE PRECISION,
    total_n DOUBLE PRECISION,
    average_n DOUBLE PRECISION,
    zones SUPER,
    additional_parameters SUPER,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedby VARCHAR(600),
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (growthstage) REFERENCES ffdp2_0.growth_scale_stage (id),
    FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field (id),
    FOREIGN KEY (seasonid) REFERENCES ffdp2_0.season (id)
) DISTSTYLE AUTO DISTKEY (id);

--create fact table analysisorderresult
CREATE TABLE IF NOT EXISTS ffdp2_0.analysisorder_result (
    id VARCHAR(60) NOT NULL,
    analysissampleid VARCHAR(60) NOT NULL,
    analysistypeid VARCHAR(60) NOT NULL,
    sampletypeid VARCHAR(60) NOT NULL,
    analysisorderid VARCHAR(60) NOT NULL,
    analysisordersampletypeid VARCHAR(60) NOT NULL,
    analysisorderinterpretationresultid VARCHAR(60) NOT NULL,
    nutrientprofileid VARCHAR(60) NOT NULL,
    fieldid VARCHAR(60) NOT NULL,
    textresult VARCHAR(100),
    decimalresult DOUBLE PRECISION,
    flag VARCHAR(100),
    "limit" DOUBLE PRECISION,
    analysismethodid VARCHAR(60) NOT NULL,
    unitofmeasureid VARCHAR(60) NOT NULL,
    resultsentdate TIMESTAMP WITH TIME ZONE,
    isdeleted BOOLEAN,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (analysissampleid) REFERENCES ffdp2_0.analysis_sample (id),
    FOREIGN KEY (analysistypeid) REFERENCES ffdp2_0.analysis_type (id),
    FOREIGN KEY (sampletypeid) REFERENCES ffdp2_0.sample_type (id),
    FOREIGN KEY (analysisorderid) REFERENCES ffdp2_0.analysis_order (id),
    FOREIGN KEY (analysisorderinterpretationresultid) REFERENCES ffdp2_0.analysis_order_interpretation_result (id),
    FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field (id)
) DISTSTYLE AUTO DISTKEY (id);

-- Creating Fact table "n_tester"
CREATE TABLE IF NOT EXISTS ffdp2_0.n_tester (
    id VARCHAR(60) NOT NULL,
    ntesterid VARCHAR(60) NOT NULL,
    seasonid VARCHAR(60) NOT NULL,
    fieldid VARCHAR(60) NOT NULL,
    cropid VARCHAR(60) NOT NULL,
    resultdate TIMESTAMP WITHOUT TIME ZONE,
    expectedyield DOUBLE PRECISION,
    expectedyielduomid VARCHAR(60) NOT NULL,
    calculationtype VARCHAR(255),
    value DOUBLE PRECISION,
    valuetype VARCHAR(255),
    listofreadings SUPER,
    listofanswers SUPER,
    notes SUPER,
    data SUPER,
    messages VARCHAR(60),
    messagekey VARCHAR(60),
    warningmessage VARCHAR(60),
    warningmessagekey VARCHAR(60),
    productrecomendation VARCHAR(60),
    pdfurl VARCHAR(60),
    nitrogensufficiencyindex DOUBLE PRECISION,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    additional_parameters SUPER,
    PRIMARY KEY(id),
    FOREIGN KEY(seasonid) references ffdp2_0.season(id),
    FOREIGN KEY(fieldid) references ffdp2_0.field(id),
    FOREIGN KEY(cropid) references ffdp2_0.crop(id)
) DISTSTYLE AUTO;

CREATE TABLE IF NOT EXISTS ffdp2_0.map (
    id VARCHAR(60) NOT NULL,
    seasonId VARCHAR(255),
    filesCountInZip INTEGER,
    filelocation VARCHAR(1000),
    eventSource VARCHAR(255),
    filesize INTEGER,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    additional_parameters SUPER,
    version INTEGER,
    source VARCHAR(60)
);

