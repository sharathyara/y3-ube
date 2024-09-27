-- liquibase formatted sql

--changeset PeterBradac:ATI-DP-PI3-SP3-6048 splitStatements:true
--comment: ATI-6048 - Smoke test user with grants for smoke testing part
CREATE USER smoke_test_user WITH PASSWORD DISABLE NOCREATEDB NOCREATEUSER;
GRANT USAGE ON SCHEMA curated_schema TO smoke_test_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA curated_schema TO smoke_test_user;

--rollback REVOKE SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA curated_schema FROM smoke_test_user;
--rollback REVOKE USAGE ON SCHEMA curated_schema FROM smoke_test_user;
--rollback DROP USER smoke_test_user;