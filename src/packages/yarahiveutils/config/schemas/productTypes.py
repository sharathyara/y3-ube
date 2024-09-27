from pyspark.sql.types import (
    StructType, StructField, StringType
)

productTypes_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("applicationNutrientUnit", StringType(), nullable=True),
    StructField("applicationRateUnit", StringType(), nullable=True)
])
