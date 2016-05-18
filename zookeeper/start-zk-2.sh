docker rm -f zk01 zk02 zk03
docker run -d --net=net04 --name zk01 --add-host zk01:192.168.4.2 --hostname zk01.mudan.com peony/zk:2 1 192.168.4.2
docker run -d --net=net04 --name zk02 --add-host zk02:192.168.4.3 --hostname zk02.mudan.com peony/zk:2 2 192.168.4.3 192.168.4.2
docker run -d --net=net04 --name zk03 --add-host zk03:192.168.4.4 --hostname zk03.mudan.com peony/zk:2 3 192.168.4.4 192.168.4.2
