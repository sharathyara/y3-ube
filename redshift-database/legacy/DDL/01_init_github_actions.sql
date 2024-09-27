create schema if not exists github_actions;
create table if not exists github_actions.maintenance (actor varchar(120), branchName varchar(120), filename varchar(120), date varchar(40), passed boolean);
CREATE OR REPLACE PROCEDURE github_actions.sp_create_user_with_grants(inUsername varchar(20), inPassword varchar(20), inSchemaName varchar(40), inGrantRead boolean, inGrantWrite boolean) 
    AS $$
    DECLARE 
        t_user_count       BIGINT;
        sql                VARCHAR(MAX) := '';
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
		-- Granting access to schema and tables
		sql := 'GRANT USAGE ON SCHEMA ' || inSchemaName || ' TO ' || inUsername || '';
		EXECUTE sql;
		
		sql := 'GRANT SELECT ON ALL TABLES IN SCHEMA ' || inSchemaName ||' TO ' || inUsername || '';
		EXECUTE sql;
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
    LANGUAGE plpgsql;
CREATE OR REPLACE PROCEDURE github_actions.update_maintenance_table(branchName varchar(120), filename varchar(120), dateExecuted varchar(40), actor varchar(120)) 
    AS $$
    DECLARE 
        sql VARCHAR(MAX) := '';
    BEGIN 
        INSERT INTO github_actions.maintenance VALUES (actor, branchName, filename, dateExecuted, true);
    EXCEPTION 
        WHEN OTHERS THEN 
            RAISE EXCEPTION '[Error while updating table github_actions.maintenance : %]', SQLERRM;
    END;
    $$
    LANGUAGE plpgsql;
