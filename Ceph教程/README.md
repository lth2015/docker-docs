#Ceph操作-操作集群
##操作集群--OPERATING A CLUSTER
###RUNNING CEPH WITH UPSTART
```
ceph的Upstart要列出工作和实例的节点上，执行如下命令:
initctl list | grep ceph

启动所有的守护进程
start ceph-all

停止所有的守护进程
stop ceph-all

按类型启动所有的守护进程
start ceph-osd-all
start ceph-mon-all
start ceph-mds-all

按类型停止所有的守护进程
stop ceph-osd-all
stop ceph-mon-all
stop ceph-mds-all

启动守护进程
start ceph-osd id={id}
start ceph-mon id={hostname}
start ceph-mds id={hostname}

例如
sudo start ceph-osd id=1
sudo start ceph-mon id=ceph-server
sudo start ceph-mds id=ceph-server

停止守护进程
要停止一个特定的守护进程实例Ceph的节点上，执行下列操作之一：


sudo stop ceph-osd id={id}
sudo stop ceph-mon id={hostname}
sudo stop ceph-mds id={hostname}

例如:
sudo stop ceph-osd id=1
sudo start ceph-mon id=ceph-server
sudo start ceph-mds id=ceph-server
```

###RUNNING CEPH-运行CEPH
```
每次您启动，重新启动，并 停止 Ceph的守护进程（或整个集群），你必须至少指定一个选项，一个命令。你也可以指定一个的守护类型或一个守护进程实例。


{commandline} [options] [commands] [daemons]



The ceph options include:

Option

Shortcut

Description

--verbose

-v

使用详细的日志记录

--valgrind

N/A

(Dev and QA only) 使用Valgrind的调试

--allhosts

-a

用ceph.conf上执行所有节点，否则它只本地执行

--restart

N/A

如果核心转储，自动启动deamon

--norestart

N/A

如果核心转储，不要重新启动守护进程

--conf

-c

使用备用配置文件

The ceph commands include:

Command

Description

start

启动守护进程

stop

停止守护进程

forcestop

强制停止所有守护进程，用-9杀死所有

killall

杀手所有特定类型的守护进程

cleanlogs

清除日志记录.

cleanalllogs

清除日志记录中的一切.

Ceph子系统操作，可以针对特定的守护类型，通过添加[守护]选项中的某个特定的服务类型。守护程序类型包括：

- mon
- osd
- mds

RUNNING CEPH WITH SYSVINIT

在红帽，Fedora和CentOS上使用传统的sysvinit是运行Ceph推荐的方式，您也可以使用Debian / Ubuntu的较老的版本。

STARTING ALL DAEMONS——启动所有守护程序

To start your Ceph cluster, execute ceph with the start command. Use the following syntax:


sudo /etc/init.d/ceph [options] [start|restart] [daemonType|daemonID]



下面的例子说明了一个典型的用例：


sudo /etc/init.d/ceph -a start



一旦你执行的 -a（即所有节点上执行），Ceph的应该开始工作。

STOPPING ALL DAEMONS——停止所有守护进程

To stop your Ceph cluster, execute ceph with the stop command. Use the following syntax:


sudo /etc/init.d/ceph [options] stop [daemonType|daemonID]



一旦你执行的-a（即所有节点上执行），Ceph的应停止运行。


sudo /etc/init.d/ceph -a stop



Once you execute with -a (i.e., execute on all nodes), Ceph should stop operating.

STARTING ALL DAEMONS BY TYPE——启动所有守护类型

要启动对当前的Ceph节点特定类型的所有Ceph的守护进程，请使用以下语法：


sudo /etc/init.d/ceph start {daemon-type}
sudo /etc/init.d/ceph start osd



要启动所有Ceph的守护程序在另一个节点上的一种特殊类型，请使用以下语法：


sudo /etc/init.d/ceph -a start {daemon-type}
sudo /etc/init.d/ceph -a start osd



STOPPING ALL DAEMONS BY TYPE——停止所有的守护程序类型

要停止所有对当前的Ceph节点特定类型的Ceph的守护进程，请使用以下语法：


sudo /etc/init.d/ceph stop {daemon-type}
sudo /etc/init.d/ceph stop osd



要停止所有CEPH特定类型的另一个节点上的守护程序，请使用以下语法：


sudo /etc/init.d/ceph -a stop {daemon-type}
sudo /etc/init.d/ceph -a stop osd



STARTING A DAEMON——启动守护进程

要开始在本地Ceph的节点Ceph的守护进程，请使用以下语法：


sudo /etc/init.d/ceph start {daemon-type}.{instance}
sudo /etc/init.d/ceph start osd.0



要开始在另一个节点上Ceph的守护程序，请使用以下语法：


sudo /etc/init.d/ceph -a start {daemon-type}.{instance}
sudo /etc/init.d/ceph -a start osd.0



STOPPING A DAEMON——停止一个守护进程

要停止在本地Ceph的节点Ceph的守护进程，请使用以下语法：


sudo /etc/init.d/ceph stop {daemon-type}.{instance}
sudo /etc/init.d/ceph stop osd.0



要停止在另一个节点上Ceph的守护程序，请使用以下语法：


sudo /etc/init.d/ceph -a stop {daemon-type}.{instance}
sudo /etc/init.d/ceph -a stop osd.0



RUNNING CEPH AS A SERVICE——以一个服务程序运行Ceph

当你用mkcephfsb部署 Argonaut or Bobtail .

STARTING ALL DAEMONS

To start your Ceph cluster, execute ceph with the start command. Use the following syntax:


sudo service ceph [options] [start|restart] [daemonType|daemonID]



The following examples illustrates a typical use case:


sudo service ceph -a start



Once you execute with -a (i.e., execute on all nodes), Ceph should begin operating.

STOPPING ALL DAEMONS

To stop your Ceph cluster, execute ceph with the stop command. Use the following syntax:


sudo service ceph [options] stop [daemonType|daemonID]



For example:


sudo service ceph -a stop



Once you execute with -a (i.e., execute on all nodes), Ceph should shut down.

STARTING ALL DAEMONS BY TYPE

To start all Ceph daemons of a particular type on the local Ceph Node, use the following syntax:


sudo service ceph start {daemon-type}
sudo service ceph start osd



To start all Ceph daemons of a particular type on all nodes, use the following syntax:


sudo service ceph -a start {daemon-type}
sudo service ceph -a start osd



STOPPING ALL DAEMONS BY TYPE

To stop all Ceph daemons of a particular type on the local Ceph Node, use the following syntax:


sudo service ceph stop {daemon-type}
sudo service ceph stop osd



To stop all Ceph daemons of a particular type on all nodes, use the following syntax:


sudo service ceph -a stop {daemon-type}
sudo service ceph -a stop osd



STARTING A DAEMON

To start a Ceph daemon on the local Ceph Node, use the following syntax:


sudo service ceph start {daemon-type}.{instance}
sudo service ceph start osd.0



To start a Ceph daemon on another node, use the following syntax:


sudo service ceph -a start {daemon-type}.{instance}
sudo service ceph -a start osd.0



STOPPING A DAEMON

To stop a Ceph daemon on the local Ceph Node, use the following syntax:


sudo service ceph stop {daemon-type}.{instance}
sudo service ceph stop osd.0



To stop a Ceph daemon on another node, use the following syntax:


sudo service ceph -a stop {daemon-type}.{instance}
sudo service ceph -a stop osd.0
```
