from pyspark.sql.types import StructType, StructField, StringType

treatmentMeasurementMatrix_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("treatmentId", StringType(), nullable=True),
    StructField("measurementId", StringType(), nullable=True)
])
