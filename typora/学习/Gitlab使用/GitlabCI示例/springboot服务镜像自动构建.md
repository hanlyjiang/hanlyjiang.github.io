# Gitlab自动构建Springboot镜像并推送harbor

## 镜像构建CI配置

```yaml
variables:
  VERSION: $VERSION
  SERVICE_NAME: blockapi-db-integrate
  DOCKER_REGISTRY: zh-registry.geostar.com.cn
  DOCKER_NAMESPACE: geopanel

build:jar:
  # 部分模块若不使用1.8编译会报错
  image: maven:3.6.3-jdk-8
  stage: build
  script:
    - cp -f $CI_PROJECT_DIR/.settings.xml ~/.m2/settings.xml
    - mvn package
    - mkdir _archiver
    - cp target/*.jar _archiver/
  artifacts:
    name: "dist-$CI_PROJECT_NAME-$CI_COMMIT_SHORT_SHA"
    paths:
      - _archiver/*.jar
    # 生成的归档包比较大，我们只保留短时间
    expire_in: 1 hours
  tags:
    - common-build
  only:
    - branches

build:docker:
  script:
    - echo $HARBOR_PWD | docker login --username='robot$gitlab-ci' $DOCKER_REGISTRY --password-stdin
    - git rev-parse HEAD >git-rev
    - IMAGE_NAME=$SERVICE_NAME
    - echo "Docker build options $DOCKER_OPTIONS, set DOCKER_OPTIONS to --no-cache force rebuild all stage"
    - cp _archiver/*.jar docker/
    - docker build $DOCKER_OPTIONS --build-arg JAR_FILE=integrate-$VERSION.jar -t $IMAGE_NAME:$CI_COMMIT_SHORT_SHA ./docker/
    - docker tag $IMAGE_NAME:$CI_COMMIT_SHORT_SHA $DOCKER_REGISTRY/$DOCKER_NAMESPACE/$IMAGE_NAME:$CI_COMMIT_SHORT_SHA
    - docker push $DOCKER_REGISTRY/$DOCKER_NAMESPACE/$IMAGE_NAME:$CI_COMMIT_SHORT_SHA
    - echo "镜像构建完成：$DOCKER_REGISTRY/$DOCKER_NAMESPACE/$IMAGE_NAME:$CI_COMMIT_SHORT_SHA"
  tags:
    - docker
  only:
    - branches
```

## 通用`Dockerfile`：

```dockerfile
## 构建 token 管理服务
# https://hub.docker.com/_/openjdk?tab=tags&page=4&name=alpine
# docker build --no-cache -t hasura-db-integrate:20201123 .
# docker buildx build --platform=linux/arm64,linux/amd64 -t zh-registry.geostar.com.cn/geopanel/blockapi-db-integrate:v0.0.1 ./ --push
# docker buildx build --platform=linux/arm64,linux/amd64 --build-arg JAR_FILE=hasura-db-integrate-v0.0.1-SNAPSHOT.jar -t zh-registry.geostar.com.cn/geopanel/blockapi-db-integrate:v0.0.1 ./ --push
FROM openjdk:8u212-jdk-alpine3.9
LABEL maintainer="jianghanghang@geostar.com.cn"

ARG JAR_FILE=hasura-db-integrate-0.0.1-SNAPSHOT.jar
ADD $JAR_FILE /app/service.jar

WORKDIR /app

EXPOSE 8080

ENTRYPOINT [ "java" ,"-jar", "service.jar"]

```

## 项目需要配置的CI环境变量：

* `HARBOR_PWD`: harbor机器人账号的访问令牌，如：`eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MTA2MDQyMDcsImlzcyI6ImhhcmJvci10b2tlbi1kZWZhdWx0SXNzdWVyIiwiaWQiOjIsInBpZCI6MiwiYWNjZXNzIjpbeyJSZXNvdXJjZSI6Ii9wcm9qZWN0LzIvcmVwb3NpdG9yeSIsIkFjdGlvbiI6InB1c2giLCJFZmZlY3QiOiIifSx7IlJlc291cmNlIjoiL3Byb2plY3QvMi9oZWxtLWNoYXJ0IiwiQWN0aW9uIjoicmVhZCIsIkVmZmVjdCI6IiJ9LHsiUmVzb3VyY2UiOiIvcHJvamVjdC8yL2hlbG0tY2hhcnQtdmVyc2lvbiIsIkFjdGlvbiI6ImNyZWF0ZSIsIkVmZmVjdCI6IiJ9XX0.mgwTE1b5a4LV0yA15pyyi7Pk9UifMWuSVonWs_NgcHkuT1itZ31gqu37kF1frW7mr6bEghCJC86mrVMsNHuLrugkrYwPBQGsQpSIGwiltWOJKhHF-uwx7SX3_jJKQtpOpCiHfi4TDvljAoTQ3Po-n3o8YmnEP9p3m1acx9m4VlPgLXJjXm1vIc_83b_BfIzm3XTGkaog-l4454sdVsOedabcSk7EG0-cLzbtgQHRwKSI7ZhqS5V_MRfyaBwYs46BoAAXNBd6q3VpMrERE75eoKRzguxVzHVzGiVpGzU3Z43ewhzcEb3KKKYX6Xx6VeCHeHiQIBdDC1-h5AFxzpLhXwJ1dBTLci6UgBg4xKUYSkuFfJBG0kcXiU6VsYfA7WX-0idCAXqGwYLiOb8WBf6HltfacDl-LDU62PTRJWBjxWtEp3jJCA1o7XEj9_d3NX8Vg4UGQ8qQyWcPOoyUKJCCKXPbVbi0F72Xa7Q1ac2bHkvv3fhJO4SwjkjOcUT_9kcLLMpqmVgp0m3XI7zQzFQ6pn4qnbOmos-kDWb-YHZeGysHfGYjdAmBdyT1i8oBgzg_NX4QEol3D7DwCsufikN8x_exMY7SQQjtIQUBrNnpsYfLRgTgq7rCIq3NR38QXpTtXeh6xCSfyvoF715Z8OuJMrzr7Wl8CHj4rf6k58CWwjY`
* `VERSION`:  当前springboot service 的版本，如： `0.0.1-SNAPSHOT`，会被用于匹配生成的jar文件。

## harbor上机器人账号获取

1. 进入harbor项目的机器人账号tab页面

   ![image-20210304171440030](../../../../../../../Application Support/typora-user-images/image-20210304171440030.png)

2. 添加机器人账户

   <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210304171537.png" alt="image-20210304171537387" style="zoom:50%;" />

3. 获取并复制令牌

   <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210304171630.png" alt="image-20210304171630393" style="zoom:50%;" />

