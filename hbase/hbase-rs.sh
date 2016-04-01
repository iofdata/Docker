# sh hbase-rs.sh hbase-rs1 dc03.mudan.com
# sh hbase-rs.sh hbase-rs2 dc02.mudan.com
# sh hbase-rs.sh hbase-rs3 dc03.mudan.com
VM_NAME=$1
VM_NODE=$2
VM_IMG="registry.mudan.com:5000/peony/hbase"
#HD_NAME="hd01-"${VM_NAME}

docker -H tcp://0.0.0.0:5732 run -it -d \
--env="constraint:node==$VM_NODE" \
--name=$VM_NAME \
--hostname=$VM_NAME \
--net=net04 \
$VM_IMG
#/etc/bootstrap.sh
