from pyspark.sql.types import (
    StructType, StructField, StringType
)

translations_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("namespace", StringType(), nullable=True),
    StructField("key", StringType(), nullable=True),
    StructField("locale", StringType(), nullable=True),
    StructField("value", StringType(), nullable=True)
])
