Kubernetes 1.2.0 发布，Docker集群管理驶入快车道
------------------------------------------------------ 

#### Kubernetes 1.2版本刚刚发布就给docker生态圈带来不小的震撼，1.2版本的新特点（相对于v1.1.1）：

**一、集群规模显著增加**
集群规模增加了400%达到了1，000台节点，而且，每个集群能够支撑的pod(不是conatiner)个数达到30，000个。每个节点上的kubelet支持的pod个数达到100个，并且性能是原来（v1.1.1）的4倍。

**二、简化应用部署和管理**
1. Dynamic Configuration: 通过新特性ConfigMap API实现，配置作为APIServer的对象来存储，在应用启动时从APIServer拉取相应的配置，而不是以前那种通过环境变量注入注入的方式，这部分会在以后的章节中深入介绍。
2. TrunKey Deployment：通过Extentions API中的Deploy API实现（Beta版）， 预先声明以后，它可以实现应用部署和滚动升级的自动化，包括版本管理、多个副本同步升级、多Pod状态搜集和管理、管理应用的应用可用性管理和版本回滚。1.2版本中kubectl run直接创建deployment。借助deployment能够实现无人值守的上线部署。

**三、自动化集群管理**
1. 在同一个平台上实现区域扩展。一个Service下的Pod会自动扩展到其它可用区，从而做到跨区容错。
2. 简化One-Pod-Per—Node的应用部署管理：通过Extensions API中的DaemonSet API实现，使Kubernetes的调度机制能过保证一个应用在每个节点上运行，并有且只有一个运行，这种场景尤其适用如logging agent这种应用。
3. 支持TLS和七层网络：通过Extentions API中的Ingress API实现，目前为Beta版，基于TLS和HTTP的七层网络路由，可以让Kubernetes更加方便的集成到传统的网络环境中。Ingress使kubernetes集群中的Service很容易的发布到公网。
4. 支持Graceful Node Shutdown（以及Node Drain）。新增的“kubelet drain”命令可以很优雅的将pod从某些节点中驱逐出去，从而为节点维护做准备，比如升级kernel，升级硬件等。
5. 支持自定义的Autoscaling的指标：通过Autoscaling API中的HorizontalPodAutoscaling API实现， Horizontal Pod Autoscaling支持自定义模板，目前为Alpha版，支持根据用户自定义的CPU阈值对应用进行自动伸缩。
6. 新的控制台（dashboard）：kubectl的web界面版本，能够使用dashboard创建rc和扩容。在1.2版本中，APISERVER:8080/ui指向了新的面板（dashboard）而不是1.1以前的kube-ui。Dashboard的界面如下所示：
