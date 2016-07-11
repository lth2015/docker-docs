## Kubernetes Deployment简介

Kubernetes Deployment是1.2版本提出来的一个新概念，它表示对Pod和将要代替Replication Controller的Replica Set的描述。

简单回顾一下，在旧版本的Kubernetes里，我们通过kubectl create -f xxx-replicas.yaml的方式来创建Replication Controller，而如今，可采用Deployment的方式进行部署，示例如下：

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

**To be continued**
