from pyspark.sql.types import (
    StructType, StructField, StringType, IntegerType, BooleanType, 
    ArrayType, TimestampType, MapType
)
demoSites_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("demoId", StringType(), nullable=True),
    StructField("cultivation_details", StringType(), nullable=True),
    StructField("breakevencalculation", StringType(), nullable=True),
    StructField("productAndApplicationCostUnit", StringType(), nullable=True),
    StructField("documents", StringType(), nullable=True),
    StructField("ProductObjective", StringType(), nullable=True),
])