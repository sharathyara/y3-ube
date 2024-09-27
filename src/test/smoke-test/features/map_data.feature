Feature: Upload and process Map data
  In order to validate processing of Map data,
  As an ELT processor 
  I want to upload a map file in shared bucket in advance
  and unzip it once received event for processing it
	 
  Scenario Outline: Uploading map data
	
	Given A new season
	 When map file "<data_file_name>" is created for new season
	 Then file is ready for upload
	
	Given A bucket for map upload
	 When map file with entity "<entity>" is uploaded in "<s3_object_key_prefix>" folder
	 Then the data file will be present in bucket

	Given No running "<raw_job>" process for entity "<entity>"
	 When map file event "<file_name>" with entity "<entity>" and "<hudi_record_key>" got updated on "2260-10-05" 
	 Then this event is created in file
	 
	Given event in a file
	 When I manually push event into platform in "<raw_object_location>"
	 Then the event object will be present in bucket
	 And the job "<raw_job>" should be running at most 5 minute(s)
	 And map file is extracted in bucket

	Given record in "conformed" zone	
	 When I manually invoke job "<curator_job>" to conformed zone for "<entity>" entity
	 Then the job "<curator_job>" should be running at most 5 minute(s)
	
	Given Redshift warehouse
	 When the recent job "<redshift_job>" exists
	 Then job "<redshift_job>" is processing "<entity>" entity table in "curated" zone
	 And the job "<redshift_job>" should be running at most 5 minute(s)
	 Then the "<entity>" record exists in Redshift using "<query>"	
	 
 Examples: Map Data files
      | data_file_name		| s3_object_key_prefix 				| entity		| hudi_record_key | ident	| raw_object_location 									| file_name 					 | raw_job 									| curator_job 						 		| redshift_job 							| query 																|
	  | map_test_file.pdf	| raw-map-uploads/test_data/map		| di_map		| mapFile		  | mapFile | di_map/eu-central-1/stage-yara-digitalsolution-di-map	| smoke-test-template-di_map.avro| hudi-init-di-map-load-job-eu-central-1b	| hudi-curator-job-di-map-eu-central-1b 	| curator-redshift-job-eu-central-1b 	| SELECT * FROM "curated_schema"."di_map" where mapfile like %IDENT%;  	| 
	 