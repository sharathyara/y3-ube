from pyspark.sql.types import (
    StructType, StructField, StringType, ArrayType, BooleanType, TimestampType,DoubleType
)

products_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("productType", StringType(), nullable=True),
    StructField("company", StringType(), nullable=True),
    StructField("applicableCountries", ArrayType(StringType()), nullable=True),
    StructField("applicableRegions", ArrayType(StringType()), nullable=True),
    StructField("applicationNutrientUnit", StringType(), nullable=True),
    StructField("applicationRateUnit", StringType(), nullable=True),
    StructField("brand", StringType(), nullable=True),
    StructField("dhcode", StringType(), nullable=True),
    StructField("nutrients", StringType(), nullable=True),
    StructField("originCountry", StringType(), nullable=True),
    StructField("reportName", StringType(), nullable=True),
    StructField("density", DoubleType(), nullable=True),
    StructField("images", StringType(), nullable=True),
    StructField("createdBy", StringType(), nullable=True),
    StructField("createdAt", TimestampType(), nullable=True),
    StructField("updatedBy", StringType(), nullable=True),
    StructField("updatedAt", TimestampType(), nullable=True),
    StructField("deletedBy", StringType(), nullable=True),
    StructField("deleteAt", TimestampType(), nullable=True),
    StructField("legacy", StringType(), nullable=True),
    StructField("ec", DoubleType(), nullable=True),
    StructField("insertedViaUpdateTreatmentProductsMigration", BooleanType(), nullable=True)
])
