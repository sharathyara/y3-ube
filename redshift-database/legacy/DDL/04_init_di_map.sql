CREATE TABLE IF NOT EXISTS curated_schema.di_map
(
  datetimeoccurred TIMESTAMP,
  sourceFile_name VARCHAR(255), 
  sourceFile_receivedDate VARCHAR(255), 
  mapFile VARCHAR(255), 
  seasonId VARCHAR(255), 
  filesCountInZip INTEGER,  
  eventSource VARCHAR(255),  
  eventType VARCHAR(255),  
  eventId VARCHAR(255),
  created_at VARCHAR(255)
);


GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE curated_schema.di_map TO gluejob;