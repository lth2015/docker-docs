Ubuntu基础镜像的构建过程
------------------------------------------------------------

##### 先编写Dockfile

```Dockfile
FROM ubuntu:latest
ADD jdk1.7.0_79 /usr/local/jdk1.7.0_79
ADD profile /etc/
ADD locale /etc/default/
ENV JAVA_HOME /usr/local/jdk1.7.0_79
ENV PATH $JAVA_HOME/bin:$PATH
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
RUN apt-get install vim -y
RUN mkdir -p /apps/product
ENV CATALINA_HOME /apps/product/tomcat7
ENV CATALINA_SH /apps/product/tomcat7/bin/catalina.sh
RUN useradd app
EXPOSE 8080

# ADD tomcat7 /apps/product/tomcat7
# RUN chown -Rf app:app /apps/product/tomcat7
# USER app

# ENTRYPOINT [ "/apps/product/tomcat7/bin/catalina.sh", "run" ]
```

##### 构建镜像
```bash
docker build -t ubuntu-base:v1 .
```

##### 查看镜像
```bash
docker images | grep ubuntu-base:v1
```

##### 推送至镜像仓库
```bash
docker tag ubuntu-base:v1 registry.test.com:5000/ubuntu-base:v1
docker push  registry.test.com:5000/ubuntu-base:v1
```

##### 从仓库拉取镜像
```bash
docker pull  registry.test.com:5000/ubuntu-base:v1
```

##### 运行容器: 可以进入镜像看看JDK，命令是否安装成功
```bash
docker run -ti --rm ubuntu-base:v1 /bin/bash
```

##### 退出容器：exit

##### 删除容器
```bash
docker ps -a | grep ubuntu-base
docker rm -f ${ContainerID}
```

