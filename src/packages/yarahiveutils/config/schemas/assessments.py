from pyspark.sql.types import StructType, StructField, StringType, MapType,ArrayType

assessments_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("demositeId", StringType(), nullable=True),
    StructField("yieldSelection", MapType(StringType(), StringType()), nullable=True),
    StructField("returnOnInvestments", ArrayType(MapType(StringType(), StringType()), containsNull=True), nullable=True),
    StructField("breakEvenCalculations", ArrayType(MapType(StringType(), StringType()), containsNull=True), nullable=True)
])
