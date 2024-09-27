-- liquibase formatted sql
 
--changeset SaveethaAnnamalai:ATI-6230-Stored-procedure-for-varda-gfid-copy-to-redshift splitStatements:false runOnChange:true
--comment: ATI-6230 - Stored procedure to copy varda GFID csv file to redshift

CREATE OR REPLACE PROCEDURE github_actions.sp_varda_gfid_lookup(
    schema_name character varying(256),
    table_name character varying(256),
    s3_file_object character varying(1024),
    iam_role character varying(512)
)
LANGUAGE plpgsql
AS $$
DECLARE
    rowcount BIGINT;
    sql_stmt VARCHAR(65535);
    gfid_lookup_table VARCHAR(500);
BEGIN
    gfid_lookup_table := schema_name || '.' || table_name;

    -- 1. Truncate the table
    sql_stmt := 'TRUNCATE TABLE ' || gfid_lookup_table;
    RAISE INFO 'Executing query: %', sql_stmt;
    EXECUTE sql_stmt;

    -- 2. Copy the data from S3 to the table
    sql_stmt := 'COPY ' || gfid_lookup_table || '
        FROM ''' || s3_file_object || '''
        IAM_ROLE ''' || iam_role || '''
        delimiter ''|''
        CSV
        IGNOREHEADER 1;';
    RAISE INFO 'Executing query: %', sql_stmt;
    EXECUTE sql_stmt;

     -- 3. Verify the copy is done successfully
    sql_stmt := 'SELECT COUNT(*) FROM ' || gfid_lookup_table;
    RAISE INFO 'Executing query: %', sql_stmt;
    EXECUTE sql_stmt INTO rowcount;
    RAISE INFO 'Rows loaded: %', rowcount;

    IF rowcount = 0 THEN
        RAISE EXCEPTION 'No rows were loaded into the table.';
    END IF;

END
$$;

-- rollback DROP PROCEDURE github_actions.sp_varda_gfid_lookup( schema_name character varying(256), table_name character varying(256), s3_file_object character varying(1024),iam_role character varying(512));
