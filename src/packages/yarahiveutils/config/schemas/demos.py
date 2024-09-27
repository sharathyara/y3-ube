# config/schemas/demos.py

from pyspark.sql.types import (
    StructType, StructField, StringType, IntegerType, BooleanType, 
    ArrayType, TimestampType, MapType
)

demos_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("demoName", StringType(), nullable=True),
    StructField("countryId", StringType(), nullable=True),
    StructField("regionId", StringType(), nullable=True),
    StructField("yaraLocalContact", StringType(), nullable=True),
    StructField("approverId", StringType(), nullable=True),
    StructField("budgetYear", IntegerType(), nullable=True),
    StructField("cropId", StringType(), nullable=True),
    StructField("subcropId", StringType(), nullable=True),
    StructField("farmId", StringType(), nullable=True),
    StructField("farmerId", StringType(), nullable=True),
    StructField("detailedObjectives", StringType(), nullable=True),
    StructField("growthStageDuration", ArrayType(MapType(StringType(), StringType())), nullable=True),
    StructField("status", StringType(), nullable=True),
    StructField("isTemplate", BooleanType(), nullable=False),
    StructField("isReadOnly", BooleanType(), nullable=False),
    StructField("tools", ArrayType(StringType()), nullable=True),
    StructField("brands", ArrayType(StringType()), nullable=True),
    StructField("currency", MapType(StringType(), StringType()), nullable=True),
    StructField("createdAt", TimestampType(), nullable=True),
    StructField("createdBy", StringType(), nullable=True),
    StructField("updatedAt", TimestampType(), nullable=True),
    StructField("updatedBy", StringType(), nullable=True),
    StructField("permissionDocument", MapType(StringType(), StringType()), nullable=True)
])