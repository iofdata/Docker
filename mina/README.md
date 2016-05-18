
### Dockerfile
```
# docker build -t registry.mudan.com:5000/peony/mina .

FROM registry.mudan.com:5000/peony/centos-7
MAINTAINER tanhao <tanhao2013@foxmail.com>

WORKDIR /usr/local/

RUN yum makecache fast
RUN yum install -y wget gcc make which
# java
RUN yum install -y wget which rsync less jq vim
ENV USER root
RUN wget http://119.254.110.32:8081/download/jdk1.7.0_60.tar.gz \
   && tar -xvzf jdk1.7.0_60.tar.gz \
   && mv jdk1.7.0_60 /usr/share/ \
   && rm -rf jdk1.7.0_60.tar.gz

RUN echo 'export JAVA_HOME=/usr/share/jdk1.7.0_60' >>  ~/.bashrc
RUN echo 'export PATH=$JAVA_HOME/bin:$PATH ' >> ~/.bashrc
RUN echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar ' >> ~/.bashrc
RUN source  ~/.bashrc

ENV JAVA_HOME /usr/share/jdk1.7.0_60

# install memcached
RUN wget http://119.254.110.32:8081/download/mina.tar.gz \
    && tar -xvzf mina.tar.gz && rm -f mina.tar.gz

#ADD run.sh /run.sh
#RUN chmod 755 /*.sh

WORKDIR /root/peony/batch/mina/classes

EXPOSE 9999
CMD ["./startServer.sh"]
```

### start

```
ssh 192.168.1.200
cd /root/devops/mem
# 启动容器
sh mina.sh mina01 dc00.mudan.com 192.168.3.9
sh mina.sh mina02 dc04.mudan.com 192.168.3.10
sh mina.sh mina03 dc05.mudan.com 192.168.3.11
sh mina.sh mina04 dc05.mudan.com 192.168.3.12
# 启动mina
sdocker exec -it mina01 bash
cd /root/peony/batch/mina/classes && sh startServer.sh

sdocker exec -it mina02 bash
cd /root/peony/batch/mina/classes && sh startServer.sh

sdocker exec -it mina03 bash
cd /root/peony/batch/mina/classes && sh startServer.sh

sdocker exec -it mina04 bash
cd /root/peony/batch/mina/classes && sh startServer.sh
```