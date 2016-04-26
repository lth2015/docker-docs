Docker极简教程—-Dockerfile篇
--------------------------------------------------------

### 容器相关操作

--------------------------------------------------------
###### Docker是一个强大的打包工具，非常强大，能够把操作系统打包在里面，进行无差别的部署和运行
###### Docker镜像，类似操作系统的镜像，包括一个完整的可运行系统，操作系统(ubuntu)、基础组件(jvm)、应用程序(java webapp)都可以打包在一个镜像中，镜像可以被导出（tar)，移植到其他系统上
###### Docker容器是个Docker镜像的执行实例，是镜像的运行态的展现形式，它可以被启动、停止、删除，容器可以被看做是一个linux的操作系统，上面运行着某种应用（Java webapp），同一台机器上可以运行多个容器

###### **通俗来讲，镜像好比DVD，容器好比放电影。    ——涛哥** 
--------------------------------------------------------

##### Docker镜像是个层叠的概念，从基础镜像开始，不断的往上叠加，而Dockerfile正是记录了这样每一层的变化

##### 我们通过一个实例来讲解如何编写一个Dockerfile

```Dockerfile
FROM ubuntu:14.04
MAINTAINER dawei.li@yeepay.com 

# Add User
RUN mkdir -p /home/kafka
RUN adduser --disabled-password --gecos '' kafka --home /home/kafka
RUN adduser kafka sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown kafka.kafka /home/kafka -R
RUN whoami
USER kafka
RUN whoami

WORKDIR /home/kafka

# Install Kafka
RUN sudo apt-get update -yqq && sudo apt-get install -y default-jre wget

RUN mkdir -p /home/kafka/Downloads
RUN wget "http://mirror.cc.columbia.edu/pub/software/apache/kafka/0.8.2.1/kafka_2.11-0.8.2.1.tgz" -O ~/Downloads/kafka.tgz
RUN mkdir -p /home/kafka/kafka
WORKDIR /home/kafka/kafka
RUN tar -xvzf ~/Downloads/kafka.tgz --strip 1
RUN echo "delete.topic.enable = true" >> ~/kafka/config/server.properties

## Install KafkaT
RUN sudo apt-get install -y ruby ruby-dev build-essential
RUN sudo gem install kafkat --source https://rubygems.org --no-ri --no-rdoc
COPY .kafkatcfg /home/kafka/
RUN kafkat partitions


EXPOSE 9092

# RUN sed -i "s/broker.id=0/broker\.id=\${env:SERVER_ID}/g" /home/kafka/kafka/config/server.properties
#ENV BROKERID=1
#COPY sed.sh /home/kafka/
#ENTRYPOINT ["/home/kafka/sed.sh"]
#RUN nohup /home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server.properties > /tmp/kafka.log 2>&1 &
```

