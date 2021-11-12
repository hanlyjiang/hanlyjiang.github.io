# OpenHarmony源码编译与烧录

参考文章： [搭建Ubuntu环境-安装包方式 | OpenHarmony](https://www.openharmony.cn/pages/00010103/#安装依赖工具)

git仓库： [OpenHarmony-v3.0-LTS](https://gitee.com/openharmony/manifest/commit/b9c7954aad468386bcce3b56c58f304f1261a7c9) 

硬件设备：[Hi3516开发板介绍 | OpenHarmony](https://www.openharmony.cn/pages/0001000101/)



## 环境准备

* 系统：`Ubuntu20.04 LTS`



安装依赖工具

```shell
sudo apt-get update && sudo apt-get install binutils git git-lfs gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip m4 bc gnutls-bin python3.8 python3-pip ruby
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
    
    # 这里需要安装 git-lfs
    sudo apt-get install git-lfs 
    git lfs install 
    sudo git lfs install --system
    
    $REPO forall -c 'git lfs pull'
    ```

* 获取prebuilts

  ```shell
  bash build/prebuilts_download.sh
  ```

## 编译及烧写

### 编译

执行如下命令编译

```shell
./build.sh --product-name Hi3516DV300
# Hi3516DV300 用于指定设备
```

编译完成之后镜像文件路径：`out\ohos-arm-release\packages\phone\images `

### 烧写（HiTool）

#### 设备连接

1. 网线连接开发板与主机
2. USB-串口连接主机与开发板

#### HITool烧写

1. 打开HITools，进行如下设置

![image-20211111162655715](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20211111162657.png)

2. 点击“烧写”
3. 对开发板断电，然后上电即开始烧写，等待烧写完成，所有分区都烧写大概需要20分钟。

