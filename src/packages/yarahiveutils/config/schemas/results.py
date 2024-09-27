from pyspark.sql.types import StructType, StructField, StringType, BooleanType, TimestampType, MapType

results_schema = StructType([
    StructField("id", StringType(), nullable=False),
    StructField("demoId", StringType(), nullable=False),
    StructField("resultType", StringType(), nullable=True),
    StructField("fileName", StringType(), nullable=True),
    StructField("documentName", StringType(), nullable=True),
    StructField("documentId", StringType(), nullable=True),
    StructField("comment", StringType(), nullable=True),
    StructField("status", StringType(), nullable=True),
    StructField("displayInResults", BooleanType(), nullable=True),
    StructField("revokeFromExternalCommunication", BooleanType(), nullable=True),
    StructField("addToReport", BooleanType(), nullable=True),
    StructField("approvalNeeded", BooleanType(), nullable=True),
    StructField("approval", MapType(StringType(), StringType()), nullable=True),
    StructField("rejection", MapType(StringType(), StringType()), nullable=True),
    StructField("updatedBy", MapType(StringType(), StringType()), nullable=True),
    StructField("createdBy", MapType(StringType(), StringType()), nullable=True),
    StructField("createdAt", TimestampType(), nullable=True),
    StructField("updatedAt", TimestampType(), nullable=True)
])
