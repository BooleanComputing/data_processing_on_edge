#!/usr/bin/env bash

echo "Delete Airflow cluster"
docker stack rm airflow-cluster

echo "Delete Spark cluster"
docker stack rm spark-cluster

echo "Delete Kafka cluster"
docker stack rm kafka-cluster

echo "Remove overlay network"
docker network remove data-stream

echo "Leave Swarm mode"
docker swarm leave -f

echo "Delete mount directory"
rm -r /mnt