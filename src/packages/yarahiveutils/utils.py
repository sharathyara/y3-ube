import sys
import json
from datetime import datetime
import boto3
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import *
from pyspark.sql.types import *
from bson import ObjectId
import hashlib

def pre_transformations(dataframe: DataFrame) -> DataFrame:
    try:
        if '_id' in dataframe.columns:
            dataframe = dataframe.withColumn("Id", col("_id.$oid")).drop("_id")
        return dataframe
    except Exception as e:
        raise

def extract_and_normalize_foreign_keys(dataframe: DataFrame, source_identifier_details: dict,
                                       target_identifier_details: dict) -> DataFrame:
    source_column_path = source_identifier_details.get('column_path')
    source_column_alias = source_identifier_details.get('column_alias')

    target_column_path = target_identifier_details.get('column_path')
    target_column_datatype = target_identifier_details.get('column_datatype')
    target_column_child_path = target_identifier_details.get('column_child_path')
    target_column_alias = target_identifier_details.get('column_alias')

    if target_column_datatype == "StringType":
        normalized_df = dataframe.select(
            col(source_column_path).alias(source_column_alias),
            col(target_column_path).alias(target_column_alias)
        )
    elif target_column_datatype == "ArrayType.StructType":
        normalized_df = dataframe.select(
            col(source_column_path).alias(source_column_alias),
            explode(col(target_column_path)).alias("foreignKey")
        ).select(
            col(source_column_alias),
            col(f"foreignKey.{target_column_child_path}").alias(target_column_alias)
        )
    elif target_column_datatype == "ArrayType.StringType":
        normalized_df = dataframe.select(
            col(source_column_path).alias(source_column_alias),
            explode(col(target_column_path)).alias(target_column_alias)
        )
    else:
        raise ValueError("Unsupported target data type")

    return normalized_df

# def generate_object_id():
#     return str(ObjectId())
def generate_object_id(col, unique_string):
    hash_input = col + unique_string
    hash_input = hash_input.encode('utf-8')
    return hashlib.sha1(hash_input).hexdigest()[:24]

def process_collection(dataframe: DataFrame, **kwargs) -> DataFrame:
    tablename = kwargs.get("tablename")
    table_data_parentpath = kwargs.get("table_data_parentpath")
    table_data_column_alias = kwargs.get("table_data_column_alias", 'data')
    table_parent_id_path = kwargs.get("table_parent_id_path", "Id")
    table_parent_id_column_alias = kwargs.get("table_parent_id_column_alias")
    table_id_column_alias = kwargs.get("table_id_column_alias", 'Id')
    table_id_path_from_data = kwargs.get("table_id_path_from_data", None)
    is_id_to_be_generated = kwargs.get("is_id_to_be_generated", False)
    if (table_id_path_from_data == None) & (is_id_to_be_generated == False):
        is_id_to_be_generated = True
    is_parent_depends_table_id = kwargs.get("is_parent_depends_table_id", False)

    selected_df = dataframe.select(
        col(table_parent_id_path).alias(table_parent_id_column_alias),
        col(table_data_parentpath).alias(table_data_column_alias)
    )

    if isinstance(selected_df.schema[table_data_column_alias].dataType, ArrayType):
        selected_df = selected_df.select(
            col(table_parent_id_column_alias),
            explode(col(table_data_column_alias)).alias(table_data_column_alias)
        )

    object_id_udf = udf(generate_object_id, StringType())

    if is_id_to_be_generated:
        sub_dataframe = selected_df.withColumn(
            table_id_column_alias,
            object_id_udf(col(table_parent_id_column_alias), lit(tablename))
        )
    else:
        sub_dataframe = selected_df.withColumn(
            table_id_column_alias, col(f"{table_data_column_alias}.{table_id_path_from_data}")
        )

    if is_parent_depends_table_id:
        dataframe = dataframe.join(
            sub_dataframe.select(col(table_id_column_alias).alias(f"{tablename[:-1]}Id"),
                                 col(table_parent_id_column_alias)),
            dataframe[table_parent_id_path] == sub_dataframe[table_parent_id_column_alias],
            how="left"
        ).drop(col(table_parent_id_column_alias))

    return tablename, sub_dataframe, dataframe


def process_and_join_collections(primary_df: DataFrame, join_configurations: list, relationship_dfs: dict,
                                 tables_relationship_configs: dict) -> DataFrame:
    try:
        for mapping_df_name in join_configurations:
            parent_dependend = mapping_df_name.split('_')[1]
            right_table_key = tables_relationship_configs[parent_dependend]['source']['column_alias']
            right_df = relationship_dfs[mapping_df_name]
            primary_df = primary_df.join(
                right_df,
                primary_df["Id"] == right_df[right_table_key],
                how="left"
            ).drop(right_table_key)
        return primary_df
    except Exception as e:
        raise


def transform_data(dataframe: DataFrame, column_mappings: dict, target_schema: StructType, logger) -> DataFrame:
    try:
        select_expr = []
        for field in target_schema.fields:
            target_col = field.name
            source_col = column_mappings.get(target_col)

            if source_col is None:
                select_expr.append(lit(None).cast(field.dataType).alias(target_col))
            elif isinstance(source_col, dict):
                nested_struct_fields = []
                for nested_target_col, nested_source_col in source_col.items():
                    if nested_source_col.endswith(".$date"):
                        nested_struct_fields.append(col(nested_source_col).cast("timestamp").alias(nested_target_col))
                    else:
                        nested_struct_fields.append(col(nested_source_col).alias(nested_target_col))
                select_expr.append(struct(*nested_struct_fields).alias(target_col))
            elif source_col.endswith(".$date"):
                select_expr.append(col(source_col).cast("timestamp").alias(target_col))
            else:
                select_expr.append(col(source_col).alias(target_col))

        dataframe = dataframe.select(*select_expr)
        # handle NULL values
        # transformed_df=replace_null_values(transformed_df,target_schema)
        null_values = ["@NULL@", "NULL", "null", "Null", "", "NaN", "N/A", "NA", "n/a", "na", "NAN", "nan"]
        for field in dataframe.schema.fields:
            if isinstance(field.dataType, StructType):
                logger.info(f"StructType {field.name = }")
                dataframe = dataframe.withColumn(field.name, to_json(col(field.name)))
            elif isinstance(field.dataType, ArrayType):
                logger.info(f"ArrayType {field.name = }")
                dataframe = dataframe.withColumn(field.name, to_json(col(field.name)))
            elif isinstance(field.dataType, StringType) and field.nullable:
                logger.info(f"StringType {field.name = }")
                dataframe = dataframe.withColumn(
                    field.name,
                    when(col(field.name).isin(null_values), lit(None)).otherwise(col(field.name))
                )
            elif isinstance(field.dataType, BooleanType):
                logger.info(f"Boolean {field.name = }")
                dataframe = dataframe.withColumn(field.name, when(col(field.name) == True, "true")
                                                 .when(col(field.name) == False, "false")
                                                 .otherwise(lit(None)))
                dataframe = dataframe.withColumn(field.name, col(field.name).cast("boolean"))
        return dataframe

    except Exception as e:
        raise