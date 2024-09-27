ALTER TABLE ffdp2_0.field
ADD COLUMN has_boundary_data BOOLEAN;

ALTER TABLE ffdp2_0.field OWNER TO "IAM:ffdp-airflow";