# 192.168.9.254

### 1. 四个分结点
#### 1.1 准备工作
安装docker及确定本地mysql数据存贮目录

```
ssh -p 9254 ubuntu@119.254.98.205
curl -sSL https://get.daocloud.io/docker | sh
sudo usermod -aG docker ubuntu
sudo groupadd mysql
sudo useradd -g mysql mysql

mkdir -p /home/ubuntu/data/mysql/conf
mkdir -p /home/ubuntu/data/mysql/data
sudo chown -R mysql:mysql /home/ubuntu/data/mysql/data
```

#### 1.2 准备脚本依次创建4个容器，数据挂载在宿主机本地目录
```
VM_NAME="docdb01"
WD_PATH="/home/ubuntu/data/mysql"
MYSQL_ROOT_PASSWORD="root"
MYSQL_PASSWORD="123456"
docker run stop $VM_NAME
docker rm $VM_NAME
docker run --detach \
  --name $VM_NAME \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  --env MYSQL_DATABASE=peony \
  --env MYSQL_USER=peony \
  --env MYSQL_PASSWORD=$MYSQL_PASSWORD \
  -v ${WD_PATH}/data/${VM_NAME}:/var/lib/mysql \
  mysql:5.7
```

...

第四个结点,注意,这里只有容器名称不一样.

```
VM_NAME="docdb04"
WD_PATH="/home/ubuntu/data/mysql"
MYSQL_ROOT_PASSWORD="root"
MYSQL_PASSWORD="123456"
docker run stop $VM_NAME
docker rm $VM_NAME
docker run --detach \
  --name $VM_NAME \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  --env MYSQL_DATABASE=peony \
  --env MYSQL_USER=peony \
  --env MYSQL_PASSWORD=$MYSQL_PASSWORD \
  -v ${WD_PATH}/data/${VM_NAME}:/var/lib/mysql \
  mysql:5.7
```

### 2. COBAR结点
#### 2.1 创建容器COBAR
与四个数据结点互联

```
VM_NAME="docdb-cobar"
#HD_NAME="hd-docdb01"
WD_PATH="/home/ubuntu/data/mysql"
MYSQL_ROOT_PASSWORD="root"
MYSQL_PASSWORD="123456"

docker stop ${VM_NAME}
docker rm ${VM_NAME}
docker run --detach \
  --name $VM_NAME \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  --env MYSQL_DATABASE=peony \
  --env MYSQL_USER=peony \
  --env MYSQL_PASSWORD=$MYSQL_PASSWORD \
  -v ${WD_PATH}/data/${VM_NAME}:/var/lib/mysql \
  -p 8096:8096 \
  --link docdb01:docdb01 \
  --link docdb02:docdb02 \
  --link docdb03:docdb03 \
  --link docdb04:docdb04 \
  mysql:5.7
```

#### 2.2 配置cobar

##### 2.2.1 先登进去容器

```
docker exec -it docdb-cobar bash 
```

##### 2.2.2 再配置基本环境如下

```
# UPDATE
apt-get update
apt-get install wget vim less zsh

# JDK
#wget http://119.254.110.32:8081/download/jdk.sh
#sh ./jdk.sh
wget http://119.254.110.32:8081/download/jdk1.7.0_60.tar.gz
tar -xzvf jdk1.7.0_60.tar.gz
mv jdk1.7.0_60 /usr/share/
echo '
export JAVA_HOME=/usr/share/jdk1.7.0_60
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
' >> ~/.bashrc
source ~/.bashrc
```

##### 2.2.3 最后是cobar配置

```
root@9a951de0a7cb:/cobar-server-1.2.7# cat /etc/hosts
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.17.0.3	docdb02 67bed1c17f9c
172.17.0.4	docdb03 0cc8bb3a0d3f
172.17.0.5	docdb04 f15724008ae3
172.17.0.2	docdb01 53e10f6d67d9
172.17.0.6	9a951de0a7cb
```

以上可以看到docdb01-04的ip及cobar自身的ip

##### 2.2.4 宿主机上准备4个初始化sql如下

```
# 1.sql
drop database if exists dbtest1;
create database dbtest1;
use dbtest1;
create table tb(
id    int not null,
val   varchar(256));

drop database if exists dbtest2;
create database dbtest2;
use dbtest2;
create table tb(
id    int not null,
val   varchar(256));
```

以及第四个结点的sql

```
# 4.sql
drop database if exists dbtest7;
create database dbtest7;
use dbtest7;
create table tb(
id    int not null,
val   varchar(256));

drop database if exists dbtest8;
create database dbtest8;
use dbtest8;
create table tb(
id    int not null,
val   varchar(256));
```

##### 2.2.5 宿主机上初始化四个结点

```
sudo apt-get -y install mysql-client mysql-server
mysql -h 172.17.0.2 -uroot -proot -e "source 1.sql;"
mysql -h 172.17.0.3 -uroot -proot -e "source 2.sql;"
mysql -h 172.17.0.4 -uroot -proot -e "source 3.sql;"
mysql -h 172.17.0.5 -uroot -proot -e "source 4.sql;"
```


##### 2.2.6 cobar容器内配置及启动cobar
进入`/cobar-server-1.2.7/conf` 修改server.xml等

备份文件

```
ls *.xml|xargs -i echo cp {} {}.bak  |sh
```

修改 rule.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE cobar:rule SYSTEM "rule.dtd">
<cobar:rule xmlns:cobar="http://cobar.alibaba.com/">
  
  <tableRule name="rule1">
    <rule>
      <columns>id</columns>
      <algorithm><![CDATA[ func1(${id}) ]]></algorithm>
    </rule>
  </tableRule>

  <function name="func1" class="com.alibaba.cobar.route.function.PartitionByLong">
    <property name="partitionCount">8</property>
    <property name="partitionLength">128</property>
  </function>

</cobar:rule>
```

修改 server.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE cobar:server SYSTEM "server.dtd">
<cobar:server xmlns:cobar="http://cobar.alibaba.com/">
  <system>
    <property name="serverPort">8096</property>
    <property name="managerPort">9066</property>
    <property name="initExecutor">16</property>
    <property name="timerExecutor">4</property>
    <property name="managerExecutor">4</property>
    <property name="processors">4</property>
    <property name="processorHandler">8</property>
    <property name="processorExecutor">8</property>
    <property name="clusterHeartbeatUser">_HEARTBEAT_USER_</property>
    <property name="clusterHeartbeatPass">_HEARTBEAT_PASS_</property>
  </system>

  <user name="root">
    <property name="password">root</property>
    <property name="schemas">dbtest</property>
  </user>

</cobar:server>
```

修改 schema.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE cobar:schema SYSTEM "schema.dtd">
<cobar:schema xmlns:cobar="http://cobar.alibaba.com/">
  <schema name="dbtest">
    <table name="tb" dataNode="dn_server1$0-1,dn_server2$0-1,dn_server3$0-1,dn_server4$0-1," rule="rule1" />
  </schema>

  <dataNode name="dn_server1">
    <property name="dataSource">
        <dataSourceRef>db_server1$0-1</dataSourceRef>
    </property>
  </dataNode>
  <dataNode name="dn_server2">
    <property name="dataSource">
        <dataSourceRef>db_server2$0-1</dataSourceRef>
    </property>
  </dataNode>
  <dataNode name="dn_server3">
    <property name="dataSource">
        <dataSourceRef>db_server1$0-1</dataSourceRef>
    </property>
  </dataNode>
  <dataNode name="dn_server4">
    <property name="dataSource">
        <dataSourceRef>db_server2$0-1</dataSourceRef>
    </property>
  </dataNode>

  <dataSource name="db_server1" type="mysql">
    <property name="location">
      <location>172.17.0.2:3306/dbtest$1-2</location>
    </property>
    <property name="user">root</property>
    <property name="password">root</property>
    <property name="sqlMode">STRICT_TRANS_TABLES</property>
  </dataSource>

  <dataSource name="db_server2" type="mysql">
    <property name="location">
      <location>172.17.0.3:3306/dbtest$3-4</location>
    </property>
    <property name="user">root</property>
    <property name="password">root</property>
    <property name="sqlMode">STRICT_TRANS_TABLES</property>
  </dataSource>

  <dataSource name="db_server3" type="mysql">
    <property name="location">
      <location>172.17.0.4:3306/dbtest$5-6</location>
    </property>
    <property name="user">root</property>
    <property name="password">root</property>
    <property name="sqlMode">STRICT_TRANS_TABLES</property>
  </dataSource>

  <dataSource name="db_server4" type="mysql">
    <property name="location">
      <location>172.17.0.5:3306/dbtest$7-8</location>
    </property>
    <property name="user">root</property>
    <property name="password">root</property>
    <property name="sqlMode">STRICT_TRANS_TABLES</property>
  </dataSource>

</cobar:schema>
```


最后 启动cobar程序

```
../bin/startup.sh
cat /cobar-server-1.2.7/logs/console.log
log4j:WARN 2016-03-05 12:24:17 [/cobar-server-1.2.7/conf/log4j.xml] load completed.
```

日志显示成功无误

##### 2.2.7 检查cobar及测试数据

```
# cobar 容器内
mysql -h 127.0.0.1 -uroot -proot -P8096 -Ddbtest
mysql> show tables;
+------------------+
| Tables_in_dbtest |
+------------------+
| tb               |
+------------------+
1 row in set (0.00 sec)

mysql> show create table tb\G;
*************************** 1. row ***************************
       Table: tb
Create Table: CREATE TABLE `tb` (
  `id` int(11) NOT NULL,
  `val` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1
1 row in set (0.03 sec)

ERROR:
No query specified

mysql> select * from tb;
Empty set (0.03 sec)

mysql> insert into tb (id,val) values (10,"ourpqda;ojd");
Query OK, 1 row affected (0.02 sec)

mysql> insert into tb (id,val) values (1,"qda;ojd"),(2,"dadaoidhao"),(3,"777%"),(9,"qduapud"),(54,"4");
Query OK, 5 rows affected (0.04 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> select * from tb;
+----+-------------+
| id | val         |
+----+-------------+
| 10 | ourpqda;ojd |
|  1 | qda;ojd     |
|  2 | dadaoidhao  |
|  3 | 777%        |
|  9 | qduapud     |
| 54 | 4           |
| 10 | ourpqda;ojd |
|  1 | qda;ojd     |
|  2 | dadaoidhao  |
|  3 | 777%        |
|  9 | qduapud     |
| 54 | 4           |
+----+-------------+
12 rows in set (0.00 sec)

```

宿主机登录检查

```
mysql -h 172.17.0.6 -uroot -proot -P8096 -Ddbtest

mysql> select * from tb;
+----+-------------+
| id | val         |
+----+-------------+
| 10 | ourpqda;ojd |
|  1 | qda;ojd     |
|  2 | dadaoidhao  |
|  3 | 777%        |
|  9 | qduapud     |
| 54 | 4           |
| 10 | ourpqda;ojd |
|  1 | qda;ojd     |
|  2 | dadaoidhao  |
|  3 | 777%        |
|  9 | qduapud     |
| 54 | 4           |
+----+-------------+
12 rows in set (0.00 sec)

mysql> select * from tb where id=10;
+----+-------------+
| id | val         |
+----+-------------+
| 10 | ourpqda;ojd |
+----+-------------+
1 row in set (0.01 sec)
```

ID查询无误,批量插入会有重复主键的问题

### 3. 待解决问题
1. 容器cpu及mem和size初始化
2. host及域名问题
3. 数据迁移问题
4. 安全问题
5. 跨主机问题
6. 跨路由、机房问题
7. 本地镜像仓库问题
8. 更智能化部署方式

### 4. 严重bug
容器时间可能不是北京时区，与宿主机不一致，需要调整。