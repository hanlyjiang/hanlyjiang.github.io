



## [概览](https://docs.docker.com/engine/swarm/)

当前版本的Docker中包含了一个swarm模式可以原生的支持管理Docker引擎集群。这个Docker引擎的集群就称之为==swarm==。 可以使用Docker命令行接口来创建集群，部署应用服务到集群，还有管理集群行为；



**主要特性：**

* **与Docker Engine集成**的**集群管理：**使用Docker Engine CLI创建一组Docker Engines，在那里您可以部署应用程序服务。您不需要额外的编排软件来创建或管理群。
* **分散式设计：**Docker Engine在运行时处理任何专业化，而不是在部署时处理节点角色之间的差异。您可以使用 Docker 引擎部署两种节点、经理和工人。这意味着您可以从单个磁盘映像构建整个群集。
* **声明式服务模型：**Docker Engine使用声明式方法，允许您定义应用程序堆栈中各种服务的理想状态。例如，您可以描述一个应用程序，该应用程序由带有消息队列服务和数据库后端的Web前端服务组成。
* **缩放：**对于每个服务，您可以声明要运行的任务数量。当您放大或缩小时，群管理器会自动通过添加或删除任务来调整，以保持所需的状态。
* **期望状态和解：**群管理器节点不断监控群集状态，并协调实际状态和您表达的所需状态之间的任何差异。例如，如果您设置一个服务来运行一个容器的10个副本，并且托管其中两个副本的工作机器崩溃，管理器将创建两个新副本来替换崩溃的副本。群管理器将新副本分配给正在运行且可用的工人。
* **多主机网络：**您可以为您的服务指定覆盖网络。群管理器在初始化或更新应用程序时会自动为覆盖网络上的容器分配地址。
* **服务发现：**群管理器节点为群中的每个服务分配一个唯一的DNS名称，并平衡正在运行的容器。您可以通过嵌入在群中的DNS服务器查询在群中运行的每个容器。
* **负载均衡：**您可以将服务的端口公开给外部负载均衡器。在内部，该群允许您指定如何在节点之间分发服务容器。
* **默认情况下安全：**群中的每个节点都强制TLS相互身份验证和加密，以确保自身与所有其他节点之间的通信安全。您可以选择使用自签名根证书或自定义根CA的证书。
* **滚动更新：**在推出时，您可以将服务更新增量应用于节点。群管理器允许您控制服务部署到不同节点集之间的延迟。如果出现任何问题，您可以回滚到服务的前一个版本。



## [关联概念](https://docs.docker.com/engine/swarm/key-concepts/)

群由多个Docker主机组成，这些主机以**群模式**运行，并担任经理（管理成员和授权）和工人（运行[群服务](https://docs.docker.com/engine/swarm/key-concepts/#services-and-tasks)）。给定的 Docker 主机可以是经理、工人或同时执行这两个角色。创建服务时，您定义其最佳状态（其可用的副本、网络和存储资源数量、服务对外公开的端口等）。Docker致力于维护所需的状态。例如，如果一个辅助节点不可用，Docker会将该节点的任务安排在其他节点上。==*任务*==是一个正在运行的容器，它是群服务的一部分，由群管理器管理，而不是独立的容器。

与独立容器相比，群服务的一个关键优势是，您可以修改服务的配置，包括其连接的网络和卷，而无需手动重新启动服务。Docker将更新配置，停止使用过时配置的服务任务，并创建与所需配置匹配的新任务。

当Docker以群模式运行时，您仍然可以在参与群的任何Docker主机上运行独立容器，以及群服务。独立容器和群服务的一个关键区别是，只有群管理器才能管理群，而独立容器可以在任何守护进程上启动。Docker守护进程可以作为经理、工人或两者兼而有之的群体参与。

与您可以使用[Docker Compose](https://docs.docker.com/compose/)定义和运行容器一样，您还可以定义和运行[Swarm服务](https://docs.docker.com/engine/swarm/services/)堆栈。



### 节点-Nodes

**节点**是参与群集的 Docker 引擎的实例。您也可以将此视为 Docker 节点。您可以在一台物理计算机或云服务器上运行一个或多个节点，但生产群部署通常包括分布在多台物理和云机器上的Docker节点。

要将应用程序部署到群集，请向**管理器节点**提交服务定义。管理节点将称为[任务](https://docs.docker.com/engine/swarm/key-concepts/#services-and-tasks)的工作单元调度到工作节点。

管理节点还执行维护群所需状态所需的编排和集群管理功能。管理节点选择单个领导者执行编排任务。

**工人节点**接收并执行从管理器节点发送的任务。默认情况下，管理器节点也作为辅助节点运行服务，但您可以将其配置为仅运行管理器任务，并且是仅管理节点。代理在每个辅助节点上运行，并报告分配给它的任务。辅助节点通知管理节点其分配任务的当前状态，以便管理器可以维护每个辅助器所需的状态。

### 服务和任务

**服务**是在管理器或辅助节点上执行的任务的定义。它是群系统的中心结构，也是用户与群交互的主要根。

创建服务时，指定使用哪个容器映像以及在运行的容器内执行哪些命令。

在**复制服务**模型中，群管理器根据您在所需状态下设置的规模，在节点之间分配特定数量的复制任务。

对于**全局服务**，群在集群中的每个可用节点上为服务运行一个任务。

**任务**携带一个Docker容器和在容器内运行的命令。它是群的原子调度单元。管理节点根据服务规模中设置的副本数量，将任务分配给工作节点。一旦任务被分配到一个节点，它就不能移动到另一个节点。它只能在指定的节点上运行或失败。



### 负载均衡


群管理器使用**入口负载平衡**将您希望外部提供的服务公开给群。群管理器可以自动为服务分配一个**PublishedPort**，也可以为服务配置一个PublishedPort。您可以指定任何未使用的端口。如果您没有指定端口，群管理器会为服务分配一个30000-32767范围内的端口。

外部组件，如云负载均衡器，无论该节点当前是否正在为服务运行任务，都可以在集群中任何节点的PublishedPort上访问服务。群路由中的所有节点都连接到正在运行的任务实例。

群模式有一个内部DNS组件，该组件会自动为群中的每个服务分配一个DNS条目。群管理器使用**内部负载平衡**，根据服务的DNS名称在集群内服务之间分配请求。





## 部署配置

参考： https://docs.docker.com/compose/compose-file/compose-file-v3/#deploy

用于指定部署和运行服务相关的配置。仅适用于swarm模式，docker-compose 模式下会被忽略；

示例配置：

```yaml
version: "3.9"
services:
  redis:
    image: redis:alpine
    deploy:
      replicas: 6
      placement:
        max_replicas_per_node: 1
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure
```

### endpoint_mode

指定连接到swarm的外部客户端的服务发现模式。

* `endpoint_mode: vip` - 默认模式，Docker为服务分配一个虚拟IP（VIP），作为客户端在网络上到达服务的前端。Docker在客户端和服务可用的辅助节点之间路由请求，客户端不知道有多少节点正在参与服务或其IP地址或端口。
* `endpoint_mode: dnsrr`- DNS循环（DNSRR）服务发现不使用单个虚拟IP。Docker为服务设置DNS条目，使服务名称的DNS查询返回IP地址列表，客户端直接连接到其中一个地址。DNS循环在想要使用自己的负载均衡器或混合Windows和Linux应用程序的情况下非常有用。

```yaml
version: "3.9"

services:
  wordpress:
    image: wordpress
    ports:
      - "8080:80"
    networks:
      - overlay
    deploy:
      mode: replicated
      replicas: 2
      endpoint_mode: vip

  mysql:
    image: mysql
    volumes:
       - db-data:/var/lib/mysql/data
    networks:
       - overlay
    deploy:
      mode: replicated
      replicas: 2
      endpoint_mode: dnsrr

volumes:
  db-data:

networks:
  overlay:
```

`endpoint_mode`的选项也可以作为群模式CLI命令[docker服务创建的](https://docs.docker.com/engine/reference/commandline/service_create/)标志。有关所有与群集相关的`docker`命令的快速列表，请参阅[群集模式CLI命令](https://docs.docker.com/engine/swarm/#swarm-mode-key-concepts-and-tutorial)。

要了解有关群模式下服务发现和联网的更多信息，请参阅群模式主题中的[配置服务发现](https://docs.docker.com/engine/swarm/networking/#configure-service-discovery)。



### labels

为服务指定标签。这些标签*只*设置在服务上，*不设置*在服务的任何容器上。

```yaml
version: "3.9"
services:
  web:
    image: web
    deploy:
      labels:
        com.example.description: "This label will appear on the web service"
```

如果要在容器上设置标签，则需要在deploy配置段之外使用labels标签：

```yaml
version: "3.9"
services:
  web:
    image: web
    labels:
      com.example.description: "This label will appear on all containers for the web service"
```

### mode

* `global`:  每个swarm节点上都运行一个容器；
* `replicated`:  （默认值），指定数量的容器

> 可以查看[swarm](https://docs.docker.com/engine/swarm/) 主题中的  [Replicated and global services](https://docs.docker.com/engine/swarm/how-swarm-mode-works/services/#replicated-and-global-services) 章节了解更多；

```yaml
version: "3.9"
services:
  worker:
    image: dockersamples/examplevotingapp_worker
    deploy:
      mode: global
```

### placement

指定替换约束及偏好。查看docker service 创建文档了解 [constraints](https://docs.docker.com/engine/reference/commandline/service_create/#specify-service-constraints---constraint), [preferences](https://docs.docker.com/engine/reference/commandline/service_create/#specify-service-placement-preferences---placement-pref), 和 [specifying the maximum replicas per node](https://docs.docker.com/engine/reference/commandline/service_create/#specify-maximum-replicas-per-node---replicas-max-per-node) 的详细规则。

```yaml
version: "3.9"
services:
  db:
    image: postgres
    deploy:
      placement:
        constraints:
          - "node.role==manager"
          - "engine.labels.operatingsystem==ubuntu 18.04"
        preferences:
          - spread: node.labels.zone
```

### max_replicas_per_node

> 3.8 版本文件格式添加

如果服务是  `replicated` 模式的，则可以[限制任意时间一个节点可以运行的replicas数量](https://docs.docker.com/engine/reference/commandline/service_create/#specify-maximum-replicas-per-node---replicas-max-per-node)。

```yaml
version: "3.9"
services:
  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    deploy:
      mode: replicated
      replicas: 6
      placement:
        max_replicas_per_node: 1
```

### replicas

指定应该运行的容器数量

```yaml
version: "3.9"
services:
  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    deploy:
      mode: replicated
      replicas: 6
```

### resources

每个配置都是一个单个值，参考 [docker service create](https://docs.docker.com/engine/reference/commandline/service_create/) 了解详细的值；

```yaml
version: "3.9"
services:
  redis:
    image: redis:alpine
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 50M
        reservations:
          cpus: '0.25'
          memory: 20M
```



### restart_policy

配置容器退出时的重启策略。

* `condition`:  `none`,`on-failure`, 或者 `any`,默认为 `any`；
* `delay`:  重启尝试之间的等待时间，默认为5秒；
* `max_attempts`:  容器启动成功前尝试的重启次数，默认永不放弃； 如果在配置的window时间内，容器重启没有成功，计数并不会增加。例如，如果max_attempts 设置为2，第一次重启尝试失败了，重启尝试的次数可能超过两次；
* `window`:  决定启动成功之前等待多久，默认立刻决定；

```yaml
version: "3.9"
services:
  redis:
    image: redis:alpine
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
```



### rollback_config

> 3.7 添加

配置服务失败时如何回滚。

- `parallelism`: 一次回滚的容器数量。设置为0时所有容器将同时回滚；
- `delay`: 每个容器组回滚之间的时间间隔 (默认 0s).
- `failure_action`: 回滚失败时做什么。 `continue` 或 `pause` (默认 `pause`)
- `monitor`: 更新每个任务以监视失败后的持续时间 `(ns|us|ms|s|m|h)` (默认 5s) **注意**: 设置为 0 将会使用默认值 5s. （？）
- `max_failure_ratio`: 回滚可以容忍的失败比例 (默认 0).
- `order`: 回滚操作的顺序. 可以设置为 `stop-first` (先停止旧的任务，然后启动新的任务), or `start-first` (新的任务先启动，新旧任务会有短暂的共存期) (默认 `stop-first`).



### update_config

配置服务如何被更新。对于配置滚动更新非常有用；

- `parallelism`: 一次更新的容器数量.
- `delay`: 更新一组容器之间的等待时间.
- `failure_action`: 更新失败时做什么.可选 `continue`, `rollback`, 或 `pause`(默认: `pause`).
- `monitor`: 更新每个任务以监视失败后的持续时间 `(ns|us|ms|s|m|h)` (默认 5s)  **注意**: 设置为 0 将会使用默认值 5s.
- `max_failure_ratio`: 更新期间容许的最大错误比例.
- `order`: 操作的顺序. 可以设置为 `stop-first` (先停止旧的任务，然后启动新的任务), or `start-first` (新的任务先启动，新旧任务会有短暂的共存期) (默认 `stop-first`). 仅支持3.4及以后版本

```yaml
version: "3.9"
services:
  vote:
    image: dockersamples/examplevotingapp_vote:before
    depends_on:
      - redis
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
        delay: 10s
        order: stop-first
```



## Docker Swarm常用命令

### 查看服务状态

* 查看stack列表

  ```shell
  docker stack ls
  ```

* 查看所有服务状态

  ```shell
  docker service ls
  ```

* 查看指定swarm的服务状态

  ```shell
  docker stack services [stack名称]
  ```

* 如果有服务启动有问题，可使用如下命令查看错误信息(`--no-trunc`避免错误信息被截断)

  ```shell
  docker stack ps --no-trunc [stack名称]
  ```

  



## 常见问题

### swarm模式下设置/dev/shm 的大小

swarm模式下设置/dev/shm 大小，参考：

- https://stackoverflow.com/questions/55416904/increase-dev-shm-in-docker-container-in-swarm-environment-docker-stack-deploy
- https://github.com/moby/moby/issues/26714
- https://github.com/docker/swarmkit/issues/1030#issuecomment-262551740

目前docker run时支持通过选项来指定shm的大小，但是swarm中不支持直接配置，可通过挂载tmpfs的方式实现：

**docker-swarm-shm.yaml**

```yaml
volumes:
      - type: tmpfs
        target: /dev/shm
        tmpfs:
           size: 4096000000 # (this means 4GB)
```
