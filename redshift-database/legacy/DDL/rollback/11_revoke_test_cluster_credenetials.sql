/*
Create ffdp_airflow user group and grant it priviledges. 
*/
REVOKE 
    ALL PRIVILEGES 
ON 
    ALL TABLES
IN SCHEMA 
    github_actions 
FROM 
   "IAM:ffdp-airflow";

REVOKE 
    USAGE
ON SCHEMA
    github_actions 
FROM 
    "IAM:ffdp-airflow";

DROP USER "IAM:ffdp-airflow";