FROM openjdk:8u121-jre-alpine

ENV KAFKA_VERSION=0.10.2.0 KAFKA_SCALA_VERSION=2.11 JMX_PORT=7203
ENV KAFKA_RELEASE_ARCHIVE kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

# Download Kafka binary distribution
RUN mkdir /kafka /kafka/data /kafka/logs && \
    apk --no-cache add bash curl && \
    curl -sS http://www.us.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE} | \
    tar -zxf - -C /kafka && \
    mv /kafka/kafka_* /kafka/dist && \
    apk --no-cache del curl

COPY config /kafka/dist/config
COPY start.sh /start.sh

# Set up a user to run Kafka
RUN addgroup kafka && \
    adduser -h /kafka -s /sbin/nologin -G kafka kafka -S -D -H && \
    chown -R kafka:kafka /kafka
USER kafka
ENV PATH /kafka/dist/bin:$PATH
WORKDIR /kafka/dist

# broker, jmx
EXPOSE 9092 ${JMX_PORT}
VOLUME [ "/kafka/data", "/kafka/logs" ]

CMD ["/start.sh"]

