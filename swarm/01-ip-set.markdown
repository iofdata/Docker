### 1 设定内网IP
```
export IPADDR=192.168.1.201
```

#### 1.1 网关配置
```
cp /etc/sysconfig/network /etc/sysconfig/network.bak
echo "
NETWORKING=yes
NETWORKING_IPV6=yes
GATEWAY=192.168.1.1
" >> /etc/sysconfig/network
```

#### 1.2 网卡配置 
```
cp /etc/sysconfig/network-scripts/ifcfg-em1 /etc/sysconfig/network-scripts/ifcfg-em1.bak
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-em1
sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-em1

echo "
BROADCAST=192.168.1.255
IPADDR=$IPADDR
NETWORK=192.168.1.0
" >>/etc/sysconfig/network-scripts/ifcfg-em1
```

#### 1.3 DNS解析
```
echo "nameserver 202.103.24.68" >/etc/resolv.conf
```