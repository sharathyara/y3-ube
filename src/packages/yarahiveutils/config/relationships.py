# config/relationships.py

tables_relationship_configs = {
    "demoSites": {
        "relationship_to_generate": {
            "treatments": {
                "column_path": "treatments",
                "column_datatype": "ArrayType.StructType",
                "column_child_path": "$oid",
                "column_alias": "treatmentId"
            },
            "media": {
                "column_path": "mediaList",
                "column_datatype": "ArrayType.StructType",
                "column_child_path": "$oid",
                "column_alias": "mediaId"
            },
            "dataCollections": {
                "column_path": "dataCollections",
                "column_datatype": "ArrayType.StructType",
                "column_child_path": "$oid",
                "column_alias": "dataCollectionId"
            }
        },
        "relationship_to_depend": ["demos_demoSites"],
        "source": {
            "column_path": "Id",
            "column_alias": "demoSiteId"
        }
    },
    "demos": {
        "relationship_to_generate": {
            "demoSites": {
                "column_path": "demoSites",
                "column_datatype": "ArrayType.StructType",
                "column_child_path": "$oid",
                "column_alias": "demoSiteId"
            },
            "results": {
                "column_path": "results",
                "column_datatype": "ArrayType.StructType",
                "column_child_path": "$oid",
                "column_alias": "resultId"
            }

        },
        "source": {
            "column_path": "Id",
            "column_alias": "demoId"
        }
    },
    "treatments":{
        "relationship_to_depend": ["demoSites_treatments"],
        "source": {
            "column_path": "Id",
            "column_alias": "treatmentId"
        }
    },
    "media":{
        "relationship_to_depend": ["demoSites_media"],
        "source": {
            "column_path": "Id",
            "column_alias": "mediaId"
        }
    },
    "dataCollections":{
        "relationship_to_depend": ["demoSites_dataCollections"],
        "source": {
            "column_path": "Id",
            "column_alias": "dataCollectionId"
        }
    },
    "results":{
        "relationship_to_depend": ["demos_results"],
        "source": {
            "column_path": "Id",
            "column_alias": "resultId"
        }
    }
}