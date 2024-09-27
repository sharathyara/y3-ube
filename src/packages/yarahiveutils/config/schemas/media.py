from pyspark.sql.types import StructType, StructField, StringType, BooleanType, DateType, TimestampType, ArrayType, MapType

media_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("demositesId", StringType(), nullable=False),
    StructField("fileId", StringType(), nullable=True),
    StructField("fileName", StringType(), nullable=True),
    StructField("name", StringType(), nullable=True),
    StructField("date", DateType(), nullable=True),
    StructField("growthStage", MapType(StringType(), StringType()), nullable=True),
    StructField("measurementTypes", ArrayType(StringType()), nullable=True),
    StructField("legacyMeasurementTypes", ArrayType(MapType(StringType(), StringType())), nullable=True),
    StructField("thumbnailFileId", StringType(), nullable=True),
    StructField("treatments", ArrayType(StringType()), nullable=True),
    StructField("comment", StringType(), nullable=True),
    StructField("addToReport", BooleanType(), nullable=True),
    StructField("createdAt", TimestampType(), nullable=True),
    StructField("updatedAt", TimestampType(), nullable=True)
])
