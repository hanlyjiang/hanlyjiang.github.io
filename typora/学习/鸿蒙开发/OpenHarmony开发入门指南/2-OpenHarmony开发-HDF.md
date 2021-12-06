#  Open Harmony 开发-HDF

本文介绍如何开发一个OpenHarmony的子系统。

参考文章：

* [驱动开发 | OpenHarmony](https://www.openharmony.cn/pages/00030001/#驱动开发步骤)
* [标准系统-平台驱动开发示例 | OpenHarmony](https://www.openharmony.cn/pages/00060101/#概述)



## HDI HDF简介

> 参考：
>
> * [OpenHarmony HDF HDI基础能力分析与使用-鸿蒙HarmonyOS技术社区-鸿蒙官方合作伙伴-51CTO.COM](https://harmonyos.51cto.com/posts/8171)

* `HDI` ： 硬件设备接口
* `HDF`： 硬件驱动框架

![image-20211115160421714](/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20211115160421714.png)

### 部署模式

![OpenHarmony HDF HDI基础能力分析与使用-鸿蒙HarmonyOS技术社区](https://harmonyos.oss-cn-beijing.aliyuncs.com/images/202109/174a1bd07ed8c91335d743bed01b01988464ff.png?x-oss-process=image/resize,w_757,h_593)

1. 直通式：HDI 实现为用户共享库，系统服务进程直接通过dlopen加载该动态库到系统服务进程，通过函数调用来实现对应硬件功能的使用；此时只需要提供HDI 函数实现即可。（HDI 实现封装具体的用户态内核态交互过程，当需要访问驱动程序时使用 IO Service 请求将消息通过 system call 方式调用到内核驱动实现。）
2. IPC模式：系统服务和HDI分为两个单独的进程，通过IPC接口进行通信，此时需要提供HDI客户端和HDI服务端实现；

> HDI 服务发布基于 UHDF（用户态 HDF 驱动框架）实现，通用的服务发布实现如下。

### IPC实现步骤

#### 实现驱动入口（`HDF_INIT(g_sampleDriverEntry)`）

```cpp
int SampleDriverBind(struct HdfDeviceObject *deviceObject)
{
    HDF_LOGE("SampleDriverBind enter!");
    static struct IDeviceIoService testService = {
        .Dispatch = SampleServiceDispatch, // 服务回调接口
    };
    deviceObject->service = &testService;
    return HDF_SUCCESS;
}
 
int SampleDriverInit(struct HdfDeviceObject *deviceObject)
{
    HDF_LOGE("SampleDriverInit enter");
 
    return HDF_SUCCESS;
}
 
void SampleDriverRelease(struct HdfDeviceObject *deviceObject)
{
    HDF_LOGE("SampleDriverRelease enter");
    return;
}
 
struct HdfDriverEntry g_sampleDriverEntry = {
    .moduleVersion = 1,
    .moduleName = "sample_driver",
    .Bind = SampleDriverBind,
    .Init = SampleDriverInit,
    .Release = SampleDriverRelease,
};

HDF_INIT(g_sampleDriverEntry);
```

* HDF_INIT 传入一个 `HdfDriverEntry`，指定绑定，初始化，释放三个函数入口，三个函数都有一个 `HdfDeviceObject` 类型的参数
* 绑定时需要将 `HdfDeviceObject->service`指向一个 `IDeviceIoService`类型的对象，`IDeviceIoService.Dispatch` 指向服务回调的接口函数。当收到HDI的调用时，改借口会被调用。

#### **实现服务响应接口**

`IDeviceIoService.Dispatch` 指向的服务响应接口函数

当收到 HDI 调用时，服务响应接口`SampleServiceDispatch`将会被调用。

- client 调用者对象，在用户态驱动中暂时未支持
- cmdId 调用命令字，用于区分调用的 API
- data 调用入参序列化对象，在 IPC 调用场景为 parcel 对象的 C 语言封装，入参需要使用序列化接口从 data 对象中获取后再使用
- reply 调用出参对象，需要返回给调用的信息写入该序列化对象



#### **UHDF 驱动配置**

> ？？ 这个驱动配置在什么地方？
>
> 参考： [驱动开发 | OpenHarmony](https://www.openharmony.cn/pages/00030001/#驱动开发步骤) 的驱动配置部分



## 问题

1. 如何调试HDI？