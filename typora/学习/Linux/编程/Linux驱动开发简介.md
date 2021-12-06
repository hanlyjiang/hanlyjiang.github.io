# Linux驱动开发

## 📚资料及书籍

* 《Linux内核设计与实现》，英文名Linux Kernel Development（所以有人叫它LKD），机械工业出版社，￥35, 美国Robert Love著，陈莉君译者。 评说：
  　　此书是当今首屈一指的入门最佳图书。作者是为2.6内核加入了抢占的人，对调度部分非常精通，而调度是整个系统的核心，因此本书是很权威的。这本书讲解浅显易懂，全书没有列举一条汇编语句，但是给出了整个Linux操作系统2.6内核的概观，使你能通过阅读迅速获得一个overview。而且对内核中较为混乱的部分（如下半部），它的讲解是最透彻的。对没怎么深入内核的人来说，这是强烈推荐的一本书。
* 《Linux设备驱动程序》、《Linux内核源代码完全注释》以及新出的《Linux内核分析及编程
* [i.MX 6系列应用处理器：多核，Arm® Cortex®-A7内核, Cortex-A9内核, Cortex-M4内核_NXP 半导体](https://www.nxp.com.cn/products/processors-and-microcontrollers/arm-processors/i-mx-applications-processors/i-mx-6-processors:IMX6X_SERIES)

## 问题

1. 驱动如何与arch架构分离而实现驱动跨平台？

## Linux内核组成

### 源码目录结构

* `arch`：硬件体系结构相关的代码，每种平台占用一个目录，存放各个平台的芯片对于Linux内核进程调度、内存管理、中断等的支持。以及每个具体的SoC和电路的板级支持的代码。
* `block`： 块设备驱动程序I/O调度
* `crypto`：常用的加密和散列算法（如AES，SHA等），还有一些压缩和CRC校验算法
* `documentation`：内核各部分的通用解释和注释
* `drivers`：设备驱动程序，每个不同的驱动占用一个子目录，如char、block、net、mtd、i2c等。
* `fs`：所支持的各种文件系统，如EXT、FAT、NTFS、JFFS2等。 
* `include`：头文件，与系统相关的头文件放置在include/linux子目录下。
* `init`：内核初始化代码。著名的`start_kernel()`就位于init/main.c文件中。 
* `ipc`：进程间通信的代码。 
* `kernel`：内核最核心的部分，包括进程调度、定时器等，而和平台相关的一部分代码放在arch/*/kernel目录下。 
* `lib`：库文件代码。 
* `mm`：内存管理代码，和平台相关的一部分代码放在arch/*/mm目录下。 
* `net`：网络相关代码，实现各种常见的网络协议
* `scripts`：用于配置内核的脚本文件。
* `security`：主要是一个SELinux的模块。 
* `sound`：ALSA、OSS音频设备的驱动核心代码和常用设备驱动。 
* `usr`：实现用于打包和压缩的cpio等。 
* `include`：内核API级别头文件。 

内核一般要做到drivers与arch的软件架构分离，驱动中不包含板级信息，让驱动跨平台。同时内核的通用部分（如kernel、fs、ipc、net等）则与具体的硬件（arch和drivers）剥离。



### Linux内核的组成部分

Linux内核主要由5个子系统组成：

* **进程调度（SCHED）**： 控制系统中多个进程对CPU的访问，使多个进程能在CPU中“微观串行，宏观并行”地执行。
* **内存管理（MM）**：控制多个进程安全的共享主内存区域。
* **虚拟文件系统（VFS）**：隐藏各种硬件的细节，为所有设备提供统一接口。
* **网络接口（NET）**: 提供对各种网络标准的存取和各种网络硬件的支持。分为网络协议和网络驱动程序，网络协议部分负责实现每一种可能的网络传输协议；网络设备驱动负责与硬件设备通信。
* **进程间通信（IPC）**：支持进程之间的通信，包括信号量，共享内存，消息队列，管道，unix域套接字等。Android内核新增了binder通信

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111191453439.png" alt="image-20211119145336380" style="zoom: 33%;" />

## 编译内核

### 编译

* 配置内核

  ```shell
  make menuconfig
  ```
  配置选项特别多

  * Makefile： 定义Linux内核的编译规则
  * Kconfig： 给用户提供配置选择功能
  * 配置工具：配置命令及配置用户界面

  执行完毕后会生成一个 .config 文件，记录哪些部分要被编译入内核之中，哪些部分被编译为内核模块。

* 编译方式：

  ```shell
  make ARCH=arm zImage
  make ARCH=arm modules
  ```

### 添加模块

在Linux内核中增加程序需要完成以下三项工作：

1. 源码复制到内核相应目录中；
2. 在目录的KConfig文件中增加关于新源代码对应项目的编译配置选项。
3. 在目录的Makefile文件中增加对新源代码的编译条目
3. 在上级模块Makefile中增加新增模块的声明（如drivers/Makefile)

一般在Makefile中 使用 KConfig中定义的配置变量来决定编译形式。如编译到内核中，或者编译成模块，或者是否参与到编译等。

### KConfig配置语法说明

组成部分：

1. 配置选项

2. 菜单结构

#### 配置选项

包括配置项名称，及配置项对应的属性：类型，数据范围，输入提示，依赖关系，选择关系及帮助信息默认值等。

一个简单的示例如下：

```kconfig
# 通过config 来新增配置项
config TTY_PRINTK_LEVEL
  # 依赖关系
	depends on TTY_PRINTK
	# 数据类型 输入提示
	int "ttyprintk log level (1-7)"
	# 范围
	range 1 7
	# 默认值
	default "6"
	# 帮助也可以用 ---help---
	help
	  Printk log level to use for ttyprintk messages.
```

* 配置项名称： 通过 `config` 定义
* 类型：bool、tristate、string、hex和int，其中tristate和string是两种基本类型，其他类型都基于这两种基本类型。类型定义后可以紧跟输入提示。
* 依赖关系：
  * `depends on <expr>`
  * `requires <expr>`
* 选择关系：（反向依赖关系）：A 如果选中了B，那么在A被选中的情况下，B自动被选中
  * `select <symbol> [if <expr>]`

* `<expr>`：

  ```shell
  <expr> ::= <symbol>              
                <symbol> '=' <symbol> 
                <symbol> '!=' <symbol> 
               '(' <expr> ')' 
               '!' <expr>  
                <expr> '&&' <expr> 
                <expr> '||' <expr>  
  ```

#### 菜单结构

**配置选项在菜单树中的位置**

```shell
menu "Character devices"

source "drivers/tty/Kconfig"

config DEVMEM
	bool "/dev/mem virtual device support"
	default y
	help
	  Say Y here if you want to support the /dev/mem device.
	  The /dev/mem device is used to access areas of physical
	  memory.
	  When in doubt, say "Y".

endmenu
```

* Menu  和 endmenu 之间的config会作为menu的子菜单
* 也可以有 choice 和 endchoice



#### 帮助

* 内核 documentation 目录中的 `kbuild/kconfig-language.rst`
* 





## Linux 内核的引导过程

ARM Linux的引导过程如下：

* soc 内嵌入了Bootrom，上电后运行bootrom
* bootrom引导bootloader，bootloader引导Linux内核
* CPU0引导bootloader，其他CPU等待
* CPU0触发中断唤醒其他CPU
* CPU0导致用户空间的init程序被调用，init再派生其他进程。

> bootrom是各个SoC厂家根据自身情况编写的，目前的SoC一般都具有从SD、eMMC、NAND、USB等介质启动的能力，这证明这些bootrom内部的代码具备读SD、NAND等能力。

## Qemu 运行

### 安装

#### macOS安装

```shell
# See: https://www.qemu.org/download/#macos
brew install qemu
```

### 使用

> * [官方文档](https://www.qemu.org/documentation/)
> * [QEMU入门指南 - 掘金 (juejin.cn)](https://juejin.cn/post/6955445595448279048)

#### 查看可用命令



#### 查看支持的机器

```shell
qemu-system-arm -machine help
```

输出如下：

```shell
Supported machines are:
akita                Sharp SL-C1000 (Akita) PDA (PXA270)
ast2500-evb          Aspeed AST2500 EVB (ARM1176)
ast2600-evb          Aspeed AST2600 EVB (Cortex-A7)
borzoi               Sharp SL-C3100 (Borzoi) PDA (PXA270)
canon-a1100          Canon PowerShot A1100 IS (ARM946)
cheetah              Palm Tungsten|E aka. Cheetah PDA (OMAP310)
collie               Sharp SL-5500 (Collie) PDA (SA-1110)
connex               Gumstix Connex (PXA255)
cubieboard           cubietech cubieboard (Cortex-A8)
emcraft-sf2          SmartFusion2 SOM kit from Emcraft (M2S010)
g220a-bmc            Bytedance G220A BMC (ARM1176)
highbank             Calxeda Highbank (ECX-1000)
imx25-pdk            ARM i.MX25 PDK board (ARM926)
integratorcp         ARM Integrator/CP (ARM926EJ-S)
kzm                  ARM KZM Emulation Baseboard (ARM1136)
lm3s6965evb          Stellaris LM3S6965EVB (Cortex-M3)
lm3s811evb           Stellaris LM3S811EVB (Cortex-M3)
mainstone            Mainstone II (PXA27x)
mcimx6ul-evk         Freescale i.MX6UL Evaluation Kit (Cortex-A7)
mcimx7d-sabre        Freescale i.MX7 DUAL SABRE (Cortex-A7)
microbit             BBC micro:bit (Cortex-M0)
midway               Calxeda Midway (ECX-2000)
mps2-an385           ARM MPS2 with AN385 FPGA image for Cortex-M3
mps2-an386           ARM MPS2 with AN386 FPGA image for Cortex-M4
mps2-an500           ARM MPS2 with AN500 FPGA image for Cortex-M7
mps2-an505           ARM MPS2 with AN505 FPGA image for Cortex-M33
mps2-an511           ARM MPS2 with AN511 DesignStart FPGA image for Cortex-M3
mps2-an521           ARM MPS2 with AN521 FPGA image for dual Cortex-M33
mps3-an524           ARM MPS3 with AN524 FPGA image for dual Cortex-M33
mps3-an547           ARM MPS3 with AN547 FPGA image for Cortex-M55
musca-a              ARM Musca-A board (dual Cortex-M33)
musca-b1             ARM Musca-B1 board (dual Cortex-M33)
musicpal             Marvell 88w8618 / MusicPal (ARM926EJ-S)
n800                 Nokia N800 tablet aka. RX-34 (OMAP2420)
n810                 Nokia N810 tablet aka. RX-44 (OMAP2420)
netduino2            Netduino 2 Machine (Cortex-M3)
netduinoplus2        Netduino Plus 2 Machine (Cortex-M4)
none                 empty machine
npcm750-evb          Nuvoton NPCM750 Evaluation Board (Cortex-A9)
nuri                 Samsung NURI board (Exynos4210)
orangepi-pc          Orange Pi PC (Cortex-A7)
palmetto-bmc         OpenPOWER Palmetto BMC (ARM926EJ-S)
quanta-gbs-bmc       Quanta GBS (Cortex-A9)
quanta-gsj           Quanta GSJ (Cortex-A9)
quanta-q71l-bmc      Quanta-Q71l BMC (ARM926EJ-S)
rainier-bmc          IBM Rainier BMC (Cortex-A7)
raspi0               Raspberry Pi Zero (revision 1.2)
raspi1ap             Raspberry Pi A+ (revision 1.1)
raspi2               Raspberry Pi 2B (revision 1.1) (alias of raspi2b)
raspi2b              Raspberry Pi 2B (revision 1.1)
realview-eb          ARM RealView Emulation Baseboard (ARM926EJ-S)
realview-eb-mpcore   ARM RealView Emulation Baseboard (ARM11MPCore)
realview-pb-a8       ARM RealView Platform Baseboard for Cortex-A8
realview-pbx-a9      ARM RealView Platform Baseboard Explore for Cortex-A9
romulus-bmc          OpenPOWER Romulus BMC (ARM1176)
sabrelite            Freescale i.MX6 Quad SABRE Lite Board (Cortex-A9)
smdkc210             Samsung SMDKC210 board (Exynos4210)
sonorapass-bmc       OCP SonoraPass BMC (ARM1176)
spitz                Sharp SL-C3000 (Spitz) PDA (PXA270)
stm32vldiscovery     ST STM32VLDISCOVERY (Cortex-M3)
supermicrox11-bmc    Supermicro X11 BMC (ARM926EJ-S)
swift-bmc            OpenPOWER Swift BMC (ARM1176) (deprecated)
sx1                  Siemens SX1 (OMAP310) V2
sx1-v1               Siemens SX1 (OMAP310) V1
tacoma-bmc           OpenPOWER Tacoma BMC (Cortex-A7)
terrier              Sharp SL-C3200 (Terrier) PDA (PXA270)
tosa                 Sharp SL-6000 (Tosa) PDA (PXA255)
verdex               Gumstix Verdex (PXA270)
versatileab          ARM Versatile/AB (ARM926EJ-S)
versatilepb          ARM Versatile/PB (ARM926EJ-S)
vexpress-a15         ARM Versatile Express for Cortex-A15
vexpress-a9          ARM Versatile Express for Cortex-A9
virt-2.10            QEMU 2.10 ARM Virtual Machine
virt-2.11            QEMU 2.11 ARM Virtual Machine
virt-2.12            QEMU 2.12 ARM Virtual Machine
virt-2.6             QEMU 2.6 ARM Virtual Machine
virt-2.7             QEMU 2.7 ARM Virtual Machine
virt-2.8             QEMU 2.8 ARM Virtual Machine
virt-2.9             QEMU 2.9 ARM Virtual Machine
virt-3.0             QEMU 3.0 ARM Virtual Machine
virt-3.1             QEMU 3.1 ARM Virtual Machine
virt-4.0             QEMU 4.0 ARM Virtual Machine
virt-4.1             QEMU 4.1 ARM Virtual Machine
virt-4.2             QEMU 4.2 ARM Virtual Machine
virt-5.0             QEMU 5.0 ARM Virtual Machine
virt-5.1             QEMU 5.1 ARM Virtual Machine
virt-5.2             QEMU 5.2 ARM Virtual Machine
virt-6.0             QEMU 6.0 ARM Virtual Machine
virt                 QEMU 6.1 ARM Virtual Machine (alias of virt-6.1)
virt-6.1             QEMU 6.1 ARM Virtual Machine
witherspoon-bmc      OpenPOWER Witherspoon BMC (ARM1176)
xilinx-zynq-a9       Xilinx Zynq Platform Baseboard for Cortex-A9
z2                   Zipit Z2 (PXA27x)
```

常见：

* vexpress-a9
* sabrelite

