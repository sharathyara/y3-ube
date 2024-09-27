from pyspark.sql.types import StructType, StructField, StringType, DoubleType, LongType

nitrogenUseEfficiency_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("assessmentId", StringType(), nullable=True),
    StructField("treatment", StringType(), nullable=True),
    StructField("cropYield", DoubleType(), nullable=True),
    StructField("nConcentrationMainProduct", DoubleType(), nullable=True),
    StructField("harvestedOrRemovedByProduct", DoubleType(), nullable=True),
    StructField("nConcentrationByProduct", LongType(), nullable=True),
    StructField("nFertilizerSynthetic", DoubleType(), nullable=True),
    StructField("nFertilizerOrganic", DoubleType(), nullable=True),
    StructField("nBNFFactor", DoubleType(), nullable=True),
    StructField("nDepositionAir", LongType(), nullable=True)
])
