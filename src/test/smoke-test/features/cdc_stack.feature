Feature: Processing Change Data Capture across buckets
  In order to validate processing of CDC stack,
  As an ELT processor 
  I want to update entity record in landing zone 
  and validate it is propagated to warehouse 
	 
  Scenario Outline: Updating a "<entity>" record in zone(s)
	
	Given No running "<raw_job>" process for entity "<entity>"
	 When file "<file_name>" with entity "<entity>" and "<hudi_record_key>" got updated on "2260-10-05" 
	 Then this event is created in file
	
	Given event in a file
     When I manually push event into platform in "<raw_object_location>"
	 Then the event object will be present in bucket
	 And the job "<raw_job>" should be running at most 5 minute(s)
	 And the record exists in "conformed" zone  	 
	
	Given record in "conformed" zone	
	 When I manually invoke job "<curator_job>" to conformed zone for "<entity>" entity
	 Then the job "<curator_job>" should be running at most 5 minute(s)
	 And the record exists in "curated" zone
	
	Given Redshift warehouse
     When the recent job "<redshift_job>" exists
	 Then job "<redshift_job>" is processing "<entity>" entity table in "curated" zone
	 And the job "<redshift_job>" should be running at most 5 minute(s)
	 Then the "<entity>" record exists in Redshift using "<query>"	
  
 Examples: CDC entity
      | entity	| hudi_record_key | ident	| raw_object_location 												| file_name 					| raw_job 							| curator_job 						 	| redshift_job 						| query 																|
	  | field	| fieldId		  | fieldid | field-profile/eu-central-1/stage-yara-digitalsolution-fafm-field	| smoke-test-template-field.avro| hudi-init-load-job-eu-central-1c	| hudi-curator-job-field-eu-central-1c 	| curator-redshift-job-eu-central-1c 	| SELECT * FROM "curated_schema"."field" where fieldid like %IDENT%;  	| 
	  | farm	| farmId		  | farmid  | farm-profile/eu-central-1/stage-yara-digitalsolution-fafm-farm 	| smoke-test-template-farm.avro	| hudi-init-load-job-eu-central-1b	| hudi-curator-job-farm-eu-central-1b 	| curator-redshift-job-eu-central-1b 	| SELECT * FROM "curated_schema"."farm" where farmid like %IDENT%;  	| 
      | user  	| id		      | userid	| user/eu-central-1/stage-yara-digitalsolution-um-user  			| smoke-test-template-user.avro | hudi-init-load-job-eu-central-1a 	| hudi-curator-job-user-eu-central-1a 	| curator-redshift-job-eu-central-1a 	| SELECT * FROM "curated_schema"."user" where userid like %IDENT%;  	|  
