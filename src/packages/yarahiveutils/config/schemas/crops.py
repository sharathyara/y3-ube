from pyspark.sql.types import (
    StructType, StructField, StringType, BooleanType, IntegerType, ArrayType, MapType, TimestampType
)

crops_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("code", IntegerType(), nullable=True),
    StructField("enabled", BooleanType(), nullable=True),
    StructField("subcrop", StringType(), nullable=True),
    StructField("country", StringType(), nullable=True),
    StructField("regions", ArrayType(StringType()), nullable=True),
    StructField("cultivationDetails", MapType(StringType(), StringType()), nullable=True),
    StructField("growthStageScale", StringType(), nullable=True),
    StructField("growthStages", ArrayType(StringType()), nullable=True),
    StructField("applicationMethods", ArrayType(StringType()), nullable=True),
    StructField("measurements", MapType(StringType(), StringType()), nullable=True),  # MapType instead of structType
    StructField("yieldUnit", StringType(), nullable=True),
    StructField("cropPriceCalculatedPerUnit", StringType(), nullable=True),
    StructField("costAndRevenueCalculatedPerUnit", StringType(), nullable=True),
    StructField("insertedViaUpdateDemoCropsUsingCropsOfDemoCountryMigration", BooleanType(), nullable=True),
    StructField("defaultCommercializationUnitsPopulatedViaMigration", BooleanType(), nullable=True),
    StructField("createdAt", TimestampType(), nullable=True),
    StructField("updatedAt", TimestampType(), nullable=True)
])
