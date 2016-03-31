# Hadoop image
# docker build -t registry.mudan.com:5000/peony/hadoop .

FROM registry.mudan.com:5000/peony/centos-7-supervisord
MAINTAINER tanhao <tanhao2013@foxmail.com>

# java
RUN yum install -y wget which install less jq
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

ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

# hadoop
RUN wget http://119.254.110.32:8081/download/hadoop-2.5.2.tar.gz \
    && tar -xvzf hadoop-2.5.2.tar.gz \
    && mv hadoop-2.5.2 /usr/local/ \
    && rm -rf hadoop-2.5.2.tar.gz
RUN cd /usr/local && ln -s ./hadoop-2.5.2 hadoop

WORKDIR /usr/local/hadoop

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/share/jdk1.7.0_60\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh

RUN mkdir -p /mnt/hadoop/dfs/name && mkdir -p /mnt/hadoop/dfs/data && mkdir -p /mnt/hadoop/journal/data

ADD core-site.xml.template /usr/local/hadoop/etc/hadoop/core-site.xml.template
ADD hdfs-site.xml.template /usr/local/hadoop/etc/hadoop/hdfs-site.xml.template

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && chmod a+x /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]

# NameNode                Secondary NameNode  DataNode                     JournalNode  NFS Gateway    HttpFS         ZKFC
EXPOSE 8020 50070 50470   50090 50495         50010 1004 50075 1006 50020  8485 8480    2049 4242 111  14000 14001    8019

#Other ports
#EXPOSE 49707 2122
