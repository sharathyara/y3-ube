# config/extractions.py

tables_to_be_extracted = {
    "demos":[
        {
            "tablename": "farms",
            "table_data_parentpath": "farm",
            "table_data_column_alias": "farmData",
            "table_parent_id_path": "Id",
            "table_parent_id_column_alias": "demoId",
            "table_id_column_alias": "Id",
            "is_id_to_be_generated": True,
            "is_parent_depends_table_id": True
        },
        {
            "tablename": "farmers",
            "table_data_parentpath": "farm",
            "table_data_column_alias": "farmerData",
            "table_parent_id_path": "Id",
            "table_parent_id_column_alias": "demoId",
            "table_id_column_alias": "Id",
            "is_id_to_be_generated": True,
            "is_parent_depends_table_id": True
        },
        {
            "tablename": "fields",
            "table_data_parentpath": "fields",
            "table_data_column_alias": "fieldData",
            "table_parent_id_path": "Id",
            "table_parent_id_column_alias": "demoId",
            "table_id_column_alias": "Id",
            "is_id_to_be_generated": True,
            "is_parent_depends_table_id": False
        },
    ],
    "demoSites": [
        {
            "tablename": "assessments",
            "table_data_parentpath": "assessment",
            "table_data_column_alias": "assessmentData",
            "table_parent_id_path": "Id",
            "table_parent_id_column_alias": "demoSiteId",
            "table_id_column_alias": "Id",
            "is_id_to_be_generated": True,
            "is_parent_depends_table_id": False
        }
    ],
    "countries": [
        {
            "tablename": "regions",
            "table_data_parentpath": "regions",
            "table_data_column_alias": "regionData",
            "table_parent_id_path": "Id",
            "table_parent_id_column_alias": "countryId",
            "table_id_column_alias": "Id",
            "table_id_path_from_data": "_id.$oid",
            "is_id_to_be_generated": False,
            "is_parent_depends_table_id": False
        }
    ],
    "assessments":[
        {
            "tablename": "grossMargin",
            "table_data_parentpath": "assessmentData.grossMargin",
            "table_data_column_alias": "grossMarginData",
            "table_parent_id_path": "Id",
            "table_parent_id_column_alias": "assessmentId",
            "table_id_column_alias": "Id",
            "is_id_to_be_generated": True,
            "is_parent_depends_table_id": False
        },
        {
            "tablename": "nitrogenUseEfficiency",
            "table_data_parentpath": "assessmentData.nitrogenUseEfficiency",
            "table_data_column_alias": "nitrogenUseEfficiencyData",
            "table_parent_id_path": "Id",
            "table_parent_id_column_alias": "assessmentId",
            "table_id_column_alias": "Id",
            "is_id_to_be_generated": True,
            "is_parent_depends_table_id": False
        }
    ],
    "treatments":[
        {
            "tablename": "growthStagesApplications",
            "table_data_parentpath": "growthStages",
            "table_data_column_alias": "growthStagesApplicationsData",
            "table_parent_id_path": "Id",
            "table_parent_id_column_alias": "treatmentId",
            "table_id_column_alias": "Id",
            "is_id_to_be_generated": True,
            "is_parent_depends_table_id": False
        }
    ],
    "measurements":[
        {
            "tablename": "treatmentMeasurementMatrix",
            "table_data_parentpath": "treatments",
            "table_data_column_alias": "treatmentMeasurementMatrixData",
            "table_parent_id_path": "Id",
            "table_parent_id_column_alias": "measurementId",
            "table_id_column_alias": "Id",
            "is_id_to_be_generated": True,
            "is_parent_depends_table_id": False
        }
    ]
}