# sh nn.sh hadoop-nn1 dc00.mudan.com 192.168.4.7
# sh nn.sh hadoop-nn2 dc04.mudan.com 192.168.4.8

VM_NAME=$1
VM_NODE=$2
VM_IPAD=$3
VM_IMG="registry.mudan.com:5000/peony/hadoop:latest"
TO_DIR="/mnt/hadoop/dfs/name"
HD_NAME="hd01-"${VM_NAME}

docker -H tcp://0.0.0.0:5732 create --env="constraint:node==$VM_NODE" --name $HD_NAME -v $TO_DIR $VM_IMG /bin/true

docker -H tcp://0.0.0.0:5732 run -it -d \
--env="constraint:node==$VM_NODE" \
--name=$VM_NAME \
--hostname=$VM_NAME \
--net=pro \
--volumes-from $HD_NAME \
--ip=$VM_IPAD \
--memory="500m" \
--cpu-shares=1 \
$VM_IMG
