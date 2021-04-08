# Gitlab-CI示例-Springboot项目自动部署

自动部署就是将原有手动的流程整理成脚本，交给机器自动完成。所以我们首先梳理下原有的构建及部署流程，然后将这些流程定义到GitlabCI。

# 原有流程整理

### 构建

    - 工程框架sprintboot，打包基于maven
    
    - 打包命令：mvn package
    
    - 打包成果物： war（target目录下）

### 部署（运行）

**普通形式**

    - 将打包出来的部署包（war，jar）复制到服务器
    
    - 执行 java -jar *.war 启动

**Docker形式（我们这里使用docker方式）**

    - 基于java构建镜像，直接使用docker运行



### 原有流程步骤列表：

- 使用mvn package打包

- 获取jar成果物

- 将jar打包成docker镜像

- 在部署服务器上重启



# Gitlab-Runner准备 

在Gitlab CI系统中，用于执行任务（脚本）的机器称之为Runner，

Gitlab-Runner的执行脚本的方式有多种，一般有docker及shell方式：

- docker 方式执行时，会通过指定的镜像，启动一个容器，并在容器内部执行我们指定的自动化任务的脚本

- shell方式执行时，等同于通过ssh方式连接到runner机器，执行指定的自动化任务的脚本；

在我们的这个自动部署任务中，需要两个Runner来分别执行构建及部署的任务。对于我们的构建及部署任务来说，构建使用docker执行方式的runner，部署则使用shell执行方式的Runner。现在我们将它们注册到gitlab。

## 构建用 Runner 准备

构建Runner使用部门共用的 Runner，该Runner上已配置docker环境。

此Runner的tag（后续指定任务执行机器）为：

- common_build

此Runner的注册过程记录在此文档：[__《GitlabRunner配置-共享》__](https://shimo.im/docs/PVAPV289P6tmFVql/)

## 部署用机器注册为Runner

我们的机器系统是 CentOS 7.6，可按如下步骤配置部署机器；

1. **安装 Gitlab Runner**

执行如下命令安装

```shell
curl -LJO https://gitlab-runner-downloads.s3.amazonaws.com/latest/rpm/gitlab-runner_amd64.rpm
yum install gitlab-runner_amd64.rpm

# install之后会自动运行，通过status查看运行状态
gitlab-runner status 
# 输出： 
# Runtime platform arch=amd64 os=linux pid=23079 
#       revision=21cb397c version=13.0.1
# 
gitlab-runner: Service is running!
```

1. **安装最新版本 git**

```shell
# 获取git源码
git     clone -b v2.27.0 https://gitee.com/hanlyjiang/git.git
cd git ; git checkout -b tag-v2.27.0 v2.27.0
# 安装编译所需工具链，不同机器初始环境可能不同，如构建（make）失败，可能需要安装其他包
yum install -y autoconf gcc openssh zlib-devel

# 开始编译
make configure 
./configure --prefix=/usr
make -j8 all 
# 编译完成，安装到系统
sudo make install 

# 安装成功，确认版本
git --version
  
# 输出如下： version 2.27.0
```

1. **获取机器注册Runner信息**

- Gitlab上进入我们项目的CI/CD的设置界面（[__http://172.17.0.205/Development/Mobile/georobox_3_0/georobox-mobile-server/-/settings/ci_cd__](http://172.17.0.205/Development/Mobile/georobox_3_0/georobox-mobile-server/-/settings/ci_cd)）

- 展开Runner标签获取注册信息

![image-20210302171729208](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171729.png)

准备如下信息

| 注册信息                  | 值                                    |
| --------------------- | ------------------------------------ |
| gitlab-ci url         | http://172.17.0.205/                 |
| gitlab-ci token       | LZ6zkDUhDbjz_edCKXbz                 |
| gitlab-ci description | GeoRobox3.0-后台                       |
| gitlab-ci tags        | georobox-deploy用于gitlab定义任务时，指定任务时机器 |
| gitlab-ci executor    | shell                                |

1. **注册为Runner**

    1. 执行：**gitlab-runner register **注册runner

    1. 执行：**gitlab-runner list** 查看注册的runner列表，确认注册情况

![image-20210302171738933](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171738.png)

1. **确认注册成功**（前往项目CI/CD设置界面，刷新，查看是否有刚才注册的Runner）

![image-20210302171743301](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171743.png)

## 部署机器给gitlab-runner添加docker执行权限

docker默认情况下仅root用户可用，我们通过gitlab-runner来更新服务时，实际上是通过gitlab-runner用户来执行的，需要给gitlab-runner用户执行docker命令的权限；

```text
 sudo usermod-a -G docker gitlab-runner
```

# Gitlab-CI 配置

Gitlab CI任务的入口配置文件为 .gitlab-ci.yml ，在执行ci流水线时，会读取此配置文件以生成对应的CI任务。

## 构建流程配置

```yaml
# 定义任务的名称
build:module:
  # 部分模块若不使用1.8编译会报错
  image: maven:3.6.3-jdk-8
  # 指定阶段为build，确定执行顺序，gitlab默认定义了三个阶段：test,build,deploy，任务按阶段顺序执行
  stage: build
  # 我们真正要做的事情，构建war
  script:
	# 默认情况下，当前所在目录为项目代码的根目录
	# 我们拷贝一个maven的配置， 指向公司的maven服务，加快依赖下载速度
    - cp -f $CI_PROJECT_DIR/settings.xml ~/.m2/settings.xml
	# 打包
    - mvn package
	# 调试用，查看包是否生成
    - ls -l $CI_PROJECT_DIR/target
  # 归档：将我们的构建好的包传递到下个阶段
  artifacts:
    name: "artifacts-$CI_PROJECT_NAME-$CI_COMMIT_SHORT_SHA-triggerBy-$CI_TRIGGER_PROJECT-$CI_TRIGGER_COMMIT_SHORT_SHA"
    paths:
	  # 指定要归档的成果文件
      - target/*.war
    # 生成的归档包比较大，我们只保留短时间
    expire_in: 1 hours
  # 指定任务运行的runner
  tags:
    - common-build
  # 指定任务执行的时机，这里的web指通过gitlab界面手动触发
  only:
    - web
```



## 部署流程配置

```yaml
deploy:all:
  # 定义阶段为 deploy，将在build阶段完成后执行
  stage: deploy
  script:
    # 调试用，查看构建成果物是否存在
    - ls -1  $CI_PROJECT_DIR/target
    # 构建docker镜像，docker镜像的名称为 georobox-server-jdk8:tag-ci
    # 我们将自己项目的docker镜像构建过程封装到shell脚本里面了
    - bash $CI_PROJECT_DIR/docker/build.sh "tag-ci" $CI_COMMIT_SHORT_SHA
    # 更新服务，在部署机器上，我们通过swarm方式启动了服务，所以这里通过docker service update 直接更新即可
    - docker service update --force --image georobox-server-jdk8:tag-ci georobox_server-main
    - echo -------- 服务已更新 ---------
  tags:
    # 指定我们的部署机器runner
    - georobox-deploy
  # 定义执行时机，只有上一阶段（build）成功的时候才执行
  when: on_success
  only:
    - web
```

# 附录：

## 项目目录结构

![image-20210302171752383](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171752.png)

## bulid.sh 

```shell
#!/bin/bash
# 用于构建GeoRobox镜像
# build.sh [IMAGE_TAG] [COMMIT_ID]
# - [IMAGE_TAG]: docker镜像的tag
# - [COMMIT_ID]：git 提交id，会作为标签写入到镜像内部
# 构建完会生成一个名为 georobox-server-jdk8:$IMAGE_TAG 的镜像
IMAGE_NAME=georobox-server-jdk8
IMAGE_TAG=$1
COMMIT_ID=$2

# IMAGE TAG 支持参数指定
if [ -z "$IMAGE_TAG" ]; then
    IMAGE_TAG="0.1"
fi

# 如果没有传提交id，则自行取
if [ -z "$COMMIT_ID" ]; then
    COMMIT_ID=$(git rev-parse --short HEAD || echo "none-git-ci-id")
fi

DOCKER_BUILD_PATH=$(
    cd $(dirname $0)
    pwd
)
PROJECT_BASE_DIR=$DOCKER_BUILD_PATH/..

# 将项目中的配置文件拷贝到docker构建目录
cp "$PROJECT_BASE_DIR/src/main/resources/application.properties" "$DOCKER_BUILD_PATH/conf/application.properties"
# 修改配置文件，重写mysql的服务地址为集群内部的
sed 's/localhost:3306/mysql:3306/g' "$DOCKER_BUILD_PATH"/conf/application.properties

# 将构建的成果物拷贝到docker构建目录
cp "$PROJECT_BASE_DIR"/target/*.war "$DOCKER_BUILD_PATH/jars/georobox.war"
if [ ! -e  "$DOCKER_BUILD_PATH"/jars/georobox.war ]; then
    echo "$DOCKER_BUILD_PATH/jars/georobox.war" not found!!!
    exit 99
fi

# 开始构建 docker 镜像
if [ -n "$CI_PROJECT_URL" ]; then
    # CI 自动构建环境下，提交多一点信息到镜像内部，后续可通过 docker inspect 查找镜像对应的代码版本
    # eg： docker inspect georobox-server-jdk8:tag-ci --format "{{json .ContainerConfig.Labels}}"
    docker build --label "git-ref=$CI_COMMIT_REF_NAME" --label "git-commit=$COMMIT_ID" --label "project-url=$CI_PROJECT_URL" -t $IMAGE_NAME:$IMAGE_TAG "$DOCKER_BUILD_PATH"
else
    # 本地执行的时候，就简单一点
    docker build --label "git-commit=$COMMIT_ID" -t $IMAGE_NAME:$IMAGE_TAG "$DOCKER_BUILD_PATH"
fi
```

## Dockerfile

```shell
# 构建GeoRobox移动后台镜像
FROM hub.c.163.com/xbingo/jdk8:latest
MAINTAINER "王僧仁" wangsengren@geostar.com.cn

# war/jar 包拷贝到镜像
ADD ./jars /georobox/jars
# 默认的配置文件拷贝到镜像
ADD ./conf /georobox/conf
# 声明配置挂载卷，方便在容器外修改配置
VOLUME /georobox/conf

# 启动后立刻启动服务
ENTRYPOINT ["java","-jar","/georobox/jars/georobox.war","--spring.config.location=/georobox/conf/application.properties"]
```



