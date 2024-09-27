from pyspark.sql.types import (
    StructType, StructField, StringType, ArrayType, StructType
)

other_contacts_schema = StructType([
    StructField("name", StringType(), nullable=True),
    StructField("contact", StringType(), nullable=True),
    StructField("email", StringType(), nullable=True)
])

farmers_schema = StructType([
    StructField("Id", StringType(), nullable=False),
    StructField("name", StringType(), nullable=True),
    StructField("phone", StringType(), nullable=True),
    StructField("email", StringType(), nullable=True),
    StructField("salesforceAccount", StringType(), nullable=True),
    StructField("businessUnitId", StringType(), nullable=True),
    StructField("OtherContacts", ArrayType(other_contacts_schema), nullable=True)
])
