
### 1. 创建２个master和３个regionserver

```
# 192.168.1.204
docker run -it -d --net=pro --name=hbase-ms1 --hostname=hbase-ms1 --memory="500m" -p 192.168.1.204:60010:60010 -p 192.168.1.204:8080:8080  registry.mudan.com:5000/peony/hbase:2
# 192.168.1.200
docker run -it -d --net=pro --name=hbase-ms2 --hostname=hbase-ms2 --memory="500m" -p 192.168.1.200:60010:60010 -p 192.168.1.200:8080:8080  registry.mudan.com:5000/peony/hbase:2
# 192.168.1.204
docker run -it -d --net=pro --name=hbase-rs1 --hostname=hbase-rs2 --memory="2g" registry.mudan.com:5000/peony/hbase:2
# 192.168.1.200
docker run -it -d --net=pro --name=hbase-rs2 --hostname=hbase-rs2 --memory="2g" registry.mudan.com:5000/peony/hbase:2
# 192.168.1.205
docker run -it -d --net=pro --name=hbase-rs3 --hostname=hbase-rs2 --memory="2g" registry.mudan.com:5000/peony/hbase:2
```

### 2. 启动hbase集群

#### 2.1 hbase-ms1容器上启动集群regionserver

```
sdocker exec -it hbase-ms1 /usr/local/hbase/bin/start-hbase.sh
# 日志
hbase-rs3: starting regionserver, logging to /usr/local/hbase/bin/../logs/hbase-root-regionserver-hbase-rs3.out
hbase-rs2: starting regionserver, logging to /usr/local/hbase/bin/../logs/hbase-root-regionserver-hbase-rs2.out
hbase-rs1: starting regionserver, logging to /usr/local/hbase/bin/../logs/hbase-root-regionserver-hbase-rs1.out
```

#### 2.2 hbase-ms1容器上启动master

```
sdocker exec -it hbase-ms1 /usr/local/hbase/bin/hbase-daemon.sh start master
```

检查regionserver日志

```
tail hbase-root-regionserver-hbase-rs1.log

2016-04-01 10:42:38,884 INFO  [regionserver/hbase-rs1/192.168.4.17:60020] regionserver.ReplicationSourceManager: Current list of replicators: [hbase-rs1.pro,60020,1459478231519] other RSs: [hbase-rs1,60020,1459478231519, hbase-rs2,60020,1459478225749, hbase-rs3,60020,1459478220473]
2016-04-01 10:42:38,927 INFO  [SplitLogWorker-hbase-rs1:60020] regionserver.SplitLogWorker: SplitLogWorker hbase-rs1.pro,60020,1459478231519 starting
2016-04-01 10:42:38,928 INFO  [regionserver/hbase-rs1/192.168.4.17:60020] regionserver.HeapMemoryManager: Starting HeapMemoryTuner chore.
2016-04-01 10:42:38,930 INFO  [regionserver/hbase-rs1/192.168.4.17:60020] regionserver.HRegionServer: Serving as hbase-rs1.pro,60020,1459478231519, RpcServer on hbase-rs1/192.168.4.17:60020, sessionid=0x30010fe11d90003
```

检查master日志

```
tail hbase-root-master-hbase-ms1.log

2016-04-01 10:42:28,347 INFO  [main] master.HMaster: hbase.rootdir=hdfs://cluster/hbase, hbase.cluster.distributed=true
2016-04-01 10:42:28,357 INFO  [main] master.HMaster: Adding backup master ZNode /hbase/backup-masters/hbase-ms1,60000,1459478492264
2016-04-01 10:42:28,448 INFO  [hbase-ms1:60000.activeMasterManager] master.ActiveMasterManager: Deleting ZNode for /hbase/backup-masters/hbase-ms1,60000,1459478492264 from backu
p master directory
2016-04-01 10:42:28,463 INFO  [hbase-ms1:60000.activeMasterManager] master.ActiveMasterManager: Registered Active Master=hbase-ms1,60000,1459478492264
2016-04-01 10:42:28,489 INFO  [master/hbase-ms1/192.168.4.15:60000] zookeeper.RecoverableZooKeeper: Process identifier=hconnection-0x483b961d connecting to ZooKeeper ensemble=zk
01:2181,zk02:2181,zk03:2181,zk04:2181,zk05:2181


tail hbase-root-master-hbase-ms2.log

2016-04-01 10:47:11,258 INFO  [main] master.HMaster: hbase.rootdir=hdfs://cluster/hbase, hbase.cluster.distributed=true
2016-04-01 10:47:11,267 INFO  [main] master.HMaster: Adding backup master ZNode /hbase/backup-masters/hbase-ms2,60000,1459478774239
2016-04-01 10:47:11,356 INFO  [hbase-ms2:60000.activeMasterManager] master.ActiveMasterManager: Another master is the active master, hbase-ms1,60000,1459478492264; waiting to become the next active master
2016-04-01 10:47:11,386 INFO  [master/hbase-ms2/192.168.4.16:60000] zookeeper.RecoverableZooKeeper: Process identifier=hconnection-0x7a0e27c6 connecting to ZooKeeper ensemble=zk01:2181,zk02:2181,zk03:2181,zk04:2181,zk05:2181
```



### 3. Reference

http://bigdata-madesimple.com/installation-of-hbase-in-the-cluster/


http://stackoverflow.com/questions/33515534/how-to-configure-an-hbase-cluster-in-fully-distributed-mode-using-docker

http://www.svds.com/using-docker-to-build-a-data-acquisition-pipeline-with-kafka-and-hbase/

https://github.com/dajobe/hbase-docker
