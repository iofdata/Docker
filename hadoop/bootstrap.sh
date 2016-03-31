: ${HADOOP_PREFIX:=/usr/local/hadoop};

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

if [ -z $CLUSTER_NAME ]; then
  CLUSTER_NAME="cluster"
  export CLUSTER_NAME
fi

#NNODE1_IP="hadoop-nn1"
#NNODE2_IP="hadoop-nn2"
#JN_IPS="hadoop-jn1:8485,hadoop-jn2:8485,hadoop-jn3:8485"
#ZK_IPS="zk01:2181,zk02:2181,zk03:2181,zk04:2181,zk05:2181"

if [ -z $NNODE1_IP ] || [ -z $NNODE2_IP ]  || [ -z $ZK_IPS ] || [ -z $JN_IPS ]; then
  echo NNODE1_IP, NNODE2_IP, JN_IPS and ZK_IPS needs to be set as environment addresses to be able to run.
  #exit;
fi

if [ -z $NNODE1_IP ]; then
  NNODE1_IP="hadoop-nn1"
  export NNODE1_IP
fi

if [ -z $NNODE2_IP ]; then
  NNODE2_IP="hadoop-nn2"
  export NNODE2_IP
fi

if [ -z $JN_IPS ]; then
  JN_IPS="hadoop-jn1:8485,hadoop-jn2:8485,hadoop-jn3:8485"
  export JN_IPS
fi

if [ -z $ZK_IPS ]; then
	ZK_IPS="zk01:2181,zk02:2181,zk03:2181,zk04:2181,zk05:2181"
	export ZK_IPS
fi

JNODES=$(echo $JN_IPS | tr "," ";")

sed "s/CLUSTER_NAME/$CLUSTER_NAME/" /usr/local/hadoop/etc/hadoop/hdfs-site.xml.template \
| sed "s/NNODE1_IP/$NNODE1_IP/" \
| sed "s/NNODE2_IP/$NNODE2_IP/" \
| sed "s/ZKNODES/$ZK_IPS/" \
| sed "s/JNODES/$JNODES/" \
> /usr/local/hadoop/etc/hadoop/hdfs-site.xml

sed "s/CLUSTER_NAME/$CLUSTER_NAME/" /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

echo CLUSTER_NAME=$CLUSTER_NAME NNODE1_IP=$NNODE1_IP NNODE2_IP=$NNODE2_IP JNODES=$JNODES ZK_IPS=$ZK_IPS
