from pyspark.sql.types import StructType, StructField, StringType, DoubleType

treatments_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("demoSiteId", StringType(), nullable=True),
    StructField("name", StringType(), nullable=True),
    StructField("description", StringType(), nullable=True),
    StructField("type", StringType(), nullable=True),  # Assuming type is a string
    StructField("treatmentComment", StringType(), nullable=True),
    StructField("expectedCropPrice", DoubleType(), nullable=True),
    StructField("expectedYield", DoubleType(), nullable=True),
    StructField("economicFeasibilityComment", StringType(), nullable=True),
    StructField("totalRevenue", DoubleType(), nullable=True)
])
