# sh mem.sh mem01 dc00.mudan.com 192.168.3.7
# sh mem.sh mem02 dc04.mudan.com 192.168.3.8
# sh mem.sh mem03 dc05.mudan.com 192.168.3.13
# sh mem.sh mem04 dc05.mudan.com 192.168.3.14
# sdocker exec -it mem01 memcached -d -c 10240 -m 1600 -u root
# sdocker exec -it mem02 memcached -d -c 10240 -m 1600 -u root
# sdocker exec -it mem03 memcached -d -c 10240 -m 1600 -u root
# sdocker exec -it mem04 memcached -d -c 10240 -m 1600 -u root


VM_NAME=$1
VM_NODE=$2
VM_IPAD=$3
VM_IMG="registry.mudan.com:5000/peony/memcached"
VM_PASS="peony"

docker -H tcp://0.0.0.0:5732 run -it -d \
--env="constraint:node==$VM_NODE" \
--name=$VM_NAME \
--hostname=$VM_NAME \
--net=pro \
--ip=$VM_IPAD \
--memory="2g" \
--cpu-shares=1 \
--env MEMCACHED_PASS=$VM_PASS \
$VM_IMG
