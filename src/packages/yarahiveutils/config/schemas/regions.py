from pyspark.sql.types import (
    StructType, StructField, StringType, BooleanType
)

regions_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("code", StringType(), nullable=True),
    StructField("name", StringType(), nullable=True),
    StructField("enabled", BooleanType(), nullable=True),
    StructField("countryId", StringType(), nullable=True)
])
