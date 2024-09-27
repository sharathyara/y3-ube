from pyspark.sql.types import (
    StructType, StructField, StringType, ArrayType
)

applicationMethods_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("countries", ArrayType(StringType()), nullable=True)
])