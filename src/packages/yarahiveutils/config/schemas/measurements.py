from pyspark.sql.types import StructType, StructField, StringType, DoubleType

measurements_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("description", StringType(), nullable=True),
    StructField("measurementType", StringType(), nullable=True),
    StructField("measurementTypeId", StringType(), nullable=True),
    StructField("measurementUnit", StringType(), nullable=True),
    StructField("growthstage", StructType([
        StructField("stage", StringType(), nullable=True),
        StructField("unit", StringType(), nullable=True)
    ]), nullable=True),
    StructField("sampleSize", StructType([
        StructField("size", DoubleType(), nullable=True),
        StructField("unit", StringType(), nullable=True),
        StructField("legacyUnit", StringType(), nullable=True)
    ]), nullable=True)
])
