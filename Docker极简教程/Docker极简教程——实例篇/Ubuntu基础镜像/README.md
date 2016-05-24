Ubuntu基础镜像与JDK7基础镜像的构建过程
------------------------------------------------------------

#### Ubuntu14.04基础镜像构建
------------------------------------------------------------

##### 先编写Dockfile

```Dockfile
FROM ubuntu:14.04

MAINTAINER dawei.li@yeepay.com

ADD profile /etc/
ADD locale /etc/default/

ENV LANG en_US.UTF-8

RUN sed -i '/archive.ubuntu.com/s/archive.ubuntu.com/cn.archive.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install telnet -y
RUN apt-get install gcc -y
RUN apt-get install make -y
RUN apt-get install dnsutils -y
RUN apt-get install wget -y
RUN apt-get install curl -y
RUN apt-get install gdb -y
RUN apt-get install traceroute -y
RUN apt-get install net-tools iputils-ping -y
RUN apt-get install -y language-pack-zh-hans
RUN echo "Asia/Singapore" > /etc/timezone
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN locale-gen en_US.UTF-8
```

#### JDK7基础镜像构建
------------------------------------------------------------

##### 先编写Dockfile

```Dockerfile
FROM ubuntu-base:v1
MAINTAINER dawei.li@yeepay.com

ADD jdk1.7.0_79 /usr/local/jdk1.7.0_79

RUN mkdir -p /apps/product

ENV JAVA_HOME /usr/local/jdk1.7.0_79
ENV PATH $JAVA_HOME/bin:$PATH
ENV CATALINA_HOME /apps/product/tomcat7
ENV CATALINA_SH /apps/product/tomcat7/bin/catalina.sh

EXPOSE 8080

```

##### 构建镜像

##### 先构建基于Ubuntu的操作系统基础镜像

```bash
docker build -t ubuntu-base:v1
```

##### 构建基于JDK 1.7的基础镜像
```bash
docker build -t ubuntu-jdk7:v1 .
```

##### 查看镜像
```bash
docker images | grep ubuntu-jdk7:v1
```

##### 推送至镜像仓库
```bash
docker tag ubuntu-jdk7:v1 registry.test.com:5000/ubuntu-jdk7:v1
docker push  registry.test.com:5000/ubuntu-jdk7:v1
```

##### 从仓库拉取镜像
```bash
docker pull  registry.test.com:5000/ubuntu-jdk7:v1
```

##### 运行容器: 可以进入镜像看看JDK，命令是否安装成功
```bash
docker run -ti --rm ubuntu-jdk7:v1 /bin/bash
```

##### 退出容器：exit

##### 删除容器
```bash
docker ps -a | grep ubuntu-jdk7
docker rm -f ${ContainerID}
```


