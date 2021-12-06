# CLion搭建Arduino开发环境

记录下使用Clion配置Arduino开发环境的过程。

<!-- more -->



Arduino 开发的环境有下面几种：

1. Arduino IDE：目前有1.8.x 和 2.0.0 Beta版本；
2. VSCode + PlatformIO；
3. CLion + PlatformIO；

目前已经试过了前面两种，都感觉不是很满意。

* Arduino IDE对代码跳转的支持不是很好，2.0支持，1.8不支持，2.0的选择Arduino的开发板还正常，但是选择esp32的板子一直显示红色的警告，无法跳转。

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112021303012.png" alt="image-20211202130350932" style="zoom: 50%;" />

* VSCode 则是实在用不习惯。（主要是一直用AndroidStudio，操作熟络了，不愿意学😫）

所以准备尝试下CLion。测试之后，感觉到了熟悉的味道😋。



## 环境说明

* macOS 12.0.1
* CLion 2021.2.3



## 安装 PlatformIO 

### 安装CLion插件

* 安装插件，安装完成之后，重启下CLion。

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112021310220.png" alt="image-20211202131036194" style="zoom:50%;" />



重启完成之后，新建项目时选择会发现提示需要安装PlatformIO Core CLI

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112021318583.png" alt="image-20211202131833556" style="zoom:50%;" />

### 安装Platform Core CLI

macOS上直接使用 brew 安装即可

```shell
brew install platformio

# 测试一下
pio home
# 打开一个网页 http://127.0.0.1:8008
```

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112021512524.png" alt="image-20211202151220500" style="zoom:50%;" />

## 运行示例

### 新建项目

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112021404249.png" alt="image-20211202140453212" style="zoom:50%;" />

> 初次初始化的某种板子的时候需要下载一些工具链，此时可能会失败，保证网络良好的情况下多试几次-选中 `platformio.ini` 文件右键，然后选择 `PlatformIO`-`Re-Init`。
>
> <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112021408296.png" alt="image-20211202140817270" style="zoom:50%;" />

### 运行

选择PlatformIO Upload 的运行配置，点击小锤子即可编译，点击运行按钮即可上传到开发板运行（会自动选择串口）。

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112021412112.png" alt="image-20211202141206079" style="zoom:50%;" />

### 串口连接

* 找到`Serial Monitor`工具窗口
* 点击🔧进行串口配置端口及波特率，点击🔌图标进行连接。

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112021414501.png" alt="image-20211202141439470" style="zoom:50%;" />

## 三方库导入
直接在 `platformio.ini`文件中添加依赖的配置即可，如：
```ini
[env:uno]
platform = atmelavr
board = uno
framework = arduino
lib_deps =
    Wire @ ^1.0
    fmalpartida/LiquidCrystal @ ^1.5.0
```

导入了 LiquidCrystal 的库（依赖Wire），配置添加完成之后 `ReInit` 一下即可。

那么去哪里查找这些库的名称及版本信息呢？打开 `pio home` ,在网页中即可查询，然后直接复制粘贴即可。

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112021511824.png" alt="image-20211202151143802" style="zoom:50%;" />

## 体验

* 编写代码简直不要太流畅。
* 很方便的在符号之间跳转。

## 参考

* [CLion — PlatformIO latest documentation](https://docs.platformio.org/en/latest//integration/ide/clion.html#installation)
* [PlatformIO Core (CLI) — PlatformIO latest documentation](https://docs.platformio.org/en/latest/core/index.html)
* PlatformIO 依赖库查找框架：[Library Dependency Finder (LDF) — PlatformIO latest documentation](https://docs.platformio.org/en/latest/librarymanager/ldf.html)
* [ESP-Prog — PlatformIO latest documentation](https://docs.platformio.org/en/latest/plus/debug-tools/esp-prog.html#debugging-tool-esp-prog)

