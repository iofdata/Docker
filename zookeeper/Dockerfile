# 安装jdk 及 zookeeper
# docker build -t peony/zk:2 .
FROM ubuntu

RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update
RUN apt-get -y install wget bash vim git ant && apt-get clean

RUN wget http://119.254.110.32:8081/download/jdk1.7.0_60.tar.gz \
   && tar -xvzf  jdk1.7.0_60.tar.gz \
   && mv jdk1.7.0_60 /usr/share/ \
   && rm -rf /usr/lib/jvm/java-1.7-openjdk \
   && mkdir -p /usr/lib/jvm/ \
   && ln -s /usr/share/jdk1.7.0_60 /usr/lib/jvm/java-1.7-openjdk \
   && rm -rf jdk1.7.0_60.tar.gz

ENV JAVA_HOME /usr/lib/jvm/java-1.7-openjdk/

RUN apt-get -y install git ant && apt-get clean

RUN mkdir /tmp/zookeeper
WORKDIR /tmp/zookeeper
RUN git clone https://github.com/apache/zookeeper.git .
RUN git checkout release-3.5.1-rc2
RUN ant jar
RUN cp /tmp/zookeeper/conf/zoo_sample.cfg /tmp/zookeeper/conf/zoo.cfg
RUN echo "standaloneEnabled=false" >> /tmp/zookeeper/conf/zoo.cfg
RUN echo "dynamicConfigFile=/tmp/zookeeper/conf/zoo.cfg.dynamic" >> /tmp/zookeeper/conf/zoo.cfg
ADD zk-init.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/zk-init.sh"]
