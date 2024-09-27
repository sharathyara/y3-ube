-- liquibase formatted sql

--changeset Sharath_S:ATI-6638-fixing-old-legacy-revoke-script splitStatements:false runOnChange:true
--comment: ATI-6638 creating revoke user procedure


CREATE OR REPLACE PROCEDURE github_actions.revoke_access_schema(
    in_user_name character varying(256),
    in_schema_name character varying(256),
    in_all_views boolean,
    in_all_tables boolean
)
LANGUAGE plpgsql
AS $$
DECLARE
    view_record         record;
    queried_table_name  VARCHAR(250) := '';
    queried_schema_name VARCHAR(250) := '';
    sql                 VARCHAR(MAX) := '';
BEGIN
    -- grant for all views in schema
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

    -- grant for all tables in schema
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

    -- revoke USAGE on SCHEMA
    RAISE INFO 'Revoking to schemas';
    sql := 'REVOKE USAGE ON SCHEMA '|| quote_ident(in_schema_name) || ' FROM ' || quote_ident(in_user_name) || '';
    RAISE INFO '%', sql;
    EXECUTE sql;

END
$$;

-- rollback DROP PROCEDURE github_actions.revoke_access_schema(in_user_name character varying(256), in_schema_name character varying(256), in_all_views boolean, in_all_tables boolean);



