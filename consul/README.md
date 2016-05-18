### 1. DC01 192.168.9.8
```
$ docker pull progrium/consul
$ mkdir ~/consul
$ docker run --rm progrium/consul cmd:run 192.168.9.8 -d -v ~/consul:/data
```

```
docker run --name consul -h $HOSTNAME \
    -p 192.168.9.8:8300:8300 \
    -p 192.168.9.8:8301:8301 \
    -p 192.168.9.8:8301:8301/udp \
    -p 192.168.9.8:8302:8302 \
    -p 192.168.9.8:8302:8302/udp \
    -p 192.168.9.8:8400:8400 \
    -p 192.168.9.8:8500:8500 \
    -p 172.17.0.1:53:53  \
    -p 172.17.0.1:53:53/udp \
    -d -v /home/ubuntu/consul:/data \
    progrium/consul -server -advertise 192.168.9.8 -bootstrap-expect 3 -ui-dir /ui
```

```
#$ curl localhost:8500/v1/catalog/nodes
$ curl dc01:8500/v1/catalog/nodes
$ dig @0.0.0.0 -p 8600 node1.node.consul
```

### 2. DC02 192.168.9.253
```
$ docker pull progrium/consul
$ mkdir ~/consul
$ docker run --rm progrium/consul cmd:run 192.168.9.253::192.168.9.8 -d -v ~/consul:/data
```

```
docker run --name consul -h $HOSTNAME 
    -p 192.168.9.253:8300:8300 \
    -p 192.168.9.253:8301:8301 \
    -p 192.168.9.253:8301:8301/udp \
    -p 192.168.9.253:8302:8302 \
    -p 192.168.9.253:8302:8302/udp \
    -p 192.168.9.253:8400:8400 \
    -p 192.168.9.253:8500:8500 \
    -p 172.17.0.1:53:53 \
    -p 172.17.0.1:53:53/udp \
    -d -v /home/ubuntu/consul:/data \
    progrium/consul -server -advertise 192.168.9.253 -join 192.168.9.8
```

### 3. DC03 192.168.9.252
```
$ docker pull progrium/consul
$ mkdir ~/consul
$ $(docker run --rm progrium/consul cmd:run 192.168.9.252::192.168.9.8 -d -v ~/consul:/data)
```

### 4. DC01 192.168.9.8 验证
```
$ curl dc01:8500/v1/catalog/nodes
[{"Node":"dc01.mudan.com","Address":"192.168.9.8"},{"Node":"dc02.mudan.com","Address":"192.168.9.253"},{"Node":"dc03.mudan.com","Address":"192.168.9.252"}]
```

#### consul 参考资料
https://hub.docker.com/r/progrium/consul/
http://jlordiales.me/2015/02/03/registrator/
http://artplustech.com/docker-consul-dns-registrator/
https://www.spirulasystems.com/blog/2015/06/25/building-an-automatic-environment-using-consul-and-docker-part-1/
https://docs.docker.com/v1.5/swarm/discovery/
http://tonybai.com/2015/07/06/implement-distributed-services-registery-and-discovery-by-consul/
