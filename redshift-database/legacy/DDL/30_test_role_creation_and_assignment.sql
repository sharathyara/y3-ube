CREATE ROLE
    test_delete_later;

GRANT USAGE ON SCHEMA 
    ffdp2_0
TO ROLE
    test_delete_later;

GRANT SELECT
    (id, countryid, regionid)
ON
    ffdp2_0.farm
TO ROLE
    test_delete_later;

GRANT ROLE test_delete_later TO USER kamran_test_3;