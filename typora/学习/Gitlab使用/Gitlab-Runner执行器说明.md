# Gitlab执行器说明

执行器的详细说明： https://docs.gitlab.com/runner/executors/README.html



## 执行器能力说明

| Executor                    | SSH  | Shell | VirtualBox | Parallels | Docker | Kubernetes |          Custom |
| :-------------------------- | :--: | :---: | :--------: | :-------: | :----: | :--------: | --------------: |
| 每次构建都清除构建环境      |  ✗   |   ✗   |     ✓      |     ✓     |   ✓    |     ✓      | conditional (4) |
| 使用之前已经存在的代码clone |  ✓   |   ✓   |     ✗      |     ✗     |   ✓    |     ✗      | conditional (4) |
| Runner文件系统访问保护 (5)  |  ✓   |   ✗   |     ✓      |     ✓     |   ✓    |     ✓      |     conditional |
| 迁移Runner机器              |  ✗   |   ✗   |  partial   |  partial  |   ✓    |     ✓      |               ✓ |
| 零配置支持并行构建          |  ✗   | ✗ (1) |     ✓      |     ✓     |   ✓    |     ✓      | conditional (4) |
| 复杂的构建环境              |  ✗   | ✗ (2) |   ✓ (3)    |   ✓ (3)   |   ✓    |     ✓      |               ✓ |
| 调试构建问题                | easy | easy  |    hard    |   hard    | medium |   medium   |          medium |

1. 可行，但是大多数情况下非常困难，尤其是构建过程使用的服务安装在构建主机上的时候；
2. 需要手动安装所有的依赖；
3. 可使用 Vagrant 来支持；
4. 根据你提供的不同的环境，可能是完全独立的或者在每个构建之间共享的；
5. 如果Runner的文件系统访问不受保护，则作业可以访问整个系统，包括Runner的令牌以及其他作业的缓存和代码。 标有✓的执行程序默认情况下不允许Runner访问文件系统。 但是，安全漏洞或某些配置可能会使作业脱离其容器并访问托管Runner的机器的文件系统。 



## 不同Runner执行器支持的特性



| Executor                             | SSH  |  Shell   | VirtualBox | Parallels | Docker | Kubernetes | Custom |
| :----------------------------------- | :--: | :------: | :--------: | :-------: | :----: | :--------: | :----: |
| 安全变量                             |  ✓   |    ✓     |     ✓      |     ✓     |   ✓    |     ✓      |   ✓    |
| GitLab Runner Exec command           |  ✗   |    ✓     |     ✗      |     ✗     |   ✓    |     ✓      |   ✓    |
| `gitlab-ci.yml`: image 配置          |  ✗   |    ✗     |     ✗      |     ✗     |   ✓    |     ✓      | ✓ (2)  |
| `gitlab-ci.yml`: services 配置       |  ✗   |    ✗     |     ✗      |     ✗     |   ✓    |     ✓      |   ✓    |
| `gitlab-ci.yml`: cache 配置          |  ✓   |    ✓     |     ✓      |     ✓     |   ✓    |     ✓      |   ✓    |
| `gitlab-ci.yml`: artifacts 配置      |  ✓   |    ✓     |     ✓      |     ✓     |   ✓    |     ✓      |   ✓    |
| 在不同构建阶段之间传递归档文件       |  ✓   |    ✓     |     ✓      |     ✓     |   ✓    |     ✓      |   ✓    |
| 使用 GitLab 容器 Registry 的私有镜像 | n/a  |   n/a    |    n/a     |    n/a    |   ✓    |     ✓      |  n/a   |
| 交互式Web控制终端                    |  ✗   | ✓ (UNIX) |     ✗      |     ✗     |   ✓    |   ✓ (1)    |   ✗    |

1. Interactive web terminals are not yet supported by [`gitlab-runner` Helm chart](https://docs.gitlab.com/runner/install/kubernetes.html), but support [is planned](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/issues/79).
2. 通过 [`$CUSTOM_ENV_CI_JOB_IMAGE`](https://docs.gitlab.com/runner/executors/custom.html#stages)



# 问题

* [如何在docker执行器中构建Docker镜像？](http://github.com/help/ci/docker/using_docker_build.md)

