# 在ubuntu14.04 安装ceph10.2.1分布式存储集群
-----------------------------------------------------------

## 对系统进行更新
```
apt-get update
apt-get upgrade
apt-get autoremove
apt-get autoclean
```

## 系统初始化
### 建立信任
```
在每个节点上更改/etc/hosts内容
127.0.0.1       localhost
10.149.149.1    node1
10.149.149.2    node2
10.149.149.3    node3
10.149.149.4    node4
10.149.149.5    node5
10.149.149.6    node6
10.149.149.7    node7
10.149.149.8    node8
10.149.149.9    node9

从node3上建立到其他节点的信任通道
root@node3:/etc/ceph# ssh-keygen  -t rsa
一路回车
root@node3:/etc/ceph# ssh-copy-id  -i ~/.ssh/id_rsa.pub  node{1-9}
```

### 配置dns server

vim /etc/resolvconf/resolv.conf.d/base
nameserver 10.149.151.70

### sysctl 参数调整（在每台机器上执行）

#### 禁用ipv6

```bash
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

#### 信号量和共享内存段设置

```bash
kernel.sem = 250 32000 100 128
kernel.shmall = 2097152
kernel.shmmax = 2147483648
kernel.shmmni = 4096
```

#### 进程可以同时打开的最大句柄数，这个参数直接限制最大并发连接数。

```bash
fs.file-max = 262140
```

#### 对内存和swap进行设置

```bash
vm.swappiness = 1
vm.vfs_cache_pressure = 50
vm.min_free_kbytes = 65536
vm.dirty_background_ratio = 2
vm.dirty_background_bytes = 209715200
vm.dirty_ratio = 40
vm.dirty_bytes = 209715200
vm.dirty_writeback_centisecs = 100
vm.dirty_expire_centisecs = 200
kernel.randomize_va_space = 2
```

#### 内核套接字缓存区大小设置

```bash
net.core.rmem_default = 33554432
net.core.rmem_max = 33554432
net.core.wmem_default = 33554432
net.core.wmem_max = 33554432
```

#### ip协议栈设置

```bash
net.ipv4.tcp_rmem = 10240 87380 33554432
net.ipv4.tcp_wmem = 10240 87380 33554432
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_tw_buckets = 360000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_orphan_retries = 2
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_congestion_control = htcp
```

#### 开启安全补丁自动更新

需先使用如下命令安装无从应答模块:

```bash
apt-get install unattended-upgrades
```

需使用如下命令进行启用:

```bash
dpkg-reconfigure -plow unattended-upgrades
```

执行上诉命令后会自动创建一个 /etc/apt/apt.conf.d/20auto-upgrades 文件，并写入如下配置内容：

```bash
APT::Periodic::Update-Package-Lists"1";
APT::Periodic::Unattended-Upgrade"1";
```

不需要的时候我们可将配置文件删除或清空即可。

#### 禁用RQBALANCE特性

RQBALANCE主要用于优化CPU使用以及降低能耗，RQBALANCE是将中断尽量平均地发送到每个CPU上，主要用于在多个 CPU 间分发硬件中断来提高性能，我建议禁用 RQBALANCE 特性以避免线程被硬件中断。

要禁用 RQBALANCE 特性需要编辑如下配置文件：

```bash
sudo vi /etc/default/irqbalance
```

将 ENABLED 的值改为 0

```bash
ENABLED=0
```

#### 设置进程限制和打开最大文件数

```bash
vim /etc/security/limits.conf 
*               soft   nproc            65535
*               hard  nproc            65535
root            soft   nproc            65535
root            hard  nproc            65535

vim /etc/security/limits.d/90-nofiles.conf
 *               soft   nofile            65535
 *               hard  nofile            65535
 root            soft   nofile            65535
 root            hard  nofile            65535
```

#### 禁用不必要的服务

Ubuntu 的服务运行都需要内存、CPU  和磁盘空间，禁用或删除不必要的服务可以提高系统的整体性能并减小攻击面。使用如下命令我们可以查看到当前系统正在运行哪些服务：

```bash
sudo initctl list | grep running
```

我们可以使用如下命令禁用不需要的服务

```bash
sudo update-rc.d -f 服务名 remove
sudo apt-get purge 服务名
```

#### 设置ntp 时间同步
```bash
vi /var/spool/cron/crontabs/root
*/2 * * * * /usr/sbin/ntpdate 10.31.10.4 >/dev/null 2>&1
```

## 安全设置
### 防止ip欺骗

编辑/etc/host.conf文件


```bash
sudo vim /etc/host.conf
```

将这行插入进去

```
nospoof on
```

### 防止内存攻击

编辑/etc/fstab文件

```bash
sudo vim /etc/fstab
```

将这行插入进去

```bash
tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0
```
### rootkit工具

安装：

```bash
sudo apt-get install rkhunter chkrootkit
```

然后可以运行一次，检查系统是否被感染：

```bash
sudo chkrootkit
```

检查和运行rkhunter：

```bash
sudo rkhunter --update
sudo rkhunter --propupd
sudo rkhunter --check
```

### 分析系统log文件

安装：

```bash
sudo apt-get install logwatch
```

运行：

```bash
sudo logwatch | less
```

### 系统安全检查

安装：

```bash
sudo apt-get install tiger
```

运行：

```bash
sudo tiger
```

## 安装ceph

### 安装ceph有两种方式，一种使用ceph-deploy，另一种是手工在每台节点上安装

### 使用ceph-deploy安装，选其中一台作为ceph-deploy的部署机，这台机器最好不要是mon节点，例如，我们选在172.21.1.11作为部署节点

```bash
apt-get install ceph-deploy -y
```

###安装ceph进程在每个节点（在ceph-deploy节点执行如下如下命令）

```bash
ceph-deploy install ${ceph-node1} ${ceph-node2} ... ${ceph-nodeN}
```

###使用ceph-deploy安装，ceph会使用官方的源，在国内会比较慢，可以考虑使用国内的阿里源，手动安装ceph:

设置ceph apt-get 源（在每个节点上执行）

```bash
vim /etc/apt/sources.list.d/ceph.list
deb http://mirrors.aliyun.com/ceph/debian-jewel/ trusty main
apt-get update
```

在每台节点上手动安装ceph：

```bash
apt-get update && apt-get install ceph -y
```

###用ceph-deploy创建集群，指定几个主机作为初始监视器(mon节点)，使用ceph-deploy new命令，这里，我们选在node2,node3,node4三台机器作为mon节点

注意，ceph-deploy命令要在部署机的/etc/ceph下执行，如果没有/etc/ceph目录，手工创建：

```bash
mkdir /etc/ceph
cd /etc/ceph
ceph-deploy new node2 node3 node4
```

new命令执行完之后，/etc/ceph目录下会有几个文件生成：ceph.conf  ceph-deploy-ceph.log  ceph.mon.keyring

在ceph.conf文件中添加如下三项信息

```bash
vim /etc/ceph/ceph.conf
osd_pool_default_size = 3
public_network = 10.149.149.0/24
rbd_default_features = 3
```

### 用ceph-deploy添加初始化监视器并建立gather the keys

```bash
ceph-deploy mon create-initial
```

查看/etc/ceph下是否有如下文件

```bash
ceph.bootstrap-mds.keyring
ceph.bootstrap-osd.keyring
ceph.bootstrap-rgw.keyring
ceph.client.admin.keyring
```

### ceph-deploy 添加osd 

```bash
ceph-deploy osd prepare node5:/dev/sde1(/dev/sde1一定要经过格式化)
ceph-deploy osd activate node5:/dev/sde1
```

### 把所有节点加入集群中管理

```bash
ceph-deploy admin node{2-9}
``` 

### 更改ceph.client.admin.keyring权限如下:

```bash
chmod +r /etc/ceph/ceph.client.admin.keyring
```

### 检查集群健康

```bash
ceph health
```

### 把osd节点中的挂载点写入/etc/fstab，例如：

```bash
mount 
/dev/sde1 on /var/lib/ceph/osd/ceph-0 type xfs (rw,noatime,inode64)
root@node5:~# cd /dev/disk/by-uuid/
root@node5:/dev/disk/by-uuid# ll
lrwxrwxrwx 1 root root  10 May 18 17:41 048b1ab1-bcbb-40be-b5ff-938b2beb5eed -> ../../sdb1
lrwxrwxrwx 1 root root  10 May 18 17:41 0612404c-6433-460d-9491-876fa0d746ee -> ../../sdd1
lrwxrwxrwx 1 root root  10 May 18 23:03 1e3af90c-8bd3-4db2-912e-b9f7effb142a -> ../../sde1
lrwxrwxrwx 1 root root  10 May 18 17:41 5ab9d0f2-5cdc-43d3-ad88-6fad66c2e42e -> ../../sdc1
lrwxrwxrwx 1 root root  10 May 19 15:46 8846ad7b-afb5-4cab-83ee-1f534e5229eb -> ../../sdg1
lrwxrwxrwx 1 root root  10 May 19 15:47 9a7f61d0-dbb3-4c26-9ef5-c03c058c03f6 -> ../../sdh1
lrwxrwxrwx 1 root root  10 May 18 23:09 fbcfabf9-ce2a-454b-85d9-6101f91d86e9 -> ../../sdf1
```

把/dev/sde1写入/etc/fstab中

```bash
root@node5:/dev/disk/by-uuid# cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sdb1 during installation
UUID=048b1ab1-bcbb-40be-b5ff-938b2beb5eed /               ext4    errors=remount-ro 0       1
tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0

UUID=1e3af90c-8bd3-4db2-912e-b9f7effb142a /var/lib/ceph/osd/ceph-0 xfs rw,noatime,inode64 0 0 
```
