# sh redis.sh redis dc00.mudan.com 192.168.3.151

VM_NAME=$1
VM_NODE=$2
VM_IPAD=$3
VM_IMG="registry.mudan.com:5000/peony/redis"
HD_NAME="hd01-"${VM_NAME}

docker -H tcp://0.0.0.0:5732 create --env="constraint:node==$VM_NODE" --name $HD_NAME -v /data $VM_IMG /bin/true

docker -H tcp://0.0.0.0:5732 run -it -d \
--env="constraint:node==$VM_NODE" \
--name=$VM_NAME \
--hostname=$VM_NAME \
--volumes-from $HD_NAME \
--net=pro \
--ip=$VM_IPAD \
--memory="2g" \
--cpu-shares=1 \
$VM_IMG redis-server --appendonly yes
