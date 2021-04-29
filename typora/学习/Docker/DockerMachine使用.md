

> 官方文档： https://docs.docker.com/machine/

## 什么是Docker-Machine

## [安装](https://docs.docker.com/machine/install-machine/)

docker-machine 不集成到Docker安装包中，需要手动安装。

macOS上安装执行如下命令：

```shell
base=https://github.com/docker/machine/releases/download/v0.16.0 \
  && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/usr/local/bin/docker-machine \
  && chmod +x /usr/local/bin/docker-machine
  
docker-machine -v
#docker-machine version 0.16.0, build 702c267f
```

## 使用

### 要求

#### macOS

* VirtualBox

  Mac 版 Docker Desktop 使用 [HyperKit](https://github.com/docker/HyperKit/)，这是一个基于 [Hypervisor.framework ](https://developer.apple.com/reference/hypervisor)构建的轻量级 macOS 虚拟化解决方案。

  现在 `docker-machine create` 时没有对应于HyperKit的驱动，所以使用virtualbox驱动来创建本地机器；

### 创建机器

#### 查看

```shell
docker-machine ls
```

#### 创建

```shell
$ docker-machine create --driver virtualbox default
Creating CA: /Users/hanlyjiang/.docker/machine/certs/ca.pem
Creating client certificate: /Users/hanlyjiang/.docker/machine/certs/cert.pem
Running pre-create checks...
(default) Image cache directory does not exist, creating it at /Users/hanlyjiang/.docker/machine/cache...
(default) No default Boot2Docker ISO found locally, downloading the latest release...
(default) Latest release for github.com/boot2docker/boot2docker is v19.03.12
(default) Downloading /Users/hanlyjiang/.docker/machine/cache/boot2docker.iso from https://github.com/boot2docker/boot2docker/releases/download/v19.03.12/boot2docker.iso...
(default) 0%....10%....20%....30%....40%....50%....60%....70%....80%....90%....100%
Creating machine...
(default) Copying /Users/hanlyjiang/.docker/machine/cache/boot2docker.iso to /Users/hanlyjiang/.docker/machine/machines/default/boot2docker.iso...
(default) Creating VirtualBox VM...
(default) Creating SSH key...
(default) Starting the VM...
(default) Check network to re-create if needed...
(default) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env default
```

上面的命令会下载一个轻量级的Linux发行版([boot2docker](https://github.com/boot2docker/boot2docker)) ，这个发行版中包含了Docker daemon，然后启动一个VirtualBox的虚拟机来运行Docker。

```shell
$ docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER      ERRORS
default   -        virtualbox   Running   tcp://192.168.99.101:2376           v19.03.12
```

我们打开VirtualBox即可看到一个名为default的虚拟机：

![image-20210423113501360](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210423113501.png)

#### 获取环境命令

```shell
$ docker-machine env
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.101:2376"
export DOCKER_CERT_PATH="/Users/hanlyjiang/.docker/machine/machines/default"
export DOCKER_MACHINE_NAME="default"
# Run this command to configure your shell:
# eval $(docker-machine env)
```

#### 连接Shell到新的机器

```shell
$ eval "$(docker-machine env default)"
```

接下来就可以执行Docker命令了（==注意我们的macOS上没有启动Docker Desktop==）

```shell
docker run busybox echo hello world
```

### 运行容器并体验Machine命令

#### 查看主机IP

```shell
$ docker-machine ip default
192.168.99.101
```

#### 运行一个Nginx服务

```shell
# 运行
$ docker run -d -p 8000:80 nginx
# 访问
$ curl $(docker-machine ip default):8000
```

### 启动及停止机器

```shell
$ docker-machine stop default
$ docker-machine start default
```

### 不指定名称操作机器

如果没有指定机器，某些docker-machine的命令默认是运行在一个名为default的机器上的。

如：

```shell
 😃$  docker-machine stop
Stopping "default"...
Machine "default" was stopped.

 😃$ docker-machine start
Starting "default"...
(default) Check network to re-create if needed...
(default) Waiting for an IP...
Machine "default" was started.
Waiting for SSH to be available...
Detecting the provisioner...
Started machines may have new IP addresses. You may need to re-run the `docker-machine env` command.

 😃 $   eval $(docker-machine env)
 😃 $   docker-machine ip
192.168.99.101
```

遵守这个规格的命令包含：

```shell
    - `docker-machine config`
    - `docker-machine env`
    - `docker-machine inspect`
    - `docker-machine ip`
    - `docker-machine kill`
    - `docker-machine provision`
    - `docker-machine regenerate-certs`
    - `docker-machine restart`
    - `docker-machine ssh`
    - `docker-machine start`
    - `docker-machine status`
    - `docker-machine stop`
    - `docker-machine upgrade`
    - `docker-machine url`
```

### 取消当前shell中设置的环境变量

为了取消之后用其他的docker引擎，可执行如下命令：

#### 查看当前是否已经有变量设置

```shell
$ env | grep DOCKER
DOCKER_TLS_VERIFY=1
DOCKER_HOST=tcp://192.168.99.101:2376
DOCKER_CERT_PATH=/Users/hanlyjiang/.docker/machine/machines/default
DOCKER_MACHINE_NAME=default
```

#### unset DOCKER相关变量

**两种方式：**

1. 手动unset

   ```shell
   unset DOCKER_TLS_VERIFY
   unset DOCKER_CERT_PATH
   unset DOCKER_MACHINE_NAME
   unset DOCKER_HOST
   ```

2. 使用Docker的快捷命令

   ```shell
   $ docker-machine env -u
   unset DOCKER_TLS_VERIFY
   unset DOCKER_HOST
   unset DOCKER_CERT_PATH
   unset DOCKER_MACHINE_NAME
   # Run this command to configure your shell:
   # eval $(docker-machine env -u)
   
   # 执行如下命令才会真正unset
   $ eval $(docker-machine env -u)
   ```

#### 确认

```shell
# 查看变量
$ env | grep DOCKER
# 使用docker命令确认无法连接了
$ docker ps
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

### 在系统启动时启动本地Machine

#### 配置shell默认扩展环境

保证Docker-client在每个shell会话启动时自动配置，可以将 `eval $(docker-machine env default)` 设置到`./.bash_profile` 文件中，但是，如果默认的机器没有启动，这个命令会执行失败，所以需要配置虚拟机默认启动；

#### 配置VM自动启动

* 在 `~/Library/LaunchAgents/` 目录中创建一个文件 `com.docker.machine.default.plist`，输入如下内容：

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
      <dict>
          <key>EnvironmentVariables</key>
          <dict>
              <key>PATH</key>
              <string>/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin</string>
          </dict>
          <key>Label</key>
          <string>com.docker.machine.default</string>
          <key>ProgramArguments</key>
          <array>
              <string>/usr/local/bin/docker-machine</string>
              <string>start</string>
              <string>default</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
      </dict>
  </plist>
  ```

  > 可以将其中的default修改为其他的机器名称



## 常用命令

### 查看帮助

```shell
# 查看可用命令
$ docker-machine help
# 查看具体命令
$ docker-machine help ssh
```

### ssh到虚拟机

```shell
docker-machine ssh default
```



### 创建虚拟机

#### 全部按默认配置

```shell
docker-machine create --driver virtualbox default
```

#### 根据公司情况指定



```shell
docker-machine create --driver virtualbox \
    # 使用主机的DNS解析，避免内网域名解析失败
	--virtualbox-host-dns-resolver \
	# 自定义的registry仓库
	--engine-insecure-registry zh-registry.geostar.com.cn \
	# 阿里云镜像加速
	--engine-registry-mirror  https://8jzj574v.mirror.aliyuncs.com \
	# 避免和公司的DNS服务器网段冲突（172.17.0.3）
	--engine-opt bip=172.13.0.1/24 \
	default 
	
    # --engine-opt dns=172.17.0.3 \
```

#### 自定义VM的配置

```shell
docker-machine create --driver virtualbox \
	  --virtualbox-memory 4096 \
    --virtualbox-cpu-count 2 \
    --virtualbox-disk-size 10240 \
    --virtualbox-host-dns-resolver \
    --engine-insecure-registry zh-registry.geostar.com.cn \
    --engine-registry-mirror  https://8jzj574v.mirror.aliyuncs.com \
    --engine-opt bip=172.13.0.1/24 \
    worker1
```

> **参数说明：**
>
> * `--virtualbox-host-dns-resolver`  : 使用主机的DNS解析，避免内网域名解析失败
> * `--engine-insecure-registry zh-registry.geostar.com.cn` :  自定义的registry仓库
> * `--engine-registry-mirror  https://8jzj574v.mirror.aliyuncs.com` ： 阿里云镜像仓库
> * `--engine-opt bip=172.13.0.1/24`:  避免和公司的DNS服务器网段冲突（172.17.0.3）
> * `--virtualbox-memory 4096`  : 指定内存大小4G
> * `--virtualbox-cpu-count 2`:  指定CPU核心数量 2核
> * `--virtualbox-disk-size 10240`:  指定硬盘大小10G 

#### 如何设置更多选项

实际上，这里有几种类型的选项：

1. 用于指定docker engine的，包括用于指定swarm相关的；
2. 用于指定machine的，即VM的选项；



engine相关的参数以engine或者swarm开头

* engine-opt 可参考： [dockerd | Docker Documentation](https://docs.docker.com/engine/reference/commandline/dockerd/)
* VM相关的可以查看： https://docs.docker.com/machine/drivers/virtualbox/
  * 通过命令也可以查看帮助： `docker-machine create --driver virtualbox --help`



> **常用选项：**
>
> * `--virtualbox-memory`:  内存大小 MB
> * `--virtualbox-cpu-count `： CPU 核心数量，默认单核
> * `--virtualbox-disk-size`:  硬盘大小（MB）

## 其他

`sed 's/192.168.43.50/192.168.99.106/g' env/global.env`