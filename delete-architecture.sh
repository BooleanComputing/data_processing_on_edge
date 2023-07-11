#!/usr/bin/env bash

docker stack rm airflow-cluster

docker stack rm spark-cluster

docker stack rm kafka-cluster

docker network remove data-stream

docker swarm leave -f
rm -r /mnt