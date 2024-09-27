/*
-- Function to map environment from one21 to ffdp
This function, 'github_actions.env_mapping_for_accounts', is used to map environment names from 'one21' to 'ffdp'.
It takes an input environment name and returns the corresponding mapped environment name or 'integration' if the environment is unknown.

Parameters:
    environment (VARCHAR): The input environment name.

Returns:
    VARCHAR: The mapped environment name or 'integration' if the environment is unknown.

Usage:
    The function can be used to map environment names from 'one21' to 'ffdp'.
    For example, calling 'github_actions.env_mapping_for_accounts('dev')' will return 'integration'.
*/
CREATE OR REPLACE FUNCTION github_actions.env_mapping_for_accounts(environment VARCHAR)
RETURNS VARCHAR
IMMUTABLE
LANGUAGE plpythonu
AS $$
# Define the mapping of environments from one21 to ffdp
env_mapping = {
    'dev': 'integration',
    'ffdp-stage': 'integration',
    'stage': 'integration',
    'preprod': 'integration',
    'ffdp-preprod': 'integration',
    'prod': 'production',
    'ffdp-prod': 'production'
}

# Get the mapped environment from the mapping dictionary, with a default value of 'integration' for unknown environments
return env_mapping.get(environment, 'integration')
$$;

/*
-- Stored Procedure to create external schemas
This stored procedure, 'github_actions.sp_create_external_schemas', is designed to create external schemas for different segments based on the specified environment
    and IAM roles. It offers a flexible and reusable solution for schema management.

Parameters:
    schema_name (VARCHAR): The name of the schema to be created.
    catalog_db_name (VARCHAR): The base name of the catalog database where the segment data resides.
    environment (VARCHAR): The input environment name. If not provided, it defaults to 'dev'.
    iam_role_string (VARCHAR): The IAM roles required for the schema.

Usage:
    CALL github_actions.sp_create_external_schemas(
        schema_name := 'segment_one21_backend_service',
        catalog_db_name := 'one21_backend_service_segment_all_events_',
        environment := '%ENVIRONMENT%',
        iam_role_string := '%IAM_ROLE_1%,%IAM_ROLE_2%'
    );
    --IF catalog DB name does n't have any prefix of suffix, then can call the same SP, with environment as NULL or ''
    CALL github_actions.sp_create_external_schemas('segment_atfarm_web', 'atfarm_web_segment_all_events_', '', '%IAM_ROLE_1%,%IAM_ROLE_2%');
    CALL github_actions.sp_create_external_schemas('segment_atfarm_web', 'atfarm_web_segment_all_events_', NULL, '%IAM_ROLE_1%,%IAM_ROLE_2%');
*/

CREATE OR REPLACE PROCEDURE github_actions.sp_create_external_schemas(
    IN schema_name VARCHAR,
    IN catalog_db_name VARCHAR,
    INOUT environment VARCHAR, -- Set default value to 'dev' if not passed
    IN iam_role_string VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    db_name VARCHAR(1000);
    schema_exists INTEGER;
    sql_stmt VARCHAR(65535);
BEGIN
    -- If environment is not provided or is an empty string, use the default value 'dev'
    IF environment IS NULL OR environment = '' THEN
        environment := '';
    END IF;

    -- If environment is not the default value, call the UDF to get the mapped environment
    IF environment <> '' THEN
        db_name := catalog_db_name || github_actions.env_mapping_for_accounts(environment);
    ELSE
        -- If environment is the default value, use it directly without calling the UDF
        db_name := catalog_db_name;
    END IF;

    RAISE INFO 'before value of schema_exists: %', schema_exists;
    RAISE INFO 'SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = %', schema_name;

    -- Check if the schema already exists
    EXECUTE 'SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = ''' || quote_ident(schema_name) || '''' INTO schema_exists;

    -- Log the initial value of schema_exists
    RAISE INFO 'After value of schema_exists: %', schema_exists;

    -- Log the execute query statement
    sql_stmt := 'CREATE EXTERNAL SCHEMA ' || schema_name || ' FROM DATA CATALOG DATABASE ''' || db_name || ''' IAM_ROLE ''' || iam_role_string || ''';';
    RAISE INFO 'Executing query: %', sql_stmt;

    -- If schema does not exist, create the external schema
    IF schema_exists = 0 THEN
        EXECUTE sql_stmt;
        RAISE INFO 'External schema % created successfully.', schema_name;
    ELSE
        RAISE INFO 'External schema % already exists.', schema_name;
    END IF;
    RAISE INFO 'Final value of schema_exists: %', schema_exists;
END;
$$;


CALL github_actions.sp_create_external_schemas('appsflyer_atfarm', 'appsflyer_atfarm_', '%ENVIRONMENT%', '%IAM_ROLE_1%,%IAM_ROLE_2%');
CALL github_actions.sp_create_external_schemas('segment_one21_backend_service', 'one21_backend_service_segment_all_events_', '%ENVIRONMENT%', '%IAM_ROLE_1%,%IAM_ROLE_2%');
CALL github_actions.sp_create_external_schemas('segment_atfarm_mobile_app', 'atfarm_mobile_app_segment_all_events_', '%ENVIRONMENT%', '%IAM_ROLE_1%,%IAM_ROLE_2%');
CALL github_actions.sp_create_external_schemas('segment_one21_web', 'one21_web_segment_all_events_', '%ENVIRONMENT%', '%IAM_ROLE_1%,%IAM_ROLE_2%');
CALL github_actions.sp_create_external_schemas('segment_atfarm_web', 'atfarm_web_segment_all_events_', '%ENVIRONMENT%', '%IAM_ROLE_1%,%IAM_ROLE_2%');