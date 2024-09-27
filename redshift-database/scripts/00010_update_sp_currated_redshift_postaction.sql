--liquibase formatted sql

--changeset ViktorasCiumanovas:ATI-DP-PI3-SP4-5892 splitStatements:false rollbackSplitStatements:false
--comment: ATI-5892 - updating stored procedure to check the rowcounts of delta ingested instead of totals
-- Stored procedure 
CREATE OR REPLACE PROCEDURE curated_schema.currated_redshift_postaction(INOUT schemaname character varying(256), INOUT tablename character varying(256), INOUT stagetablename character varying(256), INOUT sourcerowcount bigint, INOUT glue_job_id character varying(256), INOUT unique_key character varying(256))
AS $$
DECLARE
    table_row_count bigint;
    table_name varchar := schemaname || '.' || tablename;
    stage_table_name varchar := schemaname || '.' || stagetablename;
   	temp_audit_table_name varchar := 'temp_audit_' || glue_job_id;
BEGIN
    EXECUTE 'SELECT COUNT(*) FROM ' || stage_table_name INTO table_row_count;
    RAISE INFO '1. table_row_count in stage table: %', table_row_count;

    IF table_row_count != sourcerowcount THEN 
        RAISE EXCEPTION 'VALIDATION CHECK: Row count does not match: table (%), source(%)', table_row_count, sourcerowcount;
    END IF;

    EXECUTE 'DELETE FROM ' || stage_table_name || ' USING ' || table_name || ' WHERE ' || table_name || '.' || quote_ident(unique_key) || ' = ' || stage_table_name || '.' || quote_ident(unique_key) || ' AND ' || table_name || '.dateTimeOccurred >= ' || stage_table_name || '.dateTimeOccurred';
    EXECUTE 'DELETE FROM ' || table_name || ' USING ' || stage_table_name || ' WHERE ' || table_name || '.' || quote_ident(unique_key) || ' = ' || stage_table_name || '.' || quote_ident(unique_key) || ' AND ' || table_name || '.dateTimeOccurred < ' || stage_table_name || '.dateTimeOccurred';
    EXECUTE 'INSERT INTO ' || table_name || ' SELECT * FROM ' || stage_table_name;
	
    RAISE INFO '2. Completed data merge into target table';
	
    EXECUTE 'SELECT COUNT(*) FROM ' || table_name INTO table_row_count;
    RAISE INFO '3. table_row_count in target table: %', table_row_count;

    EXECUTE '
        CREATE TEMPORARY TABLE ' || temp_audit_table_name || ' AS
        SELECT
            ' || quote_literal(tablename) || ' AS audittablename,
            ' || sourcerowcount || ' AS hudi_row_count,
            current_timestamp AS execution_ts,
            ' || quote_literal(glue_job_id) || ' AS glue_job_id,
            COUNT(*) AS table_row_count
        FROM
            ' || table_name;

    EXECUTE 'INSERT INTO ' || schemaname || '.audit (
        table_name,
        hudi_row_count,
        execution_ts,
        glue_job_id,
        table_row_count
    )
    SELECT
        ta.audittablename,
        hudi_row_count,
        execution_ts,
        glue_job_id,
        table_row_count
    FROM
        ' || temp_audit_table_name || ' ta';
	
    EXECUTE 'DROP TABLE '|| temp_audit_table_name || ',' || stage_table_name;
END;
$$
LANGUAGE plpgsql;

GRANT ALL PRIVILEGES ON PROCEDURE curated_schema.currated_redshift_postaction(
    schemaname INOUT varchar,
    tablename INOUT varchar,
    stagetablename INOUT varchar,
    sourcerowcount INOUT int8,
    glue_job_id INOUT varchar,
    unique_key INOUT varchar
) TO gluejob;


--rollback CREATE OR REPLACE PROCEDURE curated_schema.currated_redshift_postaction(INOUT schemaname character varying(256), INOUT tablename character varying(256), INOUT stagetablename character varying(256), INOUT sourcerowcount bigint, INOUT glue_job_id character varying(256), INOUT unique_key character varying(256))
--rollback AS $$
--rollback DECLARE
--rollback     table_row_count bigint;
--rollback     table_name varchar := schemaname || '.' || tablename;
--rollback     stage_table_name varchar := schemaname || '.' || stagetablename;
--rollback    	temp_audit_table_name varchar := 'temp_audit_' || glue_job_id;
--rollback BEGIN
--rollback     EXECUTE 'DELETE FROM ' || stage_table_name || ' USING ' || table_name || ' WHERE ' || table_name || '.' || quote_ident(unique_key) || ' = ' || stage_table_name || '.' || quote_ident(unique_key) || ' AND ' || table_name || '.dateTimeOccurred >= ' || stage_table_name || '.dateTimeOccurred';
--rollback     EXECUTE 'DELETE FROM ' || table_name || ' USING ' || stage_table_name || ' WHERE ' || table_name || '.' || quote_ident(unique_key) || ' = ' || stage_table_name || '.' || quote_ident(unique_key) || ' AND ' || table_name || '.dateTimeOccurred < ' || stage_table_name || '.dateTimeOccurred';
--rollback     EXECUTE 'INSERT INTO ' || table_name || ' SELECT * FROM ' || stage_table_name;
--rollback 	EXECUTE 'SELECT COUNT(*) FROM ' || stage_table_name INTO table_row_count;
--rollback     RAISE INFO ' 1.Completed 3 trnx: ';
--rollback 	RAISE INFO '1.1.table_row_count in stage table: %', table_row_count;
--rollback     EXECUTE 'SELECT COUNT(*) FROM ' || table_name INTO table_row_count;
--rollback     RAISE INFO '2. assigned to variable:';
--rollback     RAISE INFO '3.table_row_count in table: %', table_row_count;
--rollback 
--rollback     IF table_row_count != sourcerowcount THEN 
--rollback         RAISE EXCEPTION 'VALIDATION CHECK: Row count does not match: table (%), source(%)', table_row_count, sourcerowcount;
--rollback     END IF;
--rollback 
--rollback     EXECUTE '
--rollback         CREATE TEMPORARY TABLE ' || temp_audit_table_name || ' AS
--rollback         SELECT
--rollback             ' || quote_literal(tablename) || ' AS audittablename,
--rollback             ' || sourcerowcount || ' AS hudi_row_count,
--rollback             current_timestamp AS execution_ts,
--rollback             ' || quote_literal(glue_job_id) || ' AS glue_job_id,
--rollback             COUNT(*) AS table_row_count
--rollback         FROM
--rollback             ' || table_name;
--rollback 
--rollback     EXECUTE 'INSERT INTO ' || schemaname || '.audit (
--rollback         table_name,
--rollback         hudi_row_count,
--rollback         execution_ts,
--rollback         glue_job_id,
--rollback         table_row_count
--rollback     )
--rollback     SELECT
--rollback         ta.audittablename,
--rollback         hudi_row_count,
--rollback         execution_ts,
--rollback         glue_job_id,
--rollback         table_row_count
--rollback     FROM
--rollback         ' || temp_audit_table_name || ' ta';
--rollback 	
--rollback     
--rollback     EXECUTE 'SELECT COUNT(*) FROM ' || stage_table_name INTO table_row_count;
--rollback   	RAISE INFO '1.1.table_row_count in stage table: %', table_row_count;
--rollback     EXECUTE 'DROP TABLE '|| temp_audit_table_name || ',' || stage_table_name;
--rollback END;
--rollback $$
--rollback LANGUAGE plpgsql;

--rollback GRANT ALL PRIVILEGES ON PROCEDURE curated_schema.currated_redshift_postaction(
--rollback     schemaname INOUT varchar,
--rollback     tablename INOUT varchar,
--rollback     stagetablename INOUT varchar,
--rollback     sourcerowcount INOUT int8,
--rollback     glue_job_id INOUT varchar,
--rollback     unique_key INOUT varchar
--rollback ) TO gluejob;