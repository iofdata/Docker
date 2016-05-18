# sh mq.sh mq-ns-01 dc00.mudan.com 192.168.3.2
# sh mq.sh mq-bm-02 dc04.mudan.com 192.168.3.3
# sh mq.sh mq-bm-03 dc04.mudan.com 192.168.3.4
# sh mq.sh mq-bs-04 dc05.mudan.com 192.168.3.5
# sh mq.sh mq-bs-05 dc05.mudan.com 192.168.3.6

VM_NAME=$1
VM_NODE=$2
VM_IPAD=$3
VM_IMG="registry.mudan.com:5000/peony/mq"

docker -H tcp://0.0.0.0:5732 run -it -d \
--env="constraint:node==$VM_NODE" \
--name=$VM_NAME \
--hostname=$VM_NAME \
--net=pro \
--ip=$VM_IPAD \
--memory="2g" \
--cpu-shares=1 \
$VM_IMG
