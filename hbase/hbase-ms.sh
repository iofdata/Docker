# sh hbase-ms.sh hbase-ms1 dc03.mudan.com
# sh hbase-ms.sh hbase-ms2 dc02.mudan.com
VM_NAME=$1
VM_NODE=$2
VM_IMG="registry.mudan.com:5000/peony/hbase"
#HD_NAME="hd01-"${VM_NAME}

docker -H tcp://0.0.0.0:5732 run -it -d \
--env="constraint:node==$VM_NODE" \
--name=$VM_NAME \
--hostname=$VM_NAME \
--net=net04 \
-p 60010:60010 -p 8080:8080 -p 60000:60000 \
$VM_IMG
#/etc/bootstrap.sh
