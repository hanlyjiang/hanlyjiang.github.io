# OpenHarmony源码编译与烧录

参考文章： [搭建Ubuntu环境-安装包方式 | OpenHarmony](https://www.openharmony.cn/pages/00010103/#安装依赖工具)

git仓库： [OpenHarmony-v3.0-LTS](https://gitee.com/openharmony/manifest/commit/b9c7954aad468386bcce3b56c58f304f1261a7c9) 

硬件设备：[Hi3516开发板介绍 | OpenHarmony](https://www.openharmony.cn/pages/0001000101/)



## 环境准备

### 硬件环境

* 开发板： `Hi3516DV300`
* 此开发板支持小型及标准版本的系统

### 软件环境

* 编译系统：`Ubuntu20.04 LTS`
* 烧写系统：`Windows`



安装依赖工具

```shell
sudo apt-get update && sudo apt-get install binutils git git-lfs gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip m4 bc gnutls-bin python3.8 python3-pip ruby libncurses5
```

## 获取源码

* 通过repo获取源码

    ```shell
    # 
    REPO=repo
    # 本机安装有repo，清楚码云的版本是否有其他修改，为了避免出错，我这里重码云版本名称使用repo3
    #REPO=repo3
    
    curl https://gitee.com/oschina/repo/raw/fork_flow/repo-py3 > ~/bin/$REPO
    chmod a+x ~/bin/$REPO
    pip install -i https://repo.huaweicloud.com/repository/pypi/simple requests
    
    # -b OpenHarmony-3.0-LTS 选择3.0分支
    $REPO init -u https://gitee.com/openharmony/manifest.git -b OpenHarmony-3.0-LTS   --no-repo-verify
    $REPO sync -c
    
    $REPO forall -c 'git lfs pull'
    ```
    
* 获取prebuilts

  ```shell
  bash build/prebuilts_download.sh
  ```

## 标准系统-编译及烧写

### 编译

执行如下命令编译

```shell
./build.sh --product-name Hi3516DV300 --ccache
# Hi3516DV300 用于指定设备
```

编译完成之后镜像文件路径：`out\ohos-arm-release\packages\phone\images `

### 烧写（HiTool）

#### 设备连接

1. 网线连接开发板与主机
2. USB-串口连接主机与开发板

#### HITool烧写

考虑到网口的文件传输速度可能会更好，所以这里我们使用网口进行烧录。

1. 打开HITools，进行如下设置

![image-20211111162655715](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20211111162657.png)

2. 点击“烧写”
3. 对开发板断电，然后上电即开始烧写，等待烧写完成，所有分区都烧写大概需要20分钟。



## 小型系统-编译及烧写

### 环境准备

小型系统编译所需的工具链和标准系统略有不同，需要进行额外的安装

```shell
ls -l /bin/sh
sudo dpkg-reconfigure dash # 选no

# Ubuntu 20+ 执行
sudo apt-get install build-essential gcc g++ make zlib* libffi-dev

# all
sudo apt-get install dosfstools mtools mtd-utils default-jre default-jdk
```

### 编译

```shell
hb set(设置编译路径)
.（选择当前路径）
选择ipcamera_hispark_taurus@hisilicon并回车
hb build -f（执行编译）
```

### 烧录(DevEco Device Tool)

> 使用 DevEco Device Tool 进行烧录参考：
> - 打开工程：[HarmonyOS设备开发-工具-HUAWEI DevEco Device Tool使用指南-工程管理-打开工程/源码](https://device.harmonyos.com/cn/docs/documentation/guide/open_project-0000001071680043)
> - 烧录：[HarmonyOS设备开发-工具-HUAWEI DevEco Device Tool使用指南-代码烧录-基于HiSilicon芯片的开发板-Hi3516DV300开发板烧录](https://device.harmonyos.com/cn/docs/documentation/guide/hi3516_upload-0000001052148681)

**Device Tool使用注意事项：**

- 需要导入harmony的源码到vscode中
- 在执行upload任务时，点击Project Task工具窗口中的upload任务无法执行（使用的3.0的beta版本），需要手动搜索并执行对应的任务；
- **烧写时最后一个分区（ userfs）烧写失败，暂时无法解决**

### 烧写（HiTool）

在HiTool中，仍然选择emmc烧录，不过需要手动添加各个分区信息，然后进行烧录，可参考：

*  [OpenHarmony源码编译-标准系统](https://dk50qlud5n.feishu.cn/wiki/wikcnFwFYEHBrs9LYFliqOAI4jh?from=from) 
*  [Hi3516DV300 AI Camera编译、HiTool烧录过程及问题解决分享-鸿蒙HarmonyOS技术社区-鸿蒙官方合作伙伴-51CTO.COM](https://harmonyos.51cto.com/posts/3073)
