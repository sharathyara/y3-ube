-- liquibase formatted sql

--changeset ramesh_s:ATI-5288-update-ffdp-user-table-change-notnull-remove-constrints splitStatements:true
--comment: ATI-5288 - create user table with auto diststyle
DROP TABLE IF EXISTS ffdp2_0.user_old;
ALTER TABLE ffdp2_0.user RENAME TO user_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.user (
    id VARCHAR(60),
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
    version INTEGER
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.user (
    id, name, email, phone, auth0id, countryid, zipcode, regionid, languagepreference,
    timezone, umopreference, source, createdat, createdby, updatedat, updatedby,
    deletedat, deletedby, consent, newsletteroptin, is_internal_user, email_verified,
    additional_parameters, version
)
SELECT
    id, name, email, phone, auth0id, countryid, zipcode, regionid, languagepreference,
    timezone, umopreference, source, createdat, createdby, updatedat, updatedby,
    deletedat, deletedby, consent, newsletteroptin, is_internal_user, email_verified,
    additional_parameters, version
FROM
    ffdp2_0.user_old;

ALTER TABLE ffdp2_0.user OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.user_old CASCADE;


-- rollback DROP TABLE IF EXISTS ffdp2_0.user_old;
-- rollback ALTER TABLE ffdp2_0.user RENAME TO user_old;

-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.user (
-- rollback     id VARCHAR(60) NOT NULL,
-- rollback     name VARCHAR(600),
-- rollback     email VARCHAR(600),
-- rollback     phone VARCHAR(60),
-- rollback     auth0id VARCHAR(60),
-- rollback     countryid VARCHAR(60),
-- rollback     zipcode VARCHAR(60),
-- rollback     regionid VARCHAR(60),
-- rollback     languagepreference VARCHAR(600),
-- rollback     timezone VARCHAR(600),
-- rollback     umopreference VARCHAR(600),
-- rollback     source VARCHAR(60),
-- rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     createdby VARCHAR(600),
-- rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     updatedby VARCHAR(600),
-- rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     deletedby VARCHAR(600),
-- rollback     consent BOOLEAN,
-- rollback     newsletteroptin BOOLEAN,
-- rollback     is_internal_user BOOLEAN,
-- rollback     email_verified BOOLEAN,
-- rollback     additional_parameters SUPER,
-- rollback     version INTEGER,
-- rollback     PRIMARY KEY (id),
-- rollback     FOREIGN KEY(countryid) references ffdp2_0.country(id),
-- rollback     FOREIGN KEY(regionid) references ffdp2_0.region(id)
-- rollback ) DISTSTYLE KEY DISTKEY id ;

-- rollback INSERT INTO ffdp2_0.user (
-- rollback     id, name, email, phone, auth0id, countryid, zipcode, regionid, languagepreference,
-- rollback     timezone, umopreference, source, createdat, createdby, updatedat, updatedby,
-- rollback     deletedat, deletedby, consent, newsletteroptin, is_internal_user, email_verified,
-- rollback     additional_parameters, version
-- rollback )
-- rollback SELECT
-- rollback     id, name, email, phone, auth0id, countryid, zipcode, regionid, languagepreference,
-- rollback     timezone, umopreference, source, createdat, createdby, updatedat, updatedby,
-- rollback     deletedat, deletedby, consent, newsletteroptin, is_internal_user, email_verified,
-- rollback     additional_parameters, version
-- rollback FROM
-- rollback     ffdp2_0.user_old;
-- rollback
-- rollback ALTER TABLE ffdp2_0.user OWNER TO "IAM:ffdp-airflow";

-- rollback DROP TABLE IF EXISTS ffdp2_0.user_old CASCADE;




--changeset ramesh_s:ATI-5288-update-ffdp-farm-table-drop-notnull-constrain splitStatements:true
--comment: ATI-5288 - create farm table with auto diststyle
DROP TABLE IF EXISTS ffdp2_0.farm_old;
ALTER TABLE ffdp2_0.farm RENAME TO farm_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.farm (
    id VARCHAR(60),
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
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.farm (
    id, countryid, regionid, farmname, address, zipcode, farmsize, farmsizeuomid,
    farmsizeuomname, nooffarmhands, nooffields, additional_parameters,
    createdat, createdby, updatedat, updatedby, deletedat, deletedby,
    version, source
)
SELECT
    id, countryid, regionid, farmname, address, zipcode, farmsize, farmsizeuomid,
    farmsizeuomname, nooffarmhands, nooffields, additional_parameters,
    createdat, createdby, updatedat, updatedby, deletedat, deletedby,
    version, source
FROM ffdp2_0.farm_old;

ALTER TABLE ffdp2_0.farm OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.farm_old CASCADE;


-- rollback DROP TABLE IF EXISTS ffdp2_0.farm_old;
-- rollback ALTER TABLE ffdp2_0.farm RENAME TO farm_old;
-- rollback
-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.farm (
-- rollback     id VARCHAR(60),
-- rollback     countryid VARCHAR(60),
-- rollback     regionid VARCHAR(60),
-- rollback     farmname VARCHAR(600),
-- rollback     address VARCHAR(1000),
-- rollback     zipcode VARCHAR(600),
-- rollback     farmsize DOUBLE PRECISION,
-- rollback     farmsizeuomid VARCHAR(60),
-- rollback     farmsizeuomname VARCHAR(600),
-- rollback     nooffarmhands INTEGER,
-- rollback     nooffields INTEGER,
-- rollback     additional_parameters SUPER,
-- rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     createdby VARCHAR(600),
-- rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     updatedby VARCHAR(600),
-- rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     deletedby VARCHAR(600),
-- rollback     version INTEGER,
-- rollback     source VARCHAR(60)
-- rollback ) DISTSTYLE AUTO;

-- rollback INSERT INTO ffdp2_0.farm (
-- rollback     id, countryid, regionid, farmname, address, zipcode, farmsize, farmsizeuomid,
-- rollback     farmsizeuomname, nooffarmhands, nooffields, additional_parameters,
-- rollback     createdat, createdby, updatedat, updatedby, deletedat, deletedby,
-- rollback     version, source
-- rollback )
-- rollback SELECT
-- rollback     id, countryid, regionid, farmname, address, zipcode, farmsize, farmsizeuomid,
-- rollback     farmsizeuomname, nooffarmhands, nooffields, additional_parameters,
-- rollback     createdat, createdby, updatedat, updatedby, deletedat, deletedby,
-- rollback     version, source
-- rollback FROM ffdp2_0.farm_old;

-- rollback ALTER TABLE ffdp2_0.farm OWNER TO "IAM:ffdp-airflow";

-- rollback ALTER TABLE ffdp2_0.field ADD CONSTRAINT field_new_farmid_fkey FOREIGN KEY (farmid) REFERENCES ffdp2_0.farm(id);
-- rollback ALTER TABLE ffdp2_0.season ADD CONSTRAINT season_farmid_fkey FOREIGN KEY (farmid) REFERENCES ffdp2_0.farm(id);
-- rollback ALTER TABLE ffdp2_0.users_farms ADD CONSTRAINT users_farms_farmid_fkey FOREIGN KEY (farmid) REFERENCES ffdp2_0.farm(id);

-- rollback DROP TABLE IF EXISTS ffdp2_0.farm_old CASCADE;


--changeset ramesh_s:ATI-5288-update-ffdp-organization-table-drop-notnull-constrain-on-subscriptionid splitStatements:true
--comment: ATI-5288 - create organization table with auto diststyle
DROP TABLE IF EXISTS ffdp2_0.organization_old;
ALTER TABLE ffdp2_0.organization RENAME TO organization_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.organization (
    id VARCHAR(60),
    organizationname VARCHAR(600),
    subscriptionid VARCHAR(60),
    subscriptionname VARCHAR(600),
    countryid VARCHAR(60),
    address VARCHAR(1000),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.organization (
    id, organizationname, subscriptionid, subscriptionname, countryid, address,
    createdat, createdby, updatedat, updatedby, deletedat, deletedby, version
)
SELECT
    id, organizationname, subscriptionid, subscriptionname, countryid, address,
    createdat, createdby, updatedat, updatedby, deletedat, deletedby, version
FROM ffdp2_0.organization_old;


ALTER TABLE ffdp2_0.organization OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.organization_old CASCADE;

-- rollback DROP TABLE IF EXISTS ffdp2_0.organization_old;
-- rollback ALTER TABLE ffdp2_0.organization RENAME TO organization_old;

-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.organization (
-- rollback     id VARCHAR(60) NOT NULL,
-- rollback     organizationname VARCHAR(600),
-- rollback     subscriptionid VARCHAR(60) NOT NULL,
-- rollback     subscriptionname VARCHAR(600),
-- rollback     countryid VARCHAR(60) NOT NULL,
-- rollback     address VARCHAR(1000),
-- rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     createdby VARCHAR(600),
-- rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     updatedby VARCHAR(600),
-- rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     deletedby VARCHAR(600),
-- rollback     version INTEGER,
-- rollback     PRIMARY KEY (id),
-- rollback     FOREIGN KEY(subscriptionid) references ffdp2_0.subscription(id),
-- rollback     FOREIGN KEY(countryid) references ffdp2_0.country(id)
-- rollback ) DISTSTYLE AUTO;

-- rollback ALTER TABLE ffdp2_0.organization OWNER TO "IAM:ffdp-airflow";

-- rollback ALTER TABLE ffdp2_0.organization_user ADD CONSTRAINT organization_user_organizationid_fkey FOREIGN KEY (organizationid) REFERENCES ffdp2_0.organization(id);
-- rollback ALTER TABLE ffdp2_0.users_farms ADD CONSTRAINT users_farms_organizationid_fkey FOREIGN KEY (organizationid) REFERENCES ffdp2_0.organization(id);

-- rollback DROP TABLE IF EXISTS ffdp2_0.organization_old CASCADE;



--changeset ramesh_s:ATI-5288-update-ffdp-cnp-table-add-new-columns splitStatements:true
--comment: ATI-5288 - create cnp table with auto diststyle
DROP TABLE IF EXISTS ffdp2_0.crop_nutrition_plan_old;
ALTER TABLE ffdp2_0.crop_nutrition_plan RENAME TO crop_nutrition_plan_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.crop_nutrition_plan (
    id VARCHAR(60),
    status VARCHAR(255),
    cnpowner VARCHAR(255),
    fieldid VARCHAR(60),
    cropid VARCHAR(60),
    userid VARCHAR(60),
    countryid VARCHAR(60),
    regionid VARCHAR(60),
    targetyield DOUBLE PRECISION,
    targetyielduomid VARCHAR(60),
    yieldsource VARCHAR(60),
    fieldsize DOUBLE PRECISION,
    fieldsizeuomid VARCHAR(60),
    soiltypeid VARCHAR(60),
    cropresiduemanagementid VARCHAR(60),
    demandunitid VARCHAR(60),
    additional_parameters SUPER,
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
    version INTEGER,
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.crop_nutrition_plan (
    id, status, cnpowner, fieldid, cropid, userid, countryid, regionid,
    targetyield, targetyielduomid, yieldsource, fieldsize, fieldsizeuomid,
    soiltypeid, cropresiduemanagementid, demandunitid, additional_parameters,
    precrop, postcrop, analysis, customproducts, appliedproducts,
    recommendationdata, planbalance, soilanalysiscalculationv2requested,
    soilanalysiscalculationv2performed, soilproductrecommendationv2requested,
    soilproductrecommendationv2performed, eventid, createdat, createdby,
    updatedat, updatedby, deletedat, deletedby
)
SELECT
    id, status, cnpowner, fieldid, cropid, userid, countryid, regionid,
    yield, yielduniomid, yieldsource, fieldsize, fieldsizeuomid,
    soiltypeid, cropresiduemanagementid, demandunitid, additionalparameters,
    precrop, postcrop, analysis, customproducts, appliedproducts,
    recommendationdata, planbalance, soilanalysiscalculationv2requested,
    soilanalysiscalculationv2performed, soilproductrecommendationv2requested,
    soilproductrecommendationv2performed, eventid, createdat, createdby,
    updatedat, updatedby, deletedat, deletedby
FROM ffdp2_0.crop_nutrition_plan_old;

ALTER TABLE ffdp2_0.crop_nutrition_plan OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.crop_nutrition_plan_old CASCADE;


-- rollback DROP TABLE IF EXISTS ffdp2_0.crop_nutrition_plan_old;
-- rollback ALTER TABLE ffdp2_0.crop_nutrition_plan RENAME TO crop_nutrition_plan_old;

-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.crop_nutrition_plan (
-- rollback     id VARCHAR(60) NOT NULL,
-- rollback     status VARCHAR(255),
-- rollback     cnpowner VARCHAR(255),
-- rollback     fieldid VARCHAR(60),
-- rollback     cropid VARCHAR(60),
-- rollback     userid VARCHAR(60),
-- rollback     countryid VARCHAR(60),
-- rollback     regionid VARCHAR(60),
-- rollback     yield DOUBLE PRECISION,
-- rollback     yielduniomid VARCHAR(60),
-- rollback     yieldsource VARCHAR(60),
-- rollback     boundries VARCHAR(60),
-- rollback     fieldsize DOUBLE PRECISION,
-- rollback     fieldsizeuomid VARCHAR(60),
-- rollback     soiltypeid VARCHAR(60),
-- rollback     cropresiduemanagementid VARCHAR(60),
-- rollback     demandunitid VARCHAR(60),
-- rollback     additionalparameters SUPER,
-- rollback     precrop SUPER,
-- rollback     postcrop SUPER,
-- rollback     analysis SUPER,
-- rollback     customproducts SUPER,
-- rollback     appliedproducts SUPER,
-- rollback     recommendationdata SUPER,
-- rollback     planbalance SUPER,
-- rollback     soilanalysiscalculationv2requested SUPER,
-- rollback     soilanalysiscalculationv2performed SUPER,
-- rollback     soilproductrecommendationv2requested SUPER,
-- rollback     soilproductrecommendationv2performed SUPER,
-- rollback     eventid VARCHAR(60),
-- rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     createdby VARCHAR(600),
-- rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     updatedby VARCHAR(600),
-- rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     deletedby VARCHAR(600),
-- rollback     PRIMARY KEY(id),
-- rollback     FOREIGN KEY(fieldid) references ffdp2_0.field(id),
-- rollback     FOREIGN KEY(cropid) references ffdp2_0.crop(id),
-- rollback     FOREIGN KEY(userid) references ffdp2_0.user(id),
-- rollback     FOREIGN KEY(countryid) references ffdp2_0.country(id),
-- rollback     FOREIGN KEY(regionid) references ffdp2_0.region(id)
-- rollback ) DISTSTYLE AUTO;

-- rollback INSERT INTO ffdp2_0.crop_nutrition_plan (
-- rollback     id, status, cnpowner, fieldid, cropid, userid, countryid, regionid,
-- rollback     yield, yielduniomid, yieldsource, fieldsize, fieldsizeuomid,
-- rollback     soiltypeid, cropresiduemanagementid, demandunitid, additionalparameters,
-- rollback     precrop, postcrop, analysis, customproducts, appliedproducts,
-- rollback     recommendationdata, planbalance, soilanalysiscalculationv2requested,
-- rollback     soilanalysiscalculationv2performed, soilproductrecommendationv2requested,
-- rollback     soilproductrecommendationv2performed, eventid, createdat, createdby,
-- rollback     updatedat, updatedby, deletedat, deletedby
-- rollback )
-- rollback SELECT
-- rollback     id, status, cnpowner, fieldid, cropid, userid, countryid, regionid,
-- rollback     targetyield, targetyielduomid, yieldsource, fieldsize, fieldsizeuomid,
-- rollback     soiltypeid, cropresiduemanagementid, demandunitid, additional_parameters,
-- rollback     precrop, postcrop, analysis, customproducts, appliedproducts,
-- rollback     recommendationdata, planbalance, soilanalysiscalculationv2requested,
-- rollback     soilanalysiscalculationv2performed, soilproductrecommendationv2requested,
-- rollback     soilproductrecommendationv2performed, eventid, createdat, createdby,
-- rollback     updatedat, updatedby, deletedat, deletedby
-- rollback FROM ffdp2_0.crop_nutrition_plan_old;

-- rollback ALTER TABLE ffdp2_0.crop_nutrition_plan OWNER TO "IAM:ffdp-airflow";
-- rollback DROP TABLE IF EXISTS ffdp2_0.crop_nutrition_plan_old CASCADE;



--changeset ramesh_s:ATI-5288-update-ffdp-ntester-table-add-new-columns splitStatements:true
--comment: ATI-5288 - create cnp table with auto diststyle
DROP TABLE IF EXISTS ffdp2_0.n_tester_old;
ALTER TABLE ffdp2_0.n_tester RENAME TO n_tester_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.n_tester (
    id VARCHAR(60),
    ntesterid VARCHAR(60),
    seasonid VARCHAR(60),
    fieldid VARCHAR(60),
    cropid VARCHAR(60),
    resultdate TIMESTAMP WITHOUT TIME ZONE,
    expectedyield DOUBLE PRECISION,
    expectedyielduomid VARCHAR(60),
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
    productrecomendation VARCHAR(1000),
    pdfurl VARCHAR(1000),
    nitrogensufficiencyindex DOUBLE PRECISION,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    additional_parameters SUPER,
    version INTEGER,
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.n_tester (
    id, ntesterid, seasonid, fieldid, cropid, resultdate,
    expectedyield, expectedyielduomid, calculationtype, value,
    valuetype, listofreadings, listofanswers, notes, data,
    messages, messagekey, warningmessage, warningmessagekey,
    productrecomendation, pdfurl, nitrogensufficiencyindex,
    createdat, createdby, updatedat, updatedby, deletedat, deletedby,
    additional_parameters
)
SELECT
    id, ntesterid, seasonid, fieldid, cropid, resultdate,
    expectedyield, expectedyielduomid, calculationtype, value,
    valuetype, listofreadings, listofanswers, notes, data,
    messages, messagekey, warningmessage, warningmessagekey,
    productrecomendation, pdfurl, nitrogensufficiencyindex,
    createdat, createdby, updatedat, updatedby, deletedat, deletedby,
    additional_parameters
FROM ffdp2_0.n_tester_old;

ALTER TABLE ffdp2_0.n_tester OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.n_tester_old CASCADE;

-- rollback DROP TABLE IF EXISTS ffdp2_0.n_tester_old;
-- rollback ALTER TABLE ffdp2_0.n_tester RENAME TO n_tester_old;

-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.n_tester (
-- rollback     id VARCHAR(60) NOT NULL,
-- rollback     ntesterid VARCHAR(60) NOT NULL,
-- rollback     seasonid VARCHAR(60) NOT NULL,
-- rollback     fieldid VARCHAR(60) NOT NULL,
-- rollback     cropid VARCHAR(60) NOT NULL,
-- rollback     resultdate TIMESTAMP WITHOUT TIME ZONE,
-- rollback     expectedyield DOUBLE PRECISION,
-- rollback     expectedyielduomid VARCHAR(60) NOT NULL,
-- rollback     calculationtype VARCHAR(255),
-- rollback     value DOUBLE PRECISION,
-- rollback     valuetype VARCHAR(255),
-- rollback     listofreadings SUPER,
-- rollback     listofanswers SUPER,
-- rollback     notes SUPER,
-- rollback     data SUPER,
-- rollback     messages VARCHAR(60),
-- rollback     messagekey VARCHAR(60),
-- rollback     warningmessage VARCHAR(60),
-- rollback     warningmessagekey VARCHAR(60),
-- rollback     productrecomendation VARCHAR(60),
-- rollback     pdfurl VARCHAR(60),
-- rollback     nitrogensufficiencyindex DOUBLE PRECISION,
-- rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     createdby VARCHAR(600),
-- rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     updatedby VARCHAR(600),
-- rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     deletedby VARCHAR(600),
-- rollback     additional_parameters SUPER,
-- rollback     PRIMARY KEY(id),
-- rollback     FOREIGN KEY(seasonid) references ffdp2_0.season(id),
-- rollback     FOREIGN KEY(fieldid) references ffdp2_0.field(id),
-- rollback     FOREIGN KEY(cropid) references ffdp2_0.crop(id)
-- rollback ) DISTSTYLE AUTO;
-- rollback ALTER TABLE ffdp2_0.n_tester OWNER TO "IAM:ffdp-airflow";
-- rollback DROP TABLE IF EXISTS ffdp2_0.n_tester_old CASCADE;


--changeset ramesh_s:ATI-5288-update-ffdp-organizationuser-table-drop-notnull-constraint splitStatements:true
--comment: ATI-5288 - create organization_user table with auto diststyle
DROP TABLE IF EXISTS ffdp2_0.organization_user_old;
ALTER TABLE ffdp2_0.organization_user RENAME TO organization_user_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.organization_user (
    id VARCHAR(60),
    organizationid VARCHAR(60),
    userid VARCHAR(60),
    roleid VARCHAR(60),
    subscriptionid VARCHAR(60),
    personaid VARCHAR(60),
    isactive BOOLEAN,
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.organization_user (
    id, organizationid, userid, roleid, subscriptionid, personaid,
    isactive, createdat, createdby, updatedat, updatedby, deletedat,
    deletedby, version
)
SELECT
    id, organizationid, userid, roleid, subscriptionid, personaid,
    isactive, createdat, createdby, updatedat, updatedby, deletedat,
    deletedby, version
FROM ffdp2_0.organization_user_old;


ALTER TABLE ffdp2_0.organization_user OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.organization_user_old CASCADE;


-- rollback DROP TABLE IF EXISTS ffdp2_0.organization_user_old;
-- rollback ALTER TABLE ffdp2_0.organization_user RENAME TO organization_user_old;

-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.organization_user (
-- rollback     id VARCHAR(60) NOT NULL,
-- rollback     organizationid VARCHAR(60) NOT NULL,
-- rollback     userid VARCHAR(60) NOT NULL,
-- rollback     roleid VARCHAR(60) NOT NULL,
-- rollback     subscriptionid VARCHAR(60) NOT NULL,
-- rollback     personaid VARCHAR(60) NOT NULL,
-- rollback     organizationregionid VARCHAR(60) NOT NULL,
-- rollback     organizationcountryid VARCHAR(60) NOT NULL,
-- rollback     userregionid VARCHAR(60) NOT NULL,
-- rollback     usercountryid VARCHAR(60) NOT NULL,
-- rollback     isactive BOOLEAN,
-- rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     createdby VARCHAR(600),
-- rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     updatedby VARCHAR(600),
-- rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     deletedby VARCHAR(600),
-- rollback     version INTEGER,
-- rollback     PRIMARY KEY(id),
-- rollback     FOREIGN KEY(organizationid) references ffdp2_0.organization(id),
-- rollback     FOREIGN KEY(userid) references ffdp2_0.user(id),
-- rollback     FOREIGN KEY(roleid) references ffdp2_0.role(id),
-- rollback     FOREIGN KEY(subscriptionid) references ffdp2_0.subscription(id),
-- rollback     FOREIGN KEY(personaid) references ffdp2_0.persona(id),
-- rollback     FOREIGN KEY(organizationregionid) references ffdp2_0.region(id),
-- rollback     FOREIGN KEY(organizationcountryid) references ffdp2_0.country(id),
-- rollback     FOREIGN KEY(userregionid) references ffdp2_0.region(id),
-- rollback     FOREIGN KEY(usercountryid) references ffdp2_0.country(id)
-- rollback ) DISTSTYLE AUTO;
-- rollback ALTER TABLE ffdp2_0.organization_user OWNER TO "IAM:ffdp-airflow";
-- rollback DROP TABLE IF EXISTS ffdp2_0.organization_user_old CASCADE;


--changeset ramesh_s:ATI-5288-update-ffdp-user_farm-table-rename-table splitStatements:true
--comment: ATI-5288 - create user_farm table with auto diststyle
DROP TABLE IF EXISTS ffdp2_0.user_farm;

CREATE TABLE IF NOT EXISTS ffdp2_0.user_farm (
    id VARCHAR(60),
    farmid VARCHAR(60),
    organizationid VARCHAR(60),
    userid VARCHAR(60),
    roleid VARCHAR(60),
    createdat TIMESTAMP WITHOUT TIME ZONE,
    createdby VARCHAR(600),
    updatedat TIMESTAMP WITHOUT TIME ZONE,
    updatedby VARCHAR(600),
    deletedat TIMESTAMP WITHOUT TIME ZONE,
    deletedby VARCHAR(600),
    version INTEGER,
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.user_farm (
    id, farmid, organizationid, userid, roleid,
    createdat, createdby, updatedat, updatedby, deletedat,
    deletedby, version
)
SELECT
    id, farmid, organizationid, userid, roleid,
    createdat, createdby, updatedat, updatedby, deletedat,
    deletedby, version
FROM ffdp2_0.users_farms;

ALTER TABLE ffdp2_0.user_farm OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.users_farms CASCADE;



-- rollback DROP TABLE IF EXISTS ffdp2_0.users_farms;

-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.users_farms (
-- rollback     id VARCHAR(60) NOT NULL,
-- rollback     farmid VARCHAR(60),
-- rollback     organizationid VARCHAR(60),
-- rollback     userid VARCHAR(60),
-- rollback     roleid VARCHAR(60),
-- rollback     userregionid VARCHAR(60),
-- rollback     usercountryid VARCHAR(60),
-- rollback     farmregionid VARCHAR(60),
-- rollback     farmcountryid VARCHAR(60),
-- rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     createdby VARCHAR(600),
-- rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     updatedby VARCHAR(600),
-- rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     deletedby VARCHAR(600),
-- rollback     version INTEGER,
-- rollback     PRIMARY KEY (id),
-- rollback     FOREIGN KEY (farmid) REFERENCES ffdp2_0.farm (id),
-- rollback     FOREIGN KEY (organizationid) REFERENCES ffdp2_0.organization (id),
-- rollback     FOREIGN KEY (userid) REFERENCES ffdp2_0.user (id),
-- rollback     FOREIGN KEY (roleid) REFERENCES ffdp2_0.role (id),
-- rollback     FOREIGN KEY (userregionid) REFERENCES ffdp2_0.region (id),
-- rollback     FOREIGN KEY (usercountryid) REFERENCES ffdp2_0.country (id),
-- rollback     FOREIGN KEY (farmregionid) REFERENCES ffdp2_0.region (id),
-- rollback     FOREIGN KEY (farmcountryid) REFERENCES ffdp2_0.country (id)
-- rollback ) DISTSTYLE AUTO DISTKEY (id);

-- rollback ALTER TABLE ffdp2_0.users_farms OWNER TO "IAM:ffdp-airflow";
-- rollback DROP TABLE IF EXISTS ffdp2_0.user_farm CASCADE;


--changeset ramesh_s:ATI-5288-update-ffdp-vra-table-drop-constraints splitStatements:true
--comment: ATI-5288 - create vra table with auto diststyle
DROP TABLE IF EXISTS ffdp2_0.vra_old;
ALTER TABLE ffdp2_0.vra RENAME TO vra_old;

CREATE TABLE IF NOT EXISTS ffdp2_0.vra (
    id VARCHAR(60),
    fieldid VARCHAR(60),
    seasonid VARCHAR(60),
    growthstage INTEGER,
    fertilizer SUPER,
    cellsize DOUBLE PRECISION,
    edited BOOLEAN,
    product_region_id VARCHAR(60),
    crop_region_id VARCHAR(60),
    min_n DOUBLE PRECISION,
    max_n DOUBLE PRECISION,
    target_n DOUBLE PRECISION,
    protein BOOLEAN,
    application_date TIMESTAMP WITH TIME ZONE,
    exportedat TIMESTAMP WITHOUT TIME ZONE,
    imagedate DATE,
    generationalgorithm VARCHAR(100),
    lastselectedmode VARCHAR(100),
    plain_property_id VARCHAR(60),
    zone_property_id VARCHAR(60),
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
    source VARCHAR(60)
) DISTSTYLE AUTO;

INSERT INTO ffdp2_0.vra (
    id, fieldid, seasonid, growthstage, fertilizer, cellsize,
    edited, product_region_id, crop_region_id, min_n, max_n,
    target_n, protein, application_date, exportedat, imagedate,
    generationalgorithm, lastselectedmode, plain_property_id,
    zone_property_id, croptype, total_fertilizer, total_n, average_n,
    zones, additional_parameters, createdat, updatedat, deletedat,
    createdby, updatedby, deletedby, version
)
SELECT
    id, fieldid, seasonid, growthstage, fertilizer, cellsize,
    edited, product_region_id, crop_region_id, min_n, max_n,
    target_n, protein, application_date, exportedat, imagedate,
    generationalgorithm, lastselectedmode, plain_property_id,
    zone_property_id, croptype, total_fertilizer, total_n, average_n,
    zones, additional_parameters, createdat, updatedat, deletedat,
    createdby, updatedby, deletedby, version
FROM ffdp2_0.vra_old;


ALTER TABLE ffdp2_0.vra OWNER TO "IAM:ffdp-airflow";
DROP TABLE IF EXISTS ffdp2_0.vra_old CASCADE;


-- rollback DROP TABLE IF EXISTS ffdp2_0.vra_old;
-- rollback ALTER TABLE ffdp2_0.vra RENAME TO vra_old;
-- rollback CREATE TABLE IF NOT EXISTS ffdp2_0.vra (
-- rollback     id VARCHAR(60) NOT NULL,
-- rollback     fieldid VARCHAR(60) NOT NULL,
-- rollback     seasonid VARCHAR(60) NOT NULL,
-- rollback     growthstage INTEGER,
-- rollback     fertilizer VARCHAR(100),
-- rollback     cellsize DOUBLE PRECISION,
-- rollback     edited BOOLEAN,
-- rollback     product_region_id VARCHAR(60) NOT NULL,
-- rollback     crop_region_id VARCHAR(60) NOT NULL,
-- rollback     min_n DOUBLE PRECISION,
-- rollback     max_n DOUBLE PRECISION,
-- rollback     target_n DOUBLE PRECISION,
-- rollback     protein BOOLEAN,
-- rollback     application_date TIMESTAMP WITH TIME ZONE,
-- rollback     exportedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     imagedate DATE,
-- rollback     generationalgorithm VARCHAR(100),
-- rollback     lastselectedmode VARCHAR(100),
-- rollback     plain_property_id VARCHAR(60) NOT NULL,
-- rollback     zone_property_id VARCHAR(60) NOT NULL,
-- rollback     croptype VARCHAR(100),
-- rollback     total_fertilizer DOUBLE PRECISION,
-- rollback     total_n DOUBLE PRECISION,
-- rollback     average_n DOUBLE PRECISION,
-- rollback     zones SUPER,
-- rollback     additional_parameters SUPER,
-- rollback     createdat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     updatedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     deletedat TIMESTAMP WITHOUT TIME ZONE,
-- rollback     createdby VARCHAR(600),
-- rollback     updatedby VARCHAR(600),
-- rollback     deletedby VARCHAR(600),
-- rollback     version INTEGER,
-- rollback     PRIMARY KEY (id),
-- rollback     FOREIGN KEY (growthstage) REFERENCES ffdp2_0.growth_scale_stage (id),
-- rollback     FOREIGN KEY (fieldid) REFERENCES ffdp2_0.field (id),
-- rollback     FOREIGN KEY (seasonid) REFERENCES ffdp2_0.season (id)
-- rollback ) DISTSTYLE AUTO DISTKEY (id);

-- rollback ALTER TABLE ffdp2_0.vra OWNER TO "IAM:ffdp-airflow";
-- rollback DROP TABLE IF EXISTS ffdp2_0.vra_old CASCADE;