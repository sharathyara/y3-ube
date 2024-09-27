CREATE TABLE IF NOT EXISTS yarahive.NitrogenUseEfficiency (
    Id VARCHAR(36) NOT NULL,
    assessmentId VARCHAR(36),
    treatment VARCHAR(255),
    cropYield DOUBLE PRECISION,
    nConcentrationMainProduct DOUBLE PRECISION,
    harvestedOrRemovedByProduct DOUBLE PRECISION,
    nConcentrationByProduct BIGINT,
    nFertilizerSynthetic DOUBLE PRECISION,
    nFertilizerOrganic DOUBLE PRECISION,
    nBNFFactor DOUBLE PRECISION,
    nDepositionAir BIGINT
);

COMMENT ON TABLE yarahive.NitrogenUseEfficiency IS 'Table to store nitrogen use efficiency data';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.Id IS 'Unique identifier for the nitrogen use efficiency entry';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.assessmentId IS 'Identifier for the associated assessment';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.treatment IS 'Treatment description';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.cropYield IS 'Crop yield value';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.nConcentrationMainProduct IS 'Nitrogen concentration in main product';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.harvestedOrRemovedByProduct IS 'Amount of harvested or removed by-product';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.nConcentrationByProduct IS 'Nitrogen concentration in by-product';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.nFertilizerSynthetic IS 'Amount of synthetic nitrogen fertilizer';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.nFertilizerOrganic IS 'Amount of organic nitrogen fertilizer';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.nBNFFactor IS 'Biological nitrogen fixation factor';
COMMENT ON COLUMN yarahive.NitrogenUseEfficiency.nDepositionAir IS 'Nitrogen deposition from air';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.NitrogenUseEfficiency TO gluejob;