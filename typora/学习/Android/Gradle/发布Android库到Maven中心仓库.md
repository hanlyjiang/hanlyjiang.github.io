# 发布Android库到Maven中心仓库

## 前言

本文用于记录如何将自己的库上传到maven中心仓库，

* 首先我们需要注册sonatype的jira账号，然后申请创建自己的repo，等待官方审核通过之后即可拥有自己的空间；
* 我们使用gradle的maven-publish和signing插件来简化打包上传的操作，通过配置之后，即可通过gradle任务来上传到maven仓库；
* 上传时可以选择上传到snapshot存储区或者staging存储区，这两个存储去上传之后即可立刻访问，snapshot区可公开访问，而staging只能供自己或有权限的人使用，需要验证用户名密码；
* 如需要将staging区的版本公开给所有人使用，可通过sonatype网站上的release操作来公开；

## 创建sonatype账号及group

> 参考： [OSSRH Guide - The Central Repository Documentation (sonatype.org)](https://central.sonatype.org/publish/publish-guide/)

1. [创建Jira账号](https://issues.sonatype.org/secure/Signup!default.jspa)

2. 创建issues： [创建问题 - Sonatype JIRA](https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134) 

创建issues并且经管理员同意后，才可以上传仓库，创建之后相当于拥有了一个group，之后可以往这个group上传其他的项目而无需再次建立issues；

![image-20210525091621597](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210525091623.png)

新建issues之后，系统会回复，根据回复的要求进行处理即可，通过后会有类似的回复：

```shell
com.github.hanlyjiang has been prepared, now user(s) hanlyjiang can:
Deploy snapshot artifacts into repository https://oss.sonatype.org/content/repositories/snapshots
Deploy release artifacts into the staging repository https://oss.sonatype.org/service/local/staging/deploy/maven2
Release staged artifacts into repository 'Releases'
please comment on this ticket when you promoted your first release, thanks
```

即表明我们拥有了自己的group；

## 生成签名key

所有上传到仓库中的文件必须进行签名，否则会无法发布，所以我们需要生成签名用的key，同时还需要将key推送到公共的key服务器，然sonatype服务器可以访问到，以进行验证；

### 生成key

过程中需要输入密码，==输入后请记住密码==

```shell
gpg --gen-key
gpg (GnuPG) 2.2.22; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

gpg: 钥匙箱‘/Users/hanlyjiang/.gnupg/pubring.kbx’已创建
注意：使用 “gpg --full-generate-key” 以获得一个功能完整的密钥产生对话框。

GnuPG 需要构建用户标识以辨认您的密钥。

真实姓名： hanlyjiang
电子邮件地址： hanlyjiang@outlook.com
您选定了此用户标识：
    “hanlyjiang <hanlyjiang@outlook.com>”

更改姓名（N）、注释（C）、电子邮件地址（E）或确定（O）/退出（Q）？ o
我们需要生成大量的随机字节。在质数生成期间做些其他操作（敲打键盘
、移动鼠标、读写硬盘之类的）将会是一个不错的主意；这会让随机数
发生器有更好的机会获得足够的熵。
我们需要生成大量的随机字节。在质数生成期间做些其他操作（敲打键盘
、移动鼠标、读写硬盘之类的）将会是一个不错的主意；这会让随机数
发生器有更好的机会获得足够的熵。
gpg: 密钥 E8A99FE282B70849 被标记为绝对信任
gpg: 吊销证书已被存储为‘/Users/hanlyjiang/.gnupg/openpgp-revocs.d/0B372361CC1A9AE2452D43FDE8A99FE282B70849.rev’
公钥和私钥已经生成并被签名。

pub   rsa3072 2021-05-24 [SC] [有效至：2023-05-24]
      0B372361CC1A9AE2452D43FDE8A99FE282B70849
uid                      hanlyjiang <hanlyjiang@outlook.com>
sub   rsa3072 2021-05-24 [E] [有效至：2023-05-24]
```

### 列出key

```shell
gpg --list-keys
gpg: 正在检查信任度数据库
gpg: 绝对信任密钥 8F5EC255E5A0D063 的公钥未找到
gpg: 绝对信任密钥 4150E419D483B9A6 的公钥未找到
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: 深度：0  有效性：  3  已签名：  0  信任度：0-，0q，0n，0m，0f，3u
gpg: 下次信任度数据库检查将于 2023-05-24 进行
/Users/hanlyjiang/.gnupg/pubring.kbx
------------------------------------
pub   rsa3072 2021-05-24 [SC] [有效至：2023-05-24]
      0B372361CC1A9AE2452D43FDE8A99FE282B70849
uid           [ 绝对 ] hanlyjiang <hanlyjiang@outlook.com>
sub   rsa3072 2021-05-24 [E] [有效至：2023-05-24]
```

### 发送key到服务器

key需要发送到服务器上，以便sonatype获取并校验签名，通过如下命令上传：

设置key的信息：

```shell
KEY_SERVER=hkp://pool.sks-keyservers.net
KEY_ID=0B372361CC1A9AE2452D43FDE8A99FE282B70849
```

上传：

```shell
$ gpg --keyserver $KEY_SERVER --send-keys $KEY_ID
gpg: 正在发送密钥 E8A99FE282B70849 到 hkp://pool.sks-keyservers.net
```

查看是否成功：

```shell
KEY_SERVER=hkp://pool.sks-keyservers.net
gpg --keyserver $KEY_SERVER --recv-keys $KEY_ID
```

可用的key-server：

```shell
hkp://keyserver.ubuntu.com
hkp://pool.sks-keyservers.net
hkp://keys.openpgp.org
hkp://keys.gnupg.net
hkp://keys.openpgp.org
```

### 导出key

导出公钥：

```shell
gpg -a -o ~/.gnupg/maven-pub.key --export 0B372361CC1A9AE2452D43FDE8A99FE282B70849
```

导出私钥：(需要输入密码)

```shell
gpg -a -o ~/.gnupg/maven-prv.key --export-secret-keys 0B372361CC1A9AE2452D43FDE8A99FE282B70849
```

导出gpgkey：

```shell
gpg --keyring secring.gpg --export-secret-keys > ~/.gnupg/secring.gpg
```

## gradle配置

官方关于Gradle下上传的说明在这里 [Gradle - The Central Repository Documentation (sonatype.org)](https://central.sonatype.org/publish/publish-gradle/)，这个文章中使用的是maven插件，另外还有一个maven-publish插件，我们使用maven-publish这个插件；

### gradle.properties

修改gradle配置：

```properties
$ cat ~/.gradle/gradle.properties

ossrhUsername=hanlyjiang # jira的用户名
ossrhPassword=#jira的密码

# 公钥ID的后8位 0B372361CC1A9AE2452D43FDE8A99FE282B70849
signing.keyId=82B70849
signing.password=生成key时的密码
signing.secretKeyRingFile=/Users/hanlyjiang/.gnupg/secring.gpg
```

> 用户名和密码可以随意命名，只要自己在build.gradle对应上就可以
>
> 而 signing 的配置则需要保持名称一致。

### build.gradle:

> 参考：
>
> * [使用 Maven Publish 插件  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/studio/build/maven-publish-plugin?hl=zh-cn#:~:text=使用 Maven Publish 插件 Android Gradle 插件 3.6.0,Gradle 插件会为应用或库模块中的每个构建变体工件创建一个 组件 ，您可以使用它来自定义要发布到 Maven 代码库的 发布内容 。)
> * [Maven Publish Plugin (gradle.org)](https://docs.gradle.org/current/userguide/publishing_maven.html)

我们在需要上传的项目中配置，注意pom中的信息也需要补全，否则上传之后无法通过sonatype的检查，无法发布；

```groovy
plugins {
    id 'com.android.library'
//    id 'maven'
    id 'signing'
    id 'maven-publish'
}

def VERSION="1.0.1"
android {
    defaultConfig {
        minSdkVersion 22
        targetSdkVersion 30
        versionCode 1
        versionName VERSION
    }
}


// Because the components are created only during the afterEvaluate phase, you must
// configure your publications using the afterEvaluate() lifecycle method.
afterEvaluate {
    publishing {
        repositories {
            maven {
                name "local"
                // change to point to your repo, e.g. http://my.org/repo
                url = "$buildDir/repo"
            }
            maven {
                name "sonartype-Staging"
                // change to point to your repo, e.g. http://my.org/repo
                url = "https://oss.sonatype.org/service/local/staging/deploy/maven2"
              //  https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/
                credentials {
                    username = ossrhUsername
                    password = ossrhPassword
                }
            }
			// 定义snapshot仓库
            maven {
                name "sonatype-Snapshots"
                // change to point to your repo, e.g. http://my.org/repo
                url = "https://oss.sonatype.org/content/repositories/snapshots/"
                credentials {
                    username = ossrhUsername
                    password = ossrhPassword
                }
            }
        }
        publications {
            // Creates a Maven publication called "release".
            release(MavenPublication) {
                // Applies the component for the release build variant.
                from components.release

                // You can then customize attributes of the publication as shown below.
                groupId = 'com.github.hanlyjiang'
                artifactId = 'apf_library'
                version = VERSION
                pom {
                    name = 'HJ Android Plugin Framework'
                    description = 'A Android Plugin Framework'
                    url = 'https://github.com/hanlyjiang/apf-library'
                    licenses {
                        license {
                            name='The Apache Software License, Version 2.0'
                            url='http://www.apache.org/licenses/LICENSE-2.0.txt'
                        }
                    }
                    developers {
                        developer {
                            id = 'hanlyjiang'
                            name = 'hanly jiang'
                            email = 'hanlyjiang@outlook.com'
                        }
                    }
                    scm {
                        connection = 'https://github.com/hanlyjiang/apf-library'
                        developerConnection = 'https://github.com/hanlyjiang/apf-library.git'
                        url = 'https://github.com/hanlyjiang/apf-library'
                    }
                }
            }
            // Creates a Maven publication called “debug”.
            debug(MavenPublication) {
                // Applies the component for the debug build variant.
                from components.debug

                groupId = 'com.github.hanlyjiang'
                artifactId = 'apf_library-debug'
                version = String.format("%s-SNAPSHOT",VERSION)

                pom {
                    name = 'HJ Android Plugin Framework'
                    description = 'A Android Plugin Framework'
                    url = 'https://github.com/hanlyjiang/apf-library'
                    licenses {
                        license {
                            name='The Apache Software License, Version 2.0'
                            url='http://www.apache.org/licenses/LICENSE-2.0.txt'
                        }
                    }
                    developers {
                        developer {
                            id = 'hanlyjiang'
                            name = 'hanly jiang'
                            email = 'hanlyjiang@outlook.com'
                        }
                    }
                    scm {
                        connection = 'https://github.com/hanlyjiang/apf-library'
                        developerConnection = 'https://github.com/hanlyjiang/apf-library.git'
                        url = 'https://github.com/hanlyjiang/apf-library'
                    }
                }
            }
        }

        signing {
            sign publishing.publications.release , publishing.publications.debug
        }
    }
}
```

发布脚本配置中有以下需要注意：

- groupId：需要配置自己申请的 groupId；
- artifactId：需要修改为自己项目的 artifactId；
- pom 中的文件描述需要修改为自己项目的描述；
- repositories 部分配置了远程仓库对应的用户名和密码，发布地址需要根据是否是新项目进行修改，旧项目域名是 [oss.sonatype.org](http://oss.sonatype.org/)，新项目域名是：[s01.oss.sonatype.org](http://s01.oss.sonatype.org/)
- signing 签名部分需要配置对应的 gpg 密钥和账户信息

> 关于maven 仓库的注意点：
>
> 1. snapshots仓库上传的库其版本号需要以 `-SNAPSHOT` 结尾，否则可能出现400错误；

### 执行上传任务

执行gradle 对应的任务即可上传

```shell
$ module=apf-library; ./gradlew "$module":publishReleasePublicationToCenterRepository
```

> 具体生成的任务可以在AndroidStudio 的Gradle工具窗口中查看publishing分组的任务；或者通过如下命令查看
>
> ```shell
> $ module=apf-library; ./gradlew "$module":tasks| grep -E "publish|generate"
> 
> generateMetadataFileForDebugPublication - Generates the Gradle metadata file for publication 'debug'.
> generateMetadataFileForReleasePublication - Generates the Gradle metadata file for publication 'release'.
> generatePomFileForDebugPublication - Generates the Maven POM file for publication 'debug'.
> generatePomFileForReleasePublication - Generates the Maven POM file for publication 'release'.
> publish - Publishes all publications produced by this project.
> publishAllPublicationsToCenterRepository - Publishes all Maven publications produced by this project to the center repository.
> publishAllPublicationsToLocalRepository - Publishes all Maven publications produced by this project to the local repository.
> publishDebugPublicationToCenterRepository - Publishes Maven publication 'debug' to Maven repository 'center'.
> publishDebugPublicationToLocalRepository - Publishes Maven publication 'debug' to Maven repository 'local'.
> publishDebugPublicationToMavenLocal - Publishes Maven publication 'debug' to the local Maven repository.
> publishReleasePublicationToCenterRepository - Publishes Maven publication 'release' to Maven repository 'center'.
> publishReleasePublicationToLocalRepository - Publishes Maven publication 'release' to Maven repository 'local'.
> publishReleasePublicationToMavenLocal - Publishes Maven publication 'release' to the local Maven repository.
> publishToMavenLocal - Publishes all Maven publications produced by this project to the local Maven cache.
> ```

## 发布

* close
* release

> 参考：
>
> * [Releasing the Deployment - The Central Repository Documentation (sonatype.org)](https://central.sonatype.org/publish/release/)

首先需要解释下这里的发布指的什么意思：我们的仓库上传之后，实际上是存储与一个临时的独立与公有仓库的地方，这个只能我们自己访问，如果需要将仓库提供给其他人访问，就需要发布；发布的过程可以手动在web页面上操作，也可以通过命令行来进行；

发布需要取sonatype的网站上操作，以下为操作步骤：

* 打开 [Nexus Repository Manager (sonatype.org)](https://oss.sonatype.org/#stagingRepositories) 

* 然后登录，登录之后可以看到 `Build Promotion` 的菜单，然后打开`Staging Repository`，其中会显示已经上传的仓库：

  ![image-20210524172822831](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524172824.png)

* 选中一个staging repo，然后点击 `Close`，并进行确认

  ![image-20210524172941960](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524172943.png)

* 结果可以在Activity中查看

  ![image-20210524173140850](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524173141.png)

​    上面的错误是找不到key，我们重新将key上传到ubuntu：

```shell
gpg --keyserver $KEY_SERVER --send-keys 0B372361CC1A9AE2452D43FDE8A99FE282B70849
gpg --keyserver $KEY_SERVER --recv-keys 0B372361CC1A9AE2452D43FDE8A99FE282B70849
```

​	然后再次close

![image-20210524173522647](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524173524.png)

* 然后再进行release

  ![image-20210524173756512](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524173757.png)

* 完成后，会发一个邮件通知，然后会更新jira上创建项目的issues：

  ![image-20210524181450169](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524181452.png)

## 引入并使用

### 引入snapshot或staging版本

snapshot和staging的仓库中的版本可在推送后立即访问，不过只能自己访问，需要验证用户名和密码。

添加以下repo配置: 

```kotlin
allprojects {
    repositories {
        maven {
            name = "Sonatype-Snapshots"
            setUrl("https://oss.sonatype.org/content/repositories/snapshots")
//            setUrl("https://s01.oss.sonatype.org/content/repositories/snapshots")
            credentials(PasswordCredentials::class.java) {
                username = property("ossrhUsername").toString()
                password = property("ossrhPassword").toString()
            }
        }
        maven {
            name = "Sonatype-Staging"
            setUrl("https://oss.sonatype.org/service/local/staging/deploy/maven2/")
//            setUrl("https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/")
            credentials(PasswordCredentials::class.java) {
                username = property("ossrhUsername").toString()
                password = property("ossrhPassword").toString()
            }
        }
        google()
        jcenter()
        mavenCentral()
    }
}
```

### 引入release版本

如果需要公开发布给自己或其他人使用，则需要release，release操作之后距离可以访问到有一定的时间周期，下面是一次release后收到的官方的邮件：

> Central sync is activated for com.github.hanlyjiang. After you successfully release, your component will be published to Central https://repo1.maven.org/maven2/, typically within 10 minutes, though updates to [https://search.maven.org](https://search.maven.org/) can take up to two hours.

也就是说从maven中心仓库中查询需要10分钟左右，从网页搜索则需要2个小时，可以访问：https://search.maven.org 来搜索，可以通过访问 https://repo1.maven.org/maven2/ 来确认是否被索引了，如果被索引，则可以引入到项目之中；

在gradle中使用则只需要导入mavenCenter() 即可；

**rootProject build.gradle:**

```groovy
allprojects {
    repositories {
        google()
        jcenter()
        mavenCentral()
    }
}
```

**app build.gradle:**

```groovy
implementation("com.github.hanlyjiang:apf_library:1.0")
```



## kotlin中使用

### 配置

```kotlin
import org.gradle.api.publish.maven.MavenPom

plugins {
    id("com.android.library")
    id("signing")
    `maven-publish`
//    kotlin("android")
//    kotlin("android.extensions")
}

android {
    // 省略android配置
}

fun getMyPom(): Action<in MavenPom> {
    return Action<MavenPom> {
        name.set("Android Common Utils Lib")
        description.set("Android Common Utils Library For HJ")
        url.set("https://github.com/hanlyjiang/lib_common_utils")
        properties.set(mapOf(
                "myProp" to "value",
                "prop.with.dots" to "anotherValue"
        ))
        licenses {
            license {
                name.set("The Apache License, Version 2.0")
                url.set("http://www.apache.org/licenses/LICENSE-2.0.txt")
            }
        }
        developers {
            developer {
                id.set("hanlyjiang")
                name.set("Hanly Jiang")
                email.set("hanlyjiang@outlook.com")
            }
        }
        scm {
            connection.set("scm:git:git://github.com/hanlyjiang/lib_common_utils.git")
            developerConnection.set("scm:git:ssh://github.com/hanlyjiang/lib_common_utils.git")
            url.set("https://github.com/hanlyjiang/lib_common_utils")
        }
    }
}

afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                from(components.getByName("release"))
                groupId = "com.github.hanlyjiang"
                artifactId = "android_common_utils"
                version = android.defaultConfig.versionName
                pom(getMyPom())
            }
        }

        repositories {
            val ossrhCredentials = Action<PasswordCredentials> {
                username = properties["ossrhUsername"].toString()
                password = properties["ossrhPassword"].toString()
            }
            // sonar的仓库，地址根据项目的版本号来确定是snapshot还是正式仓库
            maven {
                name = "Sonartype"

                val releasesRepoUrl = uri("https://oss.sonatype.org/service/local/staging/deploy/maven2")
                val snapshotsRepoUrl = uri("https://oss.sonatype.org/content/repositories/snapshots/")
                url = if (android.defaultConfig.versionName.toString().endsWith("SNAPSHOT")) snapshotsRepoUrl else releasesRepoUrl
                credentials(ossrhCredentials)
                // snapshot的地址：
                // https://oss.sonatype.org/content/repositories/snapshots/com/github/hanlyjiang/android_common_utils/
            }
            // 项目本地的仓库
            maven {
                name = "ProjectLocal"

                val releasesRepoUrl = uri(layout.buildDirectory.dir("repos/releases"))
                val snapshotsRepoUrl = uri(layout.buildDirectory.dir("repos/snapshots"))
                url = if (android.defaultConfig.versionName.toString().endsWith("SNAPSHOT")) snapshotsRepoUrl else releasesRepoUrl
            }
        }
    }
    // https://stackoverflow.com/questions/54654376/why-is-publishing-function-not-being-found-in-my-custom-gradle-kts-file-within

    signing {
        sign(publishing.publications.getByName("release"))
    }

}
```



### 问题：

```shell
A problem occurred configuring project ':lib_common_utils'.
> SoftwareComponentInternal with name 'java' not found.
```

[maven plugin - Why is 'publishing' function not being found in my custom gradle.kts file within buildSrc directory? - Stack Overflow](https://stackoverflow.com/questions/54654376/why-is-publishing-function-not-being-found-in-my-custom-gradle-kts-file-within)

[Maven Publish Plugin (gradle.org)](https://docs.gradle.org/current/userguide/publishing_maven.html)





## 上传javadoc和source

### 添加javadoc和jarsource的任务

```kotlin
tasks.register("javadoc", Javadoc::class.java) {
    group = "publishing"
    dependsOn("assemble")
    source = android.sourceSets["main"].java.getSourceFiles()
    classpath += project.files(android.bootClasspath + File.pathSeparator)
    if (JavaVersion.current().isJava9Compatible) {
        (options as StandardJavadocDocletOptions).addBooleanOption("html5", true)
    }
    android.libraryVariants.forEach { libraryVariant ->
        classpath += libraryVariant.javaCompileProvider.get().classpath
    }
    options.apply {
        encoding("UTF-8")
        charset("UTF-8")
        isFailOnError = false

        (this as StandardJavadocDocletOptions).apply {
//            addStringOption("Xdoclint:none")
            links?.add("https://developer.android.google.cn/reference/")
            links?.add("http://docs.oracle.com/javase/8/docs/api/")
        }
    }
}

tasks.register("jarSource", Jar::class.java) {
    group = "publishing"
    from(android.sourceSets["main"].java.srcDirs)
    archiveClassifier.set("sources")
}

tasks.register("jarJavadoc", Jar::class.java) {
    group = "publishing"
    dependsOn("javadoc")
    val javadoc: Javadoc = tasks.getByName("javadoc") as Javadoc
    from(javadoc.destinationDir)
    archiveClassifier.set("javadoc")
}
```

### publish中使用

```kotlin
afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                from(components.getByName("release"))
                groupId = "com.github.hanlyjiang"
                artifactId = "android_common_utils"
                version = android.defaultConfig.versionName
                pom(getMyPom())
                // 添加javadoc
                artifact(tasks.getByName("jarJavadoc") as Jar)
                // 添加source
                 artifact(tasks.getByName("jarSource") as Jar)
            }
        }

        repositories {
            val ossrhCredentials = Action<PasswordCredentials> {
                username = properties["ossrhUsername"].toString()
                password = properties["ossrhPassword"].toString()
            }
            // sonar的仓库，地址根据项目的版本号来确定是snapshot还是正式仓库
            maven {
                name = "Sonartype"

                val releasesRepoUrl = uri("https://oss.sonatype.org/service/local/staging/deploy/maven2")
                val snapshotsRepoUrl = uri("https://oss.sonatype.org/content/repositories/snapshots/")
                url = if (android.defaultConfig.versionName.toString().endsWith("SNAPSHOT")) snapshotsRepoUrl else releasesRepoUrl
                credentials(ossrhCredentials)
                // snapshot的地址：
                // https://oss.sonatype.org/content/repositories/snapshots/com/github/hanlyjiang/android_common_utils/
            }
            // 项目本地的仓库
            maven {
                name = "ProjectLocal"

                val releasesRepoUrl = uri(layout.buildDirectory.dir("repos/releases"))
                val snapshotsRepoUrl = uri(layout.buildDirectory.dir("repos/snapshots"))
                url = if (android.defaultConfig.versionName.toString().endsWith("SNAPSHOT")) snapshotsRepoUrl else releasesRepoUrl
            }
        }
    }
    // https://stackoverflow.com/questions/54654376/why-is-publishing-function-not-being-found-in-my-custom-gradle-kts-file-within


    signing {
        sign(publishing.publications.getByName("release"))
    }

}
```



## 参考文章

* [Android maven仓库和jcenter上传 (shimo.im)](https://shimo.im/docs/pqDcWPcWgVCh3qCk)
* [[OSSRH-55238\] Create a open source project for android - Sonatype JIRA](https://issues.sonatype.org/browse/OSSRH-55238?filter=-2)
* [Gradle - The Central Repository Documentation (sonatype.org)](https://central.sonatype.org/publish/publish-gradle/)
* [Jcenter 停止服务，说一说我们的迁移方案 - InfoQ 写作平台](https://xie.infoq.cn/article/e2345e367a139f37fc2fc0bbb)
* [使用 Maven Publish 插件  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/studio/build/maven-publish-plugin?hl=zh-cn#:~:text=使用 Maven Publish 插件 Android Gradle 插件 3.6.0,Gradle 插件会为应用或库模块中的每个构建变体工件创建一个 组件 ，您可以使用它来自定义要发布到 Maven 代码库的 发布内容 。)

