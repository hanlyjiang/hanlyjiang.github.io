

# 容器和镜像

> 参考：
>
> 1. https://docs.docker.com/storage/storagedriver/#copying-makes-containers-efficient
> 2. https://docs.docker.com/get-started/overview/

## 概念解释

* 镜像是包含了创建容器指令的只读模板；
* 容器是镜像的可运行实例；

## Docker如何构建和存储镜像，镜像如何被容器使用

1. Dockerfile中的每条指令（部分指令不创建）都会创建一个层。
2. 启动容器时会在镜像的基础上添加一个容器层，该层是可写的；

![Layers of a container based on the Ubuntu image](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210419104503.jpg)

3. 容器和镜像的主要区别在于顶层的可写层，对容器的的所有读写都会存储在这个可写层中；当容器删除时，这个可写层可会被删除；而其他层则会被保留；

4. 每个容器有它自己的可写层，多个容器可共用底层镜像层；

   ![Containers sharing same image](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210419104741.jpg)



# Docker卷

> 参考： 
>
> https://docs.docker.com/storage/volumes/

## 基础

启动容器时，如果创建了一个新的卷，且容器内部的对应挂载点有文件，那么容器中的文件将会被复制到这个卷中



## 在机器之间共享数据

![shared storage](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210419105519.svg)

两种方式：

1. 在APP的逻辑中直接将数据存储于类似于Amazon S3的云对象存储系统；
2. 使用支持将文件写入到外部存储系统（如NFS和Amazon S3）的**驱动**来创建数据卷； 



## docker卷驱动

[Volume 驱动列表](https://docs.docker.com/engine/extend/legacy_plugins/#volume-plugins)：





# Docker官方宣传

**构建，分享，运行**





# Docker自身问题定位

## 查看日志

docker引擎日志，docker查看服务守护进程本身日志(注意不是容器日志)

```
journalctl -u docker.service
```

>  [Docker 日志都在哪里？怎么收集？ - YatHo - 博客园 (cnblogs.com)](https://www.cnblogs.com/YatHo/p/7866029.html)

`Docker 引擎日志` 一般是交给了 `Upstart`(Ubuntu 14.04) 或者 `systemd` (CentOS 7, Ubuntu 16.04)。前者一般位于 `/var/log/upstart/docker.log` 下，后者一般通过 `jounarlctl -u docker` 来读取。不同系统的位置都不一样，SO上有人总结了一份列表，我修正了一下，可以参考：

| 系统                   | 日志位置                                                     |
| ---------------------- | ------------------------------------------------------------ |
| Ubuntu(14.04)          | `/var/log/upstart/docker.log`                                |
| Ubuntu(16.04)          | `journalctl -u docker.service`                               |
| CentOS 7/RHEL 7/Fedora | `journalctl -u docker.service`                               |
| CoreOS                 | `journalctl -u docker.service`                               |
| OpenSuSE               | `journalctl -u docker.service`                               |
| OSX                    | `~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/log/d‌ocker.log` |
| Debian GNU/Linux 7     | `/var/log/daemon.log`                                        |
| Debian GNU/Linux 8     | `journalctl -u docker.service`                               |
| Boot2Docker            | `/var/log/docker.log`                                        |



## 遇到的奇怪问题及解决

### 卡死怎么重启

