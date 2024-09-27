update ffdp2_0.field 
	set vardafieldid = b.field_id, 
		vardaboundaryid = b.boundary_id,
		iouscore = b.iou_score,
		inputbasedintersection = b.input_based_intersection,
		outputbasedintersection = b.output_based_intersection
	from (select featureid,field_id,boundary_id,iou_score,input_based_intersection,output_based_intersection from varda_gfid.lookup_gfid_uk where iou_score>='0.7' and iou_score not like '%e%') b where ffdp2_0.field.featuredataid = b.featureid and (vardafieldid is null or vardafieldid = '');