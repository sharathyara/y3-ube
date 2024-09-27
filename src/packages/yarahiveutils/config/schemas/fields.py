from pyspark.sql.types import (
    StructType, StructField, StringType, DoubleType
)

fields_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("demoSiteId", StringType(), nullable=True),
    StructField("latitude", StringType(), nullable=True),
    StructField("longitude", StringType(), nullable=True),
    StructField("boundary", StringType(), nullable=True),
    StructField("directions", StringType(), nullable=True),
    StructField("totalarea", DoubleType(), nullable=True),
    StructField("totalareaunit", StringType(), nullable=True)
])
