-- liquibase formatted sql
 
--changeset SaveethaAnnamalai:ATI-6230-Varda-Lookup-GFID-Netherlands-DDL splitStatements:true runOnChange:true
--comment: ATI-6230 - Creating table for Varda-Lookup-GFID-Netherland

DROP TABLE IF EXISTS varda_gfid.lookup_gfid_netherland ;

CREATE TABLE varda_gfid.lookup_gfid_netherland (
    featureId VARCHAR(500),
    index int,
    field_id VARCHAR(500),
    boundary_id VARCHAR(500),
    iou_score VARCHAR(500),
    input_based_intersection VARCHAR(500),
    output_based_intersection VARCHAR(500)
);

GRANT SELECT ON TABLE varda_gfid.lookup_gfid_netherland TO "IAM:ffdp-airflow";

-- rollback DROP TABLE IF EXISTS varda_gfid.lookup_gfid_netherland