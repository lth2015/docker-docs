## Kubernetes Deployment简介

Kubernetes Deployment是1.2版本提出来的一个新概念，它表示对Pod和将要代替Replication Controller的Replica Set的描述。

简单回顾一下，在旧版本的Kubernetes里，我们通过kubectl create -f xxx-replicas.yaml的方式来创建Replication Controller，而如今，可采用Deployment的方式进行部署，示例(示例来自Kubernetes官方文档)如下：

```shell
    apiVersion: extensions/v1beta1
	kind: Deployment
	metadata:
	  name: nginx-deployment
	spec:
	  replicas: 3
	  template:
	    metadata:
		  labels:
		    app: nginx
	    spec:
		  containers:
		  - name: nginx
		    image: nginx:1.7.9
			ports:
			- containerPort: 80

```

从这个yaml文件，我们可以看出Deployment的一些端倪：

- 它同样具备apiVersion、kind、metadata、spec等四个属性，这跟之前的版本一致
- 在spec里面，记录了replicas:3的字段，它就像是我们创建的Replication Controller为3个一样
- template就是准备作为生产pod的模板

从上面这些能够看出，它仍然是创建了类似于Replication Controller的东西（在后面会叫做Replica Set），那么这个跟Deployment有什么关系呢？

Deployment它是Deploy——部署的名词形式，也就是说Kubernetes的Deployment是将部署这个操作变成了一个可被操作和控制的东西。操作和控制的方法就是可以使用RESTful API的方式。

下面看一下它是怎么进行部署的：

首先执行了前面的yaml文件，可以得到3个pod，可以通过kubectl describe pod {podname}来确定其镜像版本为nginx:1.7.9，现在准备升级为nginx:1.9.1，那么可以采用如下命令完成：

```shell
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
```

经过短暂的几分钟，再次kubectl describe pod {podname} 会发现它们的镜像确实已经更替为nginx:1.9.1，这就完成了一次升级。

前面曾提到Replica Set，它是未来要代替Replication Controller的东西，可以通过kubectl get rs来列出集群里所有的Replica Set。这时候会发现存在两个与nginx部署相关的rs，名字为nginx-deployment-1436*的rs，它的Desired和Current字段均为3，表示这次部署预计产生3个pod，当前产生了3个pod。而另一个nginx-deployment-1907*的rs它的Desired和Current字段均为0，表示没有任何部署。 nginx-deployment-1436*的rs，是我们更新之后新部署产生的rs，而nginx-deployment-1907*是第一次部署产生的rs，也就是旧版本。

能够更新，也可以进行回滚。

接着使用如下命令完成回滚：

```shell
	kubectl rollout undo deployment/nginx-deployment
```

跟前面一样，这时kubectl describe pod {podname}发现它们的镜像又回归到1.7.9，而查看kubectl get rs可以看到nginx-deployment-1907*开始生效，而刚才升级的nginx-deployment-1436*失效。

升级和回滚的过程都可以通过kubectl describe deployment观察到。



**To be continued**
