### 1. 推荐创建镜像时方法
```
# Dockerfile 修改
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
# 或
#RUN echo "Europe/London" > /etc/timezone; 
RUN echo "Asia/Shanghai" > /etc/timezone;
RUN dpkg-reconfigure -f noninteractive tzdata
```

### 2. 创建容器时方法
```
#创建容器时挂载本地时间
docker run -v /etc/localtime:/etc/localtime -it -d --name= **** 
```