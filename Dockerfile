FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

#Runit
RUN apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#SSHD
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'root:root' |chpasswd
RUN sed -i "s/session.*required.*pam_loginuid.so/#session    required     pam_loginuid.so/" /etc/pam.d/sshd
RUN sed -i "s/PermitRootLogin without-password/#PermitRootLogin without-password/" /etc/ssh/sshd_config

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

#Install Oracle Java 7
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

#Zookeeper
RUN curl http://www.us.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar xz
RUN mv zookeeper* zookeeper
RUN cd zookeeper && cp conf/zoo_sample.cfg conf/zoo.cfg

#Kafka
RUN curl http://www.us.apache.org/dist/kafka/0.8.1.1/kafka_2.10-0.8.1.1.tgz | tar xz
RUN mv kafka* kafka

#Play
RUN wget http://downloads.typesafe.com/play/2.2.3/play-2.2.3.zip && \
    unzip play*
RUN rm play*zip && mv play* play

#Web console
RUN curl -L https://github.com/claudemamo/kafka-web-console/archive/v2.0.0.tar.gz | tar xz
RUN mv kafka-web-console-* kafka-web-console
RUN cd kafka-web-console && /play/play stage 

#Add runit services
ADD sv /etc/service 

