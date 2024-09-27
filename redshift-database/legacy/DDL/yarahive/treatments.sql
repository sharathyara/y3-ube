DROP TABLE IF EXISTS yarahive.Treatment;

CREATE TABLE IF NOT EXISTS yarahive.Treatments (
    Id VARCHAR(36) NOT NULL,
    demoSiteId VARCHAR(36),
    name VARCHAR(1000),
    description VARCHAR(2000),
    type VARCHAR(1000),
    treatmentComment VARCHAR(3000),
    expectedCropPrice DOUBLE PRECISION,
    expectedYield DOUBLE PRECISION,
    economicFeasibilityComment VARCHAR(4000),
    totalRevenue DOUBLE PRECISION
);

COMMENT ON TABLE yarahive.Treatments IS 'Table to store Treatments/program information';
COMMENT ON COLUMN yarahive.Treatments.Id IS 'Unique identifier for the Treatments/program';
COMMENT ON COLUMN yarahive.Treatments.demoSiteId IS 'Identifier for the demo site';
COMMENT ON COLUMN yarahive.Treatments.name IS 'Name of the Treatments/program';
COMMENT ON COLUMN yarahive.Treatments.description IS 'Description of the Treatments/program';
COMMENT ON COLUMN yarahive.Treatments.type IS 'Type of the Treatments/program';
COMMENT ON COLUMN yarahive.Treatments.treatmentComment IS 'Comments on the treatment/program';
COMMENT ON COLUMN yarahive.Treatments.expectedCropPrice IS 'Expected crop price';
COMMENT ON COLUMN yarahive.Treatments.expectedYield IS 'Expected yield';
COMMENT ON COLUMN yarahive.Treatments.economicFeasibilityComment IS 'Economic feasibility comments';
COMMENT ON COLUMN yarahive.Treatments.totalRevenue IS 'Total revenue of the Treatments/program';


GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.Treatments TO gluejob;
