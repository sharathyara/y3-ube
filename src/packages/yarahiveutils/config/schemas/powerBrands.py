from pyspark.sql.types import (
    StructType, StructField, StringType,ArrayType
)

powerBrands_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("Countries", ArrayType(StringType()), nullable=True),
])
