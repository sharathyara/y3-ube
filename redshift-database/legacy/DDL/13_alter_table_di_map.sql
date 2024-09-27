ALTER TABLE curated_schema.di_map ADD COLUMN filelocation VARCHAR(1000);
ALTER TABLE curated_schema.di_map ADD COLUMN filesize INTEGER;

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_map TO gluejob;