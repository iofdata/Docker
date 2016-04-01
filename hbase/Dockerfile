# Hbase image
# docker build -t registry.mudan.com:5000/peony/hbase .

FROM registry.mudan.com:5000/peony/centos-7-supervisord
MAINTAINER tanhao <tanhao2013@foxmail.com>

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

# passwordless ssh
RUN cd ~/.ssh && cat id_rsa.pub >> authorized_keys && chmod 600  authorized_keys

# hbase
#RUN wget http://archive.apache.org/dist/hbase/1.2.0/hbase-1.2.0-bin.tar.gz \
RUN wget http://119.254.110.32:8081/download/hbase-1.2.0-bin.tar.gz \
    && tar -xvzf hbase-1.2.0-bin.tar.gz \
    && mv hbase-1.2.0 /usr/local/ \
    && rm -rf hbase-1.2.0-bin.tar.gz
RUN cd /usr/local && ln -s ./hbase-1.2.0 hbase

ENV HBASE_PREFIX /usr/local/hbase
ENV HBASE_HOME /usr/local/hbase

WORKDIR /usr/local/hbase

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/share/jdk1.7.0_60\nexport HBASE_PREFIX=/usr/local/hbase\nexport HBASE_HOME=/usr/local/hbase\n:' $HBASE_PREFIX/conf/hbase-env.sh
RUN sed -i '/^export HBASE_MANAGES_ZK/ s:.*:export HBASE_MANAGES_ZK=false:' $HBASE_PREFIX/conf/hbase-env.sh
RUN chmod +x $HBASE_PREFIX/conf/*-env.sh
#export HBASE_MANAGES_ZK=false
#export HBASE_HEAPSIZE=7000
#export HBASE_OPTS="-XX:+UseConcMarkSweepGC"
#RUN mkdir -p /mnt/hadoop/dfs/name && mkdir -p /mnt/hadoop/dfs/data && mkdir -p /mnt/hadoop/journal/data

ADD core-site.xml.template  $HBASE_PREFIX/conf/core-site.xml.template
ADD hdfs-site.xml.template  $HBASE_PREFIX/conf/hdfs-site.xml.template
ADD hbase-site.xml.template $HBASE_PREFIX/conf/hbase-site.xml.template
ADD bootstrap.sh $HBASE_PREFIX/bootstrap.sh
RUN chown root:root $HBASE_PREFIX/bootstrap.sh && chmod a+x $HBASE_PREFIX/bootstrap.sh
RUN $HBASE_PREFIX/bootstrap.sh

#CMD ["/etc/bootstrap.sh", "-d"]

# hbase.master.port 16000
EXPOSE 60000
# hbase.master.info.port 16010
EXPOSE 60010
# hbase.regionserver.port 16020
EXPOSE 60020
# hbase.regionserver.info.port 16030
EXPOSE 60030
# hbase.rest.port
EXPOSE 8080
