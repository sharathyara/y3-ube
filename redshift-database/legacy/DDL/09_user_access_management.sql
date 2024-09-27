-- Stored procedure for revoking access to tables and views. Inputs: 
-- in_user_name (string): username used for login
-- in_schema_name (string) : comma-separated list of schemas where revoke will be applied
-- in_all_views : revoke access to all views?
-- in_all_tables : revoke access to all tables?
CREATE OR REPLACE PROCEDURE github_actions.revoke_access_schema(
    IN in_user_name text,
    IN in_schema_name text,
    IN in_all_views boolean,
    IN in_all_tables boolean
)
LANGUAGE plpgsql
AS $$
    DECLARE 
        view_record         record;
        queried_table_name  VARCHAR(250) := '';
        queried_schema_name VARCHAR(250) := '';
        sql                 VARCHAR(MAX) := '';
    BEGIN
        -- revoke for all views in schemas
        IF in_all_views THEN
            RAISE INFO 'Revoking to views';
            -- Loop through views
            FOR view_record IN 
                SELECT table_schema, table_name FROM information_schema.tables WHERE ',' ||in_schema_name|| ',' LIKE '%,' ||table_schema||',%' AND table_type = 'VIEW'
            LOOP
                queried_table_name := view_record.table_name;
                queried_schema_name := view_record.table_schema;
                sql := 'REVOKE SELECT ON TABLE '|| quote_ident(queried_schema_name) || '.' || quote_ident(queried_table_name) || ' FROM ' || quote_ident(in_user_name) || '';
                RAISE INFO '%', sql;
                EXECUTE sql;
            END LOOP;
        END IF;

        -- revoke for all tables in schemas
        IF in_all_tables THEN
            RAISE INFO 'Revoking to tables';
            -- Loop through tables
            FOR view_record IN 
                SELECT table_schema, table_name FROM information_schema.tables WHERE ',' ||in_schema_name|| ',' LIKE '%,' ||table_schema||',%' AND table_type = 'BASE TABLE'
            LOOP
                queried_table_name := view_record.table_name;
                queried_schema_name := view_record.table_schema;
                sql := 'REVOKE SELECT ON TABLE '|| quote_ident(queried_schema_name) || '.' || quote_ident(queried_table_name) || ' FROM ' || quote_ident(in_user_name) || '';
                RAISE INFO '%', sql;
                EXECUTE sql;
            END LOOP;
        END IF;
    END;
$$;


-- UPDATE OF PROCEDURE TO GRANT PERMISSION TO VIEW ONLY in LISTED SCHEMA
CREATE OR REPLACE PROCEDURE github_actions.sp_create_user_with_grants(inusername character varying(20), inpassword character varying(20), inschemaname character varying(40), ingrantread boolean, ingrantwrite boolean)
 LANGUAGE plpgsql
AS $$
    DECLARE 
        view_record         record;
        queried_table_name  VARCHAR(250) := '';
        queried_schema_name VARCHAR(250) := '';
        t_user_count        BIGINT;
        sql                 VARCHAR(MAX) := '';
    BEGIN 
        SELECT count(1)
        INTO t_user_count
        FROM pg_user WHERE LOWER(usename) = inUsername;
        IF t_user_count>0 THEN
            RAISE INFO 'User already exists';
            --sql := 'ALTER USER ' || inUsername || ' PASSWORD ''' || inPassword ||''' VALID UNTIL ''2035-01-28'' ';
            --EXECUTE sql;
        ELSE
            RAISE INFO 'Creating new user';
            sql := 'CREATE USER ' || inUsername || ' WITH PASSWORD ''' || inPassword ||''' VALID UNTIL ''2035-01-28'' NOCREATEDB NOCREATEUSER';
            RAISE INFO '%', sql;
            EXECUTE sql;
        END IF;
		
	IF inGrantRead THEN
		-- Granting access to schema and views
        sql := 'GRANT USAGE ON SCHEMA ' || inSchemaName || ' TO ' || inUsername || '';
		EXECUTE sql;

		RAISE INFO 'Granting to views';
            -- Loop through views
            FOR view_record IN 
                SELECT table_schema, table_name FROM information_schema.tables WHERE ',' || inSchemaName || ',' LIKE '%,' ||table_schema||',%' AND table_type = 'VIEW'
            LOOP
                queried_table_name := view_record.table_name;
                queried_schema_name := view_record.table_schema;
                sql := 'GRANT SELECT ON TABLE '|| quote_ident(queried_schema_name) || '.' || quote_ident(queried_table_name) || ' TO ' || quote_ident(inusername) || '';
                RAISE INFO '%', sql;
                EXECUTE sql;
            END LOOP;
	END IF;

    IF inGrantWrite THEN
		-- Granting access to schema and tables
		sql := 'GRANT USAGE ON SCHEMA ' || inSchemaName || ' TO ' || inUsername || '';
		EXECUTE sql;
		
		sql := 'GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ' || inSchemaName ||' TO ' || inUsername || '';
		EXECUTE sql;
	END IF;
		
    EXCEPTION 
        WHEN OTHERS THEN 
            RAISE EXCEPTION '[Error while creating user: %] Exception: %', inUsername, SQLERRM;
    END;
    $$
	
	
-- PROCEDURE TO REVOKE ACCESS TO VIEWS in schema	
CREATE OR REPLACE PROCEDURE github_actions.sp_regrant_access(inschemaname character varying(250))
 LANGUAGE plpgsql
AS $$
    DECLARE 
        schema_record       record;
        queried_user_entity VARCHAR(250) := '';
        queried_table_name  VARCHAR(250) := '';
        queried_schema_name VARCHAR(250) := '';
        sql                 VARCHAR(MAX) := '';
    BEGIN 
        FOR schema_record IN
            SELECT svv_schema.identity_name, svv_table.table_name, svv_table.table_schema FROM SVV_SCHEMA_PRIVILEGES svv_schema 
                JOIN SVV_TABLES svv_table ON svv_schema.namespace_name = svv_table.table_schema
            WHERE ',' || inSchemaName || ',' LIKE '%,'||svv_table.table_schema||',%' AND svv_table.table_type = 'VIEW'
        LOOP
            queried_user_entity := schema_record.identity_name;
            queried_table_name := schema_record.table_name;
            queried_schema_name := schema_record.table_schema;
            RAISE INFO 'Granting to views';
            sql := 'GRANT SELECT ON TABLE '|| quote_ident(queried_schema_name) || '.' || quote_ident(queried_table_name) || ' TO ' || quote_ident(queried_user_entity) || '';
            RAISE INFO '%', sql;
            EXECUTE sql;
        END LOOP;     

        -- grant privileges 'back' to github_actions_user
        RAISE INFO 'Granting to github_actions_user';
        sql := 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ' || quote_ident(inSchemaName) || ' TO github_actions_user WITH GRANT OPTION';
	    RAISE INFO '%', sql;
        EXECUTE sql;

    EXCEPTION 
        WHEN OTHERS THEN 
            RAISE EXCEPTION '[Error while granting to schema: %] Exception: %', inschemaname, SQLERRM;
    END;
    $$	