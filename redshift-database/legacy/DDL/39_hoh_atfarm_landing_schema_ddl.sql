---- CREATING LANDING SCHEMA FOR ATFARM DATA----

DROP SCHEMA IF EXISTS landing_schema CASCADE;

CREATE SCHEMA IF NOT EXISTS landing_schema;
 
GRANT ALL ON SCHEMA landing_schema TO "IAM:ffdp-airflow";

-- landing_schema.atfarm_feature_data

DROP TABLE IF EXISTS landing_schema.atfarm_feature_data;

CREATE TABLE IF NOT EXISTS landing_schema.atfarm_feature_data
(
	id VARCHAR(50) NOT NULL,
	created TIMESTAMP WITH TIME ZONE,   
	updated TIMESTAMP WITH TIME ZONE,   
	feature VARCHAR(65535) NOT NULL,  
	geo_hash VARCHAR(65535) NOT NULL,  
	created_by VARCHAR(50),  
    last_updated_by VARCHAR(50)   

) DISTSTYLE AUTO;

ALTER TABLE landing_schema.atfarm_feature_data OWNER TO "IAM:ffdp-airflow";

-- landing_schema.atfarm_field

DROP TABLE IF EXISTS landing_schema.atfarm_field;

CREATE TABLE IF NOT EXISTS landing_schema.atfarm_field
(
	id VARCHAR(50) NOT NULL,
	created TIMESTAMP WITH TIME ZONE,  
	updated TIMESTAMP WITH TIME ZONE,
	name VARCHAR(65535),
	farm VARCHAR(50),
	country_code VARCHAR(65535) NOT NULL,
	area DOUBLE PRECISION,
	timeline_id VARCHAR(50),
	archived BOOLEAN NOT NULL,
	archived_at TIMESTAMP WITH TIME ZONE,
	crop_type VARCHAR(65535),
	feature_data_id VARCHAR(50),
	polaris_country_code_id VARCHAR(50),
	polaris_crop_region_id VARCHAR(50),  
	created_by VARCHAR(50),
	last_updated_by VARCHAR(50),
	crop_type_last_updated_at TIMESTAMP WITHOUT TIME ZONE 
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.atfarm_field OWNER TO "IAM:ffdp-airflow";

-- landing_schema.atfarm_user

DROP TABLE IF EXISTS landing_schema.atfarm_user;

CREATE TABLE IF NOT EXISTS landing_schema.atfarm_user
(
	id VARCHAR(108) NOT NULL,
	created TIMESTAMP WITHOUT TIME ZONE,
	updated TIMESTAMP WITHOUT TIME ZONE,
	cognito_identifier VARCHAR(32768),   
	user_email VARCHAR(765),   
	email_verified BOOLEAN, 
	locale VARCHAR(105) NOT NULL , 
	name VARCHAR(765),  
	newsletter_opt_in BOOLEAN , 
	phone VARCHAR(150),  
	secret_access_token VARCHAR(765),   
	first_name VARCHAR(765) , 
	last_name VARCHAR(765),   
	archived BOOLEAN NOT NULL, 
	archived_at TIMESTAMP WITHOUT TIME ZONE,
	role VARCHAR(96),  
	created_by VARCHAR(108),   
	last_updated_by VARCHAR(108)   
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.atfarm_user OWNER TO "IAM:ffdp-airflow";

-- landing_schema.atfarm_user_farm

DROP TABLE IF EXISTS landing_schema.atfarm_user_farm;

CREATE TABLE IF NOT EXISTS landing_schema.atfarm_user_farm
(
	user_id VARCHAR(108) NOT NULL, 
	farm_id VARCHAR(108), 
	role VARCHAR(96),  
	created TIMESTAMP WITHOUT TIME ZONE,   
	updated TIMESTAMP WITHOUT TIME ZONE,  
	creator VARCHAR(1) ,
	id VARCHAR(108) ,  
	created_by VARCHAR(150),  
	last_updated_by VARCHAR(150)
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.atfarm_user_farm OWNER TO "IAM:ffdp-airflow";

-- landing_schema.atfarm_farm

DROP TABLE IF EXISTS landing_schema.atfarm_farm;

CREATE TABLE IF NOT EXISTS landing_schema.atfarm_farm
(
	id VARCHAR(108) NOT NULL,
	created TIMESTAMP WITHOUT TIME ZONE,   
	updated TIMESTAMP WITHOUT TIME ZONE ,  
	name VARCHAR(765), 
	billing_contact_id VARCHAR(108),  
	notes VARCHAR(64512),   
	farm_contact_id VARCHAR(108),   
	created_by VARCHAR(108),  
	last_updated_by VARCHAR(108)  
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.atfarm_farm OWNER TO "IAM:ffdp-airflow";

-- landing_schema.atfarm_tenant_user

DROP TABLE IF EXISTS landing_schema.atfarm_tenant_user;

CREATE TABLE IF NOT EXISTS landing_schema.atfarm_tenant_user
(
	id VARCHAR(108) NOT NULL,
	created_by VARCHAR(108),  
	created_timestamp TIMESTAMP WITHOUT TIME ZONE,  
	updated_by VARCHAR(108),   
	updated_timestamp TIMESTAMP WITHOUT TIME ZONE,
	archived VARCHAR(15),
	archived_timestamp TIMESTAMP WITHOUT TIME ZONE,   
	row_version VARCHAR(108),  
	cognito_identifier VARCHAR(64512),   
	user_email VARCHAR(765),   
	email_verified VARCHAR(15) ,  
	locale VARCHAR(105) ,  
	name VARCHAR(765),  
	newsletter_opt_in VARCHAR(15),  
	phone VARCHAR(150), 
	secret_access_token VARCHAR(765),   
	first_name VARCHAR(765),  
	last_name VARCHAR(765) ,  
	country_code VARCHAR(765) ,  
	role VARCHAR(96),   
	farms_mapped VARCHAR(15) ,  
	yara_mkt_consent VARCHAR(15)   
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.atfarm_tenant_user OWNER TO "IAM:ffdp-airflow";

-- landing_schema.atfarm_tenant_user_farm

DROP TABLE IF EXISTS landing_schema.atfarm_tenant_user_farm;

CREATE TABLE IF NOT EXISTS landing_schema.atfarm_tenant_user_farm
(
	id VARCHAR(108) NOT NULL,  
	created_by VARCHAR(108),   
	created_timestamp TIMESTAMP WITHOUT TIME ZONE,
	updated_by VARCHAR(108),
	updated_timestamp TIMESTAMP WITHOUT TIME ZONE,
	row_version VARCHAR(108),
	user_id VARCHAR(108) ,
	farm_id VARCHAR(108) ,
	role VARCHAR(96) ,
	is_user_creator VARCHAR(15) 
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.atfarm_tenant_user_farm OWNER TO "IAM:ffdp-airflow";

-- landing_schema.atfarm_tenant_farm

DROP TABLE IF EXISTS landing_schema.atfarm_tenant_farm;

CREATE TABLE IF NOT EXISTS landing_schema.atfarm_tenant_farm
(
	id VARCHAR(108) NOT NULL,  
	created_by VARCHAR(108),
	created_timestamp TIMESTAMP WITHOUT TIME ZONE ,
	updated_by VARCHAR(108),
	updated_timestamp TIMESTAMP WITHOUT TIME ZONE,
	row_version VARCHAR(108),
	name VARCHAR(768) NOT NULL,
	notes VARCHAR(64512),
	farm_contact_id VARCHAR(108)   
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.atfarm_tenant_farm OWNER TO "IAM:ffdp-airflow";

-- landing_schema.tenants_users

DROP TABLE IF EXISTS landing_schema.tenants_users;

CREATE TABLE IF NOT EXISTS landing_schema.tenants_users
(
	id VARCHAR(108) NOT NULL,
	created_at TIMESTAMP WITHOUT TIME ZONE,
	updated_at TIMESTAMP WITHOUT TIME ZONE ,
	deleted_at TIMESTAMP WITHOUT TIME ZONE,
	country_code VARCHAR(24000) ,
	role VARCHAR(24000) ,
	farms_mapped VARCHAR(15),
	yara_mkt_consent VARCHAR(15) ,
	email VARCHAR(24000),
	first_name VARCHAR(24000),
	last_name VARCHAR(24000) ,
	migrationtimestamp VARCHAR(150)  
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.tenants_users OWNER TO "IAM:ffdp-airflow";

-- landing_schema.airtable_emails;

DROP TABLE IF EXISTS landing_schema.airtable_emails;

CREATE TABLE IF NOT EXISTS landing_schema.airtable_emails
(
	email VARCHAR(256)
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.airtable_emails OWNER TO "IAM:ffdp-airflow";

-- landing_schema.irix_user

DROP TABLE IF EXISTS landing_schema.irix_user;

CREATE TABLE IF NOT EXISTS landing_schema.irix_user
(
	ir_user_id VARCHAR(512),
	ir_user_email VARCHAR(768),
	ir_user_first_name VARCHAR(512),
	ir_user_last_name VARCHAR(512),
	ir_user_newsletter_optin BOOLEAN ,
	ir_user_locale VARCHAR(512)  ,
	ir_user_country_name VARCHAR(500)  ,
	ir_user_email_confirmed BOOLEAN  ,
	ir_user_created_at TIMESTAMP WITH TIME ZONE   ,
	ir_user_updated_at TIMESTAMP WITH TIME ZONE,
	ir_user_beta_account BOOLEAN,
	ir_user_exclude BOOLEAN ,
	ir_farm_hectare INTEGER ,
	ir_hectare_range VARCHAR(5),
	origin VARCHAR(10) ,
	ir_payment_at TIMESTAMP WITH TIME ZONE ,
	ir_payment_count INTEGER   ,
	is_app BOOLEAN   ,
	load_time TIMESTAMP WITH TIME ZONE 
)
DISTSTYLE AUTO ;

ALTER TABLE landing_schema.irix_user OWNER TO "IAM:ffdp-airflow";