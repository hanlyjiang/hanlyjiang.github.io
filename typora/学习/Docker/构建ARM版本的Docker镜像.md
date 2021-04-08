# ARM版本镜像构建（非ARM机器上执行）

>参考：
>-[https://github.com/docker/cli/blob/master/experimental/README.md](https://github.com/docker/cli/blob/master/experimental/README.md)
>-[跨平台构建 Docker 镜像新姿势，x86、arm 一把梭](https://cloud.tencent.com/developer/article/1543689)
## 构建ARM镜像的两种方式

对于构建镜像的ARM版本，有如下两种方式：

1. 在ARM机器上使用 `docker build` 进行构建；
2. 在X86/AMD64 的机器上使用 `docker buildx` 进行交叉构建；

实际测试中发现第一种方式在某些情况下会有问题，建议采用结合采用这二种方式；

关于第二种构建方式，可先阅读[跨平台构建 Docker 镜像新姿势，x86、arm 一把梭](https://cloud.tencent.com/developer/article/1543689)进行了解，以下简要介使用buildx交叉构建的方式；

## 启用试验性功能

>参考：https://docs.docker.com/engine/reference/commandline/cli/#experimental-features
>注意：buildx 仅支持 docker19.03 及以上docker版本

如需使用 buildx，需要开启docker的实验功能后，才可以使用，开启方式：

* 编辑   `/etc/docker/daemon.json`
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
    * `sudo systemctl  daemon-reload`
    * `sudo systemctl  restart docker`
* 确认是否开启：
    * `docker version -f'{{.Server.Experimental}}'`
    * 如果输出true，则表示开启成功
## 使用buildx构建

buildx 的详细使用可参考：[Docker官方文档-Reference-buildx ](https://docs.docker.com/engine/reference/commandline/buildx/)

### 创建 buildx 构建器

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

此时需要替换为下面的地址：

`ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-aarch64.tar.gz /tmp/s6-overlay.tar.gz`

当然，我们需要确认该软件有此架构的归档包，如果没有，则需要考虑从源码构建；

### docker buildx 构建arm64镜像的命令

使用 --platform来指定架构，使用 --push或 --load 来指定构建完毕后的动作。

```plain
docker buildx build --platform=linux/arm64,linux/amd64 -t xxxx:tag . --push 
```
### 检查构建成果

1. 通过docker buildx imagetools inspect 命令查看镜像信息，看是否有对应的arm架构信息；
2. 实际运行镜像，确认运行正常；（在arm机器上执行）
>提示： 如运行时输出 exec format error 类似错误，则表示镜像中部分可执行文件架构不匹配。
