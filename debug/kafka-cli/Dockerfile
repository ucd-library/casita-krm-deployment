FROM azul/zulu-openjdk-alpine:11-jre
MAINTAINER Justin Merz <jrmerz@ucdavis.edu>

ENV KAFKA_VERSION=2.7.0
ENV KAFKA_URL=https://mirrors.ocf.berkeley.edu/apache/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz
# ENV KAFKA_URL=https://www-eu.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz
ENV KAFKA_TEMP_FILE=/opt/kafka.tgz
ENV KAFKA_WORKDIR=/opt/kafka

RUN apk update && apk add bash && rm -rf /var/cache/apk/*
RUN wget ${KAFKA_URL} -O ${KAFKA_TEMP_FILE}
RUN mkdir -p ${KAFKA_WORKDIR} 
RUN tar -xzpf ${KAFKA_TEMP_FILE} --strip-components=1 -C ${KAFKA_WORKDIR}
RUN rm ${KAFKA_TEMP_FILE}
RUN rm -rf ${KAFKA_WORKDIR}/bin/windows

ENV PATH ${PATH}:/opt/kafka/bin

CMD sh -c 'tail -f /dev/null'