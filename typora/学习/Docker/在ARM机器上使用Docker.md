​	

# 在ARM机器上使用Docker

## 测试机信息

| CPU      | FT-1500A 4核 arm64 |
| :------- | :----------------- |
| 内存     | 8G                 |
| OS       | 麒麟V10            |
| 包管理器 | apt                |

## Docker安装(ARM机器上执行)

>[Docker官方文档](https://docs.docker.com/engine/install/)

Docker支持如下系统及架构

![图片](https://uploader.shimo.im/f/EgAMxl7X6CbHg4J9.png!thumbnail?fileGuid=0l3NVKX0BgflYN3R)

国产系统依据安装包的格式选择对应的参考系统即可，如麒麟v10基于ubuntu，可以按[官方文档- Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)进行安装。

## 查看系统信息

```plain
geostar@geostar-ft1500a:~$ cat /proc/version
Linux version 4.4.131-20200515.kylin.desktop-generic (YHKYLIN-OS@Kylin) (gcc version 5.5.0 20171010 (Ubuntu/Linaro 5.5.0-12ubuntu1~16.04) ) #kylin SMP Fri May 15 11:29:10 CST 2020
```

这里可以看到系统是基于ubuntu16.04 的，所以我们添加ubuntu16.04（xenial）的软件源

## 添加软件源

>参考：
>https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/
>https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/

添加清华镜像软件源（arm架构）

```plain
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-security main restricted universe multiverse
```

更新：

```plain
sudo apt-get install apt-transport-https
sudo apt-get clean
sudo apt-get update
```

## 安装Docker

```plain
# 卸载旧版本docker
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# 确认key添加成功(查找：9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88)
sudo apt-key fingerprint 0EBFCD88
```

编辑 /etc/apt/source.list，添加docker软件源（arm64 xenial），并保存

```plain
# https://docs.docker.com/engine/install/ubuntu/
deb [arch=arm64] https://download.docker.com/linux/ubuntu xenial stable
```

安装 docker

```plain
sudo apt-get update
# 安装Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io
# 安装成功，查看版本
docker --version
Docker version 19.03.12, build 48a6621
```

## 在Dockerhub上查找已有的arm镜像

实际上很多镜像都有构建arm版本，对于直接使用的镜像，或者作为Dockerfile中FROM的镜像，如果有对应的arm版本，则可以直接使用，省略构建过程。以[postgres](https://hub.docker.com/_/postgres)为例，在dockerhub上可以看到

![图片](https://uploader.shimo.im/f/mEUtglSoqQESjJXs.png!thumbnail?fileGuid=0l3NVKX0BgflYN3R)

在具体的tag中也可以看到版本的镜像是否支持arm架构

![图片](https://uploader.shimo.im/f/nUbvEcHQlUFCmAkl.png!thumbnail?fileGuid=0l3NVKX0BgflYN3R)

但需要使用的镜像不是我们自己编译的时候，可以通过这种方式来确认该镜像是否有对应的arm版本。