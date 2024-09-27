from pyspark.sql.types import StructType, StructField, StringType, DoubleType, LongType

grossMargin_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("assessmentId", StringType(), nullable=True),
    StructField("treatmentId", StringType(), nullable=True),
    StructField("cropYield", DoubleType(), nullable=True),
    StructField("price", DoubleType(), nullable=True),
    StructField("fertilizerProductCost", DoubleType(), nullable=True),
    StructField("fertilizerApplicationCost", DoubleType(), nullable=True),
    StructField("otherCultivationProductCost", LongType(), nullable=True),
    StructField("otherCultivationApplicationCost", LongType(), nullable=True)
])
