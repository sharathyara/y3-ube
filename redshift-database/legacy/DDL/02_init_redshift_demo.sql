CREATE SCHEMA IF NOT EXISTS redshift_demo_view;
CREATE SCHEMA IF NOT EXISTS redshift_demo;

CREATE TABLE IF NOT EXISTS redshift_demo.user
(
  _hoodie_commit_time VARCHAR(255), 
  _hoodie_commit_seqno VARCHAR(255), 
  _hoodie_record_key VARCHAR(255), 
  _hoodie_partition_path VARCHAR(255), 
  _hoodie_file_name VARCHAR(255), 
  datetimeoccurred TIMESTAMP, 
  userid VARCHAR(255), 
  username VARCHAR(255), 
  createdby VARCHAR(255),  
  createddatetime VARCHAR(255), 
  modifiedby VARCHAR(255),  
  modifieddatetime VARCHAR(255),  
  eventtype VARCHAR(255),
  created_at VARCHAR(255)
);

CREATE OR REPLACE VIEW redshift_demo_view.user AS SELECT 
  datetimeoccurred, 
  userid,
  username,  
  createdby,  
  createddatetime,  
  modifiedby,    
  modifieddatetime,  
  eventtype,  
  created_at
FROM redshift_demo.user;

GRANT CREATE ON SCHEMA redshift_demo TO gluejob;
GRANT USAGE ON SCHEMA redshift_demo TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE redshift_demo.user TO gluejob;

CREATE TABLE IF NOT EXISTS redshift_demo.audit (audit_text varchar(1024));
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE redshift_demo.audit TO gluejob;
