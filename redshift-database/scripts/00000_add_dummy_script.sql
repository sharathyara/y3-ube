--liquibase formatted sql

--changeset KamranManzoor:ATI-5895-add-initial-dummy-script
--comment: ATI-5895 - DB automation using liquibase
select 'Hello World';

--rollback select 'Hello World';
