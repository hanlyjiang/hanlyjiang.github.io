# 相机HAL学习

## 💾 参考资料收集



## HAL是什么？

### 安卓架构图中的位置

![Android 系统架构概览](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20211106110747.png)

- **系统服务**。系统服务是专注于特定功能的模块化组件，例如窗口管理器、搜索服务或通知管理器。应用框架 API 所提供的功能可与系统服务通信，以访问底层硬件。Android 包含两组服务：“系统”（诸如窗口管理器和通知管理器之类的服务）和“媒体”（涉及播放和录制媒体的服务）。
- **硬件抽象层 (HAL)**。HAL 可定义一个标准接口以供硬件供应商实现，这可让 Android 忽略较低级别的驱动程序实现。借助 HAL，您可以顺利实现相关功能，而不会影响或更改更高级别的系统。HAL 实现会被封装成模块，并会由 Android 系统适时地加载。如需了解详情，请参阅[硬件抽象层 (HAL)](https://source.android.google.cn/devices/architecture/hal)。
- **Linux 内核**。开发设备驱动程序与开发典型的 Linux 设备驱动程序类似。Android 使用的 Linux 内核版本包含一些特殊的补充功能，例如低内存终止守护进程（一个内存管理系统，可更主动地保留内存）、唤醒锁定（一种 [`PowerManager`](https://developer.android.google.cn/reference/android/os/PowerManager.html) 系统服务）、Binder IPC 驱动程序，以及对移动嵌入式平台来说非常重要的其他功能。这些补充功能主要用于增强系统功能，不会影响驱动程序开发。您可以使用任意版本的内核，只要它支持所需功能（如 Binder 驱动程序）即可。不过，我们建议您使用 Android 内核的最新版本。如需了解详情，请参阅[构建内核](https://source.android.google.cn/setup/building-kernels)一文。

可以看到，HAL是位于内核驱动层和系统服务之间的，也就是将系统服务的高层次API连接到具体的驱动及硬件，也就是抽象出硬件接口，屏蔽不同硬件及驱动的差异。

### HAL 接口定义语言 (AIDL/HIDL)

为了屏蔽不同硬件及驱动的差异，就需要使用HAL接口定义语言（***AIDL/HIDL***）

> Android 8.0 重新设计了 Android 操作系统框架（在一个名为“Treble”的项目中），以便让制造商能够以更低的成本更轻松、更快速地将设备更新到新版 Android 系统。在这种新架构中，HAL 接口定义语言（HIDL，发音为“hide-l”）指定了 HAL 和其用户之间的接口，让用户无需重新构建 HAL，就能替换 Android 框架。**在 Android 10 中，HIDL 功能已整合到 AIDL 中。此后，HIDL 就被废弃了**，并且仅供尚未转换为 AIDL 的子系统使用。

利用新的供应商接口，Treble 将供应商实现（由芯片制造商编写的设备专属底层软件）与 Android 操作系统框架分离开来。供应商或 SOC 制造商构建一次 HAL，并将其放置在设备的 `/vendor` 分区中；框架可以在自己的分区中通过[无线下载 (OTA) 更新](https://source.android.google.cn/devices/tech/ota)进行替换，而无需重新编译 HAL。

旧版 Android 架构与当前基于 HIDL 的架构之间的区别在于对供应商接口的使用：

- Android 7.x 及更低版本中没有正式的供应商接口，因此设备制造商必须更新大量 Android 代码才能将设备更新到新版 Android 系统：

  ![img](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20211107100706.png)**图 2.** 旧版 Android 更新环境

- Android 8.0 及更高版本提供了一个稳定的新供应商接口，因此设备制造商可以访问 Android 代码中特定于硬件的部分，这样一来，设备制造商只需更新 Android 操作系统框架，即可跳过芯片制造商直接提供新的 Android 版本：

  ![img](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20211107100702.png)**图 3.** 当前 Android 更新环境

所有搭载 Android 8.0 及更高版本的新设备都可以利用这种新架构。

> 🙋供应商接口包括什么内容？

### 架构资源

要详细了解 Android 架构，请参阅以下部分：

- [HAL 类型](https://source.android.google.cn/devices/architecture/hal-types)：介绍了绑定式 HAL、直通式 HAL、Same-Process (SP) HAL 和旧版 HAL。
- [AIDL](https://source.android.google.cn/devices/architecture/aidl/overview)：有关 AIDL 的文档（不论是广泛使用还是用作 HAL 接口）。
- [HIDL（一般信息）](https://source.android.google.cn/devices/architecture/hidl)：包含与 HAL 和其用户之间的接口有关的一般信息。
- [HIDL (C++)](https://source.android.google.cn/devices/architecture/hidl-cpp)：包含关于为 HIDL 接口创建 C++ 实现的详情。
- [HIDL (Java)](https://source.android.google.cn/devices/architecture/hidl-java)：包含关于 HIDL 接口的 Java 前端的详情。
- [ConfigStore HAL](https://source.android.google.cn/devices/architecture/configstore)：介绍了可供访问 Android 框架只读配置项的 API。
- [设备树叠加层](https://source.android.google.cn/devices/architecture/dto)： 详细说明了如何在 Android 中使用设备树叠加层 (DTO)。
- [供应商原生开发套件 (VNDK)](https://source.android.google.cn/devices/architecture/vndk)：介绍了一组可供实现供应商 HAL 的供应商专用库。
- [供应商接口对象 (VINTF)](https://source.android.google.cn/devices/architecture/vintf)：介绍了可收集设备的相关信息并通过可查询 API 提供这些信息的对象。
- [SELinux for Android 8.0](https://source.android.google.cn/security/selinux/images/SELinux_Treble.pdf)：详细介绍了 SELinux 变更和自定义。





## HAL 类型

在 Android 8.0 及更高版本中，较低级别的层已重新编写以采用更加模块化的新架构。搭载 Android 8.0 或更高版本的设备必须支持使用 HIDL 语言编写的 HAL，下面列出了一些例外情况。这些 HAL 可以是绑定式 HAL 也可以是直通式 HAL。Android 11 也支持使用 AIDL 编写的 HAL。所有 AIDL HAL 均为绑定式。

- **绑定式 HAL**。以 HAL 接口定义语言 (HIDL) 或 Android 接口定义语言 (AIDL) 表示的 HAL。这些 HAL 取代了早期 Android 版本中使用的**传统 HAL 和旧版 HAL**。==在绑定式 HAL 中，Android 框架和 HAL 之间通过 Binder 进程间通信 (IPC) 调用进行通信==。所有在推出时即搭载了 Android 8.0 或后续版本的设备都必须只支持绑定式 HAL。
- **直通式 HAL**。以 HIDL 封装的传统 HAL 或[旧版 HAL](https://source.android.google.cn/devices/architecture/hal)。这些 HAL 封装了现有的 HAL，可在绑定模式和 Same-Process（直通）模式下使用。升级到 Android 8.0 的设备可以使用直通式 HAL。

| 设备                                                         | 直通式                                                       | 绑定式                                                       |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| 搭载 Android 8.0 的设备                                      | [直通式 HAL](https://source.android.google.cn/devices/architecture/hal-types#passthrough) 中列出的 HAL 必须为直通式。 | 所有其他 HAL 均为绑定式（包括作为供应商扩展程序的 HAL）。    |
| 升级到 Android 8.0 的设备                                    | [直通式 HAL](https://source.android.google.cn/devices/architecture/hal-types#passthrough) 中列出的 HAL 必须为直通式。 | [绑定式 HAL](https://source.android.google.cn/devices/architecture/hal-types#binderized) 中列出的 HAL 必须为绑定式。 |
| 供应商映像提供的所有其他 HAL 既可以在直通模式下使用，也可以在绑定模式下使用。在完全符合 Treble 标准的设备中，所有 HAL 都必须为绑定式 HAL。 |                                                              |                                                              |

### 绑定式 HAL

Android 要求所有 Android 设备（无论是搭载 Android O 的设备还是升级到 Android O 的设备）上的下列 HAL 均为绑定式：

- `android.hardware.biometrics.fingerprint@2.1`。取代 Android 8.0 中已不存在的 `fingerprintd`。
- `android.hardware.configstore@1.0`。Android 8.0 中的新 HAL。
- `android.hardware.dumpstate@1.0`。此 HAL 提供的原始接口可能无法继续使用，并且已更改。因此，`dumpstate_board` 必须在指定的设备上重新实现（这是一个可选的 HAL）。
- `android.hardware.graphics.allocator@2.0`。在 Android 8.0 中，此 HAL 必须为绑定式，因此无需在可信进程和不可信进程之间分享文件描述符。
- `android.hardware.radio@1.0`。取代由存活于自身进程中的 `rild` 提供的接口。
- `android.hardware.usb@1.0`。Android 8.0 中的新 HAL。
- `android.hardware.wifi@1.0`。Android 8.0 中的新 HAL，可取代此前加载到 `system_server` 中的旧版 WLAN HAL 库。
- `android.hardware.wifi.supplicant@1.0`。在现有 `wpa_supplicant` 进程之上的 HIDL 接口。

**注意**：Android 提供的以下 HIDL 接口将一律在绑定模式下使用：`android.frameworks.*`、`android.system.*` 和 `android.hidl.*`（不包括下文所述的 `android.hidl.memory@1.0`）。

### 直通式 HAL

Android 要求所有 Android 设备（无论是搭载 Android O 的设备还是升级到 Android O 的设备）上的下列 HAL 均在直通模式下使用：

- `android.hardware.graphics.mapper@1.0`。将内存映射到其所属的进程中。
- `android.hardware.renderscript@1.0`。在同一进程中传递项（等同于 `openGL`）。

上方未列出的所有 HAL 在搭载 Android O 的设备上都必须为绑定式。

### Same-Process HAL

Same-Process HAL (SP-HAL) 一律在使用它们的进程中打开，其中包括未以 HIDL 表示的所有 HAL，以及那些**非**绑定式的 HAL。SP-HAL 集的成员只能由 Google 控制，这一点没有例外。

SP-HAL 包括以下 HAL：

- `openGL`
- `Vulkan`
- `android.hidl.memory@1.0`（由 Android 系统提供，一律为直通式）
- `android.hardware.graphics.mapper@1.0`。
- `android.hardware.renderscript@1.0`

### 传统 HAL 和旧版 HAL

传统 HAL（在 Android 8.0 中已弃用）是指与具有特定名称及版本号的应用二进制接口 (ABI) 标准相符的接口。大部分 Android 系统接口（[相机](https://android.googlesource.com/platform/hardware/libhardware/+/master/include/hardware/camera3.h)、[音频](https://android.googlesource.com/platform/hardware/libhardware/+/master/include/hardware/audio.h)和[传感器](https://android.googlesource.com/platform/hardware/libhardware/+/master/include/hardware/sensors.h)等）都采用传统 HAL 形式（已在 [hardware/libhardware/include/hardware](https://android.googlesource.com/platform/hardware/libhardware/+/master/include/hardware) 下进行定义）。

旧版 HAL（也已在 Android 8.0 中弃用）是指早于传统 HAL 的接口。一些重要的子系统（WLAN、无线接口层和蓝牙）采用的就是旧版 HAL。虽然没有统一或标准化的方式来指明是否为旧版 HAL，但如果 HAL 早于 Android 8.0 而出现，那么这种 HAL 如果不是传统 HAL，就是旧版 HAL。有些旧版 HAL 的一部分包含在 [libhardware_legacy](https://android.googlesource.com/platform/hardware/libhardware_legacy/+/master) 中，而其他部分则分散在整个代码库中。



## [旧版HAL架构](https://source.android.google.cn/devices/architecture/hal)

为了保证 HAL 具有可预测的结构，每个硬件专用 HAL 接口都要具有在 `hardware/libhardware/include/hardware/hardware.h` 中定义的属性。这类接口可让 Android 系统以一致的方式加载 HAL 模块的正确版本。HAL 接口包含两个组件：模块和设备。

<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xl="http://www.w3.org/1999/xlink" viewBox="160 2 437 474.5" width="437" height="474.5">
  <defs>
    <font-face font-family="PingFang SC" font-size="16" panose-1="2 11 4 0 0 0 0 0 0 0" units-per-em="1000" underline-position="-150" underline-thickness="58" slope="0" x-height="600" cap-height="860" ascent="1060.0021" descent="-340.0007" font-weight="400">
      <font-face-src>
        <font-face-name name="PingFangSC-Regular"/>
      </font-face-src>
    </font-face>
    <marker orient="auto" overflow="visible" markerUnits="strokeWidth" id="StickArrow_Marker" stroke-linejoin="miter" stroke-miterlimit="10" viewBox="-1 -4 10 8" markerWidth="10" markerHeight="8" color="#666">
      <g>
        <path d="M 8 0 L 0 0 M 0 -3 L 8 0 L 0 3" fill="none" stroke="currentColor" stroke-width="1"/>
      </g>
    </marker>
  </defs>
  <metadata> Produced by OmniGraffle 7.18.5\n2021-11-07 02:53:56 +0000</metadata>
  <g id="Canvas_1" stroke-dasharray="none" fill-opacity="1" fill="none" stroke="none" stroke-opacity="1">
    <title>Canvas 1</title>
    <g id="Canvas_1_Layer_1">
      <title>Layer 1</title>
      <g id="Graphic_2">
        <path d="M 171.5 428.5 L 588.5 428.5 C 592.9183 428.5 596.5 432.0817 596.5 436.5 L 596.5 468 C 596.5 472.4183 592.9183 476 588.5 476 L 171.5 476 C 167.08172 476 163.5 472.4183 163.5 468 L 163.5 436.5 C 163.5 432.0817 167.08172 428.5 171.5 428.5 Z" fill="#dead26"/>
        <path d="M 171.5 428.5 L 588.5 428.5 C 592.9183 428.5 596.5 432.0817 596.5 436.5 L 596.5 468 C 596.5 472.4183 592.9183 476 588.5 476 L 171.5 476 C 167.08172 476 163.5 472.4183 163.5 468 L 163.5 436.5 C 163.5 432.0817 167.08172 428.5 171.5 428.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(168.5 441.25)" fill="white">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="white" x="179.5" y="17">设备驱动</tspan>
        </text>
      </g>
      <g id="Graphic_3">
        <path d="M 171.5 369.5 L 253.5 369.5 C 257.91828 369.5 261.5 373.0817 261.5 377.5 L 261.5 409 C 261.5 413.4183 257.91828 417 253.5 417 L 171.5 417 C 167.08172 417 163.5 413.4183 163.5 409 L 163.5 377.5 C 163.5 373.0817 167.08172 369.5 171.5 369.5 Z" fill="#dead26"/>
        <path d="M 171.5 369.5 L 253.5 369.5 C 257.91828 369.5 261.5 373.0817 261.5 377.5 L 261.5 409 C 261.5 413.4183 257.91828 417 253.5 417 L 171.5 417 C 167.08172 417 163.5 413.4183 163.5 409 L 163.5 377.5 C 163.5 373.0817 167.08172 369.5 171.5 369.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(168.5 371.25)" fill="white">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="white" x="12.28" y="17">HAL模块</tspan>
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="white" x="29.112" y="39">*.so</tspan>
        </text>
      </g>
      <g id="Graphic_4">
        <path d="M 282.5 369.5 L 364.5 369.5 C 368.91828 369.5 372.5 373.0817 372.5 377.5 L 372.5 409 C 372.5 413.4183 368.91828 417 364.5 417 L 282.5 417 C 278.08172 417 274.5 413.4183 274.5 409 L 274.5 377.5 C 274.5 373.0817 278.08172 369.5 282.5 369.5 Z" fill="#dead26"/>
        <path d="M 282.5 369.5 L 364.5 369.5 C 368.91828 369.5 372.5 373.0817 372.5 377.5 L 372.5 409 C 372.5 413.4183 368.91828 417 364.5 417 L 282.5 417 C 278.08172 417 274.5 413.4183 274.5 409 L 274.5 377.5 C 274.5 373.0817 278.08172 369.5 282.5 369.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(279.5 371.25)" fill="white">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="white" x="12.28" y="17">HAL模块</tspan>
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="white" x="29.112" y="39">*.so</tspan>
        </text>
      </g>
      <g id="Graphic_5">
        <path d="M 393.5 369.5 L 475.5 369.5 C 479.9183 369.5 483.5 373.0817 483.5 377.5 L 483.5 409 C 483.5 413.4183 479.9183 417 475.5 417 L 393.5 417 C 389.0817 417 385.5 413.4183 385.5 409 L 385.5 377.5 C 385.5 373.0817 389.0817 369.5 393.5 369.5 Z" fill="#dead26"/>
        <path d="M 393.5 369.5 L 475.5 369.5 C 479.9183 369.5 483.5 373.0817 483.5 377.5 L 483.5 409 C 483.5 413.4183 479.9183 417 475.5 417 L 393.5 417 C 389.0817 417 385.5 413.4183 385.5 409 L 385.5 377.5 C 385.5 373.0817 389.0817 369.5 393.5 369.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(390.5 371.25)" fill="white">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="white" x="12.28" y="17">HAL模块</tspan>
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="white" x="29.112" y="39">*.so</tspan>
        </text>
      </g>
      <g id="Graphic_6">
        <path d="M 506.5 369.5 L 588.5 369.5 C 592.9183 369.5 596.5 373.0817 596.5 377.5 L 596.5 409 C 596.5 413.4183 592.9183 417 588.5 417 L 506.5 417 C 502.0817 417 498.5 413.4183 498.5 409 L 498.5 377.5 C 498.5 373.0817 502.0817 369.5 506.5 369.5 Z" fill="#dead26"/>
        <path d="M 506.5 369.5 L 588.5 369.5 C 592.9183 369.5 596.5 373.0817 596.5 377.5 L 596.5 409 C 596.5 413.4183 592.9183 417 588.5 417 L 506.5 417 C 502.0817 417 498.5 413.4183 498.5 409 L 498.5 377.5 C 498.5 373.0817 502.0817 369.5 506.5 369.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(503.5 371.25)" fill="white">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="white" x="12.28" y="17">HAL模块</tspan>
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="white" x="29.112" y="39">*.so</tspan>
        </text>
      </g>
      <g id="Graphic_7">
        <path d="M 171.5 191.5 L 588.5 191.5 C 592.9183 191.5 596.5 195.08172 596.5 199.5 L 596.5 292.5 C 596.5 296.91828 592.9183 300.5 588.5 300.5 L 171.5 300.5 C 167.08172 300.5 163.5 296.91828 163.5 292.5 L 163.5 199.5 C 163.5 195.08172 167.08172 191.5 171.5 191.5 Z" fill="white"/>
        <path d="M 171.5 191.5 L 588.5 191.5 C 592.9183 191.5 596.5 195.08172 596.5 199.5 L 596.5 292.5 C 596.5 296.91828 592.9183 300.5 588.5 300.5 L 171.5 300.5 C 167.08172 300.5 163.5 296.91828 163.5 292.5 L 163.5 199.5 C 163.5 195.08172 167.08172 191.5 171.5 191.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="4.0,4.0" stroke-width="1"/>
        <text transform="translate(168.5 196.5)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="148.892" y="17">HAL模块（*.so）</tspan>
        </text>
      </g>
      <g id="Graphic_8">
        <path d="M 177 232.5 L 259 232.5 C 263.41828 232.5 267 236.08172 267 240.5 L 267 272 C 267 276.41828 263.41828 280 259 280 L 177 280 C 172.58172 280 169 276.41828 169 272 L 169 240.5 C 169 236.08172 172.58172 232.5 177 232.5 Z" fill="white"/>
        <path d="M 177 232.5 L 259 232.5 C 263.41828 232.5 267 236.08172 267 240.5 L 267 272 C 267 276.41828 263.41828 280 259 280 L 177 280 C 172.58172 280 169 276.41828 169 272 L 169 240.5 C 169 236.08172 172.58172 232.5 177 232.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(174 245.25)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12.28" y="17">HAL设备</tspan>
        </text>
      </g>
      <g id="Graphic_9">
        <path d="M 286 232.5 L 368 232.5 C 372.4183 232.5 376 236.08172 376 240.5 L 376 272 C 376 276.41828 372.4183 280 368 280 L 286 280 C 281.58172 280 278 276.41828 278 272 L 278 240.5 C 278 236.08172 281.58172 232.5 286 232.5 Z" fill="white"/>
        <path d="M 286 232.5 L 368 232.5 C 372.4183 232.5 376 236.08172 376 240.5 L 376 272 C 376 276.41828 372.4183 280 368 280 L 286 280 C 281.58172 280 278 276.41828 278 272 L 278 240.5 C 278 236.08172 281.58172 232.5 286 232.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(283 245.25)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12.28" y="17">HAL设备</tspan>
        </text>
      </g>
      <g id="Graphic_10">
        <path d="M 395 232.5 L 477 232.5 C 481.4183 232.5 485 236.08172 485 240.5 L 485 272 C 485 276.41828 481.4183 280 477 280 L 395 280 C 390.5817 280 387 276.41828 387 272 L 387 240.5 C 387 236.08172 390.5817 232.5 395 232.5 Z" fill="white"/>
        <path d="M 395 232.5 L 477 232.5 C 481.4183 232.5 485 236.08172 485 240.5 L 485 272 C 485 276.41828 481.4183 280 477 280 L 395 280 C 390.5817 280 387 276.41828 387 272 L 387 240.5 C 387 236.08172 390.5817 232.5 395 232.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(392 245.25)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12.28" y="17">HAL设备</tspan>
        </text>
      </g>
      <g id="Graphic_11">
        <path d="M 501 232.5 L 583 232.5 C 587.4183 232.5 591 236.08172 591 240.5 L 591 272 C 591 276.41828 587.4183 280 583 280 L 501 280 C 496.5817 280 493 276.41828 493 272 L 493 240.5 C 493 236.08172 496.5817 232.5 501 232.5 Z" fill="white"/>
        <path d="M 501 232.5 L 583 232.5 C 587.4183 232.5 591 236.08172 591 240.5 L 591 272 C 591 276.41828 587.4183 280 583 280 L 501 280 C 496.5817 280 493 276.41828 493 272 L 493 240.5 C 493 236.08172 496.5817 232.5 501 232.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(498 245.25)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12.28" y="17">HAL设备</tspan>
        </text>
      </g>
      <g id="Line_19">
        <line x1="239.51613" y1="369.5" x2="310.56973" y2="307.03646" marker-end="url(#StickArrow_Marker)" stroke="#666" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1.0,4.0" stroke-width="1"/>
      </g>
      <g id="Line_20">
        <line x1="332.6129" y1="369.5" x2="355.54175" y2="309.74295" marker-end="url(#StickArrow_Marker)" stroke="#666" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1.0,4.0" stroke-width="1"/>
      </g>
      <g id="Line_21">
        <line x1="425.7097" y1="369.5" x2="403.60784" y2="309.78447" marker-end="url(#StickArrow_Marker)" stroke="#666" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1.0,4.0" stroke-width="1"/>
      </g>
      <g id="Line_22">
        <line x1="520.4839" y1="369.5" x2="449.43027" y2="307.03646" marker-end="url(#StickArrow_Marker)" stroke="#666" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1.0,4.0" stroke-width="1"/>
      </g>
      <g id="Graphic_23">
        <path d="M 168.5 53.5 L 585.5 53.5 C 589.9183 53.5 593.5 57.08172 593.5 61.5 L 593.5 154.5 C 593.5 158.91828 589.9183 162.5 585.5 162.5 L 168.5 162.5 C 164.08172 162.5 160.5 158.91828 160.5 154.5 L 160.5 61.5 C 160.5 57.08172 164.08172 53.5 168.5 53.5 Z" fill="white"/>
        <path d="M 168.5 53.5 L 585.5 53.5 C 589.9183 53.5 593.5 57.08172 593.5 61.5 L 593.5 154.5 C 593.5 158.91828 589.9183 162.5 585.5 162.5 L 168.5 162.5 C 164.08172 162.5 160.5 158.91828 160.5 154.5 L 160.5 61.5 C 160.5 57.08172 164.08172 53.5 168.5 53.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="4.0,4.0" stroke-width="1"/>
        <text transform="translate(165.5 58.5)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="177.116" y="17">HAL 设备</tspan>
        </text>
      </g>
      <g id="Graphic_24">
        <path d="M 174 94.5 L 256 94.5 C 260.41828 94.5 264 98.08172 264 102.5 L 264 134 C 264 138.41828 260.41828 142 256 142 L 174 142 C 169.58172 142 166 138.41828 166 134 L 166 102.5 C 166 98.08172 169.58172 94.5 174 94.5 Z" fill="white"/>
        <path d="M 174 94.5 L 256 94.5 C 260.41828 94.5 264 98.08172 264 102.5 L 264 134 C 264 138.41828 260.41828 142 256 142 L 174 142 C 169.58172 142 166 138.41828 166 134 L 166 102.5 C 166 98.08172 169.58172 94.5 174 94.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(171 96.25)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12" y="17">硬件功能</tspan>
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12" y="39">函数指针</tspan>
        </text>
      </g>
      <g id="Graphic_25">
        <path d="M 283 94.5 L 365 94.5 C 369.4183 94.5 373 98.08172 373 102.5 L 373 134 C 373 138.41828 369.4183 142 365 142 L 283 142 C 278.58172 142 275 138.41828 275 134 L 275 102.5 C 275 98.08172 278.58172 94.5 283 94.5 Z" fill="white"/>
        <path d="M 283 94.5 L 365 94.5 C 369.4183 94.5 373 98.08172 373 102.5 L 373 134 C 373 138.41828 369.4183 142 365 142 L 283 142 C 278.58172 142 275 138.41828 275 134 L 275 102.5 C 275 98.08172 278.58172 94.5 283 94.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(280 96.25)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12" y="17">硬件功能</tspan>
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12" y="39">函数指针</tspan>
        </text>
      </g>
      <g id="Graphic_26">
        <path d="M 498 94.5 L 580 94.5 C 584.4183 94.5 588 98.08172 588 102.5 L 588 134 C 588 138.41828 584.4183 142 580 142 L 498 142 C 493.5817 142 490 138.41828 490 134 L 490 102.5 C 490 98.08172 493.5817 94.5 498 94.5 Z" fill="white"/>
        <path d="M 498 94.5 L 580 94.5 C 584.4183 94.5 588 98.08172 588 102.5 L 588 134 C 588 138.41828 584.4183 142 580 142 L 498 142 C 493.5817 142 490 138.41828 490 134 L 490 102.5 C 490 98.08172 493.5817 94.5 498 94.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(495 96.25)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12" y="17">硬件功能</tspan>
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12" y="39">函数指针</tspan>
        </text>
      </g>
      <g id="Graphic_27">
        <path d="M 390.5 94.5 L 472.5 94.5 C 476.9183 94.5 480.5 98.08172 480.5 102.5 L 480.5 134 C 480.5 138.41828 476.9183 142 472.5 142 L 390.5 142 C 386.0817 142 382.5 138.41828 382.5 134 L 382.5 102.5 C 382.5 98.08172 386.0817 94.5 390.5 94.5 Z" fill="white"/>
        <path d="M 390.5 94.5 L 472.5 94.5 C 476.9183 94.5 480.5 98.08172 480.5 102.5 L 480.5 134 C 480.5 138.41828 476.9183 142 472.5 142 L 390.5 142 C 386.0817 142 382.5 138.41828 382.5 134 L 382.5 102.5 C 382.5 98.08172 386.0817 94.5 390.5 94.5 Z" stroke="gray" stroke-linecap="round" stroke-linejoin="round" stroke-width="1"/>
        <text transform="translate(387.5 96.25)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12" y="17">硬件功能</tspan>
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="12" y="39">函数指针</tspan>
        </text>
      </g>
      <g id="Line_28">
        <line x1="243.47218" y1="232.5" x2="311.3072" y2="169.2513" marker-end="url(#StickArrow_Marker)" stroke="#666" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1.0,4.0" stroke-width="1"/>
      </g>
      <g id="Line_29">
        <line x1="335.0101" y1="232.5" x2="355.45503" y2="171.88083" marker-end="url(#StickArrow_Marker)" stroke="#666" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1.0,4.0" stroke-width="1"/>
      </g>
      <g id="Line_30">
        <line x1="426.54806" y1="232.5" x2="402.35043" y2="171.69832" marker-end="url(#StickArrow_Marker)" stroke="#666" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1.0,4.0" stroke-width="1"/>
      </g>
      <g id="Line_31">
        <line x1="515.5666" y1="232.5" x2="445.02183" y2="169.11658" marker-end="url(#StickArrow_Marker)" stroke="#666" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1.0,4.0" stroke-width="1"/>
      </g>
      <g id="Graphic_32">
        <text transform="translate(332.28 7)" fill="black">
          <tspan font-family="PingFang SC" font-size="16" font-weight="400" fill="black" x="0" y="17">旧版HAL结构</tspan>
        </text>
      </g>
    </g>
  </g>
</svg>

## HAL动态声明周期

Android 9 支持在不使用或不需要 Android 硬件子系统时动态关停这些子系统。例如，如果用户未使用 WLAN，WLAN 子系统就不应占用内存、耗用电量或使用其他系统资源。早期版本的 Android 中，在 Android 手机启动的整个期间，Android 设备上的 HAL/驱动程序都会保持开启状态。

Android 10 为内核和 `hwservicemanager` 添加了更多支持，可让 HAL 在没有任何客户端时自动关停。

