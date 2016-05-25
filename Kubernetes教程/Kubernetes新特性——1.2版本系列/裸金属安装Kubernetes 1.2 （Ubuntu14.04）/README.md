裸金属安装Kubernetes 1.2 （Ubuntu14.04）
------------------------------------------------------ 

#### 环境准备
------------------------------------------------------ 

准备四台主机，并安装Ubunt 14.04 x64 v3版本操作系统，确保内核版本在3.19以上

#### 连通性及信任
------------------------------------------------------ 

确认主机A，B，C，D四台主机的可以连通，并添加A到A，B，C，D的信任

#### 开始安装
------------------------------------------------------ 

##### *注意*: 下面3~6步都是在能够翻墙的情况下的操作步骤，如果您的服务器不能翻墙，请直接看本文结尾

##### 1. 在每台主机上安装*docker*

```bash
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' >> /etc/apt/sources.list
apt-get update -yqq && apt-get install docker-engine
```

##### 2. 在每台主机上安装brigde-utils组件

```bash
apt-get update -yqq && apt-get install brigde-utils
```

##### 3. 下载kubernetes源码

```bash
cd ~ && git clone https://github.com/kubernetes/kubernetes.git
```

##### 4. 设置环境变量

```bash
export KUBE_VERSION=1.2.0
export FLANNEL_VERSION=0.5.5
export ETCD_VERSION=2.3.0
```

##### 5. 设置kubernetes集群

编辑 ~/kubernetes/cluster/ubuntu/config-default.sh

```bash
export nodes=“kube@10.254.6.106 kube@10.254.7.106 kube@10.254.5.143 kube@10.254.4.144"

export role="ai i i i"

export NUM_NODES=${NUM_NODES:-4}

export SERVICE_CLUSTER_IP_RANGE=192.168.3.0/24

export FLANNEL_NET=172.16.0.0/16
```

##### 6. 执行安装脚本
```
cd ~/kubernetes/cluster/ && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh
```

##### 7. 批量安装Kubernetes的插件：
------------------------------------------------------ 

并将上述镜像load到每台kubernetes的计算节点上，然后批量安装插件：
```bash
cd ~/kubernetes/cluster/ubuntu && KUBERNETES_PROVIDER=ubuntu ./deployAddons.sh
```

#### 检查集群
------------------------------------------------------ 

查看集群插件：

* 查看dashboard：浏览器打开*http://your-kubernetes-master-ip:8080/ui*

* 查看cAdvisor：浏览器打开*http://your-kubernetes-master-ip:4194/*


### 不能翻墙
------------------------------------------------------ 

##### 1. 如果你的机器不能访问外网，请在我这里下载[K8s的Ubuntu版本二进制包](binaries.tar.gz)

* 下载一个份干净的源码： git clone https://github.com/kubernetes/kubernetes.git

* 将二进制包解压到你的kubernetes/cluster/ubuntu/下

* 注销掉~/kubernetes/cluster/ubuntu/utils.sh中的"${KUBE_ROOT}/cluster/ubuntu/download-release.sh"这句

* 执行上文中的5~7步，执行kube-up脚本

##### 2. 手工下载需要[依赖的插件镜像](k8s-images.tar.gz)：

* 将k8s-images.tar.gz解压后，依次将所有的tar文件用docker命令加载到每台主机上

如果安装过程中没有报错，则集群安装成功，若有问题，认真检查上述设置是否正确

#### 需要安装的插件
------------------------------------------------------ 
gcr.io/google_containers/heapster:v1.0.0-beta1

gcr.io/google_containers/echoserver:1.3

gcr.io/google_containers/kubernetes-dashboard-amd64:v1.0.0

gcr.io/google_containers/kubernetes-dashboard-amd64:canary

gcr.io/google_containers/kube2sky:1.14

gcr.io/google_containers/heapster_grafana:v2.6.0-2

gcr.io/google_containers/etcd-amd64:2.2.1

gcr.io/google_containers/kube-ui:v4

gcr.io/google_containers/skydns:2015-10-13-8c72f8c

gcr.io/google_containers/pause:2.0

gcr.io/google_containers/heapster_influxdb:v0.5

gcr.io/google_samples/gb-redisslave:v1

gcr.io/google_containers/kube2sky:1.11

gcr.io/google_containers/etcd:2.0.9

gcr.io/google_containers/pause:0.8.0


#### 后记
------------------------------------------------------ 

##### 一定要有一台能够翻墙的主机!

