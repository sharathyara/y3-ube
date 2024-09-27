-- Please use the following templates to create Roles in Redshift and assign them to users.

-- NEVER assign privilidges directly to users, only to roles.

-- Try to avoid setting up RBAC tables with more than 3 levels of hirarchy, for simplicity's sake.

-- ALL roles created for users in Production can have SELECT priviledge on TABLES and USAGE priviledge on schemas ONLY.

CREATE ROLE
    ROLE_NAME;

GRANT USAGE ON SCHEMA 
    SCHEMA_NAME
TO
    ROLE_NAME;

GRANT SELECT
    (COLUMN_1_NAME, COLUMN_2_NAME)
ON
    TABLE_NAME
TO
    ROLE_NAME;

CREATE RLS POLICY
    POLICY_NAME
WITH
    (COLUNM_1_NAME, COLUMN_1_DATA_TYPE)
USING
    (SQL_EXPRESSION);

ATTACH RLS POLICY
    POLICY_NAME
ON
    TABLE_NAME
TO
    ROLE_NAME;

-- If multiple policies apply to the same role, conjunction type needs to be specified. It applies
-- "AND" or "OR" logical opeator to combine policies for a given role. The default is "AND".
ALTER TABLE 
    TABLE_NAME
ROW LEVEL SECURITY
    ON 
CONJUNCTION TYPE 
    AND;

