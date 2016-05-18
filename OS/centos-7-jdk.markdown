### Dockerfile

```
# JDK image
# docker build -t registry.mudan.com:5000/peony/centos-7-jdk .
# docker push registry.mudan.com:5000/peony/centos-7-jdk
# docker pull registry.mudan.com:5000/peony/centos-7-jdk

FROM registry.mudan.com:5000/peony/centos-7
MAINTAINER tanhao <tanhao2013@foxmail.com>

# java
RUN yum install -y wget curl jq bash vim
RUN wget http://119.254.110.32:8081/download/jdk1.7.0_60.tar.gz \
   && tar -xvzf jdk1.7.0_60.tar.gz \
   && mv jdk1.7.0_60 /usr/share/ \
   && rm -rf jdk1.7.0_60.tar.gz

RUN /usr/bin/ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

RUN echo 'export JAVA_HOME=/usr/share/jdk1.7.0_60' >>  ~/.bashrc
RUN echo 'export PATH=$JAVA_HOME/bin:$PATH ' >> ~/.bashrc
RUN echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar ' >> ~/.bashrc
RUN source  ~/.bashrc

ENV JAVA_HOME /usr/share/jdk1.7.0_60
```