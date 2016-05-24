Java应用镜像的构建过程
------------------------------------------------------------

##### 先编写Dockerfile
```Dockerfile
FROM ubuntu-jdk7:v1
MAINTAINER dawei.li@yeepay.com

ADD tomcat7-40-tomcat-push-portal/ /apps/product/tomcat7
RUN mkdir -p /apps/log/tomcat-access/
RUN mkdir -p /apps/log/tomcat-nohup/
RUN chown -Rf app:app /apps
# RUN chown -Rf app:app /apps/product/tomcat7
ADD dbconfig/  /apps/dbconfig/

USER app

ENTRYPOINT [ "/apps/product/tomcat7/bin/catalina.sh", "run" ]
```

##### 编译镜像
```bash
docker build -t push-portal:v1 .
```

##### 试运行容器，观察tomcat启动日志，看tomcat能不能正常启动
```bash
docker run -ti --rm  push-portal:v1 
```

##### 在另外一个Terminal中查看container的IP
```bash
docker ps -a | grep push-portal:v1
docker inspect ${ContainerID} | grep IPAddr
```

##### 得到IP地址后进行测试
```bash
curl http://xx.xx.xx.xx/hello
```

