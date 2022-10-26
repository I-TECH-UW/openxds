#
# OpenXDS
#
#

FROM ubuntu:trusty

# Install dependencies
RUN apt-get update && \
apt-get install -y git build-essential curl wget software-properties-common openjdk-7-jre

# Install dockerize
ENV DOCKERIZE_VERSION v0.2.0
RUN curl -L "https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" -o "/tmp/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" \
    && tar -C /usr/local/bin -xzvf "/tmp/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz"

# Install database client
RUN apt-get update && apt-get install -y postgresql-client

# Install OpenXDS
ENV HOME_SHARE="/opt"

RUN mkdir -p "${HOME_SHARE}/openxds/" \
    && curl -L "https://github.com/jembi/openxds/releases/download/v1.1.2/openxds.tar.gz" \
            -o ${HOME_SHARE}/openxds.tar.gz \
    && tar -zxvf ${HOME_SHARE}/openxds.tar.gz -C ${HOME_SHARE}/openxds \
    && rm ${HOME_SHARE}/openxds.tar.gz

ADD openxds-1.1.2.jar ${HOME_SHARE}/openxds/openxds-1.1.2.jar
ADD IheActors.xml ${HOME_SHARE}/openxds/IheActors.xml
ADD openxds.log ${HOME_SHARE}/openxds/openxds.log
ADD repository.jdbc.cfg.xml ${HOME_SHARE}/openxds/repository.jdbc.cfg.xml
ADD omar.properties ${HOME_SHARE}/openxds/omar.properties
ADD openxds.properties ${HOME_SHARE}/openxds/openxds.properties
ADD create_database_schema_log2_postgres.sql ${HOME_SHARE}/openxds/misc/create_database_schema_log2_postgres.sql
RUN rm ${HOME_SHARE}/openxds/misc/create_database_schema_postgres.sql
ADD create_database_schema_postgres.sql ${HOME_SHARE}/openxds/misc/create_database_schema_postgres.sql

# Expose ports
EXPOSE 8010
EXPOSE 8020

RUN cd ${HOME_SHARE}/openxds/
ADD cmd.sh ${HOME_SHARE}/openxds/cmd.sh
RUN chmod +x ${HOME_SHARE}/openxds/cmd.sh

# Run using dockerize
CMD ["dockerize","-wait","tcp://postgresql-openxds:5432","-timeout","100s","/opt/openxds/cmd.sh", "run"]

