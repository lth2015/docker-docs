Kubernetes入门——常用命令
----------------------------------------------------------------

##### 显示所有Pods
```bash
kubectl get pods 

NAME                 READY     STATUS    RESTARTS   AGE
push-android-35sf0   1/1       Running   0          4h
push-android-mfels   1/1       Running   0          4h
push-ios-8rmps       1/1       Running   0          4h
push-ios-tp4xs       1/1       Running   0          4h
push-portal-58zxs    1/1       Running   0          4h
push-portal-secqd    1/1       Running   0          4h
```

##### 查看Pod的细节
```bash
kubectl describe pods push-android-35sf0 

Name:				push-android-35sf0
Namespace:			default
Image(s):			registry.test.com:5000/push-android:v1
Node:				172.21.1.28/172.21.1.28
Labels:				name=push-android
Status:				Running
Reason:				
Message:			
IP:				172.16.38.2
Replication Controllers:	push-android (2/2 replicas created)
Containers:
  push-android:
    Image:	registry.test.com:5000/push-android:v1
    Limits:
      cpu:		2
      memory:		4Gi
    State:		Running
      Started:		Wed, 04 May 2016 16:47:45 +0800
    Ready:		True
    Restart Count:	0
Conditions:
  Type		Status
  Ready 	True 
No events.
```

##### 查看所有的RC
```bash
kubectl get rc

CONTROLLER     CONTAINER(S)   IMAGE(S)                                 SELECTOR            REPLICAS
push-android   push-android   registry.test.com:5000/push-android:v1   name=push-android   2
push-ios       push-ios       registry.test.com:5000/push-ios:v1       name=push-ios       2
push-portal    push-portal    registry.test.com:5000/push-portal:v1    name=push-portal    2
```

##### 查看RC细节
```bash
kubectl describe rc push-ios

Name:		push-ios
Namespace:	default
Image(s):	registry.test.com:5000/push-ios:v1
Selector:	name=push-ios
Labels:		name=push-ios
Replicas:	2 current / 2 desired
Pods Status:	2 Running / 0 Waiting / 0 Succeeded / 0 Failed
No events.
```

##### 查看所有Service
```bash
kubectl get svc

NAME           LABELS                                    SELECTOR            IP(S)           PORT(S)
kubernetes     component=apiserver,provider=kubernetes   <none>              192.168.3.1     443/TCP
push-android   name=push-android                         name=push-android   192.168.3.73    8080/TCP
push-db2       name=push-db2                             <none>              192.168.3.138   50000/TCP
push-ios       name=push-ios                             name=push-ios       192.168.3.195   8080/TCP
push-portal    name=push-portal                          name=push-portal    192.168.3.219   8080/TCP
```

##### 查看具体Service细节
```bash
kubectl describe svc push-ios

Name:			push-ios
Namespace:		default
Labels:			name=push-ios
Selector:		name=push-ios
Type:			NodePort
IP:			192.168.3.195
Port:			<unnamed>	8080/TCP
NodePort:		<unnamed>	32702/TCP
Endpoints:		172.16.103.3:8080,172.16.49.5:8080
Session Affinity:	None
No events.
```

##### 查看所有endpoint
```bash
kubectl get endpoints

NAME           ENDPOINTS
android-db2    172.17.106.194:50000
kubernetes     172.21.1.11:6443
push-android   172.16.38.2:8080,172.16.49.4:8080
push-db2       172.17.106.194:50000
push-ios       172.16.103.3:8080,172.16.49.5:8080
push-portal    172.16.49.6:8080,172.16.7.2:8080
```

##### 查看具体命名空间下的pods, svc, rc, ep
```bash
kubectl get pods, rc, svc, ep --namespaces=default

NAME                 READY     STATUS    RESTARTS   AGE
push-android-35sf0   1/1       Running   0          4h
push-android-mfels   1/1       Running   0          4h
push-ios-8rmps       1/1       Running   0          4h
push-ios-tp4xs       1/1       Running   0          4h
push-portal-58zxs    1/1       Running   0          4h
push-portal-secqd    1/1       Running   0          4h

CONTROLLER     CONTAINER(S)   IMAGE(S)                                 SELECTOR            REPLICAS
push-android   push-android   registry.test.com:5000/push-android:v1   name=push-android   2
push-ios       push-ios       registry.test.com:5000/push-ios:v1       name=push-ios       2
push-portal    push-portal    registry.test.com:5000/push-portal:v1    name=push-portal    2

NAME           LABELS                                    SELECTOR            IP(S)           PORT(S)
kubernetes     component=apiserver,provider=kubernetes   <none>              192.168.3.1     443/TCP
push-android   name=push-android                         name=push-android   192.168.3.73    8080/TCP
push-db2       name=push-db2                             <none>              192.168.3.138   50000/TCP
push-ios       name=push-ios                             name=push-ios       192.168.3.195   8080/TCP
push-portal    name=push-portal                          name=push-portal    192.168.3.219   8080/TCP
```

##### 查看pod的日志
```bash
kubectl logs push-ios-tp4xs

May 04, 2016 8:49:35 AM org.apache.catalina.startup.Catalina initDirs
SEVERE: Cannot find specified temporary folder at /apps/data/tomcat-temp/
May 04, 2016 8:49:35 AM org.apache.catalina.core.AprLifecycleListener init
INFO: The APR based Apache Tomcat Native library which allows optimal performance in production environments was not found on the java.library.path: /usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
May 04, 2016 8:49:35 AM org.apache.coyote.AbstractProtocol init
INFO: Initializing ProtocolHandler ["http-bio-8080"]
May 04, 2016 8:49:35 AM org.apache.catalina.startup.Catalina load
INFO: Initialization processed in 497 ms
May 04, 2016 8:49:35 AM org.apache.catalina.core.StandardService startInternal
INFO: Starting service Catalina
......
```

##### 进入pod中查看
```bash
kubectl exec -ti push-ios-tp4xs /bin/bash

```
