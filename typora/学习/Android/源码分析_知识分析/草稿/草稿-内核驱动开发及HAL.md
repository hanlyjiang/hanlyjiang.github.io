

# 安卓驱动开发及HAL

## 路径规划

一个驱动Demo

* 内核编译
* 编写一个虚拟驱动
* 编写驱动对应的HAL层
* 编写对应的service
* 梳理整体架构

## 内核源码下载

```shell
git clone https://aosp.tuna.tsinghua.edu.cn/kernel/goldfish.git

mkdir android-kernel && cd android-kernel
repo init -u https://android.googlesource.com/kernel/manifest -b common-android11-5.4
# https://source.android.google.cn/setup/build/building-kernels?hl=zh-cn#building
# https://stackoverflow.com/questions/68708758/building-custom-kernel-for-android-emulator
# https://forum.xda-developers.com/t/guide-build-mod-update-kernel-ranchu-goldfish-5-4-5-10-gki-ramdisk-img-modules-rootavd-android-11-r-12-s-avd-google-play-store-api.4220697/
```

### 版本选择：

根据我们编译的模拟器，查看其内核版本：

```shell
generic_x86_64:/ # uname -a
Linux localhost 5.4.50-01145-g056684c0d252-ab6656030 #1 SMP PREEMPT Mon Jul 6 18:09:10 UTC 2020 x86_64
generic_x86_64:/ # cat /proc/version
Linux version 5.4.50-01145-g056684c0d252-ab6656030 (android-build@abfarm-01106) (Android (6443078 based on r383902) clang version 11.0.1 (https://android.googlesource.com/toolchain/llvm-project b397f81060ce6d701042b782172ed13bee898b79), LLD 11.0.1 (/buildbot/tmp/tmp6_m7QH b397f81060ce6d701042b782172ed13bee898b79)) #1 SMP PREEMPT Mon Jul 6 18:09:10 UTC 2020
```

可以看到版本号为：`5.4.50-01145-g056684c0d252-ab6656030`,对应于源码目录中的：`prebuilts/qemu-kernel/x86_64/5.4/kernel-qemu2`

> ```shell
> $ file kernel-qemu2
> kernel-qemu2: Linux kernel x86 boot executable bzImage, version 5.4.50-01145-g056684c0d252-ab6656030 (android-build@abfarm-01106) #1 SMP PREEMPT Mon Jul 6 18:09:10 UTC 2020, RO-rootFS, swap_dev 0xF, Normal VGA
> ```
>
> 

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20211108231142.png" alt="image-20211108231140288" style="zoom: 50%;" />

### 签出对应分支代码

通过 `git branch -a` 查看所有分支

```shell
 master
  remotes/origin/HEAD -> origin/master
  remotes/origin/android-3.10
  remotes/origin/android-3.18
  remotes/origin/android-3.4
  remotes/origin/android-4.14
  remotes/origin/android-4.14-q
  remotes/origin/android-4.4
  remotes/origin/android-5.4
  remotes/origin/android-goldfish-2.6.29
  remotes/origin/android-goldfish-3.10
  remotes/origin/android-goldfish-3.10-k-dev
  remotes/origin/android-goldfish-3.10-l-mr1-dev
  remotes/origin/android-goldfish-3.10-m-dev
  remotes/origin/android-goldfish-3.10-n-dev
  remotes/origin/android-goldfish-3.18
  remotes/origin/android-goldfish-3.18-dev
  remotes/origin/android-goldfish-3.4
  remotes/origin/android-goldfish-3.4-l-mr1-dev
  remotes/origin/android-goldfish-4.14-dev
  remotes/origin/android-goldfish-4.14-dev.120914098
  remotes/origin/android-goldfish-4.14-dev.143174688
  remotes/origin/android-goldfish-4.14-dev.150
  remotes/origin/android-goldfish-4.14-dev.20190417
  remotes/origin/android-goldfish-4.14-dev.backup
  remotes/origin/android-goldfish-4.14-gchips
  remotes/origin/android-goldfish-4.4-dev
  remotes/origin/android-goldfish-4.9-dev
  remotes/origin/android-goldfish-5.4-dev
  remotes/origin/b12
  remotes/origin/b120914098
  remotes/origin/heads/for/android-goldfish-3.18-dev
```

我们看到对应的有一个`android-goldfish-5.4-dev`的分支，我们使用此分支的代码

```shell
git checkout -b android-goldfish-5.4-dev origin/android-goldfish-5.4-dev
```

## 编译内核源码

全局环境变量配置：(两种方式都需要配置，指向对应的源码目录)

```shell
# 设置路径
export KERNEL_HOME=/mnt/aosp/kernel/goldfish
export AOSP_HOME=/mnt/aosp/aosp-11

export KERNEL_HOME=/Volumes/HIKVISION/kernel/goldfish
export AOSP_HOME=/Volumes/HIKVISION/android11
```

### 配置

x86_64-linux-android-4.9 仓库的master分支中没有gcc，我们切换到正确的分支：

```shell
cd $AOSP_HOME/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9
git fetch aosp android10-release
git checkout -b android10-release remotes/aosp/android10-release

cd $AOSP_HOME/prebuilts/gcc/darwin-x86/x86/x86_64-linux-android-4.9
git fetch aosp android10-release
git checkout -b android10-release remotes/aosp/android10-release

cd $AOSP_HOME/prebuilts/qemu-kernel
git fetch aosp android11-release
git checkout -b android11-release 
```

### 编译方式1

```shell
export PATH=$PATH:$AOSP_HOME/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin
export ARCH=X86_64
export CROSS_COMPILE=x86_64-linux-android-
#export REAL_CROSS_COMPILE=x86_64-linux-android-

make x86_64_emu_defconfig
make 
```

### 编译方式2

```shell
cd $KERNEL_HOME
$AOSP_HOME/prebuilts/qemu-kernel/build-kernel.sh --arch=x86_64 --out=$KERNEL_HOME/outputs
```



## 运行模拟器





```shell

```



## 虚拟驱动开发





```shell
#############################################|#############################################
#####                           Android 11 (R) Kernel 5.4                             #####
#####                        BRANCH=common-android11-5.4-lts                          #####
#############################################|#############################################

#############################################|#############################################
###             Download Sources, Toolchain, Buildtools etc. (approx. 22GB)             ###
#############################################|#############################################

BRANCH=common-android11-5.4-lts
ROOTDIR=AVD-kernel-$BRANCH
mkdir $ROOTDIR && cd $ROOTDIR
repo init --depth=1 -u https://android.googlesource.com/kernel/manifest -b $BRANCH
repo sync --force-sync --no-clone-bundle --no-tags -j$(nproc)

#############################################|#############################################
###                       Preparing and modding the build.config                        ###
###                      add these lines to the BUILD_CONFIG file                       ###
###             common-modules/virtual-device/build.config.goldfish.x86_64              ###
#############################################|#############################################

BUILD_INITRAMFS=1
LZ4_RAMDISK=1
SKIP_CP_KERNEL_HDR=1

#############################################|#############################################
###                 Make changes and enable features via the Menuconfig                 ###
###                     changes will be saved into the gki_defconfig                    ###
###                   i.e. USB 3.0 or UHCI HCD for USB-Serial Adapters                  ###
###     Device Drivers -> USB support -> <*> xHCI HCD (USB 3.0) support                 ###
###                                      -*- Generic xHCI driver for a platform device  ###
###                                      <*> UHCI HCD (most Intel and VIA) support      ###
#############################################|#############################################

BUILD_CONFIG=common-modules/virtual-device/build.config.goldfish.x86_64 \
FRAGMENT_CONFIG=common/arch/x86/configs/gki_defconfig \
build/config.sh

#############################################|#############################################
###                                       1st run                                       ###
###                          Building the Modules and Kernel                            ###
#############################################|#############################################

BUILD_CONFIG=common-modules/virtual-device/build.config.goldfish.x86_64 \
build/build.sh -j$(nproc)

Files copied to ~/workdir/AVD-kernel-common-android11-5.4-lts/out/android11-5.4/dist

#############################################|#############################################
###               Copy bzImage & initramfs.img into the rootAVD directory               ###
###                                   and run rootAVD                                   ###
#############################################|#############################################

cp out/android11-5.4/dist/initramfs.img ~/rootAVD/
cp out/android11-5.4/dist/bzImage ~/rootAVD/
./rootAVD.sh ~/path-to-avd-system-images/android-30/ramdisk.img InstallKernelModules

[!] Installing new Kernel Modules
[*] Copy initramfs.img /data/data/com.android.shell/Magisk/tmp/initramfs
[-] Extracting Modules from initramfs.img
Detected format: [lz4_legacy]
Decompressing to [initramfs.cpio]
[*] Removing Stock Modules from ramdisk.img
[!] 5.4.61-android11-2-00064-g4271ad6e8ade-ab6991359
[!] Android (6443078 based on r383902)
[-] Installing new Modules into ramdisk.img
[!] 5.4.113-android11-2-g926c4200b8fc-dirty
[!] Android (7211189, based on r416183)
[*] Adjusting modules.load and modules.dep
[*] Repacking ramdisk ..

#############################################|#############################################
###                                   (1+n)th Build run                                 ###
###                        Building only changes, not everything                        ###
#############################################|#############################################

BUILD_CONFIG=common-modules/virtual-device/build.config.goldfish.x86_64 \
SKIP_MRPROPER=1 \
build/build.sh -j$(nproc)

#############################################|#############################################
###              Copy bzImage as kernel-ranchu into the AVDs directory                  ###
###            Once the modules are installed, just the kernel is needed                ###
#############################################|#############################################

cp out/android11-5.4/dist/bzImage ~/path-to-avd-system-images/android-30/kernel-ranchu
```





```shell
find . -type f -name "Image.lz4-dtb"
./device/google/redbull-kernel/Image.lz4-dtb
./device/google/redbull-kernel/debug_api/Image.lz4-dtb
./device/google/redbull-kernel/debug_locking/Image.lz4-dtb
./device/google/redbull-kernel/debug_memory/Image.lz4-dtb
./device/google/redbull-kernel/kasan/Image.lz4-dtb
./device/google/redbull-kernel/vintf/Image.lz4-dtb
./device/google/sunfish-kernel/debug_api/Image.lz4-dtb
./device/google/sunfish-kernel/debug_hang/Image.lz4-dtb
./device/google/sunfish-kernel/debug_locking/Image.lz4-dtb
./device/google/sunfish-kernel/debug_memory/Image.lz4-dtb
./device/google/sunfish-kernel/kasan/Image.lz4-dtb
./device/google/sunfish-kernel/khwasan/Image.lz4-dtb


grep -a 'Linux version' ./device/google/redbull-kernel/Image.lz4-dtb
```

