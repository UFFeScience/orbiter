FROM quay.io/strimzi/kafka:0.28.0-kafka-3.1.0
USER root:root
COPY ./connectors/jars/ /opt/kafka/plugins/
COPY ./connectors/data/ /opt/data/
USER 1001