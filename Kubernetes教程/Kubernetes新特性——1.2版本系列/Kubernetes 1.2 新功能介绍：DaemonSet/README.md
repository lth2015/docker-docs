Kubernetes 1.2 新功能介绍：DaemonSet
------------------------------------------------------ 
##### 如果您正在使用kubernetes构建你的生产环境，如果您正在寻找如何在每台计算节点上运行一个守护进程（Pod），恭喜您， DaemonSet为您提供了答案！

#### 什么是DaemonSet
------------------------------------------------------ 
DaemonSet能够让所有（或者一些特定）的Node节点运行同一个pod。当节点加入到kubernetes集群中，pod会被（DaemonSet）调度到该节点上运行，当节点从kubernetes集群中被移除，被（DaemonSet）调度的pod会被移除，如果删除DaemonSet，所有跟这个DaemonSet相关的pods都会被删除。

在使用kubernetes来运行应用时，很多时候我们需要在一个区域（zone）或者所有Node上运行同一个守护进程（pod），例如如下场景：

* 每个Node上运行一个分布式存储的守护进程，例如glusterd，ceph

* 运行日志采集器在每个Node上，例如fluentd，logstash

* 运行监控的采集端在每个Node，例如prometheus node exporter，collectd等

* 在简单的情况下，一个DaemonSet可以覆盖所有的Node，来实现Only-One-Pod-Per-Node这种情形；在有的情况下，我们对不同的计算几点进行着色，或者把kubernetes的集群节点分为多个zone，DaemonSet也可以在每个zone上实现Only-One-Pod-Per-Node。

#### 如何使用DaemonSet
------------------------------------------------------ 

在具体介绍如何使用DaemonSet之前，我们先来这样的一个场景：

* java应用已经容器化并运行在kubernetes集群中

* 需要实时采集java应用的日志并做相关分析，对业务监控和预警

* 日志采集使用fluentd + kafka + elastic search + kibana实现

* EFK技术栈都已容器化并运行在kubernetes中

在这样一个具体场景下我们如何对java日志采集？假设现在没有DaemonSet，看我们至少有以下几种方法：

* 将fluentd采集端集成到每个java应用的docker镜像中，随着应用启动而启动

* 将fluentd采集端和java应用运行在一个pod内，随着pod的创建而启动

* 将fluentd运行在每个计算节点（Node）上，把java应用的输出直接输出到控制台，fluentd根据规则采集所有应用的日志

比较上述三种方法，第一种很笨重，应用和fluentd耦合太紧，修改fluentd的配置，就要重新构建镜像；第二种很复杂，不同的应用日志对应不同的fluentd采集规则，耦合的因素仍在；第三种方式最为简单和优雅，但是如何才能将fluentd调度到每台计算节点上？对，就是DaemonSet。

```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: default
spec:
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      dnsPolicy: "ClusterFirst"
      restartPolicy: "Always"
      containers:
      - name: fluentd
        image: fluentd:v0.1.0
        imagePullPolicy: "Always"
        env:
        - name: ES_HOST
          value: http://elasticsearch
        - name: ES_PORT
          value: "9200"
        volumeMounts:
          - mountPath: /var/lib/docker/containers
            name: docker-container
      volumes:
        - hostPath:
            path: /var/lib/docker/containers
          name: docker-container
```

创建DaemonSet：
```bash
kubectl create -f fluentd.yaml

kubectl get ds
NAME           DESIRED   CURRENT   NODE-SELECTOR   AGE
fluentd        4         4         <none>          2h

kubectl get nodes
NAME           STATUS    AGE
10.254.4.144   Ready     3d
10.254.5.143   Ready     3d
10.254.6.106   Ready     3d
10.254.7.106   Ready     3d

kubectl get pods 
NAME                           READY     STATUS    RESTARTS   AGE
fluentd-29xri                  1/1       Running   0          2h
fluentd-j5z1k                  1/1       Running   0          2h
fluentd-oxzki                  1/1       Running   0          2h
fluentd-rsw8f                  1/1       Running   0          2h
```

#### 如何维护DaemonSet的生命周期？
------------------------------------------------------ 

使用命令行工具kubectl来创建、删除、查询、修改DaemonSet：

* 使用kubectl create -f [daemonset file]来创建DaemonSet

* 使用kubectl get/describe [daemonsets name]来查看Daemon

* 在删除DaemonSet时，如果设置级联删除（—casecade=true)时，要先停掉所有被DaemonSet控制的pods；如果按照默认删除方式，先删除DaemonSet，然后再删除所有的pods

在某种程度上，DaemonSet承担了Repliaction Controller的功能，它也能保证相关pods持续运行，如果一个DaemonSet的Pod被杀死、停止、或者崩溃，那么DaemonSet将会重新创建一个新的副本在这台计算节点上


#### 几个简单的DaemonSet例子：
------------------------------------------------------ 

Google serve_hostname 事例：返回每个几点的hostname：

```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  namespace: default
  name: daemons-demo
spec:
  template:
    metadata:
      labels:
        demo: daemons
    spec:
      containers:
      - name: hostname
        image: gcr.io/google_containers/serve_hostname:1.1
```

Nginx-Ingress-Controller的例子：

```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: nginx-ingress-lb
spec:
  template:
    metadata:
      labels:
        name: nginx-ingress-lb
    spec:
      containers:
      - image: gcr.io/google_containers/nginx-ingress-controller:0.4
        name: nginx-ingress-lb
        imagePullPolicy: Always
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10249
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        # use downward API
        env:
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        ports:
        - containerPort: 80
          hostPort: 80
        - containerPort: 443
          hostPort: 4444
        args:
        - /nginx-ingress-controller
        - --default-backend-service=default/default-http-backend
```
