-- liquibase formatted sql

--changeset viktoras_c:ATI-6343-adding-external-segment-atfarm-mobile-app-events splitStatements:true runOnChange:true context:"ffdp-stage,ffdp-prod"
--comment: ATI-6343 - create external segment table: atfarm-mobile-app-events 
CREATE EXTERNAL SCHEMA IF NOT EXISTS segment
FROM DATA CATALOG DATABASE 'segment'
IAM_ROLE '${SEGMENT_SPECTRUM_ROLE_ARN}'
CREATE EXTERNAL DATABASE IF NOT EXISTS;


-- rollback DROP SCHEMA IF EXISTS segment;
