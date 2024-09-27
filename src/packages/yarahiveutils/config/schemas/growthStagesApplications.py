from pyspark.sql.types import StructType, StructField, StringType, DoubleType, DateType

growthStagesApplications_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("treatmentId", StringType(), nullable=True),
    StructField("stage", StringType(), nullable=True),
    StructField("applications_product", StringType(), nullable=True),
    StructField("applications_rate", DoubleType(), nullable=True),
    StructField("applications_unit", StructType([
        StructField("id", StringType(), nullable=True),
        StructField("name", StringType(), nullable=True)
    ]), nullable=True),
    StructField("applications_productcost", DoubleType(), nullable=True),
    StructField("applications_applicationdate", DateType(), nullable=True),
    StructField("applications_applicationmethodid", StringType(), nullable=True),
    StructField("applications_productpolarisid", StringType(), nullable=True),
    StructField("expectedHarvestDate", DateType(), nullable=True),
    StructField("unit", StructType([
        StructField("id", StringType(), nullable=True),
        StructField("name", StringType(), nullable=True)
    ]), nullable=True)
])
