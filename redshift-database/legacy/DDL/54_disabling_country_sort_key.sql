-- disabling sort key as dbt is not able to process data

ALTER TABLE snapshot_schema.snap_country ALTER SORTKEY NONE;