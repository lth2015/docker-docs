使用Kubernetes搭建高可用私有仓库
============================================================

##### Registry介绍
------------------------------------------------------------

Registry是Docker官方推出的镜像仓库，用于存储Docker的镜像。Docker官方推出了Docker Trusted Registry(DTR)并发布了V2版API，相对于V1版本有很大改变和优化。

本文将介绍如何使用容器云搭建私有可信镜像仓库。

文章结构快速预览：

* 下载Registry镜像

* 创建信任证书

* 构建registry镜像

* 创建部署文件

* 准备存储设备

* 创建部署脚本

* 部署私有镜像仓库

* 使用私有镜像仓库

* 发放证书


##### 下载Registry镜像

本文使用Docker官方registry:2.1镜像，先下载镜像：

```bash
docker pull registry:2.1
```


##### 创建自信任证书
------------------------------------------------------------

可以通过nginx作为registry的反向代理实现可信访问，这种方式已经被集成到最新的DTR中，可以通过[这里](https://docs.docker.com/docker-trusted-registry/architecture/)查看。

我们使用自信任证书的方式实现私有镜像的访问控制：


创建certs文件夹，用于保存证书文件:

```bash
mkdir -p certs 
```

创建证书，在Common Name处填写私有镜像仓库的地址，例如registry.docker，其他默认，一路回车：

```bash
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
```

查看certs文件夹，看是否生成了两个文件：

```bash
ls certs
domain.crt
domain.key
```

##### 构建registry镜像
------------------------------------------------------------

使用Docker官方的registry:2.1作为集成镜像，构建自信任镜像仓库的docker镜像。

编写Dockerfile:

```Dockerfile
#######################################################
# yeepay/registry:2.1
#######################################################

FROM registry:2.1
MAINTAINER dawei.li@yeepay.com

RUN mkdir /certs

ENV REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt  
ENV REGISTRY_HTTP_TLS_KEY=/certs/domain.key
ENV REGISTRY_STORAGE_DELETE_ENABLED=true 

ADD certs /certs

EXPOSE 5000
```

[Download](Dockerfile)

构建yeepay/registry:2.1镜像:

```bash
docker build -t yeepay/registry:2.1
```

##### 创建部署文件
------------------------------------------------------------

自信任registry镜像构建完成后，接下来就是将registry部署到kubernetes集群中。

创建rc文件：

```bash
cat registry-rc.yaml
```

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: registry
  namespace: default
  labels:
    k8s-app: registry
    version: "2.1"
spec:
  replicas: 1
  selector:
    k8s-app: registry
    version: "2.1"
  template:
    metadata:
      labels:
        k8s-app: registry
        version: "2.1"
    spec:
      containers:
      - name: registry
        image: registry.docker:5000/yeepay/registry:2.1
        resources:
          # keep request = limit to keep this container in guaranteed class
          limits:
            cpu: 4
            memory: 10Gi
          requests:
            cpu: 4
            memory: 10Gi
        volumeMounts:
        - name: registry
          mountPath: /var/lib/registry
        ports:
        - containerPort: 5000
          name: registry
          protocol: TCP
      volumes:
      - name: registry
        rbd: 
          monitors:
            - "10.149.149.2:6789"
            - "10.149.149.3:6789"
            - "10.149.149.4:6789"
          pool: rbd
          image: registry
          secretRef:
            name: ceph-secret
          fsType: ext4
          readOnly: false
```
[Download](registry-rc.yaml)

创建svc文件

```yaml
apiVersion: v1
kind: Service
metadata:
  name: registry
  namespace: default
  labels:
    k8s-app: registry
spec:
  selector:
    k8s-app: registry
  ports:
  - name: registry
    port: 5000
    targetPort: 5000
    protocol: TCP
    nodePort: 32500
  type: NodePort
```
[Download](registry-svc.yaml)


##### 准备存储空间
------------------------------------------------------------

使用Ceph RBD创建块设备，先创建一个1T的硬盘：

```bash
rbd create registry -s 1024000
```

映射该设备：

```bash
rbd map registry
```

查看设备的挂载点

```bash
rbd showmapped | grep registry
10 registry /dev/rbd9
```

格式化硬盘：

```bash
mkfs.ext4 /dev/rbd9
```

取消映射：
```bash
rbd unmap registry
```

在registry空间不足时，随时可以通过rbd实现无感知的扩容。

##### 创建部署脚本
------------------------------------------------------------

每次构建镜像，部署和删除registry应用都要重复很多命令，所以，我们使用make来简化构建和部署操作。

创建Makefile：

```bash
cat Makefile
```

```makefile
.PHONY:	build push

IMAGE = yeepay/registry
TAG = 2.1

build:	
	docker build -t $(IMAGE):$(TAG) .

push:	
	docker push registry.docker:5000/$(IMAGE):$(TAG)

run: 
	docker run -d -p 5000:5000 --restart=always --name registry -v ${PWD}/images/:/var/lib/registry $(IMAGE):$(TAG)

rm: 
	docker rm -f registry

clean:	
	docker rmi -f $(IMAGE):$(TAG)

deploy:
	kubectl create -f registry-rc.yaml --validate=false
	kubectl create -f registry-svc.yaml

clear:
	kubectl delete -f registry-rc.yaml
	kubectl delete -f registry-svc.yaml
```
[Download](Makefile)

下面介绍如何使用make来简化部署操作：

*  **make build**: 构建yeepay/registry:2.1镜像

*  **make push**: 试验将registry镜像推送至原有的镜像仓库，如果没有旧的仓库，这步请忽略

*  **make run**:  以裸docker的方式启动registry，启动后可以测试registy是否能够正常工作，如果正常才在容器云中部署

*  **make clean**: 清除构建的yeepay/registry:2.1镜像

*  **make deploy**: 在容器云中部署registry

*  **make clear**: 在容器云中清除registy的部署

在容器云没有界面化的团队，可以优先考虑将部署脚本使用这种方式管理，这些Makefile脚本也应该放在git/svn中进行管理。


##### 部署registry
------------------------------------------------------------

使用make将registry部署到容器云中：

```bash
make deploy
```

可以使用kubectl命令查看registry是否已经部署成功：

```bash
kubectl get pods | grep registry

kubectl get svc | grep registry
```


##### 使用私有镜像仓库
------------------------------------------------------------

将certs下的文件domain.crt重新命名为ca.crt，它将作为每个docker daemon访问私有镜像仓库的凭证。

颁发证书的过程：将ca.crt分发给需要访问私有镜像仓库的部门，使用方将ca.crt放置在/etc/docker/下，重启docker daemon即可。


验证私有仓库的使用：

```bash
docker tag busybox registry.docker:5000/busybox

docker push registry.docker:5000/busybox

docker pull registry.docker:5000/busybox
```

上述操作成功完成，说明镜像仓库可以正常使用了~


##### 后记

最新版本的Docker Trust Registry(DTR)相比之前版本有了重大改进，本文中所提及的镜像仓库是指registry:2.1版本。
我们将在详细介绍最新版本DTR在容器云中的部署和使用经验。
