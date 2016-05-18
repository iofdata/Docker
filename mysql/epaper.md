
```
docker run -itd --net=rt00 --name=test-mysql -p 192.168.1.204:3306:3306 registry.mudan.com:5000/peony/mysql:5.7

docker inspect hd01-epaper01
scp 119.254.102.70:/root/sourcedb_bakup/mdyq_info_20160408.sql ./
#scp dc05:/home/data1/docker/volumes/960f1fbe6bd22a7f198caf315ecc7041d11292b6ea415b170dd0567208540d62/_data
scp mdyq_info_20160408.sql dc05:/home/data1/docker/volumes/960f1fbe6bd22a7f198caf315ecc7041d11292b6ea415b170dd0567208540d62/_data

```