# docker build -t registry.mudan.com:5000/peony/mq .

FROM registry.mudan.com:5000/peony/centos-7
MAINTAINER tanhao <tanhao2013@foxmail.com>

WORKDIR /usr/local/

RUN yum makecache fast
RUN yum install -y wget gcc make which git dos2unix unix2dos
# java
RUN yum install -y wget which rsync less jq vim
ENV USER root
# wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u15-b03/jdk-7u15-linux-x64.tar.gz
RUN wget http://119.254.110.32:8081/download/jdk-7u15-linux-x64.tar.gz \
   && tar -xvzf jdk-7u15-linux-x64.tar.gz \
   && mv jdk1.7.0_15 /usr/share/ \
   && rm -rf jdk-7u15-linux-x64.tar.gz

# wget http://apache.opencas.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
RUN wget http://119.254.110.32:8081/download/apache-maven-3.3.9-bin.tar.gz \
  && tar -xvzf apache-maven-3.3.9-bin.tar.gz \
  && ln -s apache-maven-3.3.9 /usr/local/maven3 \
  && rm -rf apache-maven-3.3.9-bin.tar.gz

RUN echo 'export JAVA_HOME=/usr/share/jdk1.7.0_15' >>  /etc/profile
RUN echo 'export JRE_HOME=/usr/share/jdk1.7.0_15/jre' >>  /etc/profile
RUN echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH' >> /etc/profile
RUN echo 'export M2_HOME=/usr/local/maven3' >>  /etc/profile
RUN echo 'export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH' >>  /etc/profile
RUN source  /etc/profile

ENV JAVA_HOME /usr/share/jdk1.7.0_15

#wget https://github.com/alibaba/RocketMQ/releases/download/v3.2.6/alibaba-rocketmq-3.2.6.tar.gz
RUN wget http://119.254.110.32:8081/download/alibaba-rocketmq-3.2.6.tar.gz \
        && tar -xvzf alibaba-rocketmq-3.2.6.tar.gz \
        && cd alibaba-rocketmq/bin \
        && dos2unix * \
        && cd /usr/local/ \
        && rm -rf alibaba-rocketmq-3.2.6.tar.gz

WORKDIR /usr/local/alibaba-rocketmq/

EXPOSE 9876
EXPOSE 10911
EXPOSE 10912
