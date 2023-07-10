FROM brunneis/python:3.9.0-ubuntu

USER root

RUN apt-get update && apt-get install ffmpeg libsm6 libxext6 sqlite3  -y


RUN pip3 install wheel numpy apache-airflow==2.6.1 apache-airflow-providers-apache-spark opencv-python flask_bcrypt apache-airflow[postgres,docker,password] psycopg2-binary kafka-python

## Install other Airflow dependencies
ENV POSTGRES_USER=test
ENV POSTGRES_PASSWORD=test
ENV POSTGRES_DB=test



## Add files to configure Airflow for production
COPY airflow.cfg /root/airflow/airflow.cfg
COPY entrypoint.sh /root/airflow/
RUN chmod -R 775 /root/airflow/
WORKDIR /root/airflow/
RUN mkdir dags



## Run both webserver and scheduler by default (using supervisord)
RUN pip3 install supervisor
### Create supervisord config
RUN echo "[supervisord]" >> /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "user=airflow" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:webserver]" >> /etc/supervisord.conf && \
    echo "command=/usr/local/bin/airflow webserver" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/dev/stdout" >> /etc/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "stderr_logfile=/dev/stderr" >> /etc/supervisord.conf && \
    echo "stderr_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:scheduler]" >> /etc/supervisord.conf && \
    echo "command=/usr/local/bin/airflow scheduler" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/dev/stdout" >> /etc/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "stderr_logfile=/dev/stderr" >> /etc/supervisord.conf && \
    echo "stderr_logfile_maxbytes=0" >> /etc/supervisord.conf

RUN apt update && apt install -y wget &&  wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz" && \
  mkdir /usr/java  && tar -xf jdk-8u141-linux-x64.tar.gz -C /usr/java


# Set JAVA_HOME
ENV JAVA_HOME /usr/java/jdk1.8.0_141
RUN export JAVA_HOME
RUN export PATH="$PATH:/usr/java/jdk1.8.0_141/bin"

EXPOSE 18080

ENTRYPOINT ["./entrypoint.sh"]


