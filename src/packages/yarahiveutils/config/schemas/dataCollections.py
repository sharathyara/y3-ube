from pyspark.sql.types import StructType, StructField, StringType, DoubleType, ArrayType, MapType, TimestampType

dataCollections_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("demositesId", StringType(), nullable=False), 
    StructField("measurementId", ArrayType(MapType(StringType(),StringType())), nullable=True),
    StructField("treatmentId", StringType(), nullable=False),
    StructField("comment", StringType(), nullable=True),
    StructField("measurementType", StringType(), nullable=True),
    StructField("measurementOfSample", MapType(StringType(), StringType()), nullable=True),
])
