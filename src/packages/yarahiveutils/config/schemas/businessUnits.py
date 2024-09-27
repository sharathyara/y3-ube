from pyspark.sql.types import (
    StructType, StructField, StringType
)

businessUnits_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True)
])
