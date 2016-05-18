### 1. Dockerfile
### 2. run.sh
```

```

### start
```
ssh 192.168.1.200
cd /root/devops/mem
# 启动容器
sh mem.sh mem01 dc00.mudan.com 192.168.3.7
sh mem.sh mem02 dc04.mudan.com 192.168.3.8
sh mem.sh mem03 dc05.mudan.com 192.168.3.13
sh mem.sh mem04 dc05.mudan.com 192.168.3.14
# 启动 memcached
sdocker exec -it mem01 memcached -d -c 10240 -m 1600 -u root
sdocker exec -it mem02 memcached -d -c 10240 -m 1600 -u root
sdocker exec -it mem03 memcached -d -c 10240 -m 1600 -u root
sdocker exec -it mem04 memcached -d -c 10240 -m 1600 -u root
```
