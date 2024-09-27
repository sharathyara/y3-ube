create schema if not exists varda_gfid;

CREATE TABLE if not exists varda_gfid.lookup_gfid (
    featureId VARCHAR(500),
    index int,
    boundary_id VARCHAR(500),
    field_id VARCHAR(500),
    iou_score VARCHAR(500),
    input_based_intersection VARCHAR(500),
    output_based_intersection VARCHAR(500)
);

CREATE OR REPLACE PROCEDURE github_actions.sp_varda_gfid_lookup(schema_name character varying(256), table_name character varying(256), s3_file_object character varying(1024) , iam_role character varying(512))
 LANGUAGE plpgsql
AS $$
DECLARE
    sql_stmt VARCHAR(65535);
    gfid_lookup_table VARCHAR(500);
BEGIN
    gfid_lookup_table := schema_name + '.' + table_name;

    sql_stmt := 'COPY '|| gfid_lookup_table ||'
                            FROM '''|| s3_file_object ||'''
                            IAM_ROLE ''' || iam_role || '''
                            delimiter ''|''
                            CSV
                            IGNOREHEADER 1;';
    RAISE INFO 'Executing query: %', sql_stmt;
    EXECUTE sql_stmt;
    
END;
$$