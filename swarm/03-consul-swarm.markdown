### 3.1 consul
```
# 下载consul
mkdir -p /usr/local/consul
wget https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip
unzip consul_0.6.3_linux_amd64.zip
cp consul /usr/bin/
mv consul /usr/local/consul
cd /usr/local/consul

# 准备启动脚本start.sh
#IP=$(ifconfig |grep "192.168"|cut -d ":" -f 2|cut -d " " -f 1)
IP=$(ifconfig |grep "192.168" |cut -d "n" -f 2|cut -d " " -f 2)
rm -rf /usr/local/consul/data
# on master (dc00)
nohup /usr/bin/consul agent -server -bootstrap-expect 1 -data-dir /usr/local/consul/data -node=$HOSTNAME -bind=$IP -client $IP -ui-dir ./dist >consul.log &
#/usr/bin/consul agent -server -bootstrap-expect 1 -data-dir /usr/local/consul/data -node=dc00.mudan.com -bind=192.168.1.200 -client 192.168.1.200 -ui-dir ./dist
# on client (其他节点)
nohup /usr/local/consul/consul agent -server -data-dir /usr/local/consul/data -node=$HOSTNAME -bind=$IP -client $IP >consul.log &
#/usr/local/consul/consul agent -server -data-dir /usr/local/consul/data -node=dc04.mudan.com -bind=192.168.1.204 -client 192.168.1.204

# 准备加入脚本join.sh (任意节点，只运行一次，新加节点运行对应条目即可)
/usr/bin/consul join -rpc-addr=192.168.1.200:8400 192.168.1.200
/usr/bin/consul join -rpc-addr=192.168.1.200:8400 192.168.1.204
/usr/bin/consul join -rpc-addr=192.168.1.200:8400 192.168.1.205
/usr/bin/consul join -rpc-addr=192.168.1.200:8400 192.168.1.206

# 查询状态
/usr/bin/consul members  -rpc-addr=192.168.1.200:8400
/usr/bin/consul info -rpc-addr=192.168.1.200:8400
/usr/bin/consul monitor -rpc-addr=192.168.1.200:8400
```

### 3.2 swarm 
```
echo "
192.168.1.200:2375
192.168.1.204:2375
192.168.1.205:2375
192.168.1.206:2375
" >> cluster.disco
cp /tmp/cluster.disco ~/

# swarm-master.sh
docker rm -f swarm-master
docker run -v /etc/localtime:/etc/localtime:ro -v /tmp/cluster.disco:/tmp/cluster.disco -d --restart=always -p 5732:2375 --name=swarm-master swarm manage file:///tmp/cluster.disco

# 修改 ~/.bashrc 添加
alias ldocker='docker -H tcp://0.0.0.0:2375'
alias sdocker='docker -H tcp://0.0.0.0:5732' #used only on the swarm manager
source  ~/.bashrc

# 修改docker deamon 启动项
$ service docker stop
$ vi /etc/systemd/system/docker.service
ExecStart=/usr/bin/docker daemon -H fd:// --storage-driver=overlay --dns 172.17.0.1 --dns 8.8.8.8 --dns 8.8.4.4 --dns-search service.consul --dns-search mudan.com -H tcp://0.0.0.0:2375 -H unix:///run/docker.sock --cluster-advertise=192.168.1.200:2375 --cluster-store=consul://192.168.1.200:8500
$ systemctl daemon-reload
$ systemctl restart docker.service
$ sdocker info
Containers: 60
 Running: 46
 Paused: 0
 Stopped: 14
Images: 40
Server Version: swarm/1.1.3
Role: primary
Strategy: spread
Filters: health, port, dependency, affinity, constraint
Nodes: 4
 dc00.mudan.com: 192.168.1.200:2375
  └ Status: Healthy
  └ Containers: 20
  └ Reserved CPUs: 15 / 16
  └ Reserved Memory: 12.81 GiB / 32.94 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=4.5.0-1.el7.elrepo.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=overlay
  └ Error: (none)
  └ UpdatedAt: 2016-04-21T06:52:15Z
 dc04.mudan.com: 192.168.1.204:2375
  └ Status: Healthy
  └ Containers: 17
  └ Reserved CPUs: 11 / 16
  └ Reserved Memory: 11.73 GiB / 32.94 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=4.5.0-1.el7.elrepo.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=overlay
  └ Error: (none)
  └ UpdatedAt: 2016-04-21T06:52:16Z
 dc05.mudan.com: 192.168.1.205:2375
  └ Status: Healthy
  └ Containers: 22
  └ Reserved CPUs: 14 / 16
  └ Reserved Memory: 14.73 GiB / 32.94 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=4.5.0-1.el7.elrepo.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=overlay
  └ Error: (none)
  └ UpdatedAt: 2016-04-21T06:52:16Z
 dc06.mudan.com: 192.168.1.206:2375
  └ Status: Healthy
  └ Containers: 1
  └ Reserved CPUs: 0 / 16
  └ Reserved Memory: 0 B / 32.94 GiB
  └ Labels: executiondriver=, kernelversion=4.5.1-1.el7.elrepo.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=overlay
  └ Error: (none)
  └ UpdatedAt: 2016-04-21T06:52:16Z
Plugins:
 Volume:
 Network:
Kernel Version: 4.5.1-1.el7.elrepo.x86_64
Operating System: linux
Architecture: amd64
CPUs: 64
Total Memory: 131.8 GiB
Name: 4e738e9723ec
Docker Root Dir:
Debug mode (client): false
Debug mode (server): false
WARNING: No kernel memory limit support
```

### 3.3 Reference
https://docs.docker.com/v1.5/swarm/discovery/

http://stackoverflow.com/questions/34365604/how-to-create-docker-overlay-network-between-multi-hosts

https://docs.docker.com/engine/userguide/networking/dockernetworks/