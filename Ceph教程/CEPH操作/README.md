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

#MONITORING A CLUSTER——监视集群

##INTERACTIVE MODE
```
要运行在交互模式下，键入ceph工具，在命令行中不带任何参数。例如：


cephceph> healthceph> statusceph> quorum_statusceph> mon_status
```
##CHECKING CLUSTER HEALTH——检查集群健康
```
在你开始你的集群，在你开始读取和/或写入数据时，首先检查群集的健康。您可以用以下的内容检查您的CEPH集群的健康：


ceph health



如果指定你的非默认位置的配置或钥匙圈，你可以指定它们的位置：


ceph -c /path/to/conf -k /path/to/keyring health



Ceph的集群开始后，你可能会遇到如 HEALTH_WARN XXX num placement groups stale.的健康警告。稍等片刻，并重新进行检查。当你的集群准备好了， ceph health 应该返回一个消息如 HEALTH_OK。在这一点上，开始使用集群它是好的。
```
##WATCHING A CLUSTER——观看一个集群
```
要观看集群正在发生的事件，打开一个新的终端。请输入：


ceph -w



Ceph的将显示每个版本的安置组地图和自己的状态。例如，一个微小的Ceph集群包括一个monitor，一个元数据服务器和两个的OSD，它们可能会显示执行以下操作：


health HEALTH_OK
monmap e1: 1 mons at {a=192.168.0.1:6789/0}, election epoch 0, quorum 0 a
osdmap e13: 2 osds: 2 up, 2 in
placement groupmap v9713: 384 placement groups: 384 active+clean; 8730 bytes data, 22948 MB used, 264 GB / 302 GB avail
mdsmap e4: 1/1/1 up {0=a=up:active}

    2012-08-01 11:33:53.831268 mon.0 [INF] placement groupmap v9712: 384 placement groups: 384 active+clean; 8730 bytes data, 22948 MB used, 264 GB / 302 GB avail
    2012-08-01 11:35:31.904650 mon.0 [INF] placement groupmap v9713: 384 placement groups: 384 active+clean; 8730 bytes data, 22948 MB used, 264 GB / 302 GB avail
    2012-08-01 11:35:53.903189 mon.0 [INF] placement groupmap v9714: 384 placement groups: 384 active+clean; 8730 bytes data, 22948 MB used, 264 GB / 302 GB avail
    2012-08-01 11:37:31.865809 mon.0 [INF] placement groupmap v9715: 384 placement groups: 384 active+clean; 8730 bytes data, 22948 MB used, 264 GB / 302 GB avail
```
##CHECKING A CLUSTER’S STATUS——检查集群的状态
```
要检查一个集群的状态，执行以下命令：


ceph status



Or:


ceph -s



在交互模式下，输入 status 然后按 Enter键


ceph> status



Ceph的显示集群的状态。例如，一个微小的Ceph集群包括一个monitor，一个元数据服务器和两个的OSD，可能会显示执行以下操作：


health HEALTH_OK
monmap e1: 1 mons at {a=192.168.0.1:6789/0}, election epoch 0, quorum 0 a
osdmap e13: 2 osds: 2 up, 2 in
placement groupmap v9754: 384 placement groups: 384 active+clean; 8730 bytes data, 22948 MB used, 264 GB / 302 GB avail
mdsmap e4: 1/1/1 up {0=a=up:active}
```
##CHECKING OSD STATUS——检查OSD的状态
```
您可以检查OSD，以确保他们在执行：


ceph osd stat



Or:


ceph osd dump



你也可以根据OSDS在CRUSH图中的位置，查看他们的OSDS


ceph osd tree



CEPH打印出一个带有主机、OSDS的树，包括他们是否正常和权重.


# id    weight  type name      up/down reweight
-1      3      pool default
-3      3              rack mainrack
-2      3                      host osd-host
0      1                              osd.0  up      1
1      1                              osd.1  up      1
2      1                              osd.2  up      1



看进行了详细的讨论，请参阅监测的OSD和安置组。
```
##CHECKING MONITOR STATUS——检查监视器的状态
```
如果你的集群里有多个Minitor（可能），你应该检查显示器法定人数状态后在启动群集后，和读取和/或写入数据之前。你也应该定期检查显示器的状态，以确保它们正在运行。

为看到监控图，应执行以下命令：


ceph mon stat



Or:


ceph mon dump



要查看监视器队列的状态，请执行以下命令


ceph quorum_status



Ceph将返回仲裁状态。例如，Ceph的集群，包括三个minitor，可能返回以下内容：


{ "election_epoch": 10,
  "quorum": [
        0,
        1,
        2],
  "monmap": { "epoch": 1,
      "fsid": "444b489c-4f16-4b75-83f0-cb8097468898",
      "modified": "2011-12-12 13:28:27.505520",
      "created": "2011-12-12 13:28:27.505520",
      "mons": [
            { "rank": 0,
              "name": "a",
              "addr": "127.0.0.1:6789\/0"},
            { "rank": 1,
              "name": "b",
              "addr": "127.0.0.1:6790\/0"},
            { "rank": 2,
              "name": "c",
              "addr": "127.0.0.1:6791\/0"}
          ]
    }}


```
##CHECKING MDS STATUS——检查MDS状态
```
元数据服务器为CEPF FS提供元数据服务。元数据服务器有两套状态： up | down and active |inactive.。为了确保您的元数据服务器是 up and active，执行以下命令：


ceph mds stat



要显示的元数据集群的详细信息，请执行以下命令：


ceph mds dump
```
##CHECKING PLACEMENT GROUP STATES——检查放置组状态
```
安置组将对象映射到OSD。当您监视布置组，你会希望他们能 clean and active。要进行了详细的讨论，请参阅监测的OSD和安置组。
```

##USING THE ADMIN SOCKET——使用管理员接口
```
Ceph的管理员接口允许你查询一个守护进程通过一个socket接口。默认情况下，Ceph的接口驻留在/var/run/ceph. 。要访问通过管理员接口访问一个守护进程，你需要登录到主机运行的守护进程，并使用下面的命令：


ceph --admin-daemon /var/run/ceph/{socket-name}



要查看可用管理员接口命令，执行以下命令：


ceph --admin-daemon /var/run/ceph/{socket-name} help



管理socket命令可以让你在运行时显示和设置您的配置。请参阅有关详细信息，查看配置在运行。

此外，您可以直接在运行时设置配置值（即管理员接口绕过监视器monitor，不像 ceph {daemon-type} tell {id} injectargs，依靠monitor，但并不需要直接登录到主机问题）。
```

