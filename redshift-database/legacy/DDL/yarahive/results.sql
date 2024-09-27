drop Table if exists yarahive.results;

CREATE TABLE IF NOT EXISTS yarahive.results (
    id VARCHAR(36) NOT NULL,
    demoId VARCHAR(36),
    resultType VARCHAR(256),
    fileName VARCHAR(1024),
    documentName VARCHAR(1024),
    documentId VARCHAR(3000),
    comment VARCHAR(1024),
    status VARCHAR(256),
    displayInResults BOOLEAN,
    revokeFromExternalCommunication BOOLEAN,
    addToReport BOOLEAN,
    approvalNeeded BOOLEAN,
    approval VARCHAR(MAX),  -- MapType can be represented as a JSON string
    rejection VARCHAR(MAX), -- MapType can be represented as a JSON string
    updatedBy VARCHAR(MAX), -- MapType can be represented as a JSON string
    createdBy VARCHAR(MAX), -- MapType can be represented as a JSON string
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

COMMENT ON TABLE yarahive.results IS 'Table to store results information';
COMMENT ON COLUMN yarahive.results.id IS 'Unique identifier for the results';
COMMENT ON COLUMN yarahive.results.demoId IS 'Identifier for the demo';
COMMENT ON COLUMN yarahive.results.resultType IS 'Type of the result';
COMMENT ON COLUMN yarahive.results.fileName IS 'Name of the file';
COMMENT ON COLUMN yarahive.results.documentName IS 'Name of the document';
COMMENT ON COLUMN yarahive.results.documentId IS 'Identifier for the document';
COMMENT ON COLUMN yarahive.results.comment IS 'Comments on the results';
COMMENT ON COLUMN yarahive.results.status IS 'Status of the results';
COMMENT ON COLUMN yarahive.results.displayInResults IS 'Flag to display in results';
COMMENT ON COLUMN yarahive.results.revokeFromExternalCommunication IS 'Flag to revoke from external communication';
COMMENT ON COLUMN yarahive.results.addToReport IS 'Flag to add to report';
COMMENT ON COLUMN yarahive.results.approvalNeeded IS 'Flag to indicate if approval is needed';
COMMENT ON COLUMN yarahive.results.approval IS 'Approval details as JSON string';
COMMENT ON COLUMN yarahive.results.rejection IS 'Rejection details as JSON string';
COMMENT ON COLUMN yarahive.results.updatedBy IS 'Updated by details as JSON string';
COMMENT ON COLUMN yarahive.results.createdBy IS 'Created by details as JSON string';
COMMENT ON COLUMN yarahive.results.createdAt IS 'Timestamp when the results was created';
COMMENT ON COLUMN yarahive.results.updatedAt IS 'Timestamp when the results was last updated';

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLE yarahive.results TO gluejob;
