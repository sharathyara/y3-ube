DROP TABLE IF EXISTS yarahive.translations;

CREATE TABLE IF NOT EXISTS yarahive.translations (
    Id VARCHAR(50) NOT NULL,
    namespace VARCHAR(10000),
    key VARCHAR(10000),
    locale VARCHAR(10000),
    value VARCHAR(20000)
);

COMMENT ON TABLE yarahive.translations IS 'Table to store yarahive translation data';
COMMENT ON COLUMN yarahive.translations.Id IS 'Unique identifier for the translation';
COMMENT ON COLUMN yarahive.translations.namespace IS 'Namespace of the translation';
COMMENT ON COLUMN yarahive.translations.key IS 'Key of the translation';
COMMENT ON COLUMN yarahive.translations.locale IS 'Locale of the translation';
COMMENT ON COLUMN yarahive.translations.value IS 'Value of the translation';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.translations TO gluejob;
