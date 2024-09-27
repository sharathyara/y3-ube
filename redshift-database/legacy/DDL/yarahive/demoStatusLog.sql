CREATE TABLE IF NOT EXISTS yarahive.DemoStatusLog (
    id VARCHAR(36) NOT NULL,
    demoId VARCHAR(36) NOT NULL,
    type VARCHAR(255) NOT NULL,
    payload SUPER,
    createdBy VARCHAR(255),
    createdAt TIMESTAMP,
    updatedAt TIMESTAMP,
    updatedBy VARCHAR(255),
    notifiedViaEmailAt TIMESTAMP
);

COMMENT ON TABLE yarahive.DemoStatusLog IS 'Table to store demo status log information';
COMMENT ON COLUMN yarahive.DemoStatusLog.id IS 'Unique identifier for the status log entry';
COMMENT ON COLUMN yarahive.DemoStatusLog.demoId IS 'Identifier for the associated demo';
COMMENT ON COLUMN yarahive.DemoStatusLog.type IS 'Type of the status log entry';
COMMENT ON COLUMN yarahive.DemoStatusLog.payload IS 'Additional payload information';
COMMENT ON COLUMN yarahive.DemoStatusLog.createdBy IS 'User who created the log entry';
COMMENT ON COLUMN yarahive.DemoStatusLog.createdAt IS 'Timestamp of creation';
COMMENT ON COLUMN yarahive.DemoStatusLog.updatedAt IS 'Timestamp of last update';
COMMENT ON COLUMN yarahive.DemoStatusLog.updatedBy IS 'User who last updated the log entry';
COMMENT ON COLUMN yarahive.DemoStatusLog.notifiedViaEmailAt IS 'Timestamp of email notification';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.DemoStatusLog TO gluejob;