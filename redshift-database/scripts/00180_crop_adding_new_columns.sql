-- liquibase formatted sql

--changeset sandeep_c:ATI-6327-Adding-columns-to-crop-table splitStatements:true runOnChange:true
--comment: ATI-6327 - We drop some columns and re adding after adding necessary columns in crops table

-----------------------------------------
-- This script is to alter the crop table only
-- we are not droping entire crop table and recreating a new table as it has references to other table and creates an restriction for end users to access this data
-- So, We drop some columns and re adding after adding necessary columns As We are performing truncate and load data everytime for crop table
-- This approach is not applicable for User, Field, Farm, Season, Map table as we are not performing truncate and load in these tables as they have multiple data sources
-- Dont use this approach for tables with multiple data source
----------------------------------------

Alter table ffdp2_0.crop drop column yield_base_unitid;
Alter table ffdp2_0.crop drop column demand_base_unitid;
Alter table ffdp2_0.crop drop column defaultHarvestDate;
Alter table ffdp2_0.crop drop column defaultYield;
Alter table ffdp2_0.crop drop column defaultSeedingDate;
Alter table ffdp2_0.crop drop column residues_removed_n;
Alter table ffdp2_0.crop drop column residues_left_n;
Alter table ffdp2_0.crop drop column residues_incorporated_spring_n;
Alter table ffdp2_0.crop drop column residueNUptake;
Alter table ffdp2_0.crop drop column residueFactor;
Alter table ffdp2_0.crop drop column nutrientUseEfficiency;
Alter table ffdp2_0.crop drop column applicationTags;
Alter table ffdp2_0.crop drop column calculationParameters;
Alter table ffdp2_0.crop drop column additionalProperties;
Alter table ffdp2_0.crop drop column agroCoreCode;
Alter table ffdp2_0.crop drop column createdat;
Alter table ffdp2_0.crop drop column createdby;
Alter table ffdp2_0.crop drop column updatedat;
Alter table ffdp2_0.crop drop column updatedby;
Alter table ffdp2_0.crop drop column deletedat;
Alter table ffdp2_0.crop drop column deletedby;
Alter table ffdp2_0.crop drop column version;
Alter table ffdp2_0.crop drop column source;
Alter table ffdp2_0.crop add column crop_description SUPER;
Alter table ffdp2_0.crop add column crop_subclass_id VARCHAR(60);
Alter table ffdp2_0.crop add column crop_subclass SUPER;
Alter table ffdp2_0.crop add column crop_class_id VARCHAR(60);
Alter table ffdp2_0.crop add column crop_class SUPER;
Alter table ffdp2_0.crop add column crop_group_id VARCHAR(60);
Alter table ffdp2_0.crop add column crop_group SUPER;
Alter table ffdp2_0.crop add column yield_base_unitid VARCHAR(60);
Alter table ffdp2_0.crop add column demand_base_unitid VARCHAR(60);
Alter table ffdp2_0.crop add column defaultHarvestDate TIMESTAMP WITHOUT TIME zone;
Alter table ffdp2_0.crop add column defaultYield DOUBLE precision;
Alter table ffdp2_0.crop add column defaultSeedingDate TIMESTAMP WITHOUT TIME zone;
Alter table ffdp2_0.crop add column residues_removed_n DOUBLE precision;
Alter table ffdp2_0.crop add column residues_left_n DOUBLE precision;
Alter table ffdp2_0.crop add column residues_incorporated_spring_n DOUBLE precision;
Alter table ffdp2_0.crop add column residueNUptake DOUBLE precision;
Alter table ffdp2_0.crop add column residueFactor DOUBLE precision;
Alter table ffdp2_0.crop add column nutrientUseEfficiency DOUBLE precision;
Alter table ffdp2_0.crop add column applicationTags VARCHAR(1000);
Alter table ffdp2_0.crop add column calculationParameters SUPER;
Alter table ffdp2_0.crop add column additionalProperties SUPER;
Alter table ffdp2_0.crop add column agroCoreCode INTEGER;
Alter table ffdp2_0.crop add column createdat TIMESTAMP WITHOUT TIME zone;
Alter table ffdp2_0.crop add column createdby VARCHAR(600);
Alter table ffdp2_0.crop add column updatedat TIMESTAMP WITHOUT TIME zone;
Alter table ffdp2_0.crop add column updatedby VARCHAR(600);
Alter table ffdp2_0.crop add column deletedat TIMESTAMP WITHOUT TIME zone;
Alter table ffdp2_0.crop add column deletedby VARCHAR(600);
Alter table ffdp2_0.crop add column version INTEGER;
Alter table ffdp2_0.crop add column source VARCHAR(60);

-- rollback Alter table ffdp2_0.crop drop column crop_description;
-- rollback Alter table ffdp2_0.crop drop column crop_subclass_id;
-- rollback Alter table ffdp2_0.crop drop column crop_subclass;
-- rollback Alter table ffdp2_0.crop drop column crop_class_id;
-- rollback Alter table ffdp2_0.crop drop column crop_class;
-- rollback Alter table ffdp2_0.crop drop column crop_group_id;
-- rollback Alter table ffdp2_0.crop drop column crop_group;