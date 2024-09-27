drop table if exists yarahive.Assessment;
CREATE TABLE IF NOT EXISTS yarahive.Assessments (
    Id VARCHAR(1000) NOT NULL,
    demositeId VARCHAR(1000),
    YieldSelection SUPER,
    ReturnOnInvestments SUPER,
    BreakEvenCalculations SUPER
);

COMMENT ON TABLE yarahive.Assessments IS 'Table to store Assessments information';
COMMENT ON COLUMN yarahive.Assessments.Id IS 'Unique identifier for the Assessments';
COMMENT ON COLUMN yarahive.Assessments.demositeId IS 'Identifier for the demo site';
COMMENT ON COLUMN yarahive.Assessments.YieldSelection IS 'Yield selection details';
COMMENT ON COLUMN yarahive.Assessments.ReturnOnInvestments IS 'Return on investments details';
COMMENT ON COLUMN yarahive.Assessments.BreakEvenCalculations IS 'Break-even calculations details';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.Assessments TO gluejob;