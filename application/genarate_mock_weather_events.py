import random as r
import json
from kafka import KafkaProducer
import time
from datetime import datetime as dt



# Define the Kafka Producer configuration
#KAFKA_BOOTSTRAP_SERVERS = ['192.168.8.59:9094']  # Change this if your Kafka Broker is running in a different server
KAFKA_BOOTSTRAP_SERVERS = ['kafka-1:9092']  # Change this if your Kafka Broker is running in a different server
KAFKA_TOPIC_NAME = 'weather_data'
KAFKA_PRODUCER_CONFIG = {
    'bootstrap_servers': KAFKA_BOOTSTRAP_SERVERS
}


def generate_wetaher_data():
    data = {}
    data['process_timestamp'] = str(dt.now())
    data['temperature'] = r.uniform(20.0,25.0)
    data['humidity'] = r.uniform(40.0,45.0)
    data['pressure'] = r.uniform(1000, 1100)
    json_data = json.dumps(data)

    return json_data

def produce_json_message(json_data):

    print("sending message to kafka")

    producer = KafkaProducer(**KAFKA_PRODUCER_CONFIG)
    producer.send(KAFKA_TOPIC_NAME, json_data.encode())

if __name__=='__main__':

    while True:
        msg = generate_wetaher_data()
        print("msg::", msg)
        produce_json_message(msg)
        time.sleep(3)
