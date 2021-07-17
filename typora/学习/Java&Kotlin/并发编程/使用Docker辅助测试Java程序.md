# 使用Docker辅助测试Java程序

由于现在测试的程序在测试过程中可能过度占用主机资源，或者导致机器死机，所以我们使用docker来进行测试；

具体架构如下：

* 主机
  * virtualBox 虚拟机 （使用docker-machine）
    * docker - 最终测试的地方

由于又了多层的包装，无论怎么测试，都不会导致主机死机；

## gradle 编译可运行的jar

### 引入 application 插件并配置入口类

```groovy
plugins {
    id 'java'
    // 引入application插件
    id "application"
}

group 'cn.hanlyjiang'
version '1.0-SNAPSHOT'

repositories {
    mavenCentral()
}

application {
    // 配置入口类
    mainClassName("HashMapDeadLock")
}

dependencies {
    testCompile group: 'junit', name: 'junit', version: '4.12'
}
```

### 编译可运行产物

有如下命令可以执行：(我们的模块名称为 concurrent  )

```shell
./gradlew concurrent:distTar
or
./gradlew concurrent:distZip
or
./gradlew concurrent:build
or
./gradlew concurrent:assemble
```

完成后会在 `build/distributions` 目录中生成对应的 tar 或者 zip 文件；两个文件是一样的，只是归档格式差异，解压后结构如下：

```shell
.
├── bin
│   ├── concurrent
│   └── concurrent.bat
└── lib
    └── concurrent-1.0-SNAPSHOT.jar
```

我们可以通过运行 bin 目录中的脚本来从我们定义的 入口（mainClassName）来启动 jar 。

```shell
bin/concurrent
```

## 使用docker进行运行

我们使用 docker-machine 来使用docker，所以先要连接到 docker ，我们通过如下命令连接到 默认（default）的 docker-machine ，执行完毕后即可在当前终端中执行 docker 命令，该 docker 命令是连接到 default 这个虚拟机中的 docker-daemon 上的。

```shell
eval $(docker-machine env)
```

首先，我们进入到  `build/distributions`  目录，

* 执行如下命令设置要使用的镜像

    ```shell
    # 设置要使用的java镜像
    IMAGE=zh-registry.geostar.com.cn/geopanel/openjdk-12-jdk-alpine3.9:20210111
    # 或者使用 docker 官方 registry 中的镜像
    # IMAGE=openjdk-12-jdk-alpine3.9:20210111
    ```

* 启动一个容器，并进入 shell 交互环境

    这里我们通过 `-m` 来指定该 docker 容器可以使用的最大内存大小

    ```shell
    docker run -m 40MB -it --rm  -v $PWD:/work $IMAGE sh
    ```

* 启动另外一个 终端，并且连接虚拟机中的 docker，然后查看 docker 状态

  ```shell
  eval $(docker-machine env)
  
  docker stats 
  ```
  
  输出如下：
  
  ```shell
  CONTAINER ID   NAME                CPU %     MEM USAGE / LIMIT   MEM %     NET I/O     BLOCK I/O   PIDS
  7f116dea41cb   agitated_franklin   0.00%     592KiB / 40MiB      1.45%     836B / 0B   0B / 0B     1
  ```
  
* 接着我们在 docker  容器中执行 java 命令来测试对应的程序

    ```shell
    # 进入目标目录（相当于主机上的 build/distributions 目录）
    cd /work;
    
    # 解压
    unzip concurrent-1.0-SNAPSHOT.zip
    
    # 启动程序
    concurrent-1.0-SNAPSHOT/bin/concurrent
    ```

* 现在我们就可以观察执行效果及资源使用情况

  ![image-20210531112528378](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210531112530.png)

## 调试分析

如上，我们启动了两个终端，一个用于在容器中执行 java 程序，一个用于观察 docker 的状态，现在，如果我们需要进行分析，如，使用 jstack 对容器内部的 java 进程进行分析，我们应该怎么做呢？

1. 启动另外一个终端并连接 docker

   ```shell
   eval $(docker-machine env)
   ```

2. 查看启动的容器

   ```shell
   $ docker ps
   
   CONTAINER ID   IMAGE                               COMMAND   CREATED         STATUS         PORTS     NAMES
   46aaa3404f7a   openjdk-12-jdk-alpine3.9:20210111   "sh"      9 minutes ago   Up 9 minutes             vigorous_wilbur
   ```

   可以看到我们正在运行的容器，名称为 vigorous_wilbur 

3. 进入容器执行

   ```shell
   # 进入容器
   C_NAME=vigorous_wilbur
   docker exec -it $C_NAME sh
   ```

4. 在容器内部执行 jstack 命令

   ```shell
   # 由于 jstack 需要一个进程 id，我们通过 ps 来查找 (现在是在容器内部执行了)
   $$ ps -ef | grep java
     219 root      0:00 /opt/openjdk-12/bin/java -classpath /work/concurrent-1.0-SNAPSHOT/lib/concurrent-1.0-SNAPSHOT.jar DeadLock
     246 root      0:00 grep java
   ```

   可以看到我们先前执行的命令对应的进程 id 为 219 ，所以接下来我们执行 jstack 命令

   ```shell
   jstack 219 
   ```



执行 jstack  命令时我发现 jstack 命令执行的窗口中报了错误，但是在另外一个执行 java 程序的窗口中输出了一些信息

```shell
Found one Java-level deadlock:
=============================
"Thread-READ":
  waiting to lock monitor 0x000055d2d0845a00 (object 0x00000000fecad7d0, a java.lang.Object),
  which is held by "Thread-WRITE"
"Thread-WRITE":
  waiting to lock monitor 0x000055d2d0843900 (object 0x00000000fecad7c0, a java.lang.Object),
  which is held by "Thread-READ"

Java stack information for the threads listed above:
===================================================
"Thread-READ":
	at DeadLock.read(DeadLock.java:38)
	- waiting to lock <0x00000000fecad7d0> (a java.lang.Object)
	- locked <0x00000000fecad7c0> (a java.lang.Object)
	at DeadLock.lambda$main$0(DeadLock.java:19)
	at DeadLock$$Lambda$1/0x0000000801182840.run(Unknown Source)
	at java.lang.Thread.run(java.base@12-ea/Thread.java:835)
"Thread-WRITE":
	at DeadLock.write(DeadLock.java:49)
	- waiting to lock <0x00000000fecad7c0> (a java.lang.Object)
	- locked <0x00000000fecad7d0> (a java.lang.Object)
	at DeadLock.lambda$main$1(DeadLock.java:25)
	at DeadLock$$Lambda$2/0x0000000801182c40.run(Unknown Source)
	at java.lang.Thread.run(java.base@12-ea/Thread.java:835)

Found 1 deadlock.

Heap
 def new generation   total 2432K, used 1218K [0x00000000fec00000, 0x00000000feea0000, 0x00000000ff2a0000)
  eden space 2176K,  56% used [0x00000000fec00000, 0x00000000fed30b38, 0x00000000fee20000)
  from space 256K,   0% used [0x00000000fee20000, 0x00000000fee20000, 0x00000000fee60000)
  to   space 256K,   0% used [0x00000000fee60000, 0x00000000fee60000, 0x00000000feea0000)
 tenured generation   total 5504K, used 0K [0x00000000ff2a0000, 0x00000000ff800000, 0x0000000100000000)
   the space 5504K,   0% used [0x00000000ff2a0000, 0x00000000ff2a0000, 0x00000000ff2a0200, 0x00000000ff800000)
 Metaspace       used 440K, capacity 4539K, committed 4864K, reserved 1056768K
  class space    used 35K, capacity 404K, committed 512K, reserved 1048576K
```

![image-20210531114646359](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210531114647.png)

