# Gradle 常用配置整理

## 概述

开源的自动化构建工具。Gradle构建脚本使用 Groovy 或者 Kotlin DSL编写。

> Gradle 特性可以参考 [Gradle Feature](https://gradle.org/features/)

* **支持的IDE**
  * AndroidStudio
  * Eclipse
  * IntelliJ IDEA
  * Visual Studio 2019
  * XCode
* 也可以通过命令行调用



### 🧭官网资料导航

* [Training](https://gradle.com/training/?_ga=2.110207110.2063185130.1632545527-1037647491.1632545527) 
* 用户手册
* DSL 参考
* JavaDoc
* [日志](https://docs.gradle.org/current/userguide/logging.html#logging)



## 常用配置

### 通过 local.properties 或 gradle.properties 属性控制

可按照如下的代码进行配置：

```groovy
boolean getBoolProp(String name, boolean defaultValue) {
    def localProperties = loadLocalProp()
    String value
    if (localProperties != null && localProperties.containsKey(name)) {
        value = localProperties.get(name)
    } else {
        value = properties.get(name)
    }
    return value == null ? defaultValue : Boolean.parseBoolean(value)
}

Properties loadLocalProp() {
    File localProp = rootProject.file('local.properties')
    if (localProp.exists()) {
        println "local secret props file, loading props"
        Properties p = new Properties()
        p.load(new FileInputStream(localProp))
        return p
    } else {
        println "No local props file, loading"
        return null
    }
}

println("get boolean value:" + getBoolProp("test", false))
```

属性可定义在 local.properties 或者 gradle.properties  文件中，优先读取 local.properties 文件中的配置。

> **注意点：**
>
> * Properties 获取到的属性类型为 String，需要使用Boolean.parseBoolean 进行解析
> * local.properties 文件需要自行加载解析，而 gradle.properties 中的属性直接可读



### maven-publish 配置模板 - 本地AAR/jar 到本地仓库

#### 脚本定义

文件保存为 `scripts/upload-local.gradle`

```groovy
apply plugin: 'maven-publish'

publishing {
    publications {
        // 本地AAR 发布 - localAar 可以替换为更加有辨别意义的名称
        localAar(MavenPublication) {
            // 替换为对应的实际值
            groupId "com.github.hanlyjiang"
            artifactId "test-lib"
            version "1.0.0"
            artifact file("./libs/xxx.aar")
        }
    }
    repositories {
        maven {
            name = "ProjectLocal-Release"
            setUrl(new File(rootProject.rootDir, "local-maven-repo${File.separator}release").absolutePath)
        }
    }
}
```

#### 引入到模块

```kotlin
plugins {
    id("com.android.library")
}

apply(from = "${rootProject.rootDir.absolutePath}/scripts/upload-local.gradle" )
```

#### 执行

执行项目中的对应任务即可，一般名称类似于：`publishLocalAarPublicationToProjectLocal-ReleaseRepository`,可在 gradle 的 任务列表的 publishing 分组中找到。



### maven-publish 配置模板 - JAR/AAR 到在线仓库

#### 脚本定义

以下文件保存为 maven-upload.gradle 然后再引入到 build.gradle 中，注意更改其中的各项信息。

> **特别说明：**
>
> - 可以看到下面的脚本中相比于之前上传到本地文件目录中的配置多了很多，其实是maven中心仓库上传的一些要求，包括： pom 信息，签名信息，如果没有这些，则可能无法上传，如果有自建的 Nexus的maven仓库，配置上没有强制要求这些，则可以省略部分字段的配置及签名配置

```groovy
apply plugin: 'maven-publish'
apply plugin: 'signing'

// 编辑属性
def PUBLISH_GROUP_ID=""
def PUBLISH_ARTIFACT_ID=""
def PUBLISH_VERSION=""

publishing {
    publications {
      localAar(MavenPublication) {
            groupId PUBLISH_GROUP_ID
            artifactId PUBLISH_ARTIFACT_ID
            version PUBLISH_VERSION

            artifact file("./libs/xxx.aar")

            pom {
                name = PUBLISH_ARTIFACT_ID
                description = 'description'
                url = 'https://github.com/hanlyjiang/testrepo'
                licenses {
                    license {
                        name = 'The MIT License'
                        url = 'https://opensource.org/licenses/MIT'
                    }
                }
                developers {
                    developer {
                        id = 'hanlyjiang'
                        name = 'hanlyjiang'
                        email = 'hanlyjiang@gmail.com'
                    }
                }
                scm {
                    connection = 'scm:git:github.com/hanlyjiang/android-library.git'
                    developerConnection = 'scm:git:ssh://github.com/hanlyjiang/android-library.git'
                    url = 'https://github.com/github.com/hanlyjiang/android-library/tree/master'
                }
            }
        }
    }
  
    repositories {
        maven {
            name = "android-library"

            def releasesRepoUrl = "https://oss.sonatype.org/service/local/staging/deploy/maven2/"
            def snapshotsRepoUrl = "https://oss.sonatype.org/content/repositories/snapshots/"
            url = version.endsWith('SNAPSHOT') ? snapshotsRepoUrl : releasesRepoUrl

            credentials {
                username ossrhUsername
                password ossrhPassword
            }
        }
    }
}

signing {
    sign publishing.publications
}
```

#### 配置文件

部分属性需要配置到 gradle.properties 中：

```properties
# jira的用户名
ossrhUsername=hanlyjiang
 #jira的密码
ossrhPassword=jira的密码

# 公钥ID的后8位 
signing.keyId=9F612448
signing.password=XXXXXXX
signing.secretKeyRingFile=/Users/hanlyjiang/.gnupg/secring.gpg
```

#### 使用方式

上面有介绍 不重复说明
