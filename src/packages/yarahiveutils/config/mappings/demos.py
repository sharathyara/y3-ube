# config/mappings/demos.py

demos_mapping = {
    "Id": "Id",
    "demoName": "name",
    "countryId": "country.$oid",
    "regionId": "region.$oid",
    "yaraLocalContact": "localContact",
    "approverId": "approver.$oid",
    "budgetYear": "budgetYear",
    "cropId": "crop.$oid",
    "subcropId": None,
    "farmId":"farmId",
    "farmerId":"farmerId",
    "detailedObjectives": "detailedObjective",
    "growthStageDuration": "growthStageDurations",
    "status": "status",
    "isTemplate": "isTemplate",
    "isReadOnly": None,
    "tools": "tools",
    "brands": "powerBrands",
    "currency": "currency",
    "createdAt": "createdAt.$date",
    "createdBy": "createdBy.$oid",
    "updatedAt": "updatedAt.$date",
    "updatedBy": "updatedBy.$oid",
    "permissionDocument": "permissionDocument"
}