from pyspark.sql.types import (
    StructType, StructField, StringType, ArrayType, TimestampType
)

users_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("email", StringType(), nullable=True),
    StructField("roles", ArrayType(StringType(), containsNull=True), nullable=True),
    StructField("language", StringType(), nullable=True),
    StructField("businessUnits", StringType(), nullable=True),
    StructField("countries", ArrayType(StringType(), containsNull=True), nullable=True),
    StructField("regions", ArrayType(StringType(), containsNull=True), nullable=True),
    StructField("createdAt", TimestampType(), nullable=True),
    StructField("updatedAt", TimestampType(), nullable=True),
    StructField("deletedAt", TimestampType(), nullable=True),
    StructField("deletedBy", StringType(), nullable=True)
])
