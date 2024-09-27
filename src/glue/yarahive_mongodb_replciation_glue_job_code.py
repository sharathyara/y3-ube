import sys
import json
from datetime import datetime
import boto3
from awsglue.dynamicframe import DynamicFrame
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import *
from pyspark.sql.types import *
from bson import ObjectId
from yarahiveutils import utils
from yarahiveutils import colletions_config

# AWS Glue job arguments
args = getResolvedOptions(sys.argv, ["JOB_NAME", "collections_list", "source_bucket_name", "execution_date",
                                     "source_base_object_key", "mongodb_name", "aws_iam_role",
                                     "redshift_connection_user", "redshift_url", "redshift_db_name",
                                     "redshift_cluster_name", "TempDir"])

# Initialize Spark and Glue contexts
sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

# Initialize logger
logger = glue_context.get_logger()

# Get job arguments
glue_job_run_id = args['JOB_RUN_ID']
collections = args['collections_list'].split(',')
aws_iam_role = args['aws_iam_role']
redshift_user = args['redshift_connection_user']
redshift_url = args['redshift_url']
redshift_db_name = args['redshift_db_name']
redshift_cluster_name = args['redshift_cluster_name']
redshift_schema_name = 'yarahive'
temp_dir = args['TempDir']

logger.info(f"{args = }")

try:
    sub_collections = {}
    relationships_mapping = {}
    write_to_redshift_Dataframe = {}

    logger.info(f"{collections = }")
    # Loop through each collection specified in the arguments
    for collection_name in collections:
        logger.info(f" colelction name: {collection_name } ==>Processing collection: {collection_name}")
        logger.info(f" colelction name: {collection_name } ==>Sub_collection list till now : {sub_collections}")
        logger.info(f" colelction name: {collection_name } ==>relationships_mapping list till now : {relationships_mapping}")
        logger.info(f" colelction name: {collection_name } ==>write_to_redshift_Dataframe list till now : {write_to_redshift_Dataframe}")
        try:
            if collection_name in sub_collections:
                collection_df = sub_collections[collection_name]
                logger.info(f" colelction name: {collection_name } ==>Using existing dataframe for collection: {collection_name}")
            else:
                # from config get the collection alias ex: demoStatusLogs-->eventLogs
                s3_file_name = colletions_config.redshift_table_reference_to_mongodb_collection.get(collection_name,
                                                                                                    collection_name)
                s3_path = f"s3://{args['source_bucket_name']}/{args['source_base_object_key']}/{args['execution_date']}/{args['mongodb_name']}/{s3_file_name}.json"
                logger.info(f" colelction name: {collection_name } ==>Reading data from S3 path: {s3_path}")
                collection_df = spark.read.options(lineSep="\n").json(s3_path)
                logger.info(f" colelction name: {collection_name } ==>Schema of {collection_name}: {collection_df.printSchema()}")

            logger.info(f" colelction name: {collection_name } ==>analysis 1: {collection_df.count() = }")
            logger.info(f" colelction name: {collection_name } ==>analysis 1: {collection_df.columns = }")
            # Pre-transformations
            logger.info(f" colelction name: {collection_name } ==>step 0: Pre-transformations started for: {collection_name}")
            collection_df = utils.pre_transformations(collection_df)
            logger.info(f" colelction name: {collection_name } ==>step 0: Pre-transformations completed for: {collection_name}")

            # Process sub-collections if any

            if collection_name in colletions_config.tables_to_be_extracted:
                logger.info(f" colelction name: {collection_name } ==>step 1: Process sub-collections if any for : {collection_name} started")
                for index in range(len(colletions_config.tables_to_be_extracted[collection_name])):
                    sub_collection_name, sub_collection_df, collection_df = utils.process_collection(
                        collection_df, **colletions_config.tables_to_be_extracted[collection_name][index]
                    )
                    sub_collections[sub_collection_name] = sub_collection_df
                    logger.info(f" colelction name: {collection_name } ==>Processed sub-collection: {sub_collection_name}")
                    logger.info(f" colelction name: {collection_name } ==>analysis 2: {sub_collection_df.count() = }")
                    logger.info(f" colelction name: {collection_name } ==>analysis 3: {sub_collection_df.columns = }")
                logger.info(f" colelction name: {collection_name } ==>step 1: Process sub-collections if any for : {collection_name} completed, the sub-collection list = {sub_collections}")

            # Generate relationships if any
            if collection_name in colletions_config.tables_relationship_configs:
                logger.info(f" colelction name: {collection_name } ==>step 2:Generate relationships if any for : {collection_name} started")
                if "relationship_to_generate" in colletions_config.tables_relationship_configs[collection_name]:
                    relationship_to_generate_dict = colletions_config.tables_relationship_configs[collection_name][
                        "relationship_to_generate"]
                    for relationship, relationship_configs in relationship_to_generate_dict.items():
                        output_df = utils.extract_and_normalize_foreign_keys(
                            collection_df, colletions_config.tables_relationship_configs[collection_name]["source"],
                            relationship_configs
                        )
                        relationships_mapping[f"{collection_name}_{relationship}"] = output_df
                        logger.info(f" colelction name: {collection_name } ==>Generated relationship: {relationship} for collection: {collection_name}")
                logger.info(f" colelction name: {collection_name } ==>step 1: Generate relationships if any for : {collection_name} completed")

            # Process and join dependent relationships if any
            if "relationship_to_depend" in colletions_config.tables_relationship_configs.get(collection_name, {}):
                logger.info(f" colelction name: {collection_name } ==>step 3: Process and join dependent relationships if any : {collection_name} started")
                relationship_to_depend_list = colletions_config.tables_relationship_configs[collection_name][
                    "relationship_to_depend"]
                if len(relationship_to_depend_list) > 0:
                    collection_df = utils.process_and_join_collections(
                        collection_df, relationship_to_depend_list, relationships_mapping,
                        colletions_config.tables_relationship_configs
                    )
                    logger.info(f" colelction name: {collection_name } ==>Processed and joined dependent relationships for: {collection_name}")
                logger.info(f" colelction name: {collection_name } ==>step 3: Process and join dependent relationships if any : {collection_name} completed")

            # Transform data and prepare for Redshift
            target_schema = colletions_config.target_schemas.get(collection_name, None)
            column_mapping = colletions_config.column_mappings.get(collection_name, None)
            logger.info(
                f"step 4: Transform data and prepare for Redshift for collection name  : {collection_name} started")
            logger.info(f" colelction name: {collection_name } ==>{target_schema = }")
            logger.info(f" colelction name: {collection_name } ==>{column_mapping = }")

            collection_df = utils.transform_data(collection_df, column_mapping, target_schema, logger)
            logger.info(
                f"step 4: Transform data and prepare for Redshift for collection name  : {collection_name} completed")

            write_to_redshift_Dataframe[collection_name] = collection_df
        except Exception as e:
            logger.error(f"Error processing collection {collection_name}: {e}")
            raise

    # Get Redshift cluster credentials
    redshift_client = boto3.client('redshift')
    credentialsResponse = redshift_client.get_cluster_credentials(
        DbUser=redshift_user,
        DbName=redshift_db_name,
        ClusterIdentifier=redshift_cluster_name,
        DurationSeconds=3600,
        AutoCreate=False
    )

    redshift_credentials = {
        'userName': credentialsResponse['DbUser'],
        'password': credentialsResponse['DbPassword']
    }

    logger.info(f"Credentials received for {redshift_credentials['userName']}")
    logger.info("Writing to Redshift started")

    # Write data to Redshift
    for table_name, dataframe in write_to_redshift_Dataframe.items():
        redshift_table_name = table_name.lower()
        dynamic_frame_target_table = f"{redshift_schema_name}.{redshift_table_name}"

        logger.info(f" Table name: {table_name } ==>{dataframe.show(5) = }")
        try:
            counted_records = dataframe.count()
            pre_action_create_stage = f"DELETE FROM {redshift_schema_name}.{redshift_table_name};"
            redshift_connection_options = {
                "url": redshift_url,
                "dbtable": dynamic_frame_target_table,
                "user": redshift_credentials['userName'],
                "password": redshift_credentials['password'],
                "tempdir": temp_dir,
                "redshiftTmpDir": args["TempDir"],
                "aws_iam_role": aws_iam_role,
                "autoCreate": False,
                "preactions": pre_action_create_stage,
                "batchsize":1000
                # "postactions": post_action_target_table
            }

            logger.info(f" Table name: {table_name } ==>Writing to Redshift started for collection: {table_name}")
            logger.info(f" Table name: {table_name } ==>Redshift table: {redshift_table_name}")
            logger.info(f" Table name: {table_name } ==>Pre-actions: {pre_action_create_stage}")
            # logger.info(f" Table name: {table_name } ==>Post-actions: {post_action_target_table}")

            logger.info(f" Table name: {table_name } ==>{dataframe.count() = }")
            logger.info(f" Table name: {table_name } ==>{dataframe.show(5) = }")
            logger.info(f" Table name: {table_name } ==>{dataframe.collect()[:5] = }")
            logger.info(f" Table name: {table_name } ==>{dataframe.columns = }")
            logger.info(f" Table name: {table_name } ==>{dataframe.schema = }")
            logger.info(f" Table name: {table_name } ==>{dataframe.printSchema() = }")

            dataframe.write \
                .format("jdbc") \
                .options(**redshift_connection_options) \
                .mode("append") \
                .save()


            logger.info(f" Table name: {table_name } ==>Writing to Redshift completed for collection {table_name}")
        except Exception as e:
            logger.error(f"Error during writing to Redshift for collection {table_name}: {str(e)}")
            raise

except Exception as e:
    logger.error(f"Job failed: {e}")
    raise

# Commit job
job.commit()
logger.info("Job committed successfully")
