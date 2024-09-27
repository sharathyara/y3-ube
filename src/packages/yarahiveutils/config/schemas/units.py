from pyspark.sql.types import (
    StructType, StructField, StringType, ArrayType, MapType
)

units_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("category", StringType(), nullable=True),
    StructField("countries", ArrayType(StringType()), nullable=True),
    StructField("legacyId", StringType(), nullable=True),
    StructField("legacyCategory", StringType(), nullable=True),
    StructField("legacySampleSizeUnit", MapType(StringType(), StringType()), nullable=True)
])
