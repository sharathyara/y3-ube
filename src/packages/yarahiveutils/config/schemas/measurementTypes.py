from pyspark.sql.types import StructType, StructField, StringType

measurementTypes_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True)
])
