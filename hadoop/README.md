### 1. 创建镜像及容器
#### 1.1 镜像

```
docker build -t registry.mudan.com:5000/peony/hadoop .
docker push registry.mudan.com:5000/peony/hadoop .
```

#### 1.2 容器
结合[zookeeper-and-docker](http://buttonwood.github.io/2016/03/15/2016-03-15-zookeeper-and-docker/)创建的5个zookeeper容器,我们这里再创建2个namenode,3个journal和3个datanoe.

```
# 2 namenode
sh nn.sh hadoop-nn1 dc00.mudan.com 192.168.4.7
sh nn.sh hadoop-nn2 dc04.mudan.com 192.168.4.8
# 3 journal
sh jn.sh hadoop-jn1 dc00.mudan.com 192.168.4.9
sh jn.sh hadoop-jn2 dc04.mudan.com 192.168.4.10
sh jn.sh hadoop-jn3 dc05.mudan.com 192.168.4.11
# 3 datanoe
sh dn.sh hadoop-dn1 dc00.mudan.com 192.168.4.12
sh dn.sh hadoop-dn2 dc04.mudan.com 192.168.4.13
sh dn.sh hadoop-dn3 dc05.mudan.com 192.168.4.14
```

注意,为了与生产坏境部署一致，我们这里了固定ip的做法，实际上docker的overlay网络是不需要设定固定ip的，通过容器名可以直接进行服务发
现。

### 2. 启动hadoop集群
#### 2.1 格式化 ZooKeeper 集群,在任意的 namenode 上都可以执行
宿主机登陆nn1容器

```
sdocker exec -it hadoop-nn1 bash
```

格式化ZooKeeper

```
$HADOOP_HDFS_HOME/bin/hdfs zkfc -formatZK

16/03/31 17:13:27 INFO ha.ActiveStandbyElector: Session connected.
16/03/31 17:13:27 INFO ha.ActiveStandbyElector: Successfully created /hadoop-ha/cluster in ZK.
16/03/31 17:13:27 INFO zookeeper.ZooKeeper: Session: 0x30010fe11d90001 closed
16/03/31 17:13:27 INFO zookeeper.ClientCnxn: EventThread shut down
```

#### 2.2  启动 journalnode 结点
宿主机上执行

```
sdocker exec -it hadoop-jn1 /usr/local/hadoop/sbin/hadoop-daemon.sh start journalnode
sdocker exec -it hadoop-jn2 /usr/local/hadoop/sbin/hadoop-daemon.sh start journalnode
sdocker exec -it hadoop-jn3 /usr/local/hadoop/sbin/hadoop-daemon.sh start journalnode
```

宿主机上登录验证

```
sdocker exec -it hadoop-jn3 bash
```

容器内查看运行日志

```
tail /usr/local/hadoop/logs/hadoop-root-journalnode-hadoop-jn3.log
2016-03-31 17:15:58,312 INFO org.mortbay.log: Started HttpServer2$SelectChannelConnectorWithSafeStartup@0.0.0.0:8480
2016-03-31 17:16:08,443 INFO org.apache.hadoop.ipc.CallQueueManager: Using callQueue class java.util.concurrent.LinkedBlockingQueue
2016-03-31 17:16:08,460 INFO org.apache.hadoop.ipc.Server: Starting Socket Reader #1 for port 8485
2016-03-31 17:16:08,495 INFO org.apache.hadoop.ipc.Server: IPC Server Responder: starting
2016-03-31 17:16:08,495 INFO org.apache.hadoop.ipc.Server: IPC Server listener on 8485: starting
```

#### 2.3 格式化集群的 NameNode 并启动刚格式化的 NameNode

nn1 容器内

```
$HADOOP_PREFIX/bin/hadoop namenode -format
```

运行情况

```
16/03/31 17:19:55 WARN ssl.FileBasedKeyStoresFactory: The property 'ssl.client.truststore.location' has not been set, no TrustStore will be loaded
16/03/31 17:19:55 INFO namenode.FSImage: Allocated new BlockPoolId: BP-305947057-192.168.4.7-1459415995773
16/03/31 17:19:55 INFO common.Storage: Storage directory /mnt/hadoop/dfs/name has been successfully formatted.
16/03/31 17:19:56 INFO namenode.NNStorageRetentionManager: Going to retain 1 images with txid >= 0
16/03/31 17:19:56 INFO util.ExitUtil: Exiting with status 0
16/03/31 17:19:56 INFO namenode.NameNode: SHUTDOWN_MSG:
```

格式化成功, 启动该namenode

nn1 容器内执行

```
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
```

检查上面运行的日志

```
tail /usr/local/hadoop/logs/hadoop-root-namenode-hadoop-nn1.log

2016-03-31 17:22:44,491 INFO org.apache.hadoop.ipc.Server: IPC Server Responder: starting
2016-03-31 17:22:44,491 INFO org.apache.hadoop.ipc.Server: IPC Server listener on 8020: starting
2016-03-31 17:22:44,492 INFO org.apache.hadoop.hdfs.server.namenode.NameNode: NameNode RPC up at: hadoop-nn1/192.168.4.7:8020
2016-03-31 17:22:44,492 INFO org.apache.hadoop.hdfs.server.namenode.FSNamesystem: Starting services required for standby state
2016-03-31 17:22:44,494 INFO org.apache.hadoop.hdfs.server.namenode.ha.EditLogTailer: Will roll logs on active node at hadoop-nn2/192.168.4.8:8020 every 120 seconds.
2016-03-31 17:22:44,498 INFO org.apache.hadoop.hdfs.server.namenode.ha.StandbyCheckpointer: Starting standby checkpoint thread...
Checkpointing active NN at http://hadoop-nn2:50070
Serving checkpoints at http://hadoop-nn1:50070
```

开启nn1上 zookeeper 进程

```
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start zkfc

tail /usr/local/hadoop/logs/hadoop-root-zkfc-hadoop-nn1.log

2016-03-31 17:27:20,495 INFO org.apache.hadoop.ha.ActiveStandbyElector: Checking for any old active which needs to be fenced...
2016-03-31 17:27:20,502 INFO org.apache.hadoop.ha.ActiveStandbyElector: No old node to fence
2016-03-31 17:27:20,502 INFO org.apache.hadoop.ha.ActiveStandbyElector: Writing znode /hadoop-ha/cluster/ActiveBreadCrumb to indicate that the local node is the most recent active...
2016-03-31 17:27:20,514 INFO org.apache.hadoop.ha.ZKFailoverController: Trying to make NameNode at hadoop-nn1/192.168.4.7:8020 active...
2016-03-31 17:27:21,083 INFO org.apache.hadoop.ha.ZKFailoverController: Successfully transitioned NameNode at hadoop-nn1/192.168.4.7:8020 to active state
```

#### 2.4 同步 NameNode1 元数据到 NameNode2 上
宿主机登录到nn2容器内

```
sdocker exec -it hadoop-nn2 bash
```

nn2 执行bootstrapStandby
```
$HADOOP_PREFIX/bin/hadoop namenode -bootstrapStandby

16/03/31 17:25:09 INFO namenode.TransferFsImage: Opening connection to http://hadoop-nn1:50070/imagetransfer?getimage=1&txid=0&storageInfo=-57:2142625186:0:CID-22a35ddb-646e-4104-be99-1b7cbc578a83
16/03/31 17:25:09 INFO namenode.TransferFsImage: Image Transfer timeout configured to 60000 milliseconds
16/03/31 17:25:09 INFO namenode.TransferFsImage: Transfer took 0.02s at 0.00 KB/s
16/03/31 17:25:09 INFO namenode.TransferFsImage: Downloaded file fsimage.ckpt_0000000000000000000 size 351 bytes.
16/03/31 17:25:09 INFO util.ExitUtil: Exiting with status 0
16/03/31 17:25:09 INFO namenode.NameNode: SHUTDOWN_MSG:
```

成功后同上nn1过程启动namenode

```
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
tail /usr/local/hadoop/logs/hadoop-root-namenode-hadoop-nn2.log

2016-03-31 17:26:25,011 INFO org.apache.hadoop.ipc.Server: IPC Server Responder: starting
2016-03-31 17:26:25,011 INFO org.apache.hadoop.ipc.Server: IPC Server listener on 8020: starting
2016-03-31 17:26:25,013 INFO org.apache.hadoop.hdfs.server.namenode.NameNode: NameNode RPC up at: hadoop-nn2/192.168.4.8:8020
2016-03-31 17:26:25,013 INFO org.apache.hadoop.hdfs.server.namenode.FSNamesystem: Starting services required for standby state
2016-03-31 17:26:25,015 INFO org.apache.hadoop.hdfs.server.namenode.ha.EditLogTailer: Will roll logs on active node at hadoop-nn1/192.168.4.7:8020 every 120 seconds.
2016-03-31 17:26:25,019 INFO org.apache.hadoop.hdfs.server.namenode.ha.StandbyCheckpointer: Starting standby checkpoint thread...
Checkpointing active NN at http://hadoop-nn1:50070
Serving checkpoints at http://hadoop-nn2:50070
```

及zkfc

```
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start zkfc

tail /usr/local/hadoop/logs/hadoop-root-zkfc-hadoop-nn2.log
2016-03-31 17:28:15,782 INFO org.apache.hadoop.ha.ZKFailoverController: Local service NameNode at hadoop-nn2/192.168.4.8:8020 entered state: SERVICE_HEALTHY
2016-03-31 17:28:15,821 INFO org.apache.hadoop.ha.ZKFailoverController: ZK Election indicated that NameNode at hadoop-nn2/192.168.4.8:8020 should become standby
2016-03-31 17:28:15,832 INFO org.apache.hadoop.ha.ZKFailoverController: Successfully transitioned NameNode at hadoop-nn2/192.168.4.8:8020 to standby state
```

#### 2.5 启动所有datanode

可在宿主机上启动
```
sdocker exec -it hadoop-dn1 /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode
sdocker exec -it hadoop-dn2 /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode
sdocker exec -it hadoop-dn3 /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode
```

进入容器内部检查运行日志

```
sdocker exec -it hadoop-dn1 bash

tail /usr/local/hadoop/logs/hadoop-root-datanode-hadoop-dn1.log

2016-03-31 17:31:23,791 INFO org.apache.hadoop.hdfs.server.datanode.BlockPoolSliceScanner: Periodic Block Verification Scanner initialized with interval 504 hours for block pool BP-305947057-192.168.4.7-1459415995773
2016-03-31 17:31:23,795 INFO org.apache.hadoop.hdfs.server.datanode.DataBlockScanner: Added bpid=BP-305947057-192.168.4.7-1459415995773 to blockPoolScannerMap, new size=1
```

以上!
