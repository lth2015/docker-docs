使用Kubernetes部署Redis主从服务器
========================================================

#### Redis主从集群
-------------------------------------------------------------------

使用Redis主从集群的主要目的在于提高Redis集群的可用性,主节点宕机，从节点可以代替Redis主节点来提供服务。Redis主从集群还可以实现读写分离，即“写“和”读“操作分别作用在主、从节点上。这种模式下，从几点可以有多个，特别是写少读多的场景尤为适合，在具体的场景下，可以适当调节从节点的个数来提高性能。
							
Redis主从结构以及读写分离示意图如下：

						  |============|
						  |    Redis   |
                                             /----|    从节点  |--------
			 |=============|    /     |============|        \         
	|---------|      |    Redis    |---/                             \         |--------|
	|  写端   |------|    主节点   |---                               \--------|  读端  |
	|---------|      |=============|   \      |============|         /         |--------|
	                                    \     |   Redis    |        /
					     \----|   从节点   |--------
						  |============|




#### 在kubernetes中部署Redis主从集群
-------------------------------------------------------------------

使用Kubernetes部署Redis集群，有如下几个优势：

* 部署简单，可以在秒级部署一套Redis主从集群

* 高可用性，Kubernetes集群负责管理Redis主从集群的高可用性

* 多租户隔离，用户可以在自己的隔离区域部署自己的Redis主从集群，其他用户不可见

* 运行时资源定制化，用户可以设定Redis主从节点的资源使用上限，比如CPU，内存，对于Redis，主要是定时内存

* ”缓存场景“：运维成本几乎为零，秒级创建集群，用后即焚

* ”存储场景“: 可以挂在云盘，云盘保证数据高可用，并可以在线扩容

#### 使用实例
-------------------------------------------------------------------

##### 创建Redis主节点控制器

编写rc文件

```bash

cat > redis-master-rc.yaml
```

```yaml

apiVersion: v1
kind: ReplicationController
metadata:
  name: redis-master
  labels:
    name: redis-master
spec:
  replicas: 1
  selector:
    name: redis-master
  template:
    metadata:
      labels:
        name: redis-master
    spec:
      containers:
      - name: master-memory
        image: registry.docker:5000/redis
        ports:
        - containerPort: 6379
        resources:
          limits:
            memory: "4096M"
```
[下载主节点RC文件](redis-master-rc.yaml)

创建redis主节点rc

```bash
kubectl create -f redis-master-rc.yaml
```

##### 创建Redis从节点控制器

```bash

cat > redis-slave-rc.yaml
```

编写rc文件

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: redis-slave
  labels:
    name: redis-slave
spec:
  replicas: 2
  selector:
    name: redis-slave
  template:
    metadata:
      labels:
        name: redis-slave
    spec:
      containers:
      - name: worker
        image: registry.docker:5000/gcr/redis-slave:v1
        env:
        - name: GET_HOSTS_FROM
          value: dns
        ports:
        - containerPort: 6379
        resources:
          limits:
            memory: "4096M"
```
[下载从节点RC文件](redis-slave-rc.yaml)

```bash

kubectl create -f redis-slave-rc.yaml
```


##### 创建Redis主节点访问服务

```bash

cat > redis-master-svc.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-master
  labels:
    name: redis-master
spec:
  type: NodePort
  ports:
  - port: 6379
    targetPort: 6379
    nodePort: 32379
  selector:
    name: redis-master

```
[下载主节点Service文件](redis-master-svc.yaml)

```bash

kubectl create -f redis-master-svc.yaml
```

##### 创建Redis从节点访问服务

```bash

cat > redis-slave-svc.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-slave
  labels:
    name: redis-slave
spec:
  type: NodePort
  ports:
  - port: 6379
    targetPort: 6379
    nodePort: 32380
  selector:
    name: redis-slave

```
[下载从节点Service文件](redis-slave-svc.yaml)

```bash

kubectl create -f redis-slave-svc.yaml
```

到此为止，Kubernetes集群内的redis已经创建完成了，现在可以通过计算节点的32379和32340来分别访问redis的主、从节点了。

#### 使用场景
-------------------------------------------------------------------

我们建议本文的所述的Redis主从结构模式只使用在“缓存”的场景下，另外，“存储”型的使用场景我们会在后续的文章中介绍。
