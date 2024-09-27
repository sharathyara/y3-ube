from pyspark.sql.types import (
    StructType, StructField, StringType
)

cropMetadata_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("key", StringType(), nullable=True),
    StructField("value", StringType(), nullable=True)
])
