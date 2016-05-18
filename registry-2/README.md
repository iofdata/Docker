### 部署节点 `DC01-192.168.9.8`
#### 1. 工作目录
登陆部署节点并创建镜像工作目录:

```
$ ssh ubuntu@192.168.9.8
$ mkdir -p /home/ubuntu/registry
$ cd /home/ubuntu/registry
# 启动容器registry
# sudo docker run -d -p 5000:5000 -v `pwd`/data:/var/lib/registry --restart=always --name registry registry:2
```

#### 2. CA证书
##### 2.1 为提高安全性,生成CA证书

```
$ mkdir certs
$ openssl req -newkey rsa:2048 -nodes -sha256 -keyout certs/registry.mudan.com.key -x509 -days 3650 -out certs/registry.mudan.com.crt
```

过程如下:

```
Country Name (2 letter code) [AU]:CN
State or Province Name (full name) [Some-State]:HB
Locality Name (eg, city) []:Wuhan
Organization Name (eg, company) [Internet Widgits Pty Ltd]:PEONY
Organizational Unit Name (eg, section) []:DATA
Common Name (e.g. server FQDN or YOUR name) []:registry.mudan.com
Email Address []:peony_wh@163.com
```

##### 2.2 重新启动registry容器:

```
$ docker stop registry
$ docker rm registry
$ docker run -d -p 5000:5000 --restart=always --name registry \
  -v `pwd`/data:/var/lib/registry \
  -v `pwd`/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.mudan.com.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.mudan.com.key \
  registry:2
$ sudo vi /etc/hosts
192.168.9.8 registry.mudan.com registry
```

##### 2.3 拷贝证书到配置目录

```
$ sudo mkdir -p /etc/docker/certs.d/registry.mudan.com:5000
$ sudo cp certs/registry.mudan.com.crt /etc/docker/certs.d/registry.mudan.com:5000/ca.crt
$ sudo service docker restart
```

##### 2.4 本地推送镜像测试
```
docker pull busybox:latest
docker tag busybox:latest registry.mudan.com:5000/peony/busybox:latest
docker push registry.mudan.com:5000/peony/busybox
```

#### 3. 并分发到各个节点上
如 `DC03 192.168.9.252`上:

```
$ sudo mkdir -p /etc/docker/certs.d/registry.mudan.com:5000
$ sudo scp ubuntu@192.168.9.8:/home/ubuntu/registry/certs/registry.mudan.com.crt \
    /etc/docker/certs.d/registry.mudan.com:5000/
$ docker pull registry.mudan.com:5000/peony/busybox
$ docker images
```

#### 4. 账号登陆，待完成

#### 参考资料
https://github.com/docker/distribution/blob/master/docs/deploying.md

https://github.com/docker/distribution/blob/master/docs/configuration.md#storage

http://seanlook.com/2014/11/13/deploy-private-docker-registry-with-nginx-ssl/

http://tonybai.com/
