### 2 docker 配置
#### 2.1 内核升级
```
# 更新系统时间（可选，先检查服务器时间是否正确）
yum install -y ntpdate
yum -y install ntp
systemctl enable ntpd
systemctl start ntpd
ntpdate -u cn.pool.ntp.org
systemctl restart ntpd
# 内核升级
# docker 需要较高版本的系统内核，请确保服务器支持3.8版本以上的内核
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum clean all && yum --enablerepo=elrepo-kernel install kernel-ml -y && grub2-set-default 0
reboot
```

#### 2.2 安装docker
```
# centOS7 先关闭防火墙
service firewalld stop
# daocloud 加速
curl -sSL https://get.daocloud.io/docker | sh
sudo usermod -aG docker root
service docker start
service docker stop
```

#### 2.3 overlay 文件系统
```
$ cp /lib/systemd/system/docker.service /etc/systemd/system/docker.service
$ vi /etc/systemd/system/docker.service
ExecStart=/usr/bin/docker daemon -H fd:// --storage-driver=overlay
$ echo "overlay" > /etc/modules-load.d/overlay.conf

$ mkdir -p /home/data1/docker
$ cp -r /var/lib/docker/*  /home/data1/docker
$ rm -rf /var/lib/docker/
$ ln -s /home/data1/docker /var/lib/docker
$ systemctl daemon-reload
$ systemctl restart docker.service
```

