#!/usr/bin/env bash

docker swarm leave

#Initialize single node docker swarm cluster
docker swarm init

docker network remove  data-stream
#Create overlay network
docker network create -d overlay --scope=swarm data-stream

#Create local volumes for data persistence
mkdir -p /mnt/airflow/dags /mnt/airflow/logs /mnt/airflow/config /mnt/airflow/plugins /mnt/airflow/scripts /mnt/data /mnt/kafka-1-data

cp airflow/dags/* /mnt/airflow/dags/
cp application/*  /mnt/airflow/scripts/

#Bring up Airflow cluster as a Docker Swarm Service
cd airflow/swarm && sudo docker stack deploy -c docker-compose-swarm-uber.yml  airflow-cluster

#Bring up Spark cluster as a Docker Swarm Service
cd spark && sudo docker stack deploy -c docker-compose-swarm.yml spark-cluster

#Bring up Kafka cluster as a Docker Swarm Service
cd kafka && sudo docker stack deploy -c docker-compose_no_ssl_swarm.yml kafka-cluster


#airflow ui: http://<host>:8080

#spark history server: http://<host>:5000

#spark connect server: http://<host>:4040

#Kafka UI: http://localhost:5001