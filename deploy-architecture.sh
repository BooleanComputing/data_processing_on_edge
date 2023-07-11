#!/usr/bin/env bash


echo "Initialize docker swarm cluster"
docker swarm init

echo "Create overlay network"
docker network create -d overlay --scope=swarm data-stream

echo "Create local dir for data persistence"
mkdir -p /mnt/airflow/dags /mnt/airflow/logs /mnt/airflow/config /mnt/airflow/plugins /mnt/airflow/scripts /mnt/data /mnt/kafka-1-data /mnt/spark_checkpoint/
chmod -R 775 /mnt


echo "Download Apache Spark binaries"
wget https://dlcdn.apache.org/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz
tar -xvf spark-3.4.1-bin-hadoop3.tgz
mv spark-3.4.1-bin-hadoop3 /mnt/airflow/scripts/spark
rm spark-3.4.1-bin-hadoop3.tgz


echo "Copy additional Spark jars"
cp airflow/spark_jars/ /mnt/airflow/scripts/spark_jars/
cp airflow/dags/* /mnt/airflow/dags/
cp application/*  /mnt/airflow/scripts/

echo "Bootstrap Airflow cluster as a Docker Swarm Service"

cd airflow && sudo docker stack deploy -c docker-compose.yml  airflow-cluster
chmod -R 775 /mnt/airflow/scripts/spark_jars/

echo "Bootstrap Spark cluster as a Docker Swarm Service"
cd ../spark && sudo docker stack deploy -c docker-compose.yml spark-cluster

echo "Bootstrap Kafka cluster as a Docker Swarm Service"
cd ../kafka && sudo docker stack deploy -c docker-compose.yml kafka-cluster


# Web UI URL's for tthe services

#airflow ui: http://<host>:8080

#spark history server: http://<host>:5000

#spark connect server: http://<host>:4040

#Kafka UI: http://localhost:5001
