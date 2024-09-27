-- Create the Farm table
DROP table if exists yarahive.farms;

CREATE TABLE IF NOT EXISTS yarahive.farms (
    Id VARCHAR(50) NOT NULL, -- Unique identifier for the farm
    name VARCHAR(1000), -- Name of the farm
    address VARCHAR(2000), -- Address of the farm
    farmSize DOUBLE PRECISION, -- Size of the farm
    farmSizeUnit VARCHAR(100) -- Unit of measurement for the farm size
);

-- Add comments to the columns
COMMENT ON TABLE yarahive.farms IS 'Table to store yarhive farm';
COMMENT ON COLUMN yarahive.farms.Id IS 'Unique identifier for the farm';
COMMENT ON COLUMN yarahive.farms.name IS 'Name of the farm';
COMMENT ON COLUMN yarahive.farms.address IS 'Address of the farm';
COMMENT ON COLUMN yarahive.farms.farmSize IS 'Size of the farm';
COMMENT ON COLUMN yarahive.farms.farmSizeUnit IS 'Unit of measurement for the farm size';

-- Granting permissions to the specific user
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.farms TO gluejob;
