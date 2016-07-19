# Builds an image for Apache Kafka 0.8.1.1 from binary distribution.
#
# The netflixoss/java base image runs Oracle Java 7 installed atop the
# ubuntu:trusty (14.04) official image. Docker's official java images are
# OpenJDK-only currently, and the Kafka project, Confluent, and most other
# major Java projects test and recommend Oracle Java for production for optimal
# performance.

FROM alpine:3.4

RUN apk --no-cache add bash openjdk7-jre

# The Scala 2.11 build is currently recommended by the project.
ENV KAFKA_VERSION=0.10.0.0 KAFKA_SCALA_VERSION=2.11 JMX_PORT=7203
ENV KAFKA_RELEASE_ARCHIVE kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN mkdir /kafka /kafka/data /kafka/logs

# Download Kafka binary distribution
RUN apk --no-cache add curl && \
  curl -sS http://www.us.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE} | \
  tar -zxf - -C /kafka && \
  mv /kafka/kafka_* /kafka/dist && \
  apk --no-cache del curl

ADD config /kafka/dist/config
ADD start.sh /start.sh

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
