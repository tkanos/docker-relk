FROM ubuntu:latest
MAINTAINER Felipe.dutratineesilva <fdutratine@gmail.com>

WORKDIR /opt

# Prerequisites

## Upgrade ubuntu to latest
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -q update
RUN apt-get -yq upgrade
## Install wget
RUN apt-get install -yq wget
## Install Software Properties Common to use add-apt-repository command
RUN apt-get -yq install software-properties-common

## Add ELK key to ubuntu repository
RUN wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
## Add Elastic Search Repository to Ubuntu
RUN add-apt-repository "deb http://packages.elastic.co/elasticsearch/1.7/debian stable main"
## Add Log Stash Repository to Ubuntu
RUN add-apt-repository "deb http://packages.elasticsearch.org/logstash/1.5/debian stable main"
## Add Oracle Java 8 Repository to Ubuntu
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN add-apt-repository -y ppa:webupd8team/java

## Update after changing the sources list
RUN apt-get -q update

## Install Oracle Java 8
RUN apt-get -yq install oracle-java8-installer
## Set JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Installing the ELK stack

# Install Redis
RUN apt-get -yq install redis-server
# Redis configuration
RUN sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf

# Install ElasticSearch
RUN apt-get -yq install elasticsearch
## Configuring Elastic Search
### Add cluster name and Add node name
RUN sed -i 's/#cluster.name: elasticsearch/cluster.name: elasticsearch/g' /etc/elasticsearch/elasticsearch.yml
RUN sed -i 's/#node.name: "Franz Kafka"/node.name: "logstash"/g' /etc/elasticsearch/elasticsearch.yml
### Allow Kibana to connect to Elastic Search
RUN echo 'http.cors.allow-origin: "/.*/"' | tee -a /etc/elasticsearch/elasticsearch.yml
RUN echo 'http.cors.enabled: true' | tee -a /etc/elasticsearch/elasticsearch.yml
### Move elastic search configurations to the right place
RUN mkdir /usr/share/elasticsearch/config
RUN cp /etc/elasticsearch/*.yml /usr/share/elasticsearch/config

# Install LogStash
RUN apt-get -yq install logstash
## Configuring LogStash
### Indexer configuration
ADD ./logstash/logstash-indexer.conf /etc/logstash/conf.d/logstash-indexer.conf

# Install Kibana4
RUN wget -P /opt/ https://download.elasticsearch.org/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz
RUN tar xvf /opt/kibana-*.tar.gz -C /opt/
RUN rm /opt/kibana-*.tar.gz
RUN mv /opt/kibana-* /etc/kibana

# Install Supervisor
RUN apt-get -yq install supervisor software-properties-common
ADD ./supervisor/elasticsearch.conf /etc/supervisor/conf.d/
ADD ./supervisor/logstash.conf /etc/supervisor/conf.d/
ADD ./supervisor/kibana.conf /etc/supervisor/conf.d/
ADD ./supervisor/redis.conf /etc/supervisor/conf.d/

# Remove unwanted applications & Clean Installations
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Exposing Redis Server Port, Kibana Port and SYSLOG Port
EXPOSE 6379
EXPOSE 5601 
EXPOSE 9200

# Start supervisor
CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
