Memcached容器化方案
==========================================================

##### Memcached介绍
----------------------------------------------------------

Memcached是一款高性能的Key-Value缓存引擎，它在很多场景


##### Memcached容器化
----------------------------------------------------------

由于Memcached的使用场景是在缓存模式，所以在实际的使用过程中，Memcached异常退出时，Memcached能够自动恢复运行。

下文中将介绍在Kubernetes中如何部署容器化的Memcached。

说明：在本文中提到的Memcached Docker镜像，都是指官方1.4.24版本的镜像，您可以在DockerHub上下载：

```bash
docker pull memcached:1.4.24
```

###### Standalone
----------------------------------------------------------

创建replica为1的ReplicationController描述文件：

```bash
cat standalone/memcached-rc.yaml
```

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: memcached
  labels:
    role: memcached
    mode: standalone
spec:
  replicas: 1
  selector:
    role: memcached
    mode: standalone
  template:
    metadata:
      labels:
        role: memcached
        mode: standalone
    spec:
      containers:
      - name: memcached
        image: "memcached:1.4.24"
        ports:
        - containerPort: 11211
        resources:
          limits:
            cpu: "2"
            memory: "4096M"
```
[Download](standalone/memcached-rc.yaml)

在Kubernetes集群中部署Memcached的ReplcationController:

```bash
kubectl create -f standalone/memcached-rc.yaml
```

创建外部访问的Service文件：

```bash
cat standalone/memcached-svc.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: memcached
  labels:
    name: memcached
spec:
  type: NodePort
  ports:
  - port: 11211
    targetPort: 11211
    nodePort: 32211
    protocol: TCP
  selector:
    role: memcached
    mode: standalone
```

Service使用了NodePort的方式来向集群外部的计算节点提供Memcached的服务，即可以通过Kubernetes的任意一个计算节点（Node）的32211端口即可访问这个memcached服务。


###### Cluster: Consistent Hash
----------------------------------------------------------

###### Cluster: Memcached Agent
----------------------------------------------------------

##### 使用场景推荐
----------------------------------------------------------

在缓存量不大的情景下，我们推荐使用Standalone的方式；如果数据量的规模超过了单机所能承受的范围，我们推荐使用第二种（客户端一致性哈希）的方式部署；Agent的方式不推荐在生产环境中使用。

##### 总结
----------------------------------------------------------

AWS官方推出了基于Memcached的弹性缓存引擎，
