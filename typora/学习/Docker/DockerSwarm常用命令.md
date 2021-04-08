# Docker Swarm常用命令

## 查看服务状态

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

  

