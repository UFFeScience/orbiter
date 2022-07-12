FROM gcr.io/spark-operator/spark-py:v3.1.1-hadoop3

USER root:root

RUN mkdir -p /app

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir delta-spark

COPY bronze_layer_app.py /app/

COPY ./jars/ /opt/spark/jars

WORKDIR /app

USER 1001