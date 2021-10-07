# 虚拟机安装OpenWRT

## 前言

官方文档：

* https://openwrt.org/docs/guide-user/virtualization/vmware
* 下载地址：https://downloads.openwrt.org/snapshots/targets/x86/64/





## 镜像下载

我们下载这个： [generic-ext4-combined-efi.img.gz](https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz)

### 解压并转换成 vmdk 的格式

```shell
brew install qemu
qemu-img convert -f raw -O vmdk  openwrt-x86-64-generic-ext4-combined-efi.img openwrt-x86-64-generic-ext4-combined-efi.vmdk
```

### 创建虚拟机

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210921105745.png" alt="image-20210921105632497" style="zoom:50%;" />

![image-20210921105822138](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210921105844.png)



![image-20210921105941530](images/image-20210921105941530.png)

