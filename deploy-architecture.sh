#!/usr/bin/env bash


#Initialize single node docker swarm cluster
docker swarm init

#Create overlay network
docker network create -d overlay --scope=swarm data-stream

#Create local volumes for data persistence
mkdir -p /mnt/airflow/dags /mnt/airflow/logs /mnt/airflow/config /mnt/airflow/plugins /mnt/airflow/scripts /mnt/data /mnt/kafka-1-data
chmod -R 775 /mnt

cp airflow/spark_jars/ /mnt/airflow/scripts/spark_jars/

wget https://dlcdn.apache.org/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz
tar -xvf spark-3.4.1-bin-hadoop3.tgz
mv spark-3.4.1-bin-hadoop3 /mnt/airflow/scripts/spark
rm spark-3.4.1-bin-hadoop3.tgz


cp airflow/dags/* /mnt/airflow/dags/
cp application/*  /mnt/airflow/scripts/

#Bring up Airflow cluster as a Docker Swarm Service
cd airflow && cp airflow/spark_jars/ /mnt/airflow/scripts/spark_jars/ && sudo docker stack deploy -c docker-compose.yml  airflow-cluster

#Bring up Spark cluster as a Docker Swarm Service
cd ../spark && sudo docker stack deploy -c docker-compose.yml spark-cluster

#Bring up Kafka cluster as a Docker Swarm Service
cd ../kafka && sudo docker stack deploy -c docker-compose.yml kafka-cluster


#airflow ui: http://<host>:8080

#spark history server: http://<host>:5000

#spark connect server: http://<host>:4040

#Kafka UI: http://localhost:5001