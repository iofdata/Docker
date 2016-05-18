# sh mina.sh mina01 dc00.mudan.com 192.168.3.9
# sh mina.sh mina02 dc04.mudan.com 192.168.3.10
# sh mina.sh mina03 dc05.mudan.com 192.168.3.11
# sh mina.sh mina04 dc05.mudan.com 192.168.3.12
# sdocker exec -it mina01 memcached -d -c 10240 -m 1600 -u root
# sdocker exec -it mina02 memcached -d -c 10240 -m 1600 -u root
# sdocker exec -it mina03 memcached -d -c 10240 -m 1600 -u root
# sdocker exec -it mina04 memcached -d -c 10240 -m 1600 -u root

VM_NAME=$1
VM_NODE=$2
VM_IPAD=$3
VM_IMG="registry.mudan.com:5000/peony/mina"
VM_PASS="peony"

docker -H tcp://0.0.0.0:5732 run -it -d \
--env="constraint:node==$VM_NODE" \
--name=$VM_NAME \
--hostname=$VM_NAME \
--net=pro \
--ip=$VM_IPAD \
--memory="1g" \
--cpu-shares=1 \
--env MEMCACHED_PASS=$VM_PASS \
$VM_IMG
