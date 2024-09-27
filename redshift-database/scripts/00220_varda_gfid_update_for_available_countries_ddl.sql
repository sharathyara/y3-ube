-- liquibase formatted sql
 
--changeset SaveethaAnnamalai:ATI-6230-Varda-Lookup-GFID-France-DDL splitStatements:true runOnChange:true
--comment: ATI-6230 - Creating table for Varda-Lookup-GFID-France

DROP TABLE IF EXISTS varda_gfid.lookup_gfid_france ;

CREATE TABLE varda_gfid.lookup_gfid_france (
    featureId VARCHAR(500),
    index int,
    field_id VARCHAR(500),
    boundary_id VARCHAR(500),
    iou_score VARCHAR(500),
    input_based_intersection VARCHAR(500),
    output_based_intersection VARCHAR(500)
);

GRANT SELECT ON TABLE varda_gfid.lookup_gfid_france TO "IAM:ffdp-airflow";

-- rollback DROP TABLE IF EXISTS varda_gfid.lookup_gfid_france



--changeset SaveethaAnnamalai:ATI-6230-Varda-Lookup-GFID-UK-DDL splitStatements:true runOnChange:true
--comment: ATI-6230 - Creating table for Varda-Lookup-GFID-UK

DROP TABLE IF EXISTS varda_gfid.lookup_gfid_uk;

CREATE TABLE varda_gfid.lookup_gfid_uk (
    featureId VARCHAR(500),
    index int,
    field_id VARCHAR(500),
    boundary_id VARCHAR(500),
    iou_score VARCHAR(500),
    input_based_intersection VARCHAR(500),
    output_based_intersection VARCHAR(500)
);

GRANT SELECT ON TABLE varda_gfid.lookup_gfid_uk TO "IAM:ffdp-airflow";

-- rollback DROP TABLE IF EXISTS varda_gfid.lookup_gfid_uk




--changeset SaveethaAnnamalai:ATI-6230-Varda-Lookup-GFID-Germany-DDL splitStatements:true runOnChange:true
--comment: ATI-6230 - Creating table for Varda-Lookup-GFID-Germany

DROP TABLE IF EXISTS varda_gfid.lookup_gfid_germany ;

CREATE TABLE varda_gfid.lookup_gfid_germany (
    featureId VARCHAR(500),
    index int,
    field_id VARCHAR(500),
    boundary_id VARCHAR(500),
    iou_score VARCHAR(500),
    input_based_intersection VARCHAR(500),
    output_based_intersection VARCHAR(500)
);

GRANT SELECT ON TABLE varda_gfid.lookup_gfid_germany TO "IAM:ffdp-airflow";

-- rollback DROP TABLE IF EXISTS varda_gfid.lookup_gfid_germany


--changeset SaveethaAnnamalai:ATI-6230-Varda-Lookup-GFID-Spain-DDL splitStatements:true runOnChange:true
--comment: ATI-6230 - Creating table for Varda-Lookup-GFID-Spain

DROP TABLE IF EXISTS varda_gfid.lookup_gfid_spain ;

CREATE TABLE varda_gfid.lookup_gfid_spain (
    featureId VARCHAR(500),
    index int,
    field_id VARCHAR(500),
    boundary_id VARCHAR(500),
    iou_score VARCHAR(500),
    input_based_intersection VARCHAR(500),
    output_based_intersection VARCHAR(500)
);

GRANT SELECT ON TABLE varda_gfid.lookup_gfid_spain TO "IAM:ffdp-airflow";

-- rollback DROP TABLE IF EXISTS varda_gfid.lookup_gfid_spain


--changeset SaveethaAnnamalai:ATI-6230-Varda-Lookup-GFID-Belgium-DDL splitStatements:true runOnChange:true
--comment: ATI-6230 - Creating table for Varda-Lookup-GFID-Belgium

DROP TABLE IF EXISTS varda_gfid.lookup_gfid_belgium ;

CREATE TABLE varda_gfid.lookup_gfid_belgium (
    featureId VARCHAR(500),
    index int,
    field_id VARCHAR(500),
    boundary_id VARCHAR(500),
    iou_score VARCHAR(500),
    input_based_intersection VARCHAR(500),
    output_based_intersection VARCHAR(500)
);

GRANT SELECT ON TABLE varda_gfid.lookup_gfid_belgium TO "IAM:ffdp-airflow";

-- rollback DROP TABLE IF EXISTS varda_gfid.lookup_gfid_belgium


--changeset SaveethaAnnamalai:ATI-6230-Varda-Lookup-GFID-Italy-DDL splitStatements:true runOnChange:true
--comment: ATI-6230 - Creating table for Varda-Lookup-GFID-Italy

DROP TABLE IF EXISTS varda_gfid.lookup_gfid_italy ;

CREATE TABLE varda_gfid.lookup_gfid_italy (
    featureId VARCHAR(500),
    index int,
    field_id VARCHAR(500),
    boundary_id VARCHAR(500),
    iou_score VARCHAR(500),
    input_based_intersection VARCHAR(500),
    output_based_intersection VARCHAR(500)
);

GRANT SELECT ON TABLE varda_gfid.lookup_gfid_italy TO "IAM:ffdp-airflow";

-- rollback DROP TABLE IF EXISTS varda_gfid.lookup_gfid_italy


--changeset SaveethaAnnamalai:ATI-6230-Varda-Lookup-GFID-Poland-DDL splitStatements:true runOnChange:true
--comment: ATI-6230 - Creating table for Varda-Lookup-GFID-Poland

DROP TABLE IF EXISTS varda_gfid.lookup_gfid_poland ;

CREATE TABLE varda_gfid.lookup_gfid_poland (
    featureId VARCHAR(500),
    index int,
    field_id VARCHAR(500),
    boundary_id VARCHAR(500),
    iou_score VARCHAR(500),
    input_based_intersection VARCHAR(500),
    output_based_intersection VARCHAR(500)
);

GRANT SELECT ON TABLE varda_gfid.lookup_gfid_poland TO "IAM:ffdp-airflow";

-- rollback DROP TABLE IF EXISTS varda_gfid.lookup_gfid_poland





