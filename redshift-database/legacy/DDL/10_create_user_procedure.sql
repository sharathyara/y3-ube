/*
Create user procedure.
*/
CREATE PROCEDURE create_user_if_not_exists(name varchar)
LANGUAGE plpgsql
AS $$
DECLARE
  existing varchar;
BEGIN
  SELECT usename INTO existing FROM pg_user WHERE usename = name;
  IF existing IS NULL
  THEN
    EXECUTE 'CREATE USER ' || quote_ident(name) || '
      WITH PASSWORD DISABLE;
      ';
  END IF;
END;
$$;