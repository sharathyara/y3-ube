/*
Create ffdp_airflow user group and grant it priviledges. 
*/

CALL create_user_if_not_exists('IAM:ffdp-airflow');

GRANT 
    ALL PRIVILEGES 
ON 
    ALL TABLES
IN SCHEMA 
    github_actions 
TO 
   "IAM:ffdp-airflow";

GRANT 
    USAGE
ON SCHEMA
    github_actions 
TO 
    "IAM:ffdp-airflow";
