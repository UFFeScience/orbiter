# import libraries
import os
from delta.tables import *
from pyspark.sql import SparkSession
from pyspark import SparkConf

# main spark program
# init application
if __name__ == '__main__':

    # get environment variables
    app_table_name = os.getenv('APP_TABLE_NAME')
    table_name = os.getenv('TABLE_NAME')

    # init session
    # set configs
    spark = SparkSession \
        .builder \
        .appName("dev_app") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio.datalake.svc.cluster.local:9000/") \
        .config("spark.hadoop.fs.s3a.access.key", "T11ZDXNGN4MCJF2PZ393") \
        .config("spark.hadoop.fs.s3a.secret.key", "gvrgSv49v4ZPgBqnOPQFh3iR7rxti+iEC8WOWM10") \
        .config("spark.hadoop.fs.s3a.path.style.access", True) \
        .config("spark.hadoop.fs.s3a.fast.upload", True) \
        .config("spark.hadoop.fs.s3a.multipart.size", 104857600) \
        .config("fs.s3a.connection.maximum", 100) \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.delta.logStore.class", "org.apache.spark.sql.delta.storage.S3SingleDriverLogStore") \
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
        .config("hive.metastore.uris", "thrift://hive-metastore.data-exploration.svc.cluster.local:9083") \
        .config("spark.sql.warehouse.dir", "s3a://hive-metastore/warehouse/") \
        .enableHiveSupport() \
        .getOrCreate()

    # show configured parameters
    print(SparkConf().getAll())

    # set log level
    spark.sparkContext.setLogLevel("INFO")

    schema = spark.sql("select * from bronze.acidentes_antt limit 0").schema
    print(schema)

    df = (
        spark.read.format("parquet")
        .schema(schema)
        .load("s3a://datalake/landing-zone/acidentes_antt/*/*/*/*/")
    )

    df.printSchema()

    df.select("tipo_de_acidente", "tipo_de_ocorrencia").show(10)

    spark.stop()
