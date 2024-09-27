CREATE TABLE IF NOT EXISTS yarahive.DemoSites (
    Id VARCHAR(36) NOT NULL,
    name VARCHAR(1000),
    demoId VARCHAR(36),
    cultivation_details SUPER,
    breakevencalculation SUPER,
    productAndApplicationCostUnit SUPER,
    documents SUPER,
    ProductObjective SUPER
);

COMMENT ON TABLE yarahive.DemoSites IS 'Table to store demo site information';
COMMENT ON COLUMN yarahive.DemoSites.Id IS 'Unique identifier for the demo site';
COMMENT ON COLUMN yarahive.DemoSites.name IS 'Name of the demo site';
COMMENT ON COLUMN yarahive.DemoSites.demoId IS 'Identifier for the demo';
COMMENT ON COLUMN yarahive.DemoSites.cultivation_details IS 'Cultivation details of the demo site';
COMMENT ON COLUMN yarahive.DemoSites.breakevencalculation IS 'Break-even calculation details';
COMMENT ON COLUMN yarahive.DemoSites.productAndApplicationCostUnit IS 'Product and application cost unit';
COMMENT ON COLUMN yarahive.DemoSites.documents IS 'Documents associated with the demo site';
COMMENT ON COLUMN yarahive.DemoSites.ProductObjective IS 'Product objective of the demo site';

GRANT SELECT, INSERT, UPDATE, DELETE,TRUNCATE ON TABLE yarahive.DemoSites TO gluejob;