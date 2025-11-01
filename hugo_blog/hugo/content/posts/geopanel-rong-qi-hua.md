---
date: '2021-04-08 15:10:06'
feature: null
hideInList: false
isTop: false
tags: []
title: GeoPanel容器化
---
# GeoPanel容器化概览

此部分主要工作是对GeoPanel中的各服务进行容器化改造，即制作docker镜像，然后对服务进行容器化编排，简化部署步骤，适应更加智能化的部署需求。

主要包括如下部分：

```mermaid
graph 

GeoPanel[GeoPanel容器化]
GeoPanel --> pgspider打包
GeoPanel --> hasura-块数据API引擎
GeoPanel --> 公司自研镜像打包
GeoPanel --> 服务编排
```

* 由于pgspider和hasura的打包过程比较复杂，所以需要这里单独列出；
* 公司自研服务的镜像打包主要是springboot的镜像打包，流程比较简单，所以合并起来说；
* 服务编排中描述当前已经容器化的服务及使用swarm编排的情况；



# GeoPanel容器化-ARM镜像构建-通用步骤

这里的国产化主要指：制作arm版本的镜像

## 前言

移动中心所有服务全部基于docker，故此文档实际叙述的是基于docker部署的服务在arm平台上迁移的基本路径；

1. ARM 版本Docker安装；
2. 构建所有镜像的ARM版本；

## 测试机信息

| CPU      | FT-1500A 4核 arm64 |
| :------- | :----------------- |
| 内存     | 8G                 |
| OS       | 麒麟V10            |
| 包管理器 | apt                |

## ARM机器上安装Docker

>[Docker官方文档](https://docs.docker.com/engine/install/?fileGuid=0l3NVKX0BgflYN3R)

Docker支持如下系统及架构

![图片](https://uploader.shimo.im/f/EgAMxl7X6CbHg4J9.png!thumbnail?fileGuid=0l3NVKX0BgflYN3R)

国产系统依据安装包的格式选择对应的参考系统即可，如麒麟v10基于ubuntu，可以按[官方文档- Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/?fileGuid=0l3NVKX0BgflYN3R)进行安装。

### 查看系统信息

```plain
geostar@geostar-ft1500a:~$ cat /proc/version
Linux version 4.4.131-20200515.kylin.desktop-generic (YHKYLIN-OS@Kylin) (gcc version 5.5.0 20171010 (Ubuntu/Linaro 5.5.0-12ubuntu1~16.04) ) #kylin SMP Fri May 15 11:29:10 CST 2020
```

这里可以看到系统是基于ubuntu16.04 的，所以我们添加ubuntu16.04（xenial）的软件源

### 添加软件源

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

### 安装Docker

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

实际上很多镜像都有构建arm版本，对于直接使用的镜像，或者作为Dockerfile中FROM的镜像，如果有对应的arm版本，则可以直接使用，省略构建过程。以[postgres](https://hub.docker.com/_/postgres?fileGuid=0l3NVKX0BgflYN3R)为例，在dockerhub上可以看到

![图片](https://uploader.shimo.im/f/mEUtglSoqQESjJXs.png!thumbnail?fileGuid=0l3NVKX0BgflYN3R)

在具体的tag中也可以看到版本的镜像是否支持arm架构

![图片](https://uploader.shimo.im/f/nUbvEcHQlUFCmAkl.png!thumbnail?fileGuid=0l3NVKX0BgflYN3R)

但需要使用的镜像不是我们自己编译的时候，可以通过这种方式来确认该镜像是否有对应的arm版本。

## ARM版本镜像构建（非ARM机器上执行）

>参考：
>-[https://github.com/docker/cli/blob/master/experimental/README.md](https://github.com/docker/cli/blob/master/experimental/README.md?fileGuid=0l3NVKX0BgflYN3R)
>-[跨平台构建 Docker 镜像新姿势，x86、arm 一把梭](https://cloud.tencent.com/developer/article/1543689?fileGuid=0l3NVKX0BgflYN3R)

### 构建ARM镜像的两种方式

对于构建镜像的ARM版本，有如下两种方式：

1. 在ARM机器上使用 docker build 进行构建；
2. 在X86/AMD64 的机器上使用 docker buildx 进行交叉构建；

实际测试中发现第一种方式在某些情况下会有问题，建议采用结合采用这二种方式；

关于第二种构建方式，可先阅读[跨平台构建 Docker 镜像新姿势，x86、arm 一把梭](https://cloud.tencent.com/developer/article/1543689?fileGuid=0l3NVKX0BgflYN3R)进行了解，以下简要介绍使用buildx交叉构建的方式；

> **⚠️注意：**
>
> 1. 交叉构建和交叉运行的方式会有一些无法预知的问题，建议简单的构建步骤（如只是下载解压对应架构的文件）可考虑在x86下交叉构建，复杂的（如需要编译的）则直接在arm机器上进行构建；
>
> 2. 实际测试发现，使用[qemu方式](https://github.com/multiarch/qemu-user-static)在x86平台下运行arm版本的镜像时，执行简单的命令可以成功（如arch），执行某些复杂的程序时（如启动java虚拟机），会无响应，所以镜像的验证工作应尽量放置到arm机器上进行；
>
>    上面第二点按如下方式测试： 
>
>    * `docker run --rm --platform=linux/arm64 openjdk:8u212-jre-alpine arch` 可正常输出；
>    * `docker run --rm --platform=linux/arm64 openjdk:8u212-jre-alpine java -version` 则会**卡住**，且需要使用`docker stop`停止容器才可以退出容器；

### 启用试验性功能

>参考：https://docs.docker.com/engine/reference/commandline/cli/#experimental-features
>注意：buildx 仅支持 docker19.03 及以上docker版本

如需使用 buildx，需要开启docker的实验功能后，才可以使用，开启方式：

* 编辑   /etc/docker/daemon.json
* 添加：

```json
{
    "experimental": true
}
```

* 编辑 ～/.docker/config.json 添加：

```json
"experimental" : "enabled"
```

* 重启Docker使生效：
  * sudo systemctl  daemon-reload
  * sudo systemctl  restart docker
* 确认是否开启：
  * docker version -f'{{.Server.Experimental}}'
  * 如果输出true，则表示开启成功

### 使用buildx构建

buildx 的详细使用可参考：[Docker官方文档-Reference-buildx ](https://docs.docker.com/engine/reference/commandline/buildx/?fileGuid=0l3NVKX0BgflYN3R)

#### 创建 buildx 构建器

使用 docker buildx ls 命令查看现有的构建器

```shell
docker buildx ls
```

创建并构建器：

```shell
# 下面的创建命令任选一条符合情况的即可
# 1. 不指定任何参数创建
docker buildx create --use --name multiarch-builder
# 2. 如创建后使用docker buildx ls 发现构建起没有arm架构支持，可使用--platform明确指定要支持的构建类型，如以下命令
docker buildx create --platform linux/arm64,linux/arm/v7,linux/arm/v6 --name multiarch-builder
# 3. 如需在buildx访问私有registry，可使用host模式，并手动指定配置文件，避免buildx时无法访问本地的registry主机 
docker buildx create --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6  --driver-opt network=host --config=/Users/hanlyjiang/.docker/buildx-config.toml --use --name multiarch-builder 
```

buildx-config.toml 配置文件写法类似：

```plain
# https://github.com/moby/buildkit/blob/master/docs/buildkitd.toml.md
# registry configures a new Docker register used for cache import or output.
[registry."zh-registry.geostar.com.cn"]
  mirrors = ["zh-registry.geostar.com.cn"]
  http = true
  insecure = true
```

**启用构建器**

```shell
# 初始化并激活
docker buildx inspect multiarch-builder --bootstrap
```

**确认成功**

```plain
# 使用 docker buildx ls 查看
docker buildx ls 
```

### 修改Dockerfile

对 Dockerfile 的修改，大致需要进行如下操作：

1. 确认基础镜像（FROM）是否有arm版本，如果有，则可以不用改动，如果没有，则需要寻找替代镜像，如没有替代镜像，则可能需要自行编译；
2. 确认dockerfile的各个步骤中是否有依赖CPU架构的，如果有，则需要替换成arm架构的，如在构建jitis的镜像时，Dockerfile中有添加一个amd64架构的软件

`ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz /tmp/s6-overlay.tar.gz`

此时需要替换为下面的地址(注意amd64替换成了aarch64，当然，需要先确认下载地址中有无对应架构的gz包，不能简单做字符替换)：

`ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-aarch64.tar.gz /tmp/s6-overlay.tar.gz`

当然，我们需要确认该软件有此架构的归档包，如果没有，则需要考虑从源码构建；

> **提示：**
>
> 怎么确定一个可执行文件/so库的对应的执行架构？ 可以通过 `file {可执行文件路径}` 来查看，
>
> 如下面时macOS上执行file命令的输入，可以发现macOS上的git程序可以兼容两种架构-`x86_64&arm64e`：
>
> ```shell
> file $(which git)
> /usr/bin/git: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit executable x86_64] [arm64e:Mach-O 64-bit executable arm64e]
> /usr/bin/git (for architecture x86_64):	Mach-O 64-bit executable x86_64
> /usr/bin/git (for architecture arm64e):	Mach-O 64-bit executable arm64e
> ```
>
> 下面的命令则对一个so文件执行了file，可以看到其中的架构信息 `ARM aarch64`：
>
> ```shell
> file /lib/aarch64-linux-gnu/libpthread-2.23.so
> /lib/aarch64-linux-gnu/libpthread-2.23.so: ELF 64-bit LSB shared object, ARM aarch64, version 1 (GNU/Linux), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=880365ebb22114e4c10108b73243144d5fa315dc, for GNU/Linux 3.7.0, not stripped
> ```

### docker buildx 构建arm64镜像的命令

使用 --platform来指定架构，使用 `--push` 或 `--load` 来指定构建完毕后的动作。

```shell
docker buildx build --platform=linux/arm64,linux/amd64 -t xxxx:tag . --push 
```

> 提示：当指定多个架构时，只能使用 --push 推送到远程仓库，无法 --load，推送成功后再通过 docker pull --platform 来拉取指定架构的镜像

### 检查构建成果

1. 通过 `docker buildx imagetools inspect` 命令查看镜像信息，看是否有对应的arm架构信息；
2. 实际运行镜像，确认运行正常；（在arm机器上执行）

>提示：如运行时输出 exec format error 类似错误，则表示镜像中部分可执行文件架构不匹配。



## 在x86上运行arm镜像

可参考 [github/qemu-user-static](https://github.com/multiarch/qemu-user-static) ,简要描述如下：

* 执行如下命令安装：

  `docker run --rm --privileged multiarch/qemu-user-static --reset -p yes`

* 之后即可运行arm版本的镜像，如：

  ```shell
  docker run --rm -t arm64v8/fedora uname -m
  ```

  





# GeoPanel容器化-PGspider镜像构建

## 概览

postgreSQL是一个开源的对象-关系型数据库管理系统，本身提供了x86及arm版本的镜像，那么我们为什么要自己构建对应呢？

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210319141649.png" alt="image-20210319141649673" style="zoom: 50%;" />

因为我们需要使用[pgspider](https://github.com/pgspider/pgspider)，它是给予pg11.6的代码补丁包，所以我们无法直接复用官方的镜像作为基础镜像；

同时，我们还添加了许多pg的插件用于扩展pg的能力，如此，我们必须自行打包pg镜像；

### 镜像需要包括的组件：

| 组件                 | 说明                                                        |
| -------------------- | ----------------------------------------------------------- |
| postgis11.6          | postgreSQL                                                  |
| pgspider             | postgreSQL源码补丁，增强FDW功能                             |
| postgis2.5.3及其依赖 | postgres gis 插件，用于提供geometry相关支持                 |
| postgres_fdw         | postgres_fdw 接入外部postgres数据源                         |
| sqlite_fdw           | sqlite_fdw 接入外部sqlite数据源                             |
| mysql_fdw            | mysql_fdw 接入外部mysql数据源                               |
| oracle_fdw           | oracle_fdw 接入外部oracle数据源                             |
| zdb(es_fdw)          | es_fdw 接入外部es数据源                                     |
| debezium             | 数据库事件转为事件流，配合kafka使用，实现数据实时同步       |
| wal2json             | pg 日志格式转换插件，配合debezium使用，以json格式推送事件流 |



### 整体构建流程

为了构建此镜像，我们制作了若干辅助镜像，包括：

```mermaid
graph 
builder

pgspider-base

postgis-pgspider
```

其中:

* `builder` 镜像为我们的构建器镜像，用做pgspider的编译环境，其中包含pg11.6源码及pgspider源码，及编译好的pg及pgspider，但是我们并未对成果物进行提取，因为此进行要保留所有构建环境，用于后续其他我们附加到pg的插件的构建；
* `pgspider-base` 镜像中安装postgres运行所需要的若干依赖，作为最终镜像构建的基础，避免每次构建镜像都需要执行重复的依赖安装操作；
* `postgis-pgspider` 为我们的最终镜像；基于`pgspider-base`镜像制作，并合并我们使用 `builder` 镜像构建的所有需要的成果文件；

接下来我们详细说明以上几个镜像分别如何构建。



### 现在成果仓库

Gitlab仓库地址：[geopanel-deploy](http://172.17.0.205/dept-development/product-project/geopanel/geopanel-deploy/-/tree/master/build/pgspider)

> 提示： 可查看[仓库目录中的README.md](http://172.17.0.205/dept-development/product-project/geopanel/geopanel-deploy/-/tree/master/build/pgspider) 了解更多信息；

目录结构如下：

```shell
pgspider
    ├── Dockerfile-base.dockerfile - 构建pgspider-base镜像的脚本
    ├── Dockerfile-builder.dockerfile - 构建pgspider-builder镜像的脚本
    ├── Dockerfile-source-arm-add.dockerfile - 构建postgis-pgspider镜像的脚本（用于增量构建）
    ├── Dockerfile-source-arm.dockerfile - 构建postgis-pgspider镜像的脚本
    ├── Dockerfile-source.dockerfile - 构建postgis-pgspider镜像的脚本
    ├── README.md
    ├── binary - 我方有修改的预编译的fdw（x86架构）
    │   ├── mysql_fdw
    │   │   ├── mysql_fdw--1.1.sql
    │   │   ├── mysql_fdw.control
    │   │   └── mysql_fdw.so
    │   ├── oracle
    │   │   └── oracle_fdw.so
    │   └── zdblibs
    │       ├── zombodb--1.0.0a1--1.0.0a2.sql
    │       ├── zombodb--1.0.0a2--1.0.0a3.sql
    │       ├── zombodb--1.0.0a3--1.0.0a4.sql
    │       ├── zombodb--1.0.0a4--1.0.0a5.sql
    │       ├── zombodb--1.0.0a5--1.0.0a6.sql
    │       ├── zombodb--1.0.0a6--1.0.0a7.sql
    │       ├── zombodb--1.0.0a7--1.0.0a8.sql
    │       ├── zombodb--1.0.0a8--1.0.0a9.sql
    │       ├── zombodb--1.0.0a9--10-1.0.0a9.sql
    │       ├── zombodb--10-1.0.0--10-1.0.1.sql
    │       ├── zombodb--10-1.0.0a9--10-1.0.0b1.sql
    │       ├── zombodb--10-1.0.0b1--10-1.0.0b2.sql
    │       ├── zombodb--10-1.0.0b10--10-1.0.0b11.sql
    │       ├── zombodb--10-1.0.0b11--10-1.0.0b12.sql
    │       ├── zombodb--10-1.0.0b12--10-1.0.0.sql
    │       ├── zombodb--10-1.0.0b2--10-1.0.0b3.sql
    │       ├── zombodb--10-1.0.0b3--10-1.0.0b4.sql
    │       ├── zombodb--10-1.0.0b4--10-1.0.0b5.sql
    │       ├── zombodb--10-1.0.0b5--10-1.0.0b6.sql
    │       ├── zombodb--10-1.0.0b6--10-1.0.0b7.sql
    │       ├── zombodb--10-1.0.0b7--10-1.0.0b8.sql
    │       ├── zombodb--10-1.0.0b8--10-1.0.0b9.sql
    │       ├── zombodb--10-1.0.0b9--10-1.0.0b10.sql
    │       ├── zombodb--10-1.0.1--10-1.0.2.sql
    │       ├── zombodb--10-1.0.2--10-1.0.3.sql
    │       ├── zombodb--10-1.0.3--10-1.0.4.sql
    │       ├── zombodb--10-1.0.4--10-1.0.5.sql
    │       ├── zombodb--10-1.0.5--4.0.sql
    │       ├── zombodb--4.0.sql
    │       ├── zombodb.control
    │       └── zombodb.so
    ├── binary-arm 我方有修改的预编译的fdw（arm架构）
    │   ├── mysql_fdw
    │   │   ├── mysql_fdw--1.1.sql
    │   │   ├── mysql_fdw.control
    │   │   └── mysql_fdw.so
    │   └── zdblibs
    │       ├── zombodb--1.0.0a1--1.0.0a2.sql
    │       ├── zombodb--1.0.0a2--1.0.0a3.sql
    │       ├── zombodb--1.0.0a3--1.0.0a4.sql
    │       ├── zombodb--1.0.0a4--1.0.0a5.sql
    │       ├── zombodb--1.0.0a5--1.0.0a6.sql
    │       ├── zombodb--1.0.0a6--1.0.0a7.sql
    │       ├── zombodb--1.0.0a7--1.0.0a8.sql
    │       ├── zombodb--1.0.0a8--1.0.0a9.sql
    │       ├── zombodb--1.0.0a9--10-1.0.0a9.sql
    │       ├── zombodb--10-1.0.0--10-1.0.1.sql
    │       ├── zombodb--10-1.0.0a9--10-1.0.0b1.sql
    │       ├── zombodb--10-1.0.0b1--10-1.0.0b2.sql
    │       ├── zombodb--10-1.0.0b10--10-1.0.0b11.sql
    │       ├── zombodb--10-1.0.0b11--10-1.0.0b12.sql
    │       ├── zombodb--10-1.0.0b12--10-1.0.0.sql
    │       ├── zombodb--10-1.0.0b2--10-1.0.0b3.sql
    │       ├── zombodb--10-1.0.0b3--10-1.0.0b4.sql
    │       ├── zombodb--10-1.0.0b4--10-1.0.0b5.sql
    │       ├── zombodb--10-1.0.0b5--10-1.0.0b6.sql
    │       ├── zombodb--10-1.0.0b6--10-1.0.0b7.sql
    │       ├── zombodb--10-1.0.0b7--10-1.0.0b8.sql
    │       ├── zombodb--10-1.0.0b8--10-1.0.0b9.sql
    │       ├── zombodb--10-1.0.0b9--10-1.0.0b10.sql
    │       ├── zombodb--10-1.0.1--10-1.0.2.sql
    │       ├── zombodb--10-1.0.2--10-1.0.3.sql
    │       ├── zombodb--10-1.0.3--10-1.0.4.sql
    │       ├── zombodb--10-1.0.4--10-1.0.5.sql
    │       ├── zombodb--10-1.0.5--4.0.sql
    │       ├── zombodb--4.0.sql
    │       ├── zombodb.control
    │       └── zombodb.so
    ├── config - 数据库配置文件
    │   ├── pg_hba.conf
    │   ├── pg_hba.conf.raw
    │   └── postgresql.conf
    ├── debezium - debezium插件的源码及wal2json的源码
    │   ├── README.md
    │   ├── init-debezium.sh
    │   ├── postgres-decoderbufs.tar.gz
    │   ├── test.sql
    │   └── wal2json-wal2json_1_0.tar.gz
    ├── docker-entrypoint.sh - 入口启动脚本
    ├── draft - 临时文件，可忽略
    │   ├── Dockerfile
    │   ├── Dockerfile-all-in-one.dockerfile
    │   ├── Dockerfile-apt.dockerfile
    │   ├── Dockerfile-postGIS.dockerfile
    │   └── README.md
    ├── initdb-fdw.sh - 初始化fdws脚本
    ├── oracle
    │   ├── instantclient-basic-linux.x64-12.2.0.1.0.zip
    │   ├── instantclient-sdk-linux.x64-12.2.0.1.0.zip
    │   ├── instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
    │   └── oracle_fdw-ORACLE_FDW_2_2_0.tar.gz
    ├── postgis - postgis及其依赖库源码及初始化脚本
    │   ├── CGAL-4.11.2.tar.xz
    │   ├── SFCGAL-1.3.5.tar.gz
    │   ├── boost_1_67_0.tar.gz
    │   ├── gdal-3.0.2.tar.gz
    │   ├── geos-3.8.0.tar.bz2
    │   ├── initdb-postgis.sh
    │   ├── libspatialite-4.3.0a.tar.gz
    │   ├── mpfr-4.0.2.tar.gz
    │   ├── postgis-2.5.2.tar.gz
    │   ├── postgis-2.5.3.tar.gz
    │   ├── proj-6.2.0.tar.gz
    │   └── update-postgis.sh
    └── test.sql - 测试是否正常工作的sql文件

```



## builder镜像构建

builder镜像的打包脚本为 `Dockerfile-builder.dockerfile`，我们使用相同的脚本构建arm及x86版本的镜像；

### 打包命令

```shell
TAG=$(date +%Y%m%d)
# X86 镜像构建
docker build -t pgspider-builder:$TAG -f Dockerfile-builder.dockerfile ./
## arm
docker buildx build \
      --progress plain \
      --platform=linux/arm64 \
      -t pgspider-builder-arm:latest \
      -f Dockerfile-builder.dockerfile ./ --load
```

### 脚本详解

> 文件地址： [Dockerfile-builder.dockerfile](http://172.17.0.205/dept-development/product-project/geopanel/geopanel-deploy/-/blob/master/build/pgspider/Dockerfile-builder.dockerfile)

脚本内容如下，请查看脚本中的注释：

这里需要注意的是，我们编译后的成果其实位于 `/usr/local/pgspider` 目录中，这个后面会用到；

```dockerfile
#
# pgspider 源码构建镜像，包含pgspider源码及中间临时成果，用于后续构建其他fdw及提取pgspider可运行镜像
#
## 使用 debian:stretch-slim 作为基础
FROM debian:stretch-slim
RUN apt-get update && apt-get install -y build-essential git libossp-uuid-dev wget libreadline-dev  zlib1g-dev
## 设置工作目录为app
WORKDIR /app
## 
# 来源 https://github.com/docker-library/postgres/blob/master/11/Dockerfile
## 配置locales为en_US.utf8
RUN set -eux; \
   if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
       # if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
       grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
       sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
       ! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
   fi; \
   apt-get update; apt-get install -y locales; rm -rf /var/lib/apt/lists/*; \
   localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

## 安装所需依赖
RUN set -eux; \
   apt-get update; \
# install "nss_wrapper" in case we need to fake "/etc/passwd" and "/etc/group" (especially for OpenShift)
# https://github.com/docker-library/postgres/issues/359
# https://cwrap.org/nss_wrapper.html
   apt-get install -y --no-install-recommends libnss-wrapper; \
   rm -rf /var/lib/apt/lists/*
  
## 获取pg11.6源码
RUN wget https://ftp.postgresql.org/pub/source/v11.6/postgresql-11.6.tar.gz
## 获取pgspider的补丁包
RUN wget https://raw.githubusercontent.com/pgspider/pgspider/master/pgspider.patch
## 解压pg
RUN tar xvf postgresql-11.6.tar.gz
## 应用pgspider源码补丁包到pg源码
RUN patch -p1 -d postgresql-11.6 < /app/pgspider.patch
## 开始执行编译，可参考pgspider github页面
RUN cd postgresql-11.6 \
   && ./configure --with-uuid=ossp \
   ## 编译PG并install
   && make && make install \
   ## 编译pgspider_core_fdw 并install
   && cd /app/postgresql-11.6/contrib/pgspider_core_fdw \
   && make && make install \
   ## 编译 pgspider_fdw 并install
   && cd /app/postgresql-11.6/contrib/pgspider_fdw \
   && make && make install \
   ## 编译postgres_fdw并install
   && cd /app/postgresql-11.6/contrib/postgres_fdw \
   && make && make install \
   ## 编译contrib并install
   && cd /app/postgresql-11.6/contrib \
   && make && make install
ENV PATH $PATH:/usr/local/pgspider/bin
```



## base镜像构建

base 镜像的打包脚本为 `Dockerfile-base.dockerfile`，我们使用相同的脚本构建arm及x86版本的镜像；

### 打包命令

```shell
TAG=$(date +%Y%m%d)
# 打包x86版本
docker build -t pgspider-base:$TAG -f Dockerfile-base.dockerfile ./
## arm
docker buildx build \
      --progress plain \
      --platform=linux/arm64 \
      -t pgspider-base-arm:$TAG \
      -f Dockerfile-base.dockerfile ./ --load
      
## 也可使用一条命令构建两个版本的镜像，此时必须在镜像tag中包含可用的docker registry地址，并且使用 `--push` 参数在打包完成后推送镜像到registry
## 完成后再拉取到本地进行测试
docker buildx build \
      --progress plain \
      --platform=linux/arm64,linux/amd64 \
      -t hanlyjiang/pgspider-base-arm:$TAG \
      -f Dockerfile-base.dockerfile ./ --push
```



### 脚本详解

> 脚本在线地址： [gitlab](http://172.17.0.205/dept-development/product-project/geopanel/geopanel-deploy/-/blob/master/build/pgspider/Dockerfile-base.dockerfile)

```dockerfile
#
# PGSpider 基础镜像
# 1. 安装需要的依赖，避免后续每次构建时都需要安装（依赖部分可能需要精简）
# 2. 添加对应的postgres用户
FROM debian:stretch-slim

## 安装必要依赖
RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

## 安装依赖，并创建pg需要的用户及组id，创建pg需要的目录并赋予对应的组和id改目录的权限
# explicitly set user/group IDs
RUN set -eux; \
	groupadd -r postgres --gid=999; \
# https://salsa.debian.org/postgresql/postgresql-common/blob/997d842ee744687d99a2b2d95c1083a2615c79e8/debian/postgresql-common.postinst#L32-35
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
# also create the postgres user's home directory with appropriate permissions
# see https://github.com/docker-library/postgres/issues/274
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql

## 添加 gosu 用于后续方便使从root降权限
# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.12
RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates wget; \
	rm -rf /var/lib/apt/lists/*; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true

## 配置locale
# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN set -eux; \
	if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
# if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
		grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
		sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
		! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
	fi; \
	apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

## 安装必要依赖库
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
# install "nss_wrapper" in case we need to fake "/etc/passwd" and "/etc/group" (especially for OpenShift)
# https://github.com/docker-library/postgres/issues/359
# https://cwrap.org/nss_wrapper.html
		libnss-wrapper \
# install "xz-utils" for .sql.xz docker-entrypoint-initdb.d files
		xz-utils \
	; \
	rm -rf /var/lib/apt/lists/*

## 配置信任的gpg key
RUN set -ex; \
# pub   4096R/ACCC4CF8 2011-10-13 [expires: 2019-07-02]
#       Key fingerprint = B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8
# uid                  PostgreSQL Debian Repository
	key='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --batch --export "$key" > /etc/apt/trusted.gpg.d/postgres.gpg; \
	command -v gpgconf > /dev/null && gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
	apt-key list

ENV PG_MAJOR 11
ENV GOSU_VERSION 1.11

## 添加postgresql软件源仓库
RUN set -ex; \
	\
# see note below about "*.pyc" files
	export PYTHONDONTWRITEBYTECODE=1; \
	\
	dpkgArch="$(dpkg --print-architecture)"; \
	case "$dpkgArch" in \
		amd64 | i386 | ppc64el) \
# arches officialy built by upstream
			echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main $PG_MAJOR" > /etc/apt/sources.list.d/pgdg.list; \
			echo "apt-get update;"; \
			;; \
		*) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from their 
        echo "deb-src http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main $PG_MAJOR" > /etc/apt/sources.list.d/pgdg.list; \
        ;; \
	esac;

# 添加必要的工具及依赖
RUN apt-get update && apt-get install -y --no-install-recommends unzip wget \
    libreadline-dev \
    libmongoc-1.0-0  \
    libmysql++-dev \
    libsqlite3-dev libspatialite7 \
    libsybdb5 \
    libhiredis-dev \
    freetds-dev freetds-common libcurl4-nss-dev unixodbc-dev  \
    # libaio-dev - oracle_fdw
    libaio-dev \
    && rm -rf /var/lib/apt/lists/*;

```



## pgspider镜像构建

对x86及arm架构，我们分别编写了对应的脚本，其中x86使用 Dockerfile-source.dockerfile 脚本构建，arm使用Dockerfile-source-arm.dockerfile脚本构建；

### 构建命令

```shell
TAG=$(date +%Y%m%d)
docker build -t pgspider-postgis:$TAG -f Dockerfile-source.dockerfile ./
## arm 
docker buildx build \
      --progress plain \
      --build-arg --platform=linux/arm64 \
      -t pgspider-postgis:arm-$TAG \
      -f Dockerfile-source-arm.dockerfile ./ --load
```

### 脚本详解

* pgspider 镜像构建的步骤较多，我们采取分步骤构建的方式使用中间构建过程来减小最终镜像的层数及大小；

* 另外两个平台的构建脚本大体一致，仅有少数过程有差异，我们先使用x86版本的对整体过程进行说明，后面我们会说明两个平台之间的差异；

#### x86 构建脚本

> 提示：脚本中有多个FROM段，此为Docker多阶段构建可以通过[此文章](https://zhuanlan.zhihu.com/p/33795821)进行了解；

主要过程如下：

**第一阶段：**

1. 从builder镜像开始，由于builder镜像中已经包含pg源码还有已经编好的pg及pgspider等，所以我们无需再编译这些；

2. 编译 mysql_fdw 及 sqlite_fdw（注意，其中mysql_fdw其实可以不用了）

3. 安装 oracle_fdw 所需要的依赖（oracle instant client）；

4. 编译postgis，编译postgis需要先编译其依赖（mpfr，boost_1_67_0，CGAL等），这里我们将postgis的所有的依赖及其自身的安装路径都设置为 `/usr/local/pgspider/plugin/postgis`

   ```shell
   ENV PGIS_INSTALL_PATH /usr/local/pgspider/plugin/postgis
   ```

5. 编译并安装 debezium及wal2json；

6. 使用strip对postgis目录中的所有so库进行大小优化

7. 将预先编译好的 几个fdw的so及配置及sql文件拷贝到指定目录以安装或更新这些fdw；

**第二阶段：**

1. 从 pgspider-base 镜像开始构建；
2. 安装必要的依赖；
3. 从第一阶段拷贝出oracle_instantclient的依赖；（arm版本无此步骤，因为oracle_instantclient不支持arm架构）
4. 从第一阶段拷贝出 /usr/local/pgspider 目录，其中包含了我们之前编译的的成果；
5. 添加各种初始化脚本，并为pg运行做必要的准备，可以参考官方dockerfile；
6. 最后使用 EXPOSE 暴露 5432端口，使用 CMD ["postgres"] 默认启动pg；

```dockerfile
# ---
# 构建融合中心pg镜像(从源码构建）：
# 1. 构建pgspider（pgspider-base镜像中包含）
# 2. 添加若干fdw：mysql_fdw,oracle_fdw,sqlite_fdw,postgres_fdw（postgres_fdw包含于pgspider-base镜像中）
# 3. 添加 postgis
#
# 参考：
# - https://github.com/rongfengliang/pgspider-docker/blob/master/Dockerfile-all-in-one
# ---
## 构建 sqlite_fdw  mysql_fdw  oracle_fdw
#FROM pgspider-builder as build
FROM hanlyjiang/pgspider-builder as build

WORKDIR /app

## PG 主版本
ENV PG_MAJOR 11
ENV PG_VERSION 6

## 安装构建所需的依赖
RUN apt-get update \
    && apt-get install -y automake autoconf libtool pkg-config libssl-dev \
    libsqlite3-dev libsybdb5 freetds-dev freetds-common \
    libhiredis-dev libcurl4-nss-dev unixodbc-dev libaio-dev \
    # for oracle
    unzip \
#    libmysql++-dev
    libmysql++-dev \
    # libspatialite sqlite 空间数据支持 - https://packages.debian.org/stretch/libspatialite7
    libspatialite7
#    postgresql-${PG_MAJOR}-python-multicorn python-pip

## 安装 sqlite_fdw
RUN git clone https://github.com/pgspider/sqlite_fdw.git /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/sqlite_fdw
RUN cd /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/sqlite_fdw && make && make install

## 安装 mysql_fdw
RUN git clone https://github.com/pgspider/mysql_fdw.git /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/mysql_fdw
RUN cd /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/mysql_fdw && make && make install

## 安装 Install es_fdw
#RUN pip install pg_es_fdw

## 安装 oracle_fdw
### 安装oracle instantclient
# https://github.com/rongfengliang/pgspider-docker/blob/master/Dockerfile-all-in-one-oracle
ADD oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip
ADD oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip
ADD oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
RUN unzip /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /usr/local/
RUN ln -s /usr/local/instantclient_12_2 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus
ENV ORACLE_HOME=/usr/local/instantclient
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/instantclient

#RUN wget -O /app/ORACLE_FDW_2_2_0.tar.gz https://github.com/laurenz/oracle_fdw/archive/ORACLE_FDW_2_2_0.tar.gz \
ADD oracle/oracle_fdw-ORACLE_FDW_2_2_0.tar.gz /app/
RUN mv /app/oracle_fdw-ORACLE_FDW_2_2_0 /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/oracle_fdw \
    && cd /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/oracle_fdw \
    && make && make install

##  POSTGIS 构建
### 安装依赖
RUN apt-get install  -y --no-install-recommends \
    libtool libxml2 libxml2-dev \
    libxslt1.1 libxslt1-dev \
    libjson-c-dev libgmp-dev \
    cmake libmpfr-dev

### 创建临时工作目录
RUN mkdir /app/postgis/
ENV PGIS_INSTALL_PATH /usr/local/pgspider/plugin/postgis
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PGIS_INSTALL_PATH/lib
ENV PATH $PGIS_INSTALL_PATH/bin:/usr/local/pgspider/bin:$PATH

### 构建 mpfr
ADD postgis/mpfr-4.0.2.tar.gz /app/postgis/
RUN cd /app/postgis/mpfr-4.0.2 \
    && ./configure --prefix=$PGIS_INSTALL_PATH \
    && make && make install

### 构建 boost
ADD postgis/boost_1_67_0.tar.gz /app/postgis/
RUN cd /app/postgis/boost_1_67_0  \
    && ./bootstrap.sh -prefix=$PGIS_INSTALL_PATH && ./b2 && ./b2 install

### 构建 CGAL
ADD postgis/CGAL-4.11.2.tar.xz /app/postgis/
RUN cd /app/postgis/CGAL-4.11.2  \
    && cmake -DCMAKE_INSTALL_PREFIX=$PGIS_INSTALL_PATH . && make -j$(nproc) && make install

### 构建 SFCGAL
ADD postgis/SFCGAL-1.3.5.tar.gz /app/postgis/
RUN cd /app/postgis/SFCGAL-1.3.5 \
    && cmake -DCMAKE_INSTALL_PREFIX=$PGIS_INSTALL_PATH . && make -j$(nproc) && make install

### 构建 proj，需要先安装sqlite3
RUN apt-get install  -y --no-install-recommends sqlite3 libsqlite3-dev
ADD postgis/proj-6.2.0.tar.gz /app/postgis/
RUN cd /app/postgis/proj-6.2.0  \
    && ./configure --prefix=$PGIS_INSTALL_PATH && make -j$(nproc) && make install

### 构建 gdal
ADD postgis/gdal-3.0.2.tar.gz /app/postgis/
RUN cd /app/postgis/gdal-3.0.2  \
    && ./configure --prefix=$PGIS_INSTALL_PATH \
    # proj 无法直接找到，必须手动指定（可能是需要配置include），这里我们直接指定，postgis里面同
        --with-proj=$PGIS_INSTALL_PATH \
    && make -j$(nproc) && make install

### 构建 geos
ADD postgis/geos-3.8.0.tar.bz2 /app/postgis/
RUN cd /app/postgis/geos-3.8.0  \
    && ./configure --prefix=$PGIS_INSTALL_PATH  \
    && make -j$(nproc) && make install

### 构建 postgis
ADD postgis/postgis-2.5.3.tar.gz /app/postgis/
RUN cd /app/postgis/postgis-2.5.3  \
    && ./configure --prefix=$PGIS_INSTALL_PATH \
    # 几个config命令直接配置PATH后可以找到，所以不在使用参数配置
#        --with-pgconfig=/usr/local/pgspider/bin/pg_config \
#        --with-geosconfig=$$PGIS_INSTALL_PATH/bin/geos-config \
#        --with-gdalconfig=$$PGIS_INSTALL_PATH/bin/gdal-config \
        --with-projdir=$PGIS_INSTALL_PATH \
    && make -j$(nproc) && make install


RUN set -ex \
#    && sed -i "s/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
#    && sed -i "s/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g"  /etc/apt/sources.list \
    # https://packages.debian.org/stretch-backports/libboost-atomic1.67-dev
#    && echo "deb http://deb.debian.org/debian stretch-backports main" >>/etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      libprotobuf-c-dev \
#      postgresql-12-wal2json \
      protobuf-c-compiler \
      && rm -rf /var/lib/apt/lists/*

## 添加 debezium https://github.com/eulerto/wal2json
ADD debezium/wal2json-wal2json_1_0.tar.gz /app/debezium/
RUN cd /app/debezium/wal2json-wal2json_1_0 \
    && make -j$(nproc) && make install

## 添加 debezium - decoderbufs 研究院修改版本
ADD debezium/postgres-decoderbufs.tar.gz /app/debezium/
RUN cd /app/debezium/postgres-decoderbufs \
    && cd proto \
    && protoc-c --c_out=../src/proto pg_logicaldec.proto \
    && cd .. \
    ## make -B： 研究院提供的包中可能带有之前make的成果，此时不会重新构建，所以我们使用 -B 来强制重新构建，也可以先执行 make clean
    && make -B -j$(nproc) && make install

## 添加 debezium - decoderbufs 官方版本
#ADD debezium/postgres-decoderbufs-v.1.3.1.Final.tar.gz /app/debezium/
#RUN cd /app/debezium/postgres-decoderbufs-v.1.3.1.Final \
#    && make -j$(nproc) && make install

### 对构建postgis过程中生成的文件进行优化，以减小大小
#### 1. 移除静态链接库文件；2. 使用strip命令对动态链接库so文件进行符号表优化
RUN cd $PGIS_INSTALL_PATH/lib \
    && rm *.a \
    && find . -type f -name "lib*.so.*" -exec strip {} +
#    && cd /usr/local/pgspider/plugin/proj/lib \
#    && rm *.a && find . -type f -name "lib*.so.*" -exec strip {} +

## 拷贝mysql
COPY binary/mysql_fdw/*.sql         /usr/local/pgspider/share/postgresql/extension/
COPY binary/mysql_fdw/*.control    /usr/local/pgspider/share/postgresql/extension/
COPY binary/mysql_fdw/*.so         /usr/local/pgspider/lib/postgresql/
## 拷贝zombodb
COPY binary/zdblibs/*.sql          /usr/local/pgspider/share/postgresql/extension/
COPY binary/zdblibs/*.control      /usr/local/pgspider/share/postgresql/extension/
COPY binary/zdblibs/*.so           /usr/local/pgspider/lib/postgresql/

## 拷贝oracle fdw
COPY binary/oracle/*.so           /usr/local/pgspider/lib/postgresql/

# ------ 开始构建实际发布的镜像 ------
FROM hanlyjiang/pgspider-base:latest
LABEL maintainer="jianghanghang@geostar.com.cn"

## 设置若干ENV，指示版本信息
# buster 上为12 ，stretch 上为 12
# ENV CDAL_VERSION 12
ENV BOOST_VERSION=1.67.0 \
    PG_MAJOR=11 \
    PG_VERSION=6 \
    POSTGIS_VESION=2.5.3

## 安装必要的依赖（TODO: 部分依赖可能不需要）
RUN set -ex \
#    && sed -i "s/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
#    && sed -i "s/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g"  /etc/apt/sources.list \
    # https://packages.debian.org/stretch-backports/libboost-atomic1.67-dev
#    && echo "deb http://deb.debian.org/debian stretch-backports main" >>/etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      libcurl3-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c3 \
      # buster 上为6，stretch上为4
#      libmpfr6 \
#      libmpfr4 \
      libprotobuf-c1 \
      libtiff5 \
      libxml2 \
      # for debezium
      postgresql-12-wal2json \
      libprotobuf-c-dev \
      && rm -rf /var/lib/apt/lists/*

## 安装oracle_fdw需要的 Oracle instantclient
### from: https://github.com/rongfengliang/pgspider-docker/blob/master/Dockerfile-all-in-one-oracle
COPY --from=build  /usr/local/instantclient_12_2 /usr/local/instantclient_12_2
RUN set -ex \
    && ln -s /usr/local/instantclient_12_2 /usr/local/instantclient \
    && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

## 设置若干运行需要的环境变量
ENV ORACLE_HOME=/usr/local/instantclient \
    PGIS_INSTALL_PATH=/usr/local/pgspider/plugin/postgis
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PGIS_INSTALL_PATH/lib:/usr/local/instantclient \
    PATH=$PGIS_INSTALL_PATH/bin:/usr/local/pgspider/bin:$PATH
## 拷贝构建好的成果
COPY --from=build  /usr/local/pgspider /usr/local/pgspider
## 入口脚本添加
COPY docker-entrypoint.sh /usr/local/bin/
RUN mkdir /docker-entrypoint-initdb.d \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh /

## postgis 脚本添加
### from： https://github.com/postgis/docker-postgis/blob/master/Dockerfile.master.template
COPY ./postgis/initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./postgis/update-postgis.sh /usr/local/bin
## 添加扩展初始化脚本
COPY ./initdb-fdw.sh /docker-entrypoint-initdb.d/00_fdws.sh
COPY ./debezium/init-debezium.sh /docker-entrypoint-initdb.d/01_debezium.sh

## make the sample config easier to munge (and "correct by default")
RUN sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/local/pgspider/share/postgresql/postgresql.conf.sample; \
   grep -F "listen_addresses = '*'" /usr/local/pgspider/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql  && chmod 2777 /var/run/postgresql

ENV PGDATA /var/lib/postgresql/data
## 设置目录权限 - this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"
VOLUME /var/lib/postgresql/data

ENTRYPOINT ["docker-entrypoint.sh"]

# COPY FROM https://github.com/docker-library/postgres/blob/master/11/Dockerfile
# We set the default STOPSIGNAL to SIGINT, which corresponds to what PostgreSQL
# calls "Fast Shutdown mode" wherein new connections are disallowed and any
# in-progress transactions are aborted, allowing PostgreSQL to stop cleanly and
# flush tables to disk, which is the best compromise available to avoid data
# corruption.
#
# Users who know their applications do not keep open long-lived idle connections
# may way to use a value of SIGTERM instead, which corresponds to "Smart
# Shutdown mode" in which any existing sessions are allowed to finish and the
# server stops when all sessions are terminated.
#
# See https://www.postgresql.org/docs/12/server-shutdown.html for more details
# about available PostgreSQL server shutdown signals.
#
# See also https://www.postgresql.org/docs/12/server-start.html for further
# justification of this as the default value, namely that the example (and
# shipped) systemd service files use the "Fast Shutdown mode" for service
# termination.
#
STOPSIGNAL SIGINT

# An additional setting that is recommended for all users regardless of this
# value is the runtime "--stop-timeout" (or your orchestrator/runtime's
# equivalent) for controlling how long to wait between sending the defined
# STOPSIGNAL and sending SIGKILL (which is likely to cause data corruption).
#
# The default in most runtimes (such as Docker) is 10 seconds, and the
# documentation at https://www.postgresql.org/docs/12/server-start.html notes
# that even 90 seconds may not be long enough in many instances.
EXPOSE 5432
CMD ["postgres"]
```

### ARM版本构建脚本

与x86版本不同之处在于：

1. from的镜像不同，一个是x86版本，一个是arm版本；
2. arm版本不包含oracle_fdw 构建的相关步骤；

```dockerfile
# ---
# 构建融合中心pg镜像-armb版本(从源码构建）：
# 1. 构建pgspider（pgspider-base镜像中包含）
# 2. 添加若干fdw：mysql_fdw,sqlite_fdw,postgres_fdw（postgres_fdw包含于pgspider-base镜像中）
# 3. 添加 postgis
#
# 参考：
# - https://github.com/rongfengliang/pgspider-docker/blob/master/Dockerfile-all-in-one
# ---
## 构建 sqlite_fdw  mysql_fdw
FROM zh-registry.geostar.com.cn/geopanel/pgspider-builder-arm:latest as build

WORKDIR /app

## PG 主版本
ENV PG_MAJOR 11
ENV PG_VERSION 6

## 安装构建所需的依赖
RUN apt-get update \
    && apt-get install -y automake autoconf libtool pkg-config libssl-dev \
    libsqlite3-dev libsybdb5 freetds-dev freetds-common \
    libhiredis-dev libcurl4-nss-dev unixodbc-dev libaio-dev \
    # for oracle
    unzip \
#    libmysql++-dev
    libmysql++-dev \
    # libspatialite sqlite 空间数据支持 - https://packages.debian.org/stretch/libspatialite7
    libspatialite7
#    postgresql-${PG_MAJOR}-python-multicorn python-pip

## 安装 sqlite_fdw
RUN git clone https://github.com/pgspider/sqlite_fdw.git /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/sqlite_fdw
RUN cd /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/sqlite_fdw && make && make install

## 安装 mysql_fdw
RUN git clone https://github.com/pgspider/mysql_fdw.git /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/mysql_fdw
RUN cd /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/mysql_fdw && make && make install

## 安装 Install es_fdw
#RUN pip install pg_es_fdw

## 安装 oracle_fdw(arm 不支持)
### 安装oracle instantclient
# https://github.com/rongfengliang/pgspider-docker/blob/master/Dockerfile-all-in-one-oracle
#ADD oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip
#ADD oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip
#ADD oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
#RUN unzip /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /usr/local/
#RUN unzip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/
#RUN unzip /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /usr/local/
#RUN ln -s /usr/local/instantclient_12_2 /usr/local/instantclient
#RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
#RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus
#ENV ORACLE_HOME=/usr/local/instantclient
#ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/instantclient

#RUN wget -O /app/ORACLE_FDW_2_2_0.tar.gz https://github.com/laurenz/oracle_fdw/archive/ORACLE_FDW_2_2_0.tar.gz \
#ADD oracle/oracle_fdw-ORACLE_FDW_2_2_0.tar.gz /app/
#RUN mv /app/oracle_fdw-ORACLE_FDW_2_2_0 /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/oracle_fdw \
#    && cd /app/postgresql-${PG_MAJOR}.${PG_VERSION}/contrib/oracle_fdw \
#    && make && make install

##  POSTGIS 构建
### 安装依赖
RUN apt-get install  -y --no-install-recommends \
    libtool libxml2 libxml2-dev \
    libxslt1.1 libxslt1-dev \
    libjson-c-dev libgmp-dev \
    cmake libmpfr-dev

### 创建临时工作目录
RUN mkdir /app/postgis/
ENV PGIS_INSTALL_PATH /usr/local/pgspider/plugin/postgis
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PGIS_INSTALL_PATH/lib
ENV PATH $PGIS_INSTALL_PATH/bin:/usr/local/pgspider/bin:$PATH

### 构建 mpfr
ADD postgis/mpfr-4.0.2.tar.gz /app/postgis/
RUN cd /app/postgis/mpfr-4.0.2 \
    && ./configure --prefix=$PGIS_INSTALL_PATH \
    && make && make install

### 构建 boost
ADD postgis/boost_1_67_0.tar.gz /app/postgis/
RUN cd /app/postgis/boost_1_67_0  \
    && ./bootstrap.sh -prefix=$PGIS_INSTALL_PATH && ./b2 && ./b2 install

### 构建 CGAL
ADD postgis/CGAL-4.11.2.tar.xz /app/postgis/
RUN cd /app/postgis/CGAL-4.11.2  \
    && cmake -DCMAKE_INSTALL_PREFIX=$PGIS_INSTALL_PATH . && make -j$(nproc) && make install

### 构建 SFCGAL
ADD postgis/SFCGAL-1.3.5.tar.gz /app/postgis/
RUN cd /app/postgis/SFCGAL-1.3.5 \
    && cmake -DCMAKE_INSTALL_PREFIX=$PGIS_INSTALL_PATH . && make -j$(nproc) && make install

### 构建 proj，需要先安装sqlite3
RUN apt-get install  -y --no-install-recommends sqlite3 libsqlite3-dev
ADD postgis/proj-6.2.0.tar.gz /app/postgis/
RUN cd /app/postgis/proj-6.2.0  \
    && ./configure --prefix=$PGIS_INSTALL_PATH && make -j$(nproc) && make install

### 构建 gdal
ADD postgis/gdal-3.0.2.tar.gz /app/postgis/
RUN cd /app/postgis/gdal-3.0.2  \
    && ./configure --prefix=$PGIS_INSTALL_PATH \
    # proj 无法直接找到，必须手动指定（可能是需要配置include），这里我们直接指定，postgis里面同
        --with-proj=$PGIS_INSTALL_PATH \
    && make -j$(nproc) && make install

### 构建 geos
ADD postgis/geos-3.8.0.tar.bz2 /app/postgis/
RUN cd /app/postgis/geos-3.8.0  \
    && ./configure --prefix=$PGIS_INSTALL_PATH  \
    && make -j$(nproc) && make install

### 构建 postgis
ADD postgis/postgis-2.5.3.tar.gz /app/postgis/
RUN cd /app/postgis/postgis-2.5.3  \
    && ./configure --prefix=$PGIS_INSTALL_PATH \
    # 几个config命令直接配置PATH后可以找到，所以不在使用参数配置
#        --with-pgconfig=/usr/local/pgspider/bin/pg_config \
#        --with-geosconfig=$$PGIS_INSTALL_PATH/bin/geos-config \
#        --with-gdalconfig=$$PGIS_INSTALL_PATH/bin/gdal-config \
        --with-projdir=$PGIS_INSTALL_PATH \
    && make -j$(nproc) && make install

RUN set -ex \
#    && sed -i "s/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
#    && sed -i "s/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g"  /etc/apt/sources.list \
    # https://packages.debian.org/stretch-backports/libboost-atomic1.67-dev
#    && echo "deb http://deb.debian.org/debian stretch-backports main" >>/etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      libprotobuf-c-dev \
#      postgresql-12-wal2json \
      protobuf-c-compiler \
      && rm -rf /var/lib/apt/lists/*

## 添加 debezium https://github.com/eulerto/wal2json
ADD debezium/wal2json-wal2json_1_0.tar.gz /app/debezium/
RUN cd /app/debezium/wal2json-wal2json_1_0 \
    && make -j$(nproc) && make install

## 添加 debezium - decoderbufs 研究院修改版本
ADD debezium/postgres-decoderbufs.tar.gz /app/debezium/
RUN cd /app/debezium/postgres-decoderbufs \
    && cd proto \
    && protoc-c --c_out=../src/proto pg_logicaldec.proto \
    && cd .. \
    ## make -B： 研究院提供的包中可能带有之前make的成果，此时不会重新构建，所以我们使用 -B 来强制重新构建，也可以先执行 make clean
    && make -B -j$(nproc) && make install

### 对构建postgis过程中生成的文件进行优化，以减小大小
#### 1. 移除静态链接库文件；2. 使用strip命令对动态链接库so文件进行符号表优化
RUN cd $PGIS_INSTALL_PATH/lib \
    && rm *.a \
    && find . -type f -name "lib*.so.*" -exec strip {} +
#    && cd /usr/local/pgspider/plugin/proj/lib \
#    && rm *.a && find . -type f -name "lib*.so.*" -exec strip {} +

## 拷贝mysql
COPY binary-arm/mysql_fdw/*.sql         /usr/local/pgspider/share/postgresql/extension/
COPY binary-arm/mysql_fdw/*.control    /usr/local/pgspider/share/postgresql/extension/
COPY binary-arm/mysql_fdw/*.so         /usr/local/pgspider/lib/postgresql/
# 拷贝zombodb
COPY binary-arm/zdblibs/*.sql          /usr/local/pgspider/share/postgresql/extension/
COPY binary-arm/zdblibs/*.control      /usr/local/pgspider/share/postgresql/extension/
COPY binary-arm/zdblibs/*.so           /usr/local/pgspider/lib/postgresql/

# ------ 开始构建实际发布的镜像 ------
FROM zh-registry.geostar.com.cn/geopanel/pgspider-base-arm:latest
LABEL maintainer="jianghanghang@geostar.com.cn"

## 设置若干ENV，指示版本信息
# buster 上为12 ，stretch 上为 12
# ENV CDAL_VERSION 12
ENV BOOST_VERSION=1.67.0 \
    PG_MAJOR=11 \
    PG_VERSION=6 \
    POSTGIS_VESION=2.5.3

## 安装必要的依赖（TODO: 部分依赖可能不需要）
RUN set -ex \
#    && sed -i "s/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
#    && sed -i "s/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g"  /etc/apt/sources.list \
    # https://packages.debian.org/stretch-backports/libboost-atomic1.67-dev
#    && echo "deb http://deb.debian.org/debian stretch-backports main" >>/etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      libcurl3-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c3 \
      # buster 上为6，stretch上为4
#      libmpfr6 \
#      libmpfr4 \
      libprotobuf-c1 \
      libtiff5 \
      libxml2 \
      && rm -rf /var/lib/apt/lists/*

## 安装oracle_fdw需要的 Oracle instantclient (arm版本不支持）
### from: https://github.com/rongfengliang/pgspider-docker/blob/master/Dockerfile-all-in-one-oracle
#COPY --from=build  /usr/local/instantclient_12_2 /usr/local/instantclient_12_2
#RUN set -ex \
#    && ln -s /usr/local/instantclient_12_2 /usr/local/instantclient \
#    && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

## 设置若干运行需要的环境变量
#ENV ORACLE_HOME=/usr/local/instantclient \
ENV PGIS_INSTALL_PATH=/usr/local/pgspider/plugin/postgis
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PGIS_INSTALL_PATH/lib:/usr/local/instantclient \
    PATH=$PGIS_INSTALL_PATH/bin:/usr/local/pgspider/bin:$PATH
## 拷贝构建好的成果
COPY --from=build  /usr/local/pgspider /usr/local/pgspider
## 入口脚本添加
COPY docker-entrypoint.sh /usr/local/bin/
RUN mkdir /docker-entrypoint-initdb.d \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh /

## postgis 脚本添加
### from： https://github.com/postgis/docker-postgis/blob/master/Dockerfile.master.template
COPY ./postgis/initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./postgis/update-postgis.sh /usr/local/bin
## 添加扩展初始化脚本
COPY ./initdb-fdw.sh /docker-entrypoint-initdb.d/00_fdws.sh
COPY ./debezium/init-debezium.sh /docker-entrypoint-initdb.d/01_debezium.sh

## make the sample config easier to munge (and "correct by default")
RUN sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/local/pgspider/share/postgresql/postgresql.conf.sample; \
   grep -F "listen_addresses = '*'" /usr/local/pgspider/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql  && chmod 2777 /var/run/postgresql

ENV PGDATA /var/lib/postgresql/data
## 设置目录权限 - this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"
VOLUME /var/lib/postgresql/data

ENTRYPOINT ["docker-entrypoint.sh"]

# COPY FROM https://github.com/docker-library/postgres/blob/master/11/Dockerfile
# We set the default STOPSIGNAL to SIGINT, which corresponds to what PostgreSQL
# calls "Fast Shutdown mode" wherein new connections are disallowed and any
# in-progress transactions are aborted, allowing PostgreSQL to stop cleanly and
# flush tables to disk, which is the best compromise available to avoid data
# corruption.
#
# Users who know their applications do not keep open long-lived idle connections
# may way to use a value of SIGTERM instead, which corresponds to "Smart
# Shutdown mode" in which any existing sessions are allowed to finish and the
# server stops when all sessions are terminated.
#
# See https://www.postgresql.org/docs/12/server-shutdown.html for more details
# about available PostgreSQL server shutdown signals.
#
# See also https://www.postgresql.org/docs/12/server-start.html for further
# justification of this as the default value, namely that the example (and
# shipped) systemd service files use the "Fast Shutdown mode" for service
# termination.
#
STOPSIGNAL SIGINT

# An additional setting that is recommended for all users regardless of this
# value is the runtime "--stop-timeout" (or your orchestrator/runtime's
# equivalent) for controlling how long to wait between sending the defined
# STOPSIGNAL and sending SIGKILL (which is likely to cause data corruption).
#
# The default in most runtimes (such as Docker) is 10 seconds, and the
# documentation at https://www.postgresql.org/docs/12/server-start.html notes
# that even 90 seconds may not be long enough in many instances.
EXPOSE 5432
CMD ["postgres"]
```



## 镜像测试及使用

> 提示：镜像使用了pg官方的入口脚本，官方支持的配置及变量都可以使用，具体可查看[官方dockerhub页面](https://hub.docker.com/_/postgres?tab=description&page=1&ordering=last_updated)

下面描述了一个简单的测试流程，详细可参考： [pgspider镜像运行测试](http://172.17.0.205/dept-development/product-project/geopanel/geopanel-deploy/-/blob/master/build/pgspider/README.md#%E8%BF%90%E8%A1%8C-1)

```shell
## 根据平台及需要使用的源，设置 `PG_IMAGE` 变量
# x86 - dockerhub 
PG_IMAGE=hanlyjiang/pgspider-postgis:latest
# arm - dockerhub
PG_IMAGE=hanlyjiang/pgspider-postgis-arm:latest
# x86 - 阿里云
PG_IMAGE= zh-registry.geostar.com.cn/geopanel/pgspider-postgis:latest
# arm - 阿里云
PG_IMAGE= zh-registry.geostar.com.cn/geopanel/pgspider-postgis-arm:latest

# 启动 pgspider （可以将 --rm 换成 -d 以便持续在后台运行 ）
## 通过 POSTGRES_PASSWORD 变量可以设置密码
docker run -it --rm \
    --name pgspider \
    -p 5434:5432 \
    -e POSTGRES_PASSWORD=mysecretpassword \
    -v $PWD/data:/var/lib/postgresql/data \
    $PG_IMAGE

## 启动后进入容器：
docker exec -it pgspider bash
### 然后可以执行 psql 等命令

# 测试用，正常运行可以不用管
docker run -it --rm \
    --entrypoint="" \
    --name pgspider \
    -e POSTGRES_PASSWORD=mysecretpassword \
    -v $PWD/data:/var/lib/postgresql/data \
    pgspider-postgis:latest bash

```

## 可优化部分

builder镜像和base镜像的构建arm及x86两个架构的镜像构建可以合并成一条命令并使用相同的镜像名称；同时pgspider镜像也可以经过一定的更改统一成一个打包脚本；



# GeoPanel容器化-hasura即块数据API引擎镜像构建

## Hasura镜像构建概览

### hasura 是什么？

引用[hasura官方](https://github.com/hasura/graphql-engine/blob/master/translations/README.chinese.md
)的介绍

> Hasura GraphQL引擎是一个高性能的GraphQL服务器，可为您提供 **Postgres上开箱即用的实时GraphQL API**， 响应数据库事件的 [**Webhook触发器**](https://github.com/hasura/graphql-engine/blob/master/event-triggers.md)，以及用于业务逻辑处理的 [**远端Schema**](https://github.com/hasura/graphql-engine/blob/master/remote-schemas.md)。
> Hasura可帮助您构建基于Postgres的GraphQL应用程序，或将使用Postgres的现有应用迁移到GraphQL上。

Github及DockerHub地址：

* 开源仓库Github地址：[hasura/graphql-engine](hasura/graphql-engine)
* 官方Dockerhub镜像地址：[hasura/graphql-engine](https://hub.docker.com/r/hasura/graphql-engine/tags?page=1&ordering=last_updated)

### 我们做的修改

我们使用hasura作为融合中心的块数据API引擎，针对开源版本作了如下修改/扩展：

1. 汉化了 graphl-engine console，其中包括：
   * 汉化 graphql-engine的console入口文件中的 `Loading...`;
   * console web页面的所有界面；
2. 根据需要扩展了几个模块，模块扩展的方式为：1）在console中添加扩展模块的web操作界面；2）提供对应的springboot服务作为后端接口提供服务；到目前为止，包括以下模块：
   * token管理服务
   * 数据库集成服务
   * restapi服务

### 目标及成果

通过官方的dockerhub可以看到，目前没有arm版本的镜像，故我们需要从头编译。同时我们希望能让hasura在arm平台上运行，最终也完成了构建流程，整体如下：

![image-20210316140949364](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210316140949.png)

### hasura整体结构

```mermaid
graph

graphql-engine

console

cli

```

1. graphql-engine: graphql 引擎

2. console：前端界面，实际上console也会一起打包到graphql-engine的镜像里面

3. Hasura CLI是一个命令行工具，是管理Hasura项目和迁移的主要模式。

实际上我们只需要前两个部分即可

### 整体构建流程梳理

#### 代码结构说明

```shell
graphql-engine 
	|-- server
		  |-- src-rsr
		  		|-- console.html
	|-- console
		  |-- xx.html
		  |-- xxxx
```

server 目录会编译出一个 graphql-engine 的二进制文件，其中会包含 `server/src-rsr/console.html` 文件作为首页的加载模板（即console.html）。

#### graphql-engine console

console为web工程，使用npm run build即可编译，非常简单。我们只需要重点关注server部分即可。现在我们重点分析这个server部分：

#### graphql-engine server

- graphql-engine server 使用haskell语言进行编写，使用 cabal 进行构建；
- haskell是一个函数式编程语言，编译器为GHC，编译工具一般使用cabal，cabal同时也是项目的管理工具（如包管理，依赖管理）。

也就是说为了编译server，我们需要GHC及cabal，那么这两个工具的arm版本现状如何了？

* GHC： 无arm版本现成的docker镜像，有预编译的二进制；
* cabal： 无arm版本现成的docker镜像及二进制文件；

为了不污染环境，并且持久化构建环境，我们准备构建一个docker的镜像，包含ghc及cabal，也就是说，我们两者都需要构建。

总结以下构建步骤：

1. 准备haskell的ARM版本编译环境（包括GHC编译器及hasura编译所需要的cabal工具）；
2. 使用之前准备好的ARM版本编译环境编译hasura；
3. 打包成Docker镜像；



#### 整体构建流程

在浏览`graphql-engine` 的仓库中ci构建的部分文件之后，我发现还需要其他一些辅助镜像，最后梳理出如下构建流程：

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210316090603.png" alt="docker-image-builder-flow" style="zoom: 50%;" />



1. 首先，我们需要构建 `graphql-engine-builder` 的镜像，其中包括haskell的GHC编译器及cabal依赖管理工具；
2. 然后我们使用`graphql-engine-builder`镜像对 graphql-engine 的源码进行编译，生成 graphql-engine 的二进制可执行文件及 graphql-engine 运行所需要的依赖库；
3. 由于第二步构建过程中有很多中间成果，我需要为graphql-engine创造一个纯净的运行环境以缩小最终的运行镜像的大小，所以我们需要构建 `graphql-engine-packager` 镜像，其中包含一个精简版的根文件系统。
4. 现在，我们将第二步中生成的graphql-engine及其依赖文件和第三步 `graphql-engine-packager` 镜像中的根文件系统合并到一个scratch镜像，然后生成 `graphql-engine-base` 的镜像，这个镜像已经包含了一个可以正常运行的 graphql-engine ，只是没有集成console资源到镜像中；
5. 最后我们对console进行编译，生成assets资源，然后基于 `graphql-engine-base` 添加这些前端资源文件，生成我们最终需要的 `graphql-engine` 镜像；



## graphql-engine-builder 镜像构建

基于以下原因，我决定构建一个graphql-engine-builder的镜像：

1. 不想污染自己的主机的环境，安装一堆haskell的构建环境；
2. 持久化编译环境，使得构建过程可以无成本迁移到任何机器；

这个builder镜像包含以下内容(实际上就是haskell语言的构建环境)：

* GHC
* cabal

经过一番尝试，确定了如下Dockerfile构建脚本：

### **X86** Dockerfile

```dockerfile
#  x86 用于构建hasura的镜像
# 构建命令 docker build -f Dockerfile -t hanlyjiang/graphql-engine-builder:latest .
FROM haskell:8.10.1

## ensure locale is set during build（否则无法构建cabal，会出现hGetContent错误）
ENV LANG            C.UTF-8

# 避免配置tzdata时出现的交互式等待界面导致构建卡住
## https://techoverflow.net/2019/05/18/how-to-fix-configuring-tzdata-interactive-input-when-building-docker-images/
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i "s/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list && \
   sed -i "s/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g"  /etc/apt/sources.list && \
   apt-get update && \
   apt-get install -y --no-install-recommends apt-utils lsb-release wget && \
   echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc |  apt-key add - && \
   apt-get update && \
   apt-get install -y --no-install-recommends  postgresql libpq-dev && \
   rm -fr /var/lib/apt/lists/* && \
   # 安装 upx
   wget https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz && \
           tar -xf upx-3.96-amd64_linux.tar.xz  && \
           cp upx-3.96-amd64_linux/upx /usr/bin/upx && \
           rm -fr upx-3.96-amd64_linux
```

x86版本基于 haskell官方的`haskell:8.10.1` 镜像，添加了如下动作：

1. 替换软件源为国内软件源；
2. 安装必要的软件依赖；
3. 添加了upx用于二进制文件优化；

### **ARM** Dockerfile

arm版本的则需要从头构建

* 我们使用 `ubuntu:18.04` 作为基础镜像；
* 首先安装了 LLVM6.0 及 GHC8.6.5 ；
* 使用 GHC8.6.5 构建 Cabal3.2.0.0（包括cabal-install），因为GHC8.10.1无法成功构建cabal-install 3.2；
* 然后安装 LLVM 9 及GHC8.10.1，用于后续编译hasura；
* 添加必要的依赖；
* 添加了upx用于二进制文件优化；

```dockerfile
## Hasura graphql-engine 编译环境
# 测试发现只有在arm机器上才可能构建成功，x86 docker交叉构建失败
# docker build -t registry.cn-hangzhou.aliyuncs.com/geostar_private_arm/haskell-ghc8.6.5_8.10.1-cabal3.2:20200817 .

# ghc-8.6.5的安装构建需要在ubuntu18.04上（glibc2.27)
## 通过如下方式确认glibc版本：
### docker run -it --rm ubuntu:18.04 bash -c "find / -type f | grep libc-.*.so" # 输出 /lib/x86_64-linux-gnu/libc-2.27.so
### docker run -it --rm debian:stretch bash -c "find / -type f | grep libc-.*.so" # 输出 /lib/x86_64-linux-gnu/libc-2.24.so
### docker run -it --rm debian:buster bash -c "find / -type f | grep libc-.*.so" # 输出 /lib/aarch64-linux-gnu/libc-2.28.so
### debian也可以在此页面查看：https://packages.debian.org/search?searchon=sourcenames&keywords=glibc
#FROM debian:stretch
FROM ubuntu:18.04

## ensure locale is set during build（否则无法构建cabal，会出现hGetContent错误）
ENV LANG            C.UTF-8

# 避免配置tzdata时出现的交互式等待界面导致构建卡住
## https://techoverflow.net/2019/05/18/how-to-fix-configuring-tzdata-interactive-input-when-building-docker-images/
ENV DEBIAN_FRONTEND noninteractive

# 以防网络不好，切换到国内镜像源
RUN apt-get update && \
     apt install -y apt-transport-https ca-certificates
ADD ubuntu18.04-sources.list /etc/apt/sources.list


# 避免 hash sum mismatch 问题：
## https://stackoverflow.com/questions/15505775/debian-apt-packages-hash-sum-mismatch
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get update && \

# 安装常用软件及GHC构建相关依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg ca-certificates dirmngr curl git wget && \
    apt-get install -y --no-install-recommends zlib1g-dev libtinfo-dev libsqlite3-dev \
                g++ netbase xz-utils libnuma-dev make openssh-client \
                # hasura 构建需要（pg-client）
                ## https://stackoverflow.com/questions/17915098/openssl-ssl-h-no-such-file-or-directory-during-installation-of-git
                libssl-dev libkrb5-dev && \
    # 安装llvm 6.0（用于构建cabal）
    LLVM_VERSION=6.0 && \
    # apt-get install -y software-properties-common && \
    apt-get install -y --no-install-recommends libghc-network-dev \
        llvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev postgresql libpq-dev && \
        rm -fr /var/lib/apt/lists/* && \
    ln -s /usr/lib/llvm-${LLVM_VERSION}/bin/llc /usr/local/bin/llc  && \
    ln -s /usr/lib/llvm-${LLVM_VERSION}/bin/opt /usr/local/bin/opt

# 安装 GHC 8.6.5（用于构建Cabal3.2.0.0）
RUN GHC=8.6.5 && GHC_OS_DIST=ubuntu18.04 && \
    ## 下载链接类似：https://downloads.haskell.org/~ghc/8.10.1/ghc-8.10.1-aarch64-deb9-linux.tar.xz 
    wget https://downloads.haskell.org/~ghc/${GHC}/ghc-${GHC}-aarch64-${GHC_OS_DIST}-linux.tar.xz && \
    tar -xvf ghc-${GHC}-aarch64-${GHC_OS_DIST}-linux.tar.xz && \
    cd ghc-${GHC}  && \
    ./configure && \
    make install && \
    cd ../ && \
    rm -rf ghc-${GHC}-aarch64-${GHC_OS_DIST}-linux.tar.xz ghc-${GHC} 

# 构建 Cabal 3.2.0.0 （包括 cabal-install）
RUN git clone -b cabal-install-v3.2.0.0 https://github.com/haskell/cabal.git && \
    cd cabal/cabal-install && \
    ./bootstrap.sh && \
    cd ../.. && \
    rm -fr cabal

# 安装 llvm 9 及其他构建所需 （postgresql libpq-dev）pg_config
RUN LLVM_VERSION=9 && \
    apt-get update && \
    apt-get install -y --no-install-recommends llvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev postgresql libpq-dev && \
    # 如果有旧版本的，则移除链接
    rm /usr/local/bin/llc /usr/local/bin/opt && \
    ln -s /usr/lib/llvm-${LLVM_VERSION}/bin/llc /usr/local/bin/llc && \
    ln -s /usr/lib/llvm-${LLVM_VERSION}/bin/opt /usr/local/bin/opt && \
    # 安装ghc8.10.1 ，自带Cabal库的3.2版本
    GHC=8.10.1 && GHC_OS_DIST=deb9 && \
    wget https://downloads.haskell.org/~ghc/${GHC}/ghc-${GHC}-aarch64-${GHC_OS_DIST}-linux.tar.xz && \
    tar -xvf ghc-${GHC}-aarch64-${GHC_OS_DIST}-linux.tar.xz && \
    cd ghc-${GHC}  && \
    ./configure && \
    make install && \
    cd ../ && \
    rm -rf ghc-${GHC}-aarch64-${GHC_OS_DIST}-linux.tar.xz ghc-${GHC} && \
    # 安装3.96版本的upx-用于压缩优化graphql-engine二进制可执行文件（软件源中的3.94版本有压缩aarch的二进制后有问题 https://github.com/upx/upx/issues/130）
    wget https://github.com/upx/upx/releases/download/v3.96/upx-3.96-arm64_linux.tar.xz && \
    tar -xf upx-3.96-arm64_linux.tar.xz  && \
    cp upx-3.96-arm64_linux/upx /usr/bin/upx && \
    rm -fr upx-3.96-arm64_linux upx-3.96-arm64_linux.tar.xz /var/lib/apt/lists/*


## stack 安装(hasura构建可不安装stack)
# ARG STACK=2.1.3
# ARG STACK_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442
# ARG STACK_RELEASE_KEY=2C6A674E85EE3FB896AFC9B965101FF31C5C154D

# RUN arch=`uname -m` && \
#     echo $arch && \ 
#     curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$arch.tar.gz -o  stack.tar.gz && \
#     curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$arch.tar.gz.asc -o stack.tar.gz.asc 
# RUN export GNUPGHOME="$(mktemp -d)" && \
#     gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys ${STACK_KEY} && \
#     gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys ${STACK_RELEASE_KEY} && \
#     gpg --batch --trusted-key 0x575159689BEFB442 --verify stack.tar.gz.asc stack.tar.gz && \
#     tar -xf stack.tar.gz -C /usr/local/bin --strip-components=1 && \
#     /usr/local/bin/stack config set system-ghc --global true && \
#     /usr/local/bin/stack config set install-ghc --global false && \
#     rm -rf "$GNUPGHOME" /var/lib/apt/lists/* /stack.tar.gz.asc /stack.tar.gz;

# 设置环境变量使可以找到cabal，GHC的默认会安装到PATH中，无需额外设置
ENV PATH /root/.cabal/bin:$PATH

## 没有指定命令的时候默认运行ghci
CMD ["ghci"]

```

> 注意：由于以上builder镜像是用于编译graphql-engine的工具镜像，而非最终的镜像，所以并未刻意对镜像大小进行优化；

## graphql-engine-packager 构建

packager镜像中包含一个纯净的根文件系统，可为graphql-engine server提供基础的运行环境；

### 整体说明

graphql-engine-packager的镜像构建脚本位于源码的 `server/packaging` 目录中的 `package.df` 文件中，内容如下：

```dockerfile
FROM hasura/haskell-docker-packager:20190731
MAINTAINER vamshi@hasura.io

RUN apt-get update && apt-get install -y libpq5 upx \
 && update-ca-certificates \
 && mkdir -p /usr/src/busybox/rootfs/etc/ssl/certs \
 && cp -L /etc/ssl/certs/* /usr/src/busybox/rootfs/etc/ssl/certs/ \
 && rm -rf /var/lib/apt/lists/*
```

可以看到其基于 `hasura/haskell-docker-packager:20190731` 的镜像（[DockerHub对应页面](https://hub.docker.com/r/hasura/haskell-docker-packager/tags?page=1&ordering=last_updated)），具体构建方式如下：

```shell
registry=hanlyjiang  # 替换成自行设置的值
packager_ver=20210316 # 替换成自行设置的值

docker build -t '$registry/graphql-engine-packager:$packager_ver' -f packaging/packager.df ./packaging/
```

从以上分析可知，我们要构建packager镜像，需要先构建`haskell-docker-packager`镜像，而对于X86版本来说，可以直接使用使用官方已经构建好的镜像，对于ARM版本来说，则需要我们从头构建；



### X86镜像构建

如上所述，我们直接基于官方的 `hasura/haskell-docker-packager:20190731`并使用源码目录中的 `packaging/packager.df` 文件构建出对应的`graphql-engine-packager`镜像即可；

### ARM

#### haskell-docker-packager 镜像构建

arm版本则需要我们从头构建 `haskell-docker-packager` 的镜像，基于官方的 [github/hasura/haskell-docker-builder](https://github.com/hasura/haskell-docker-builder) 源码，我略作修改，让其可以构建出arm版本的镜像，对应的代码放置于 [github/hanlyjiang/haskell-docker-builder](https://github.com/hanlyjiang/haskell-docker-builder) 中，执行如下命令即可构建出arm版本的 `haskell-docker-packager` 镜像：

```shell
git clone git@github.com:hanlyjiang/haskell-docker-builder.git 
make build 
```

上述命令执行完毕后会生成一个 `hanlyjiang/haskell-docker-packager:当前日期` 的镜像。



#### graphql-engine-packager 镜像构建

同样的，我们在 graphql-engine的源代码的 `server/packaging` 目录中添加一个名为 `packaging-arm.df` 的文件用于构建 arm 版本的 `graphql-engine-packager` 镜像，内容如下：

```dockerfile
FROM hanlyjiang/haskell-docker-packager:20200814
MAINTAINER hanlyjiang@outlook.com

RUN apt-get update && apt-get install -y libpq5 upx \
 && update-ca-certificates \
 && mkdir -p /usr/src/busybox/rootfs/etc/ssl/certs \
 && cp -L /etc/ssl/certs/* /usr/src/busybox/rootfs/etc/ssl/certs/ \
 && rm -rf /var/lib/apt/lists/*
```

可通过如下命令构建arm版本镜像：

```shell
registry=hanlyjiang  # 替换成自行设置的值
packager_ver=20210316 # 替换成自行设置的值
```

构建可以在arm机器上执行，也可以在x86机器上通过buildx来交叉构建：

- arm 机器上执行：    

```shell
docker build -t '$registry/graphql-engine-packager:$packager_ver' -f packaging/packager-arm.df ./packaging/
```

- 非arm机器上交叉构建arm镜像

```shell
docker buildx build --platform=linux/arm64 -t '$registry/graphql-engine-packager:$packager_ver' -f packaging/packager-arm.df ./packaging/ --load
```



## graphql-engine-base 构建

`graphql-engine-base` 镜像包含 graphql-engine 的 server，当不包含 console 的 web 资源；

### X86镜像构建

```dockerfile
### 构建 graphql-engine 镜像
## docker build -f Dockerfile-all.dockerfile -t graphql-engine-base:20201109 ./

## -- 编译 graphql-engine
# 
FROM hanlyjiang/graphql-engine-builder:20201111 as builder

ARG GIT_TAG=v1.3.2
ARG GIT_USER=docker-build
ARG GIT_PWD=4Kqy9Cb4FcYx2H4goiEq

RUN git clone -b $GIT_TAG http://$GIT_USER:$GIT_PWD@172.17.0.205/dept-development/product-project/geopanel/development-center/blockdataapi-engine.git /app/graphql-engine 

WORKDIR /app/graphql-engine/server

# 初始化cabal的配置
RUN ln -s cabal.project.ci cabal.project.local && \
    export LANG=C.UTF-8 && \
    # 生成配置文件(~/.cabal/config) https://cabal.readthedocs.io/en/3.4/installing-packages.html
    cabal user-config update && \
    # 替换为国内源
    sed -i 's/hackage.haskell.org/mirrors.tuna.tsinghua.edu.cn/g' /root/.cabal/config  && \
    sed -i 's/mirrors.tuna.tsinghua.edu.cn\//mirrors.tuna.tsinghua.edu.cn\/hackage/g' /root/.cabal/config

# 重新更新软件包信息(单独作为一层，以便缓存)
RUN cabal new-update

# 编译 graphql-engine 可执行文件
# 我们将加载中替换为中文
RUN sed -i 's/Loading/加载中/g' src-rsr/console.html && \
    # https://cabal.readthedocs.io/en/3.4/cabal-project.html#cfg-flag---jobs
    cabal new-build --jobs=$(nproc)
RUN build_output=../_build_output && \
    exec_glob=`find ./dist-newstyle/ -type f -name "graphql-engine"` && \
    mkdir $build_output && \
    cp "$exec_glob" $build_output/ && \
    # get-version 需要基于git仓库获取版本号
    ../scripts/get-version.sh >$build_output/version.txt 


## -- 提取基础的rootfs
# docker build --progress plain -t graphql-engine-baserootfs:20201110 --target baseRootfs ./
FROM hasura/graphql-engine-packager:20190731 as baseRootfs
COPY --from=builder /app/graphql-engine/_build_output/ /root/
RUN mkdir /rootfs/ && /build.sh graphql-engine | tar -x -C /rootfs/


## 构建最终的rootfs
# docker build --progress plain -f Dockerfile-all.dockerfile -t graphql-engine-builderrootfs:20201110 --target bulderRootfs ./
FROM builder as bulderRootfs
WORKDIR /app/graphql-engine/
COPY --from=baseRootfs /rootfs /app/graphql-engine/server/packaging/build/rootfs

RUN pg_dump_ver=12 && \
    exec_glob=`find server/dist-newstyle/ -type f -name "graphql-engine"` && \
    build_output=./_build_output  && \
    packaging_dir=./server/packaging/  && \
    rootfs_dir=$packaging_dir/build/rootfs  && \
    cp $build_output/graphql-engine $rootfs_dir/bin && \
    # 获取所有动态链接库
    ldd $build_output/graphql-engine | awk 'BEGIN{ORS="\n"}$1~/^\//{print $1}$3~/^\//{print $3}' | xargs cp -n -L --parents -t $rootfs_dir/ && \
    # 获取 pg_dump
    cp /usr/lib/postgresql/$pg_dump_ver/bin/pg_dump $rootfs_dir/bin/pg_dump && \
    # 优化&压缩
    strip --strip-unneeded $rootfs_dir/bin/graphql-engine && \
    upx $rootfs_dir/bin/graphql-engine 

## - 不带 console-assets
# docker build --progress plain -f Dockerfile-base.dockerfile -t graphql-engine-base:20201110 --target graphql-engine-base ./
FROM scratch as graphql-engine-base
COPY --from=bulderRootfs /app/graphql-engine/server/packaging/build/rootfs/ /
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
CMD ["graphql-engine", "serve"]
```

执行如下命令构建：

```shell
TAG=$(date '+%Y%m%d')

docker build -t graphql-engine-base:$TAG ./ 
```



### ARM版本镜像构建

```dockerfile
### 构建 graphql-engine 镜像
## docker buildx build --platform=linux/arm64  -f Dockerfile-base-arm.dockerfile -t graphql-engine-base:arm-20201109 ./ --load


## 构建准备
# docker pull hanlyjiang/graphql-engine-builder:arm-latest

## -- 编译 graphql-engine
# 
FROM hanlyjiang/graphql-engine-builder:arm-latest as builder

ARG GIT_TAG=v1.3.2
ARG GIT_USER=docker-build
ARG GIT_PWD=4Kqy9Cb4FcYx2H4goiEq

RUN git clone -b $GIT_TAG http://$GIT_USER:$GIT_PWD@172.17.0.205/dept-development/product-project/geopanel/development-center/blockdataapi-engine.git /app/graphql-engine 

WORKDIR /app/graphql-engine/server

# 初始化cabal的配置
RUN ln -s cabal.project.ci cabal.project.local && \
    export LANG=C.UTF-8 && \
    # 生成配置文件(~/.cabal/config) https://cabal.readthedocs.io/en/3.4/installing-packages.html
    cabal user-config update && \
    # 替换为国内源
    sed -i 's/hackage.haskell.org/mirrors.tuna.tsinghua.edu.cn/g' /root/.cabal/config  && \
    sed -i 's/mirrors.tuna.tsinghua.edu.cn\//mirrors.tuna.tsinghua.edu.cn\/hackage/g' /root/.cabal/config

# 重新更新软件包信息(单独作为一层，以便缓存)
## update 过程中可能自动去github下载仓库
RUN cabal new-update

# 编译 graphql-engine 可执行文件
RUN sed -i 's/Loading/加载中/g' src-rsr/console.html && \
    # https://cabal.readthedocs.io/en/3.4/cabal-project.html#cfg-flag---jobs
    cabal new-build --jobs=$(nproc)
RUN build_output=../_build_output && \
    exec_glob=`find ./dist-newstyle/ -type f -name "graphql-engine"` && \
    mkdir $build_output && \
    cp "$exec_glob" $build_output/ && \
    # get-version 需要基于git仓库获取版本号
    ../scripts/get-version.sh >$build_output/version.txt 


## -- 提取基础的rootfs
# docker buildx build --platform=linux/arm64  -f Dockerfile-base.dockerfile --progress plain -t graphql-engine-baserootfs:20201110 --target baseRootfs ./ --load
FROM hanlyjiang/graphql-engine-packager:20200814 as baseRootfs
COPY --from=builder /app/graphql-engine/_build_output/ /root/
# build.sh 的内容就是下面的 ldd graphql-engine | awk 'BEGIN{ORS="\n"}$1~/^\//{print $1}$3~/^\//{print $3}' | xargs cp -n -L --parents -t ，用于拷贝packager镜像中graphql-engine需要的依赖库到rootfs
RUN mkdir /rootfs/ && /build.sh graphql-engine | tar -x -C /rootfs/


## 构建最终的rootfs
# docker buildx build --platform=linux/arm64  --progress plain -f Dockerfile-base.dockerfile -t graphql-engine-builderrootfs:20201110 --target bulderRootfs ./ --load
FROM builder as bulderRootfs
WORKDIR /app/graphql-engine/
COPY --from=baseRootfs /rootfs /app/graphql-engine/server/packaging/build/rootfs

RUN pg_dump_ver=12 && \
    exec_glob=`find server/dist-newstyle/ -type f -name "graphql-engine"` && \
    build_output=./_build_output  && \
    packaging_dir=./server/packaging/  && \
    rootfs_dir=$packaging_dir/build/rootfs  && \
    cp $build_output/graphql-engine $rootfs_dir/bin && \
    # 获取所有动态链接库
    ldd $build_output/graphql-engine | awk 'BEGIN{ORS="\n"}$1~/^\//{print $1}$3~/^\//{print $3}' | xargs cp -n -L --parents -t $rootfs_dir/ && \
    # 获取 pg_dump(arm builder镜像路径不一样)
    cp /usr/share/postgresql-common/pg_wrapper $rootfs_dir/bin/pg_dump && \
    # 优化&压缩
    strip --strip-unneeded $rootfs_dir/bin/graphql-engine && \
    upx $rootfs_dir/bin/graphql-engine 

## - 不带 console-assets
# docker buildx build --platform=linux/arm64  --progress plain -f Dockerfile-base.dockerfile -t graphql-engine-base-arm:20201110 --target graphql-engine-base ./ --load
FROM scratch as graphql-engine-base
LABEL maintainer="jianghanghang@geostar.com.cn"
COPY --from=bulderRootfs /app/graphql-engine/server/packaging/build/rootfs/ /
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
CMD ["graphql-engine", "serve"]

```

执行如下命令构建：

```shell
TAG=$(date '+%Y%m%d')

# ARM机器执行
docker build  -t graphql-engine-base:arm-$TAG  ./

# x86交叉构建
docker buildx build --platform=linux/arm64 -t  graphql-engine-base:arm-$TAG ./ --load
```



### 构建脚本合并简化（未验证）

```dockerfile
### 构建 graphql-engine 镜像
## docker build -f Dockerfile-all.dockerfile -t graphql-engine-base:20201109 ./

## -- 编译 graphql-engine
# 

ARG builder_image
ARG packager_image
FROM ${builder_image} as builder

ARG GIT_TAG=v1.3.2
ARG GIT_USER=docker-build
ARG GIT_PWD=4Kqy9Cb4FcYx2H4goiEq

RUN git clone -b $GIT_TAG http://$GIT_USER:$GIT_PWD@172.17.0.205/dept-development/product-project/geopanel/development-center/blockdataapi-engine.git /app/graphql-engine 

WORKDIR /app/graphql-engine/server

# 初始化cabal的配置
RUN ln -s cabal.project.ci cabal.project.local && \
    export LANG=C.UTF-8 && \
    # 生成配置文件(~/.cabal/config) https://cabal.readthedocs.io/en/3.4/installing-packages.html
    cabal user-config update && \
    # 替换为国内源
    sed -i 's/hackage.haskell.org/mirrors.tuna.tsinghua.edu.cn/g' /root/.cabal/config  && \
    sed -i 's/mirrors.tuna.tsinghua.edu.cn\//mirrors.tuna.tsinghua.edu.cn\/hackage/g' /root/.cabal/config

# 重新更新软件包信息(单独作为一层，以便缓存)
RUN cabal new-update

# 编译 graphql-engine 可执行文件
# 我们将加载中替换为中文
RUN sed -i 's/Loading/加载中/g' src-rsr/console.html && \
    # https://cabal.readthedocs.io/en/3.4/cabal-project.html#cfg-flag---jobs
    cabal new-build --jobs=$(nproc)
RUN build_output=../_build_output && \
    exec_glob=`find ./dist-newstyle/ -type f -name "graphql-engine"` && \
    mkdir $build_output && \
    cp "$exec_glob" $build_output/ && \
    # get-version 需要基于git仓库获取版本号
    ../scripts/get-version.sh >$build_output/version.txt 


## -- 提取基础的rootfs
# docker build --progress plain -t graphql-engine-baserootfs:20201110 --target baseRootfs ./
FROM ${packager_image} as baseRootfs
COPY --from=builder /app/graphql-engine/_build_output/ /root/
RUN mkdir /rootfs/ && /build.sh graphql-engine | tar -x -C /rootfs/


## 构建最终的rootfs
# docker build --progress plain -f Dockerfile-all.dockerfile -t graphql-engine-builderrootfs:20201110 --target bulderRootfs ./
FROM builder as bulderRootfs
WORKDIR /app/graphql-engine/
COPY --from=baseRootfs /rootfs /app/graphql-engine/server/packaging/build/rootfs

RUN pg_dump_ver=12 && \
    exec_glob=`find server/dist-newstyle/ -type f -name "graphql-engine"` && \
    build_output=./_build_output  && \
    packaging_dir=./server/packaging/  && \
    rootfs_dir=$packaging_dir/build/rootfs  && \
    cp $build_output/graphql-engine $rootfs_dir/bin && \
    # 获取所有动态链接库
    ldd $build_output/graphql-engine | awk 'BEGIN{ORS="\n"}$1~/^\//{print $1}$3~/^\//{print $3}' | xargs cp -n -L --parents -t $rootfs_dir/ && \
    # 获取 pg_dump
    cp /usr/lib/postgresql/$pg_dump_ver/bin/pg_dump $rootfs_dir/bin/pg_dump && \
    # 优化&压缩
    strip --strip-unneeded $rootfs_dir/bin/graphql-engine && \
    upx $rootfs_dir/bin/graphql-engine 

## - 不带 console-assets
# docker build --progress plain -f Dockerfile-base.dockerfile -t graphql-engine-base:20201110 --target graphql-engine-base ./
FROM scratch as graphql-engine-base
COPY --from=bulderRootfs /app/graphql-engine/server/packaging/build/rootfs/ /
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
CMD ["graphql-engine", "serve"]
```

构建命令：

* **X86**

  ```shell
  builder_image=hanlyjiang/graphql-engine-builder:20201111
  packager_image=hasura/graphql-engine-packager:20190731
  TAG=$(date '+%Y%m%d')
  
  docker build ./ -t graphql-engine-base:$TAG --build-arg builder_image="$builder_image" --build-arg packager_image="$packager_image"
  ```

* **ARM**

  ```shell
  builder_image=hanlyjiang/graphql-engine-builder:arm-latest
  packager_image=hanlyjiang/graphql-engine-packager:20200814
  TAG=$(date '+%Y%m%d')
  
  # ARM机器执行
  docker build  -t graphql-engine-base:arm-$TAG --build-arg builder_image="$builder_image" --build-arg packager_image="$packager_image" ./
  
  # x86交叉构建
  docker buildx build --platform=linux/arm64 -t  graphql-engine-base:arm-$TAG --build-arg builder_image="$builder_image" --build-arg packager_image="$packager_image" ./ --load
  ```

  

## graphql-engine 镜像构建

graphql-engine 即是我们最终需要使用的镜像，包含graphql-engine 的server及console web资源；

### X86

```dockerfile
### 构建 graphql-engine 镜像
## docker build -t graphql-engine:20201111 ./

## -- 构建 console 
# docker build --progress plain -f Dockerfile-console.dockerfile  -t graphql-engine-consolebuilder:20201110 --target consoleBuilder ./
FROM hanlyjiang/node-11-alpine-git:20201113 as consoleBuilder
# 有时console代码更新，我们直接从仓库获取最新代码
# COPY --from=builder /app/graphql-engine/console /app/console
ARG GIT_TAG=v1.3.2
ARG GIT_USER=docker-build
ARG GIT_PWD=4Kqy9Cb4FcYx2H4goiEq
RUN git clone -b $GIT_TAG http://$GIT_USER:$GIT_PWD@172.17.0.205/dept-development/product-project/geopanel/development-center/blockdataapi-engine.git /app/graphql-engine

WORKDIR /app/graphql-engine/console
# 单独提取install步骤便于缓存
RUN set -eux ; \
    npm config set sass_binary_site=https://npm.taobao.org/mirrors/node-sass && \
    npm install --registry=https://registry.npm.taobao.org
# RUN npm install
RUN git pull && npm run build
# 开始构建
RUN set -eux ; \
    CONSOLE_ASSETS_PATH=./static/assets && \
    DIST_PATH=./static/dist && \
    ls -laR $DIST_PATH && \
    if [ ! -d "$CONSOLE_ASSETS_PATH/common" ]; then \
		mkdir -p $CONSOLE_ASSETS_PATH/common; \
		cp -r "$DIST_PATH/../assets/common" "$CONSOLE_ASSETS_PATH"; \
	fi;  \ 
	rm -rf "$CONSOLE_ASSETS_PATH/versioned" && \
	mkdir -p "$CONSOLE_ASSETS_PATH/versioned" && \
    cp "$DIST_PATH"/*.js "$CONSOLE_ASSETS_PATH/versioned/" && \
	gzip -f $CONSOLE_ASSETS_PATH/versioned/*.js && \
    # console 打包方式中可能将css放置到js中，这里不强制要求有css文件生成
    cp "$DIST_PATH"/*.css "$CONSOLE_ASSETS_PATH/versioned/" || true && \
    gzip -f $CONSOLE_ASSETS_PATH/versioned/*.css || true

## -- 构建最终镜像
# docker build --progress plain -t graphql-engine:20201110 ./
FROM zh-registry.geostar.com.cn/geopanel/graphql-engine-base:20201123
LABEL maintainer="jianghanghang@geostar.com.cn"
COPY --from=consoleBuilder /app/graphql-engine/console/static/assets /srv/console-assets

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh /

ENTRYPOINT ["docker-entrypoint.sh"]
```

执行如下命令构建：

```shell
TAG=$(date '+%Y%m%d')
docker build -t graphql-engine:$TAG ./
```



### ARM

```dockerfile
### 构建 graphql-engine 镜像
## docker build  -f Dockerfile-arm.dockerfile -t graphql-engine:20201113 ./
## docker buildx build --platform=linux/arm64  -f Dockerfile-arm.dockerfile -t graphql-engine:arm-20201113 ./ --load

## -- 构建 console 
# docker buildx build --platform=linux/arm64 --progress plain -f Dockerfile-console.dockerfile  -t graphql-engine-consolebuilder:20201110 --target consoleBuilder ./  --load
FROM hanlyjiang/node-11-alpine-git:20201113 as consoleBuilder
# 有时console代码更新，我们直接从仓库获取最新代码
# COPY --from=builder /app/graphql-engine/console /app/console
ARG GIT_TAG=v1.3.2
ARG GIT_USER=docker-build
ARG GIT_PWD=4Kqy9Cb4FcYx2H4goiEq
RUN git clone -b $GIT_TAG http://$GIT_USER:$GIT_PWD@172.17.0.205/dept-development/product-project/geopanel/development-center/blockdataapi-engine.git /app/graphql-engine

WORKDIR /app/graphql-engine/console
# 单独提取install步骤便于缓存
RUN npm install --registry=https://registry.npm.taobao.org
RUN npm run build 
# 开始构建
RUN set -eux ; \
    CONSOLE_ASSETS_PATH=./static/assets && \
    DIST_PATH=./static/dist && \
    ls -laR $DIST_PATH && \
    if [ ! -d "$CONSOLE_ASSETS_PATH/common" ]; then \
		mkdir -p $CONSOLE_ASSETS_PATH/common; \
		cp -r "$DIST_PATH/../assets/common" "$CONSOLE_ASSETS_PATH"; \
	fi;  \ 
	rm -rf "$CONSOLE_ASSETS_PATH/versioned" && \
	mkdir -p "$CONSOLE_ASSETS_PATH/versioned" && \
    cp "$DIST_PATH"/*.js "$CONSOLE_ASSETS_PATH/versioned/" && \
	gzip -f $CONSOLE_ASSETS_PATH/versioned/*.js && \
    # console 打包方式中可能将css放置到js中，这里不强制要求有css文件生成
    cp "$DIST_PATH"/*.css "$CONSOLE_ASSETS_PATH/versioned/" || true && \
    gzip -f $CONSOLE_ASSETS_PATH/versioned/*.css || true

## -- 构建最终镜像
# docker buildx build --platform=linux/arm64  --progress plain -t graphql-engine:20201110 ./  --load
FROM zh-registry.geostar.com.cn/geopanel/graphql-engine-base:arm-v1.3.2
LABEL maintainer="jianghanghang@geostar.com.cn"
COPY --from=consoleBuilder /app/graphql-engine/console/static/assets /srv/console-assets
# COPY --from=zh-registry.geostar.com.cn/geopanel/graphql-engine:v1.3.2 /srv/console-assets /srv/console-assets

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh /

ENTRYPOINT ["docker-entrypoint.sh"]

```

构建命令：

```shell
TAG=$(date '+%Y%m%d')
docker build  -f Dockerfile-arm.dockerfile -t graphql-engine:$TAG ./
docker buildx build --platform=linux/arm64  -f Dockerfile-arm.dockerfile -t graphql-engine:arm-$TAG ./ --load
```



### 构建脚本简化(未验证)

```dockerfile
### 构建 graphql-engine 镜像
## docker build  -f Dockerfile-arm.dockerfile -t graphql-engine:20201113 ./
## docker buildx build --platform=linux/arm64  -f Dockerfile-arm.dockerfile -t graphql-engine:arm-20201113 ./ --load

ARG base_image

## -- 构建 console 
# docker buildx build --platform=linux/arm64 --progress plain -f Dockerfile-console.dockerfile  -t graphql-engine-consolebuilder:20201110 --target consoleBuilder ./  --load
FROM hanlyjiang/node-11-alpine-git:20201113 as consoleBuilder
# 有时console代码更新，我们直接从仓库获取最新代码
# COPY --from=builder /app/graphql-engine/console /app/console
ARG GIT_TAG=v1.3.2
ARG GIT_USER=docker-build
ARG GIT_PWD=4Kqy9Cb4FcYx2H4goiEq
RUN git clone -b $GIT_TAG http://$GIT_USER:$GIT_PWD@172.17.0.205/dept-development/product-project/geopanel/development-center/blockdataapi-engine.git /app/graphql-engine

WORKDIR /app/graphql-engine/console
# 单独提取install步骤便于缓存
RUN npm install --registry=https://registry.npm.taobao.org
RUN npm run build 
# 开始构建
RUN set -eux ; \
    CONSOLE_ASSETS_PATH=./static/assets && \
    DIST_PATH=./static/dist && \
    ls -laR $DIST_PATH && \
    if [ ! -d "$CONSOLE_ASSETS_PATH/common" ]; then \
		mkdir -p $CONSOLE_ASSETS_PATH/common; \
		cp -r "$DIST_PATH/../assets/common" "$CONSOLE_ASSETS_PATH"; \
	fi;  \ 
	rm -rf "$CONSOLE_ASSETS_PATH/versioned" && \
	mkdir -p "$CONSOLE_ASSETS_PATH/versioned" && \
    cp "$DIST_PATH"/*.js "$CONSOLE_ASSETS_PATH/versioned/" && \
	gzip -f $CONSOLE_ASSETS_PATH/versioned/*.js && \
    # console 打包方式中可能将css放置到js中，这里不强制要求有css文件生成
    cp "$DIST_PATH"/*.css "$CONSOLE_ASSETS_PATH/versioned/" || true && \
    gzip -f $CONSOLE_ASSETS_PATH/versioned/*.css || true

## -- 构建最终镜像
# docker buildx build --platform=linux/arm64  --progress plain -t graphql-engine:20201110 ./  --load
FROM ${base_image}
LABEL maintainer="jianghanghang@geostar.com.cn"
COPY --from=consoleBuilder /app/graphql-engine/console/static/assets /srv/console-assets
# COPY --from=zh-registry.geostar.com.cn/geopanel/graphql-engine:v1.3.2 /srv/console-assets /srv/console-assets

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh /

ENTRYPOINT ["docker-entrypoint.sh"]
```

* x86构建：

  ```shell
  base_image=zh-registry.geostar.com.cn/geopanel/graphql-engine-base:20201123
  
  TAG=$(date '+%Y%m%d')
  
  docker build ./ -t graphql-engine-base:$TAG --build-arg base_image="$base_image" --build-arg 
  ```

  

* arm构建

  ```shell
  base_image=zh-registry.geostar.com.cn/geopanel/graphql-engine-base:arm-v1.3.2
  
  TAG=$(date '+%Y%m%d')
  
  # arm 机器直接构建
  docker build ./ -t graphql-engine:arm-$TAG --build-arg base_image="$base_image" --build-arg 
  
  
  # x86交叉构建
  docker buildx build --platform=linux/arm64 -t  graphql-engine:arm-$TAG --build-arg base_image="$base_image" ./ --load
  ```



# GeoPanel容器化-自研服务镜像构建

## 前言

所有当前已经构建的服务，都可以通过[gepanel-deploy 仓库中的readme](http://172.17.0.205/dept-development/product-project/geopanel/geopanel-deploy/-/blob/master/README.md)进行快速导航，如：

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210319162128.png" alt="image-20210319162127913" style="zoom: 50%;" />

## blockapi-token 服务镜像构建

镜像构建的相关文件目录位于 [gitlab此路径](http://zh-gitlab.geostar.com.cn/dept-development/product-project/geopanel/development-center/blockdataapi-engine/-/tree/v1.3.2/docker/hasura-token)，具体构建时操作步骤如下：

1. **王峰**提供成品jar包；
2. 放置到此目录执行docker buildx build 命令打包；

由于其dockerfile非常简单，所以在此不再解释，可直接查看gitlab中对应的：

* [dockerfile](http://172.17.0.205/dept-development/product-project/geopanel/development-center/blockdataapi-engine/-/blob/v1.3.2/docker/hasura-token/Dockerfile)
* [打包及使用方式](http://172.17.0.205/dept-development/product-project/geopanel/development-center/blockdataapi-engine/-/blob/v1.3.2/docker/hasura-token/README.md)



## blockapi-db-integrate 服务镜像构建

数据库集成服务的镜像构建相关文件位于 [gitlab此路径](http://zh-gitlab.geostar.com.cn/dept-development/product-project/geopanel/FusionCenter/integrate-db/-/tree/dev/docker) ，具体构建时操作步骤如下：

1. **韩小乐** 提供成品jar或者我们自行从[源码](http://zh-gitlab.geostar.com.cn/dept-development/product-project/geopanel/FusionCenter/integrate-db/-/tree/dev)编译jar；
2. 放置到docker构建目录使用docker buildx build命令构建；

由于其dockerfile非常简单，所以在此不再解释，可直接查看gitlab中对应的：

* [dockerfile](http://172.17.0.205/dept-development/product-project/geopanel/FusionCenter/integrate-db/-/blob/dev/docker/Dockerfile)
* [打包及使用方式](http://172.17.0.205/dept-development/product-project/geopanel/FusionCenter/integrate-db/-/blob/dev/docker/README.md)



## blockapi-restapi 服务镜像构建

由于之前有完成过，在此不在叙述，可参考 [此gitlab目录](http://zh-gitlab.geostar.com.cn/dept-development/product-project/geopanel/FusionCenter/rest-api/-/tree/master/docker)



## gpl-datacollection 服务镜像构建

埋点系统服务镜像的构建文件位于 [gitlab此路径](http://zh-gitlab.geostar.com.cn/dept-development/product-project/geopanel/development-center/event-tracking-manager-system/-/tree/develop/docker) ，具体构建时操作步骤如下：

1. **王峰** 提供成品jar；
2. 放置到docker构建目录使用 docker buildx build命令构建；

由于其dockerfile非常简单，所以在此不再解释，可直接查看gitlab中对应的：

* [dockerfile](http://172.17.0.205/dept-development/product-project/geopanel/development-center/event-tracking-manager-system/-/blob/develop/docker/Dockerfile)
* [打包及使用方式](http://172.17.0.205/dept-development/product-project/geopanel/development-center/event-tracking-manager-system/-/blob/develop/docker/README.md)





# GeoPanel容器化-服务编排

## 镜像存储及分发管理

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210323092448.png" alt="geopanel-registrys" style="zoom: 40%;" />

1. harbor 为内网基于 [harbor](https://goharbor.io/) 搭建的私有docker registry;
2. 对于自行构建的镜像，我们只需要将镜像推送到harbor，根据配置好的自动复制规则，镜像会自动同步到阿里云私有docker镜像仓库，之后该镜像即可从阿里云镜像仓库拉取；
3. harbor仓库可使用域账号进行登录，按项目进行读写权限控制；   
4. 阿里云的私有镜像仓库开放一个公用的只读账号，不接受手动镜像推送；   
5. 实际部署时，可根据现场的网络情况，选择使用公司仓库/阿里云仓库在线拉取，或者使用镜像批量导出脚本批量导出镜像文件，进行离线部署；



## GeoPanel服务名及变量命名约定

### 自有服务命名约定   

规范服务命名能方便标识服务之间的逻辑关系，对应的服务命名会反映到集群部署中服务的名称，服务中接口/页面的基础地址，服务相关的配置变量。

* 服务中应包含服务所属的模块内容缩写，如块数据api引擎为blockapi；
* 服务的容器编排名称，镜像名称，服务的基础服务地址，服务在整个集群中的导入或导出的配置变量名称均应保持一致性；

目前有如下几个主要服务单元：

#### **当前集群服务命名**

| 服务             | 命名说明                                                     |
| ---------------- | ------------------------------------------------------------ |
| 块数据API引擎    | 命名为 blockapi ，包含以下服务：<br/>1. `blockapi` : 块数据api引擎服务（基础hasura graphql引擎）<br/>2. `blockapi-token`: 块数据api引擎扩展模块-token管理service <br/>3. `blockapi-db-integrate`：块数据api引擎扩展模块-数据库集成service <br/>4. `blockapi-restapi`: 块数据api引擎扩展模块-restapi service |
| 埋点日志管理系统 | 命名 ： `gpl-data-collection`                                |

#### **当前各服务接口/web界面基础地址：**

| 服务                  | 基础地址             | 示例                                                         |
| --------------------- | -------------------- | ------------------------------------------------------------ |
| blockapi              | -                    | 保持和开源版本graphql-engine一致                             |
| blockapi-token        | /block-api/tks       | http://192.168.43.73:8881/block-api/tks                      |
| blockapi-db-integrate | /block-api/db-intgrs | http://192.168.43.73:8882/block-api/db-intgrs                |
| blockapi-restapi      | /block-api/restapi   | [http://172.17.0.105:8884/block-api/restapi](http://172.17.0.105:8884/block-api/restapi) |
| gpl-data-collection   | /gpl-dc              | http://192.168.43.73:8883/gpl-dc                             |

### 通用变量说明

#### 概述

在服务部署时，我们使用环境变量来为各个服务提供需要的配置，以下通用变量用于减少服务部署时所需要的变量，大致按以下原则：

* 相同含义的变量尽量统一为一个
* 有可能内部和外部用途的服务使用两个变量区分开来
* 变量命名需要带上服务名前缀

> **外部URL和内部URL说明：（下方部分服务会导出内部和外部两个url的变量）**
>
> * **内部URL**：在docker集群内部，可以使用服务名替代IP地址访问对应的服务，一般用于服务内部之间互相访问；（如使用内部URL，在部署时可不需要修改配置）
> * **外部URL**：当服务需要给客户端（如APP或浏览器）或不属于我方服务集群的其他服务调用时，需要提供外部的IP（非docker集群内部）给外部访问；

| **服务**              | **变量名**                                                   | 说明及示例值                                                 | **springboot变量名**                      |
| :-------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | ----------------------------------------- |
| postgres              |                                                              |                                                              |                                           |
| zookeeper             |                                                              | 暂未供外部使用，不导出变量                                   |                                           |
| kafka                 | *kafka 内部地址*<br/>`KAFKA_INTERNAL_URL`                    | kafka:9092                                                   | kafka.internal_url                        |
|                       | *kafka 外部地址*<br/>`KAFKA_EXTERNAL_URL`                    | 192.168.43.22:9094                                           | kafka.external_url                        |
| redis                 | Redis服务主机<br/>`REDIS_HOST`                               | redis                                                        | redis.host                                |
|                       | Redis服务端口<br/>`REDIS_PORT`                               | 6379                                                         | redis.port                                |
|                       | Redis服务访问密码<br/>`REDIS_PASSWORD`                       | vsMEDgmxZdjOi7Nd                                             | redis.password                            |
| blockapi              | 块数据API引擎数据库地址<br/>`HASURA_GRAPHQL_DATABASE_URL`<br/>`BLOCKAPI_DATABASE_URL` | postgres://postgres:<br/>d8cfe3137214759a932014084ac410b9<br/>@postgres:5432/hasura | blockapi.database_url                     |
|                       | 块数据API引擎管理密钥<br/>`HASURA_GRAPHQL_ADMIN_SECRET`<br/>`BLOCKAPI_ADMIN_SECRET` | d8cfe3137214759a932014084ac410b9<br/>两个变量含义一致，优先使用 BLOCKAPI_ADMIN_SECRET | blockapi.admin_secert                     |
|                       | 块数据API引擎内部地址<br/>`BLOCKAPI_INTERNAL_URL`            | `http://graphql-engine:8080`                                 | blockapi.internal_url                     |
|                       | 块数据API引擎的外部地址<br>`BLOCKAPI_EXTERNAL_URL`           | `http://192.168.43.22:8883`                                  | blockapi.external_url                     |
| blockapi-token<br>    | 块数据API引擎token管理服务内部接口地址<br>`BLOCKAPI_TOKEN_INTERNAL_URL` | http://blockapi-token:9099/block-api/tks                     | blockapi.token.internal_url               |
|                       | 块数据API引擎token管理服务外部接口地址<br>`BLOCKAPI_TOKEN_EXTERNAL_URL` | http://192.168.43.73:8881/block-api/tks                      | blockapi.token.external_url               |
| blockapi-db-integrate | 块数据API引擎数据库集成服务外部接口地址<br>`BLOCKAPI_DATABASE_INTEGRATE_EXTERNAL_URL` | http://192.168.43.73:8882/block-api/db-intgrs                | blockapi.database_intergrate.external_url |
| gpl-data-collection   | 埋点系统服务地址，暂未供外部使用，但提供预定义2个变量<br>`GPL_DATACOLLECTION_INTERNAL_URL` |                                                              | gpl_datacollection.internal_url           |
|                       | `GPL_DATACOLLECTION_EXTERNAL_URL`                            |                                                              | gpl_datacollection.external_url           |

#### 在springboot中使用变量

> 待补充



## 当前服务编排策略

当前将所有已经容器化的服务划分为如下服务部署单元：

```mermaid
graph LR

G[GeoPanel] --> B

G --> K

G --> GPL_DC

B[blockapi] --> blockapi-engine
B --> postgres
B --> redis
B --> blockapi-token
B --> blockapi-db-integrate
B --> blockapi-restapi

K[kafka] --> kafka
K --> zookeeper

GPL_DC[gpl-datacollection] --> gpl-datacollection
```

目前分为三块（blockapi，kafka，gpl-datacollection），每个模块分别对应一个swarm的部署yml配置，可以单独进行启动，使用相同的stack名称启动后，则可以进入一个stack中；

部署仓库地址位于[gitlab上](http://zh-gitlab.geostar.com.cn/dept-development/product-project/geopanel/geopanel-deploy)。

## 当前部署仓库细节说明

```shell
.
├── README.md -- 文档说明
├── blockapi -- 块数据api引擎的部署配置所在目录
│   ├── README.md -- 块数据api引擎的配置及启动说明文档
│   ├── config.env -- 单独的配置文件，目前未使用
│   ├── db-init - 数据库初始化脚本，仅做备份，目前未使用
│   │   ├── 00_fdws.sh
│   │   ├── 10_postgis.sh
│   │   └── 20_gpl_data_collection.sql
│   ├── docker-compose-arm.yml -- arm版本的部署配置文件
│   ├── docker-compose.yml -- x86版本的部署配置文件
│   └── redis-config -- redis 配置
│       └── redis.conf
├── data -- 数据挂载目录
│   └── redis
├── deploy.sh -- 辅助部署脚本
├── env -- 全局配置目录
│   └── global.env -- 全局配置，包含所有配置项目，如可能有需要使用公共配置的，服务都应该在yml中声明时引用此配置
├── gpl-datacollection -- 埋点管理系统部署配置目录
│   ├── README.md -- 埋点系统的配置修改及启动方式说明文档
│   ├── config.env -- 埋点系统的单独的配置文件，目前未使用
│   └── docker-compose.yml --埋点系统的部署启动配置文件
├── kafka -- kafka的部署配置目录
│   ├── README.md -- kafka服务说明，kafka验证方式说明
│   └── docker-compose.yml -- 部署配置文件
```

总的来说，目前有如下结构设计：

1. 按逻辑相关性将服务进行一定的划分，一个单元的服务的部署相关文件及配置在一个部署目录中单独存储，使用一个docker-compose.yml文件来编排，可以单独启动；
2. 使用一个 `env/global.env` 文件来存放所有需要修改的配置及全局配置/需要共享的配置-以方便部署时统一修改，每个部署单元中预留一个`.env`文件-用于存放私有配置，只是目前都没有使用；
3. 提供了一个 `deploy.sh` 的辅助部署脚本用于简化部署步骤，但此脚本目前并不够完善；
4. 每个部署目录提供README.md单独对当前目录中的部署单元进行说明，一般应包含配置修改说明，部署启动说明，启动成功确认方式，数据挂载情况说明，根据具体情况也可以提供简单的测试步骤；

> 对于各个部署单元的部署文件，不再单独说明，请参考仓库中的yml部署文件及readme




