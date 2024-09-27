from pyspark.sql.types import StructType, StructField, StringType, DoubleType

farms_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("address", StringType(), nullable=True),
    StructField("farmSize", DoubleType(), nullable=True),
    StructField("farmSizeUnit", StringType(), nullable=True),
])