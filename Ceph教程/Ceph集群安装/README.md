Ubuntu上安装Ceph集群
----------------------------------------------------

#### 安装过程简述
----------------------------------------------------

在Ubuntu系统上安装Ceph集群大概需要如下几个步骤：

* 配置国内ceph源（国外的机器不用考虑这步）

* 安装Ceph程序

* 初始化mon节点

* 准备块设备（存储设备或独立分区的硬盘）

* 准备并激活OSD

* 调整PG和PGP的数量

#### 环境准备
----------------------------------------------------


* 准备需要部署分布式存储的物理机

* 每台机器上安装Ubuntu 14.04 v3 x64操作系统

* 挂载独立的块设备作为分布式存储的OSD设备

* 选择一个部署节点（一台物理机，最好不用做Mon节点）

* 建立部署节点到其他节点的信任


#### 配置国内ali源
----------------------------------------------------

##### 创建源文件

```bash
cat ceph.list

deb http://mirrors.aliyun.com/ceph/debian-jewel/ trusty main
```

##### 发布源文件到每个节点

```bash
for i in `seq 1 7`
do
  scp ceph.list root@node$i:/etc/apt/sources.list.d/
  apt-get update
done
```

> 如果在过程中报错，出现不信任的KEY，那么执行下面操作，如果没有异常，请忽略：
> ```bash
> curl https://git.ceph.com/release.asc | sudo apt-key add -
> sudo apt-get update
> ```


#### 安装Ceph程序
----------------------------------------------------

安装Ceph有两种方式，一种是使用ceph-deploy安装，一种是手工安装

##### 使用ceph-deploy安装

先选择一台部署节点，比如，我们选在node01作为部署节点，在它上面安装ceph-deploy程序

```bash
sudo apt-get install ceph-deploy -y 
```

使用ceph-deploy为每台节点安装ceph程序

```bash
ceph-deploy install node1 node2 node3 node4 node5 node6 node7
```

> ceph-deploy默认使用官方的Ceph源，ceph的程序比较大，使用国外的源过程比较慢，我们推荐手工安装ceph的方式

##### 手工安装ceph程序

在每台节点上执行如下命令：

```bash
sudo apt-get install ceph -y
```

安装完ceph后，确认每个节点的ceph版本

```bash
ceph -v

ceph version 10.2.1 (3a66dd4f30852819c1bdaa8ec23c795d4ad77269) 安装Ceph程序
```

检查每个节点的版本是否一致，而且版本要大于等于10.2.1


#### 初始化Mon节点
----------------------------------------------------

##### 使用ceph-deploy创建ceph集群

选择几个主机作为初始监控节点（Mon），假设我们使用node2, node3, node4作为Mon节点

```bash
cd /etc/ceph

ceph-deploy new node2 node3 node4
```

> 注：ceph-deploy命令要在/etc/ceph目录下执行，它默认将配置文件生成在执行ceph-deploy的目录下

new命令执行完毕后，/etc/ceph下会生成几个文件：

```bash
ceph.conf ceph-deploy-ceph.log ceph.mon.keyring
```

修改Ceph的初始配置，在/etc/ceph/ceph.conf下追加如下内容：

```bash
osd_pool_default_min_size = 1
osd_pool_default_size = 3
public_network = 172.21.1.0/24
rbd_default_features = 3
```

##### 使用ceph-deploy初始化集群

```bash
ceph-deploy mon create-initial
```

如果顺利的话，/etc/ceph下会生成如下几个文件：

```bash
ceph.bootstrap-mds.keyring
ceph.bootstrap-osd.keyring
ceph.bootstrap-rgw.keyring
ceph.client.admin.keyring
```

#### 准备块设备
----------------------------------------------------

在每台节点上准备作为ceph集群使用的块设备

例如，每台节点的/dev/sdb作为ceph的存储设备，先分区，然后在格式化：

将/dev/sdb分一个主分区/dev/sdb1

```bash
fdisk /dev/sdb
```

使用xfs文件系统格式化/dev/sdb1

```bash
mkfs.xfs /dev/sdb1
```

#### 创建OSD节点
----------------------------------------------------

选定作为osd节点的主机，这里，我们node1~node7作为osd节点

##### 使每个节点都成为amdin节点

这个操作的目的是在每个节点上都可以执行ceph管理命令

```bash
ceph-deploy amdin node1 node2 node3 node4 node5 node6 node7
```


##### 准备、激活osd设备

准备、激活每台的OSD设备，命令如下：

```bash
ceph-deploy osd prepare node1:/dev/sdb1
ceph-deploy osd activate node1:/dev/sdb1
```


##### 查看ceph osd的状态

```bash
ceph osd tree

ID WEIGHT  TYPE NAME      UP/DOWN REWEIGHT PRIMARY-AFFINITY 
-1 0.20508 root default                                     
-2 0.02930     host node1                                   
0 0.02930         osd.0       up  1.00000          1.00000 
-3 0.02930     host node2                                   
1 0.02930         osd.1       up  1.00000          1.00000 
-4 0.02930     host node3                                   
2 0.02930         osd.2       up  1.00000          1.00000 
-5 0.02930     host node4                                   
3 0.02930         osd.3       up  1.00000          1.00000 
-6 0.02930     host node5                                   
4 0.02930         osd.4       up  1.00000          1.00000 
-7 0.02930     host node6                                   
5 0.02930         osd.5       up  1.00000          1.00000 
-8 0.02930     host node7                                   
6 0.02930         osd.6       up  1.00000          1.00000 
```

#### 调整PG和PGP的数量
----------------------------------------------------

##### 查看集群状态

```bash
ceph -s

cluster eacd6a64-2878-44a7-9ebb-2e8842c71bad
 health HEALTH_WARN
        too few PGs per OSD (27 < min 30)
 monmap e1: 3 mons at {node2=172.21.1.22:6789/0,node3=172.21.1.23:6789/0,node4=172.21.1.24:6789/0}
        election epoch 6, quorum 0,1,2 node2,node3,node4
 osdmap e36: 7 osds: 7 up, 7 in
        flags sortbitwise
 pgmap v102: 64 pgs, 1 pools, 0 bytes data, 0 objects
        36077 MB used, 174 GB / 209 GB avail
              64 active+clean
```

##### 调整数据同步参数，减少数据同步时对业务的影响
当调整 PG/PGP 的值时，会引发ceph集群的 backfill 操作，数据会以最快的数据进行平衡，因此可能导致集群不稳定。 因此首先设置 backfill ratio 到一个比较小的值，通过下面的命令设置：

```bash
ceph tell osd.* injectargs '--osd-max-backfills 1'
ceph tell osd.* injectargs '--osd-recovery-max-active 1'
```

##### 调整PG NUMBER

使用ceph -s命令查看ceph集群的健康状态，集群正处于HEALTH_WARN状态，原因是：too few PGs per OSD (27 < min 30)，pg_num默认为64，建议的pg_num的通过如下方式计算：

SUM(osd)*100/replica最接近2的指数幂的整数

本文的例子中，有7个osd，默认3个副本，那么7*100/3=233.333，最近的2的幂次为256，我们选择256作为目标pg_num的个数

> 调整pg_num要在集群状态为active+clean（使用ceph -s查看）的状态才行，保险起见，先将pg_num调整为128，再调整为256

```bash
ceph osd pool set rbd pg_num 128
```

通过ceph -s查看调整后集群进入active+clean后，继续调整

```bash
ceph osd pool set rbd pg_num 256
```

调整期间，可以不断的使用ceph -s命令查看集群的状态，集群状态恢复到active+clean后，开始调整pgp_num

##### 调整PGP NUMBER

```bash
ceph osd pool set rbd pgp_num 256
```

使用ceph -s或者ceph -w查看集群的状态，直至集群恢复到active+clean状态




##### 删除OSD方法

如果安装过程中出点osd不能激活或者其他报错情况，有可能需要删除osd重新激活，删除osd需要执行如下几个步骤：

使用osd tree命令查看down了的osd，假如为osd.1

```bash
ceph osd tree
```

停掉osd进程（这步可能不需要执行）

```bash
stop ceph-osd id=0
```

先将osd.1踢出集群

```bash
ceph osd out 0
```

从crashmap中移除该osd

```bash
ceph osd crush remove osd.0
```

移除osd.0的信任

```bash
ceph auth del osd.0
```

移除该盘

```bash
ceph osd rm 0
```


##### 重启osd进程

在要重启的节点上执行：

```bash
stop ceph-osd-all
start ceph-osd-all
```

