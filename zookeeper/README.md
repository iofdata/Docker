###  1. 创建 Dockerfile
####  1.1 安装jdk 及 zookeeper
```
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
```

####  1.2 zookeeper 初始化脚本 zk-init.sh
```
#!/bin/bash

MYID=$1
MYIP=$2
ZK=$3
#IPADDRESS=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`
IPADDRESS=$MYIP

cd /tmp/zookeeper

if [ -n "$ZK" ];then
  output=`./bin/zkCli.sh -server $ZK:2181 get /zookeeper/config | grep ^server`
  #echo $output >> /tmp/zookeeper/conf/zoo.cfg.dynamic
  for i in $output; do echo $i >> /tmp/zookeeper/conf/zoo.cfg.dynamic; done
  echo "server.$MYID=$IPADDRESS:2888:3888:observer;2181" >> /tmp/zookeeper/conf/zoo.cfg.dynamic
  cp /tmp/zookeeper/conf/zoo.cfg.dynamic /tmp/zookeeper/conf/zoo.cfg.dynamic.org
  /tmp/zookeeper/bin/zkServer-initialize.sh --force --myid=$MYID
  ZOO_LOG_DIR=/var/log
  ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE'
  /tmp/zookeeper/bin/zkServer.sh start
  /tmp/zookeeper/bin/zkCli.sh -server $ZK:2181 reconfig -add "server.$MYID=$IPADDRESS:2888:3888:participant;2181"
  /tmp/zookeeper/bin/zkServer.sh stop
  ZOO_LOG_DIR=/var/log
  ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE'
  /tmp/zookeeper/bin/zkServer.sh start-foreground
else
  echo "server.$MYID=$IPADDRESS:2888:3888;2181" >> /tmp/zookeeper/conf/zoo.cfg.dynamic
  /tmp/zookeeper/bin/zkServer-initialize.sh --force --myid=$MYID
  ZOO_LOG_DIR=/var/log
  ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE'
  /tmp/zookeeper/bin/zkServer.sh start-foreground
fi
```

### 2. 创建镜像
```
docker build -t peony/zk:2 .
```

### 3. 开启容器
start-zk-2.sh

```
docker rm -f zk01 zk02 zk03
docker run -d --net=net04 --name zk01 --add-host zk01:192.168.4.2 --hostname zk01.mudan.com peony/zk:2 1 192.168.4.2
docker run -d --net=net04 --name zk02 --add-host zk02:192.168.4.3 --hostname zk02.mudan.com peony/zk:2 2 192.168.4.3 192.168.4.2
docker run -d --net=net04 --name zk03 --add-host zk03:192.168.4.4 --hostname zk03.mudan.com peony/zk:2 3 192.168.4.4 192.168.4.2
```