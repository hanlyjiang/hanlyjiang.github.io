# Hasura镜像构建概览

## 目标及成果

我们希望能让hasura在arm平台上运行，最终也完成了构建流程，整体如下：

![image-20210316140949364](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210316140949.png)

## hasura 是什么？

引用[hasura官方]([https://github.com/hasura/graphql-engine/blob/master/translations/README.chinese.md](https://github.com/hasura/graphql-engine/blob/master/translations/README.chinese.md)
)的介绍
> Hasura GraphQL引擎是一个高性能的GraphQL服务器，可为您提供 **Postgres上开箱即用的实时GraphQL API**， 响应数据库事件的 [**Webhook触发器**](https://github.com/hasura/graphql-engine/blob/master/event-triggers.md)，以及用于业务逻辑处理的 [**远端Schema**](https://github.com/hasura/graphql-engine/blob/master/remote-schemas.md)。
> Hasura可帮助您构建基于Postgres的GraphQL应用程序，或将使用Postgres的现有应用迁移到GraphQL上。



Github及DockerHub地址：

* 开源仓库Github地址：[hasura/graphql-engine](hasura/graphql-engine)
* 官方Dockerhub镜像地址：[hasura/graphql-engine](https://hub.docker.com/r/hasura/graphql-engine/tags?page=1&ordering=last_updated)

通过官方的dockerhub可以看到，目前没有arm版本的镜像，故我们需要从头编译。

## hasura整体结构

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

## 整体构建流程梳理

### 代码结构说明

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

### graphql-engine console

console为web工程，使用npm run build即可编译，非常简单。我们只需要重点关注server部分即可。现在我们重点分析这个server部分：

### graphql-engine server

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



### 整体构建流程

在浏览`graphql-engine` 的仓库中ci构建的部分文件之后，我发现还需要其他一些辅助镜像，最后梳理出如下构建流程：

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210316090603.png" alt="docker-image-builder-flow" style="zoom: 50%;" />



1. 首先，我们需要构建 `graphql-engine-builder` 的镜像，其中包括haskell的GHC编译器及cabal依赖管理工具；
2. 然后我们使用`graphql-engine-builder`镜像对 graphql-engine 的源码进行编译，生成 graphql-engine 的二进制可执行文件及 graphql-engine 运行所需要的依赖库；
3. 由于第二步构建过程中有很多中间成果，我需要为graphql-engine创造一个纯净的运行环境以缩小最终的运行镜像的大小，所以我们需要构建 `graphql-engine-packager` 镜像，其中包含一个精简版的根文件系统。
4. 现在，我们将第二步中生成的graphql-engine及其依赖文件和第三步 `graphql-engine-packager` 镜像中的根文件系统合并到一个scratch镜像，然后生成 `graphql-engine-base` 的镜像，这个镜像已经包含了一个可以正常运行的 graphql-engine ，只是没有集成console资源到镜像中；
5. 最后我们对console进行编译，生成assets资源，然后基于 `graphql-engine-base` 添加这些前端资源文件，生成我们最终需要的 `graphql-engine` 镜像；



# graphql-engine-builder 镜像构建

基于以下原因，我决定构建一个graphql-engine-builder的镜像：

1. 不想污染自己的主机的环境，安装一堆haskell的构建环境；
2. 持久化编译环境，使得构建过程可以无成本迁移到任何机器；

这个builder镜像包含以下内容(实际上就是haskell语言的构建环境)：

* GHC
* cabal

经过一番尝试，确定了如下Dockerfile构建脚本：

## **X86** Dockerfile

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

## **ARM** Dockerfile

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

# graphql-engine-packager 构建

packager镜像中包含一个纯净的根文件系统，可为graphql-engine server提供基础的运行环境；

## 整体说明

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



## X86镜像构建

如上所述，我们直接基于官方的 `hasura/haskell-docker-packager:20190731`并使用源码目录中的 `packaging/packager.df` 文件构建出对应的`graphql-engine-packager`镜像即可；

## ARM

### haskell-docker-packager 镜像构建

arm版本则需要我们从头构建 `haskell-docker-packager` 的镜像，基于官方的 [github/hasura/haskell-docker-builder](https://github.com/hasura/haskell-docker-builder) 源码，我略作修改，让其可以构建出arm版本的镜像，对应的代码放置于 [github/hanlyjiang/haskell-docker-builder](https://github.com/hanlyjiang/haskell-docker-builder) 中，执行如下命令即可构建出arm版本的 `haskell-docker-packager` 镜像：

```shell
git clone git@github.com:hanlyjiang/haskell-docker-builder.git 
make build 
```

上述命令执行完毕后会生成一个 `hanlyjiang/haskell-docker-packager:当前日期` 的镜像。



### graphql-engine-packager 镜像构建

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



# graphql-engine-base 构建

`graphql-engine-base` 镜像包含 graphql-engine 的 server，当不包含 console 的 web 资源；

## X86镜像构建

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



## ARM版本镜像构建

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



## 构建脚本合并简化（未验证）

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

  

# graphql-engine 镜像构建

graphql-engine 即是我们最终需要使用的镜像，包含graphql-engine 的server及console web资源；

## X86

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



## ARM

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



## 构建脚本简化(未验证)

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