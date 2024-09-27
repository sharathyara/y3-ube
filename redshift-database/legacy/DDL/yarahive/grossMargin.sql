CREATE TABLE IF NOT EXISTS yarahive.GrossMargin (
    Id VARCHAR(36) NOT NULL,
    assessmentId VARCHAR(36),
    treatmentId VARCHAR(36),
    cropYield DOUBLE PRECISION,
    price DOUBLE PRECISION,
    fertilizerProductCost DOUBLE PRECISION,
    fertilizerApplicationCost DOUBLE PRECISION,
    otherCultivationProductCost BIGINT,
    otherCultivationApplicationCost BIGINT
);

COMMENT ON TABLE yarahive.GrossMargin IS 'Table to store gross margin information';
COMMENT ON COLUMN yarahive.GrossMargin.Id IS 'Unique identifier for the gross margin entry';
COMMENT ON COLUMN yarahive.GrossMargin.assessmentId IS 'Identifier for the associated assessment';
COMMENT ON COLUMN yarahive.GrossMargin.treatmentId IS 'Identifier for the associated treatment';
COMMENT ON COLUMN yarahive.GrossMargin.cropYield IS 'Crop yield value';
COMMENT ON COLUMN yarahive.GrossMargin.price IS 'Price value';
COMMENT ON COLUMN yarahive.GrossMargin.fertilizerProductCost IS 'Cost of fertilizer product';
COMMENT ON COLUMN yarahive.GrossMargin.fertilizerApplicationCost IS 'Cost of fertilizer application';
COMMENT ON COLUMN yarahive.GrossMargin.otherCultivationProductCost IS 'Cost of other cultivation products';
COMMENT ON COLUMN yarahive.GrossMargin.otherCultivationApplicationCost IS 'Cost of other cultivation applications';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.GrossMargin TO gluejob;