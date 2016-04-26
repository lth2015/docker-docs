Docker命令极简教程
--------------------------------------------------------

# 镜像相关操作

### 列出本机所有镜像
```bash
docker images 

REPOSITORY                                                     TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
ubuntu                                                         v1                  430ca3f05ab6        6 days ago          719.1 MB
xul487290/centos7                                              v1                  c65d6e695e3d        7 days ago          863.1 MB
ubuntu                                                         latest              6bfe060d0a45        12 days ago         188 MB
centos                                                         7                   49dccac9d468        3 weeks ago         196.7 MB
centos                                                         latest              49dccac9d468        3 weeks ago         196.7 MB
yeepay/images_server                                           v1                  5d2b11130d1f        4 weeks ago         705.3 MB
registry.docker:5000/yeepay/images_server                      v1                  5d2b11130d1f        4 weeks ago         705.3 MB
openresty-images                                               1.9.7               db543ff3876e        4 weeks ago         773.3 MB
openresty                                                      1.9.7               b3814a5377da        4 weeks ago         773.2 MB
yeepay/ubuntu                                                  14.04               15fd68a42608        4 weeks ago         482.3 MB
fastdfs                                                        latest              909cd4487fae        4 weeks ago         424.9 MB
fluentd-writer                                                 latest              989d2d70c430        5 weeks ago         769.6 MB
yeepay/fluentd-ui                                              0.4.2               ec0d9cd60c95        5 weeks ago         769.6 MB
fluentd-ui-dan-init-new                                        0.4.2               5bce5f7a1ef5        5 weeks ago         771.6 MB
```

### 强制删除镜像
```bash
*docker **rmi** -f registry.docker:5000/yeepay/images_server:v1*

Deleted: 52575e11eff08fe82992f032eb070b72f0ae6a564bac2e40cdd2074e1d2eb7eb
Deleted: 35c8419fd008582c47f7210dfbc9a84287d69560aff16260dacf3503cea39d57
Deleted: 1cb0801fc5ec371b69075fa8f1deffaa99cb4e31b321b92ee29e58158aae04e1
Deleted: 9768c23ce62e8e8e11f003a790182dce0d39f53b33aacb517a56a09dc8a7d49a
Deleted: 11b35d6955e9588b90ab5bb2b83ee9f537a706eba8d654f7e865a05199d334e8
Deleted: d2bfe0e7e14c1d99ee19d362716d78db2e57287f10da5af5378a945fce7ae2ac
Deleted: 964316c6ab2d3f65094ecb89672c99d4686d336878bc2ebf5703ed7e6c8292ef
```

### 从docker hub（默认）上搜索镜像
```bash
*docker **search** ubuntu*

NAME                              DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
ubuntu                            Ubuntu is a Debian-based Linux operating s...   3734      [OK]       
ubuntu-upstart                    Upstart is an event-based replacement for ...   61        [OK]       
torusware/speedus-ubuntu          Always updated official Ubuntu docker imag...   25                   [OK]
ubuntu-debootstrap                debootstrap --variant=minbase --components...   24        [OK]       
rastasheep/ubuntu-sshd            Dockerized SSH service, built on top of of...   24                   [OK]
consol/ubuntu-xfce-vnc            Ubuntu container with "headless" VNC sessi...   11                   [OK]
konstruktoid/ubuntu               Ubuntu base image                               0                    [OK]
rallias/ubuntu                    Ubuntu with the needful                         0                    [OK]
teamrock/ubuntu                   TeamRock's Ubuntu image configured with AW...   0                    [OK]
uvatbc/ubuntu                     Ubuntu images with unprivileged user            0                    [OK]
```

## 上传、下载仓库的镜像，必须带上仓库地址的前缀
### 从私有镜像仓库下载镜像: registry.docker是私有仓库的地址
```bash
docker pull registry.docker:5000/yeepay/images_server:v1

v1: Pulling from yeepay/images_server
964316c6ab2d: Pulling fs layer
52575e11eff0: Pulling fs layer
35c8419fd008: Verifying Checksum
35c8419fd008: Download complete
9768c23ce62e: Verifying Checksum
35c8419fd008: Pull complete
52575e11eff0: Pull complete
Digest: sha256:a8da6eda137ee4946c8e916c11258fb4a3587e08a031c5e2a82afe0b04d178b7
Status: Downloaded newer image for registry.docker:5000/yeepay/images_server:v1
```

### 从私有镜像


