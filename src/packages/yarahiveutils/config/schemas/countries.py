from pyspark.sql.types import (
    StructType, StructField, StringType, BooleanType, MapType
)

currency_schema = StructType([
    StructField("name", StringType(), nullable=True),
    StructField("symbol", StringType(), nullable=True),
    StructField("code", StringType(), nullable=True)
])

countries_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("code", StringType(), nullable=True),
    StructField("name", StringType(), nullable=True),
    StructField("enabled", BooleanType(), nullable=True),
    StructField("localCurrency", currency_schema, nullable=True),
    StructField("currency", currency_schema, nullable=True)
])
