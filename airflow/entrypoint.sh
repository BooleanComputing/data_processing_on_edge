#!/usr/bin/env bash


# Configure database (assuming it is already setup & reachable)
/usr/local/bin/airflow db init && \
/usr/local/bin/airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin && \
#python3 add_superuser.py && \
/usr/local/bin/supervisord -c /etc/supervisord.conf