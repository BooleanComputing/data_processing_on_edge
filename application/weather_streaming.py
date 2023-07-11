from pyspark.sql import SparkSession
from pyspark.sql.functions import col,avg, from_json, window,to_timestamp,round
from pyspark.sql.types import MapType,StringType,DoubleType
import sys
from datetime import datetime as dt, timedelta
import time


kafaka_bootstrap_servers = sys.argv[1]
kafka_input_topic = sys.argv[2]
kafka_output_topic = sys.argv[3]
dag_run_time= sys.argv[4]

dag_run_time = dag_run_time.split(".")[0]
dag_run_time = dt.strptime(dag_run_time, '%Y-%m-%dT%H:%M:%S')
execution_time = dag_run_time + timedelta(seconds=60 * 2)

checkpoint_dir = "/home/images/checkpoint_weather"
stream_termination_time= 60 * 25

def get_spark():
    spark_session = SparkSession \
        .builder \
        .appName("StructuredImagestreaming") \
        .getOrCreate()

    spark_session.conf.set("spark.sql.streaming.schemaInference", True)
    spark_session.conf.set("spark.sql.streaming.stateStore.stateSchemaCheck", False)

    return spark_session



def wait_for_spark_context(dag_run_time,execution_time):

    while dag_run_time < execution_time:
        print("waiting for execution time")
        time.sleep(1)
        dag_run_time = dt.now()

def avg_values_and_write_to_kafka(df, epoch_id):
    df.printSchema()
    df.show()
    df.write \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafaka_bootstrap_servers) \
    .option("checkpointLocation", checkpoint_dir) \
    .option("topic", kafka_output_topic) \
    .save()

def create_file_stream(spark_session):

    #####CREATE FILE STREAM #############
    df = spark_session.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafaka_bootstrap_servers) \
    .option("subscribe", kafka_input_topic) \
    .option("failOnDataLoss", "false") \
    .load()

    return df

def create_console_write_stream(df):
    #####CREATE WRITE STREAM #############
    df \
     .writeStream \
     .format("console") \
     .option("truncate", False) \
     .queryName("weatherTable") \
     .start() \
     .awaitTermination(stream_termination_time)


def apply_watermark_and_aggregations(df):

    return df.selectExpr("CAST(key AS String)", "CAST(value AS String)") \
     .withColumn("value", from_json("value", MapType(StringType(), StringType()))) \
     .withColumn("temperature", col("value.temperature").cast(DoubleType())) \
     .withColumn("pressure", col("value.pressure").cast(DoubleType())) \
     .withColumn("humidity", col("value.humidity").cast(DoubleType())) \
     .withColumn("timestamp", to_timestamp(col("value.process_timestamp"))) \
     .withWatermark('timestamp', '10 seconds') \
     .groupBy(window('timestamp', "10 seconds")) \
     .agg(
        round(avg("temperature"), 2).alias("avg_temperature"),
        round(avg("humidity"), 2).alias("avg_humidity"),
        round(avg("pressure"), 2).alias("avg_pressure"),
    ) \
    .drop("value")

def create_kafka_write_stream(df):

    df.selectExpr("to_json(struct(*)) AS value")\
     .writeStream \
     .format("kafka") \
     .option("kafka.bootstrap.servers", kafaka_bootstrap_servers) \
     .option("topic", kafka_output_topic) \
     .option("checkpointLocation", checkpoint_dir) \
     .start() \
     .awaitTermination(stream_termination_time)

if __name__=="__main__":
    print("bootstrapping application at", dt.now())
    spark_session = get_spark()
    print("finished bootstrapping application at", dt.now())

    wait_for_spark_context(dag_run_time, execution_time)

    print("creating read stream at", dt.now())
    df = create_file_stream(spark_session)
    print("created read stream at", dt.now())

    print("apply aggregations", dt.now())
    df = apply_watermark_and_aggregations(df)
    print("applied aggregations", dt.now())

    print("creating write stream at", dt.now())
    #create_console_write_stream(df)
    create_kafka_write_stream(df)
    print("terminated write stream at", dt.now())
