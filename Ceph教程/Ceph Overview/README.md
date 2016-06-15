CEPH OVERVIEW
----------------------------------------------------

##### 简介
----------------------------------------------------

Ceph是一个被设计用于实现杰出的性能，可靠性，扩展性的分布式的对象存储和文件系统。Ceph是一个统一的存储系统，提供了三种对外访问接口: 对象存储、文件系统、块存储。

* 对象存储：提供原生的或radosgw访问对象的API接口，提供Restful风格的API接口，可以跟swift和s3无缝兼容的API接口

* 块存储：支持精简配置、快照、克隆等

* 文件系统：支持Posix接口，支持快照

Ceph作为一个分布式的存储系统，它有如下特点：

* 高扩展性：使用普通的X86服务器，支持10~1000台服务器，支持TB到PB级的扩展

* 高可靠性：没有单点故障，多数据副本，自动管理，自动修复

* 高性能：数据分布均衡，并行化程度高。对于对象存储和块存储，不需要元数据服务器。


##### Ceph架构
----------------------------------------------------

###### 组件

Ceph的底层是RADOS(a Reliable, Autonomous, Distributed Object Storage)，即是一个可靠的，自主的，分布式对象存储。RADOS由两个组件组成：

* OSD(Object Storage Device): 提供存储资源

* Monitor: 维护整个Ceph集群的全局状态

RADOS具有很强的扩展性和可编程行，Ceph基于RADOS开发了Object Storage, Block Storage, FileSystem。Ceph另外两个组件是：

* MDS: 用于保存CephFS的元数据

* RADOS Gateway: 对外提供REST接口，兼容S3和Swift的API


###### 映射

Ceph的命名空间是(Pool, Object)，每个Object都会映射到一组OSD中，由这组OSD保存这个object：(Pool, Object) -> (Pool, PG) -> OSD set -> Disk。

Ceph中Pools的属性有：Object的副本数，Placement Groups的数量，和所使用的CRUSH Ruleset。

在ceph中，Object先映射到PG（Placement Group），再由PG映射到OSD set。每个Pool有多个PG，每个Object通过计算Hash值并取模得到对应PG。PG再映射到一组OSD（OSD的个数由Pool的副本数决定），第一个OSD是Primary，剩下的都是Replicas。

数据映射(Data Placement)的方式决定了存储系统的性能和扩展性。(Pool, PG)-> OSD set的映射由四个因素决定：

* CURSH算法：一种均匀分布的伪随机数生成算法

* OSD MAP：包含当前所有的Pool的状态和所有OSD的状态

* CRUSH MAP：包含当前磁盘、服务器、机架的层级结构

* CRUSH Rules：数据映射的策略，这些策略可以灵活的调整object存放的区域


Client从Monitor中得到CRUSH MAP、OSD MAP、CRUSH Ruleset，然后使用CRUSH算法计算出Object所在的OSD set。所以，Ceph不需要Name服务器，Client直接跟OSD通信。我们通过几行代码来描述这个映射过程：

```bash
locator = object_name 
obj_hash = hash(locator)
pg = obj_hash % num_pg
osds_for_pg = crush(pg)
# return a list of osds
primary = osds_for_pg[0]
replicas = osds_for_pg[1:]
```

这种映射的优点有一下几点：

* 把object分成组，这降低了需求追踪和处理metadata的数量（在全局的层面上，我们不需要追踪和处理每个object的metadata和placement，只需要管理PG的metadata就可以了。PG的数量级远远低于object的数量级）

* 增加PG的数量可以均衡每个OSD的负载，提高并行度

* 分割故障域，提高数据的可靠性

###### 强一致性

Ceph的读写操作采用Primary-Replica模型，Client只向object所对应的OSD set的Primary发起读写请求，这保证数据的强一致性。由于每个Object都只有一个Primary OSD，因此对Object的更新都是顺序的，不存在同步问题。当Primary收到Object的写请求时，它负责把数据发送给其他Replicas，只要这个数据被保存在所有OSD上时，Primary才应答Ojbect的写请求，这保证了副本的一致性。


###### 容错性

在分布式系统中，常见的故障有网络中断、掉电、服务器宕机、硬盘故障等，Ceph能够容忍这些故障并进行自动修复，保证数据的可靠性和系统的可用性。


##### 优点
----------------------------------------------------

###### 高性能

* Client和Server直接通信，不需要代理和转发

* 多个OSD带来的高并发，Object分布在多个OSD上

* 负载均衡，每个OSD都有权重值（现在以容量为权重），按照权重来进行负载均衡

* Client不需要负责副本的复制（由Primary负责），这降低了client的网络消耗

###### 高可靠性

* 数据多副本，可配置的per-pool副本策略和故障域布局，支持强一致性

* 没有单点故障，可以忍受许多故障的场景，能够防止脑裂，单个组件也可滚动升级并在线替换

* 故障检测和自动恢复，恢复不需要人工介入，在恢复期间，可以保证正常的数据访问

* 并行恢复，该机制极大的降低了数据恢复的时间，提供数据的可靠性


###### 高扩展

* 高度并行，没有单个中心控件组件。所有负载都能动态的划分到各个服务器上，把更多的功能放到OSD上，让OSD更智能

* 自管理，容易扩展、升级、替换。当组件发生故障时，自动进行数据的重新复制。当组件发生变化时（添加/删除），自动进行数据重分布

在单机的情况下，RBD的性能不如传统的RAID10，这是因为RBD的I/O路径很复杂，导致性能不高；Ceph有很好的可扩展性，它的性能会随着磁盘数量线性增加，因此在集群的情况下，RBD的IOPS和吞吐量会高于单机的RAID10（不过性能会受限于网络的带宽）。

如前所述，Ceph优势显著，使用它能够显著降低硬件成本和运维成本。
