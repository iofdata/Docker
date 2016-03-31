# sh dn.sh hadoop-dn1 dc00.mudan.com 192.168.4.12
# sh dn.sh hadoop-dn2 dc04.mudan.com 192.168.4.13
# sh dn.sh hadoop-dn3 dc05.mudan.com 192.168.4.14

VM_NAME=$1
VM_NODE=$2
VM_IPAD=$3
VM_IMG="registry.mudan.com:5000/peony/hadoop:latest"
TO_DIR="/mnt/hadoop/dfs/data"
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
