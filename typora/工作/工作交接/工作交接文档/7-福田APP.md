# 福田政务通APP相关工作说明

## 简介

福田APP包括如下内容：

| 模块         | 说明                                                     | Gitlab仓库地址                                               |
| ------------ | -------------------------------------------------------- | ------------------------------------------------------------ |
| 福田业务代码 | 福田APP的主体代码                                        | [福田政务通Android端@Gitlab](http://172.17.0.205/Development/Mobile/support/futian_zwt/futian_zwt_android) |
| GIMSDK       | IM相关功能库                                             | [GIMSDK@Gitlab](http://172.17.0.205/Development/Mobile/support/futian_zwt/gimsdk) |
| Robox        | 原研发中心开发的插件框架及动态表单框架                   | [Robox@Gitlab](http://172.17.0.205/Development/Mobile/history/robox) |
| zeusBox      | 原研发中心开发的宙斯相关库（提供错误收集及统计相关功能） | [宙斯Box-AndroidSdk@Gitlab](http://172.17.0.205/Development/Mobile/history/zeusbox-android-sdk/-/tree/release/v1.0.1) |

## 代码获取与AS中打开

福田业务代码依赖于GIMSDK及Robox，其中GIMSDK以Git子模块的方式引入到代码中，而Robox则以aar依赖包的形式引入；根据这种差异，获取GIMSDK的代码只需要同福田政务通代码一起拉取即可，而如需修改Robox的代码，则需要单独拉取Robox的Gitlab仓库，下面分别进行说明：

### 获取福田政务通代码并进行开发调试

#### 获取代码

> 获取代码及切换分支的步骤可参考仓库README

* 获取代码(为了能够一起获取GIMSDK的模块代码，请务必加上`--recurse-submodule`选项)

   ```shell
  git clone --recurse-submodule git@172.17.0.205:Development/Mobile/support/futian_zwt/futian_zwt_android.git 
  ```

  正常输出如下：

  ```shell
  Cloning into 'futian_zwt_android'...
  remote: Enumerating objects: 92, done.
  remote: Counting objects: 100% (92/92), done.
  remote: Compressing objects: 100% (73/73), done.
  remote: Total 21572 (delta 28), reused 0 (delta 0), pack-reused 21480
  Receiving objects: 100% (21572/21572), 148.21 MiB | 6.21 MiB/s, done.
  Resolving deltas: 100% (12168/12168), done.
  Submodule 'module/GIMSDK' (git@172.17.0.205:Development/Mobile/support/futian_zwt/gimsdk.git) registered for path 'module/GIMSDK'
  Cloning into '/Users/hanlyjiang/Temps/work-to-others/futian_zwt_android/module/GIMSDK'...
  remote: Enumerating objects: 1843, done.
  remote: Counting objects: 100% (1843/1843), done.
  remote: Compressing objects: 100% (1001/1001), done.
  remote: Total 1843 (delta 690), reused 1769 (delta 658), pack-reused 0
  Receiving objects: 100% (1843/1843), 1.08 MiB | 2.11 MiB/s, done.
  Resolving deltas: 100% (690/690), done.
  Submodule path 'module/GIMSDK': checked out 'e6b9fedc0211fa202510d7844a3ed8ec3d355b4f'
  ```

* 切换主模块分支（福田政务通代码开发分支位于`develop`分支，而GIMSDK模块位于`master_futian_v1`分支）

  ```shell
  # 进入到项目根目录
  cd futian_zwt_android
  
  # 确认当前在develop分支
  git br | more
  # * develop
  
  # 如果不在develop分支，则需要手动切换主仓库分支到 develop 分支，可通过如下命令切换
  git checkout -b develop origin/develop 
  ```
* 切换（GIMSDK）子模块分支
  ```shell
  # 进入GIMSDK 子模块
  cd module/GIMSDK
  
  # 确认当前所在分支
  git br | more
  # 输入应该如下，说明当前不在 master_futian_v1 分支
  # * (HEAD detached at e6b9fed) 
  #   master_futian_v1
  
  # 切换GIMSDK 子仓库分支到 master_futian_v1 
  git checkout master_futian_v1
  # 如果上述命令执行失败，可以尝试下面的命令
  git checkout -b master_futian_v1 origin/master_futian_v1
  ```


> 说明：以上切换分支步骤也可以在AndroidStudio中完成。

#### 项目开发调试

获取代码后，使用AndroidStudio打开仓库的根目录即可。

### 获取Robox代码并进行开发调试

#### 获取代码


  ```shell
git clone git@172.17.0.205:Development/Mobile/history/robox.git
  ```

#### 项目开发调试

获取代码后，使用AndroidStudio打开仓库的根目录即可。



### 获取zeusBox代码并进行开发调试

#### 获取代码

福田对应的代码位于 `release/v1.0.1` 分支

```shell
git clone -b release/v1.0.1 git@172.17.0.205:Development/Mobile/history/zeusbox-android-sdk.git
```

#### 项目开发调试

获取代码后，使用AndroidStudio打开仓库的根目录即可。

## 项目结构说明

### 福田政务通项目结构说明

```shell
.
├── README.md
├── aplugin-config.gradle
├── app  - APP主模块
│   ├── build.gradle
│   ├── libs
│   ├── proguard-rules.pro
│   └── src
├── app-config.gradle
├── archivePlugin.sh
├── build-aliyun.gradle
├── build.bat
├── build.gradle
├── docs
│   └── Index.md
├── futian.jks
├── gradle
│   └── wrapper
├── gradle.properties
├── gradlew
├── gradlew.bat
├── module - APP依赖模块
│   ├── GIMSDK - IMSDK
│   ├── asmack - 废弃模块
│   ├── attendance - 插件
│   ├── circleLibrary - 朋友圈
│   ├── filter-lib - UI控件
│   ├── futianLibrary - 通用库
│   ├── guestbook - 插件
│   ├── hellocharts-library - 图表库
│   ├── lib-auth - 认证库
│   ├── lib-calendar - attendance插件依赖的日历库
│   ├── lib-utils - 工具库
│   ├── lib_supercalendar - app模块依赖的日历库
│   ├── notice - 插件
│   ├── personalInfo - 插件
│   ├── sdk_mcp - 废弃模块
│   ├── worktodo - 插件
│   └── xutils - xutils 库
├── permission_test
│   └── build.gradle
├── robox-release - Robox的aar
│   ├── build.gradle
│   ├── robox-debug-20200424_1427-bf7fa3a35d2c.aar
│   └── robox-releases.aar
├── run-worktodo.bat
├── run-worktodo.sh
├── settings.gradle 
├── sonar-project.properties
└── zeusBox-release-v1.0.2.aar - 宙斯AAR
```

### Robox项目结构说明

```shell
.
├── README.md
├── Samples - 插件示例
│   ├── plugin01 - 插件示例1
│   ├── plugin02 - 插件示例2
│   └── pluginfragment - 插件示例3
├── aars - AAR存档，目前已废弃
│   ├── robox-com.geo.futian.conferenceManager-20990909-release.aar
│   └── roboxNoTrident-com.geo.futian.conferenceManager-20990909-release.aar
├── app - 测试APP
│   ├── build
│   ├── build.gradle
│   ├── libs
│   ├── proguard-rules.pro
│   └── src
├── build
│   └── intermediates
├── build.gradle
├── copy.sh
├── doc
│   ├── changelog.md
│   └── robox-upgrade-readme.md
├── gradle
│   └── wrapper
├── gradle.properties
├── gradlew
├── gradlew.bat
├── lib-plugin-framework - 插件框架代码，来源于Android-Plugin-Framework
│   ├── build
│   ├── build.gradle
│   ├── consumer-rules.pro
│   ├── proguard-rules.pro
│   └── src
├── local.properties
├── robox - Robox相关代码
│   ├── build
│   ├── build.gradle
│   ├── host.gradle
│   ├── jcenter.gradle
│   ├── libs
│   ├── plugin.gradle
│   ├── proguard-project.txt
│   ├── proguard-rules.pro
│   ├── project.properties
│   ├── public.xml
│   └── src
├── roboxNoTrident - Robox相关代码
│   ├── build.gradle
│   ├── host.gradle
│   ├── jcenter.gradle
│   ├── libs
│   ├── plugin.gradle
│   ├── proguard-project.txt
│   ├── proguard-rules.pro
│   ├── project.properties
│   ├── public.xml
│   └── src
└── settings.gradle
```

**关于Robox和roboxNoTrident的特别说明：**

* Robox之前的模块划分是为外部提供两种类型的aar
  1. 带插件框架&动态表单框架的 - 也就是robox模块
  2. 不带插件框架的 - 也就是roboxNoTrident模块
* 不过robox模块和roboxNoTrident模块之间的动态表单相关的代码是两个模块中都有一份文件，且还有少许差异。
* 后面，由于插件框架来源于开源框架Android-Plugin-Framework，但是最初的开发是将开源代码直接拿了过来，并且将所有开源代码更改了包名及类名，不利于后期同步开源代码，修复BUG，故后面借着项目修复BUG的成本将插件框架还原成了开源版本，并从`robox`模块中剥离了出去，形成了`lib-plugin-framework`模块
* 原准备将没有了插件框架代码的`robox`和 `roboxNoTrident` 的模块整合成一个模块，以减少重复代码，不过由于没有需求及成本，所以并没有实施；
* 故：现在如需使用带插件框架的，还是使用robox模块打包aar，如不需要插件框架，还是使用roboxNoTrident模块打包aar；

**关于Robox授权的说明：**

* 早期robox作为研发中心产品提供给外部时，是需要限制项目的包名的，并在代码中固定好使用期限；
* 后面研发中心移动端团队解散后，便去除了授权的限制，可以自由使用到任意项目；



### zeusBox项目结构说明

提供的功能：

* crash异常检测与上报
* 操作日志上报收集

需要配合宙斯后台使用；

```shell
.
├── app - 测试APP代码
├── build.gradle
├── gradle
│   └── wrapper
├── gradle.properties
├── gradlew
├── gradlew.bat
├── local.properties
└── zeusBox - 宙斯sdk代码
```

## 打包成果包

### 福田政务通

对APP模块执行gradle assemble任务即可

```shell
./gradlew app:assembleRelease
```

### Robox

#### 提供Robox包

```shell
./gradlew robox:assembleRelease
```

#### 提供roboxNoTrident包

```shell
./gradlew roboxNoTrident:assembleRelease
```

### zeusBox

```shell
./gradlew zeusBox:assembleRelease
```



## 其他说明

1. robox的插件框架相关的，可以直接参考github仓库 [Android-Plugin-Framework](https://github.com/limpoxe/Android-Plugin-Framework) 

