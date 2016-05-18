# Dockerfile
# docker build -t registry.mudan.com:5000/peony/memcached:2 .

FROM registry.mudan.com:5000/peony/centos-7
MAINTAINER tanhao <tanhao2013@foxmail.com>

WORKDIR /usr/local/

RUN yum makecache fast
RUN yum install -y wget gcc make which

# install memcached
RUN wget http://119.254.110.32:8081/download/libevent-2.0.21-stable.tar.gz \
    && tar -xvzf libevent-2.0.21-stable.tar.gz
RUN cd libevent-2.0.21-stable && ./configure && make && make install && cd ../ \
    && rm -rf libevent-2.0.21*
#wget http://rpm.pbone.net/index.php3/stat/26/dist/94/size/862345/name/libevent-2.0.21-4.el7.src.rpm
#wget ftp://ftp.ntua.gr/pub/linux/centos/7.2.1511/os/x86_64/Packages/libevent-devel-2.0.21-4.el7.i686.rpm
#RUN wget http://119.254.110.32:8081/download/libevent-2.0.21-4.el7.src.rpm
#RUN wget http://119.254.110.32:8081/download/libevent-devel-2.0.21-4.el7.i686.rpm
#RUN yum install -y libevent-2.0.21-4.el7.src.rpm libevent-devel-2.0.21-4.el7.i686.rpm
#RUN wget http://119.254.110.32:8081/download/memcached-1.4.15-9.el7.x86_64.rpm
#RUN yum install -y memcached-1.4.15-9.el7.x86_64.rpm
RUN yum clean all
#ftp://195.220.108.108/linux/centos/7.2.1511/os/x86_64/Packages/memcached-1.4.15-9.el7.x86_64.rpm
RUN wget http://119.254.110.32:8081/download/memcached-1.4.20.tar.gz \
    && tar -xvzf memcached-1.4.20.tar.gz \
    && cd memcached-1.4.20 && ./configure && make && make install && cd ../ \
    && rm -rf memcached-1.4.2*

RUN ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5

ADD run.sh /run.sh
RUN chmod 755 /*.sh

EXPOSE 11211

CMD ["/run.sh"]
