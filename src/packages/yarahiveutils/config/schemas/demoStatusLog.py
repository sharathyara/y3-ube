from pyspark.sql.types import StructType, StructField, StringType, TimestampType, MapType

demoStatusLog_schema = StructType([
    StructField("id", StringType(), nullable=False),
    StructField("demoId", StringType(), nullable=False),
    StructField("type", StringType(), nullable=False),
    StructField("payload", MapType(StringType(), StringType()), nullable=True),
    StructField("createdBy", StringType(), nullable=True),
    StructField("createdAt", TimestampType(), nullable=True),
    StructField("updatedAt", TimestampType(), nullable=True),
    StructField("updatedBy", StringType(), nullable=True),
    StructField("notifiedViaEmailAt", TimestampType(), nullable=True)
])
