alter table curated_schema.farm rename to farm_backup;
create table curated_schema.farm BACKUP NO as select * from curated_schema.farm_backup;

alter table curated_schema.field rename to field_backup;
create table curated_schema.field BACKUP NO as select * from curated_schema.field_backup;

alter table curated_schema.season rename to season_backup;
create table curated_schema.season BACKUP NO as select * from curated_schema.season_backup;

alter table curated_schema.user rename to user_backup;
create table curated_schema.user BACKUP NO as select * from curated_schema.user_backup;


alter table curated_schema.di_farm rename to di_farm_backup;
create table curated_schema.di_farm BACKUP NO as select * from curated_schema.di_farm_backup;

alter table curated_schema.di_field rename to di_field_backup;
create table curated_schema.di_field BACKUP NO as select * from curated_schema.di_field_backup;

alter table curated_schema.di_season rename to di_season_backup;
create table curated_schema.di_season BACKUP NO as select * from curated_schema.di_season_backup;

alter table curated_schema.di_user rename to di_user_backup;
create table curated_schema.di_user BACKUP NO as select * from curated_schema.di_user_backup;

alter table curated_schema.di_map rename to di_map_backup;
create table curated_schema.di_map BACKUP NO as select * from curated_schema.di_map_backup;


GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.user TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.farm TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.field TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.season TO gluejob;

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_farm TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_field TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_season TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_user TO gluejob;
GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_map TO gluejob;

DROP TABLE IF EXISTS curated_schema.farm_backup;
DROP TABLE IF EXISTS curated_schema.field_backup;
DROP TABLE IF EXISTS curated_schema.season_backup;
DROP TABLE IF EXISTS curated_schema.user_backup;
DROP TABLE IF EXISTS curated_schema.di_farm_backup;
DROP TABLE IF EXISTS curated_schema.di_field_backup;
DROP TABLE IF EXISTS curated_schema.di_season_backup;
DROP TABLE IF EXISTS curated_schema.di_user_backup;
DROP TABLE IF EXISTS curated_schema.di_map_backup;