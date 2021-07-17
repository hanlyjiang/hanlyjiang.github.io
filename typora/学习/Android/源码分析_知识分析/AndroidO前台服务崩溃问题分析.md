# Android O前台服务导致的崩溃问题分析

## 我们为什么需要一个前台服务？

* 从最近任务杀掉APP，前台服务仍然在运行；（android模拟器8.0级12版本）
* 为什么需要直接使用 startForegroundService 来启动前台服务？

## 前因后果

从Android O开始，引入了 [后台执行限制](https://developer.android.google.cn/about/versions/oreo/android-8.0-changes#back-all) ，其中有涉及到前台服务的：

> Android 8.0 为提高电池续航时间而引入的变更之一是，当您的应用进入[已缓存](https://developer.android.google.cn/guide/topics/processes/process-lifecycle)状态时，如果没有活动的[组件](https://developer.android.google.cn/guide/components/fundamentals#Components)，系统将解除应用具有的所有唤醒锁。
>
> 此外，为提高设备性能，系统会限制未在前台运行的应用的某些行为。具体而言：
>
> - 现在，在后台运行的应用对后台服务的访问受到限制。
> - 应用无法使用其清单注册大部分隐式广播（即，并非专门针对此应用的广播）。
>
> 默认情况下，这些限制仅适用于针对 O 的应用。不过，用户可以从 **Settings** 屏幕为任意应用启用这些限制，即使应用并不是以 O 为目标平台。
>
> Android 8.0 还对特定函数做出了以下变更：
>
> - 如果针对 Android 8.0 的应用尝试在不允许其创建后台服务的情况下使用 `startService()` 函数，则该函数将引发一个 `IllegalStateException`。
> - 新的 `Context.startForegroundService()` 函数将启动一个前台服务。现在，即使应用在后台运行，系统也允许其调用 `Context.startForegroundService()`。不过，应用必须在创建服务后的五秒内调用该服务的 `startForeground()` 函数。
>
> 如需了解详细信息，请参阅[后台执行限制](https://developer.android.google.cn/preview/features/background)。

注意其中有一条说明：启动前台服务必须调用`Context.startForegroundService()`方法，并且必须在 5s 之内调用该服务的 `startForeground()` 函数。

关于后台执行的限制： [后台执行限制  | Android 开发者  | Android Developers](https://developer.android.com/about/versions/oreo/background)

## 后台 Service 限制

> 在后台中运行的 Service 会消耗设备资源，这可能会降低用户体验。 为了缓解这一问题，系统对这些 Service 施加了一些限制。
>
> 系统可以区分*前台*和*后台*应用。 （用于 Service 限制目的的后台定义与[内存管理](https://developer.android.com/topic/performance/memory-overview)使用的定义不同；一个应用按照内存管理的定义可能处于后台，但按照能够启动 Service 的定义又处于前台。）如果满足以下任意条件，应用将被视为处于前台：
>
> - 具有可见 Activity（不管该 Activity 已启动还是已暂停）。
> - 具有前台 Service。
> - 另一个前台应用已关联到该应用（不管是通过绑定到其中一个 Service，还是通过使用其中一个内容提供程序）。 例如，如果另一个应用绑定到该应用的 Service，那么该应用处于前台：
>   - [IME](https://developer.android.com/guide/topics/text/creating-input-method)
>   - 壁纸 Service
>   - 通知侦听器
>   - 语音或文本 Service
>
> 如果以上条件均不满足，应用将被视为处于后台。
>
> **请注意：**这些应用不会对[绑定 Service](https://developer.android.com/guide/components/bound-services) 产生任何影响。 如果您的应用定义了绑定 Service，则不管应用是否处于前台，其他组件都可以绑定到该 Service。
>
> 处于前台时，应用可以自由创建和运行前台与后台 Service。 进入后台时，在一个持续数分钟的时间窗内，应用仍可以创建和使用 Service。 在该时间窗结束后，应用将被视为处于*空闲*状态。 此时，系统将停止应用的后台 Service，就像应用已经调用 Service 的 `Service.stopSelf()` 方法一样。
>
> 在这些情况下，后台应用将被置于一个临时白名单中并持续数分钟。 位于白名单中时，应用可以无限制地启动 Service，并且其后台 Service 也可以运行。 处理对用户可见的任务时，应用将被置于白名单中，例如：
>
> - 处理一条高优先级 [Firebase 云消息传递 (FCM)](https://firebase.google.com/docs/cloud-messaging/)消息。
> - 接收广播，例如短信/彩信消息。
> - 从通知执行 `PendingIntent`。
> - 在 VPN 应用将自己提升为前台进程前开启 `VpnService`。
>
> **请注意：** `IntentService` 是一项 Service，因此其遵守针对后台 Service 的新限制。 因此，许多依赖 `IntentService` 的应用在适配 Android 8.0 或更高版本时无法正常工作。 出于这一原因，[Android 支持库 26.0.0](https://developer.android.com/topic/libraries/support-library/revisions#26-0-0) 引入了一个新的`JobIntentService`类，该类提供与 `IntentService` 相同的功能，但在 Android 8.0 或更高版本上运行时使用作业而非 Service。
>
> 在很多情况下，您的应用都可以使用 `JobScheduler` 作业替换后台 Service。 例如，CoolPhotoApp 需要检查用户是否已经收到好友共享的照片，即使该应用未在前台运行也需如此。 之前，应用使用一种会检查其云存储的后台 Service。 为了迁移到 Android 8.0（API 级别 26），开发者使用一个计划作业替换了这种后台 Service，该作业将按一定周期启动，查询服务器，然后退出。
>
> 在 Android 8.0 之前，创建前台 Service 的方式通常是先创建一个后台 Service，然后将该 Service 推到前台。 Android 8.0 有一项复杂功能：系统不允许后台应用创建后台 Service。 因此，Android 8.0 引入了一种全新的方法，即 `startForegroundService()`，以在前台启动新 Service。 在系统创建 Service 后，应用有五秒的时间来调用该 Service 的 `startForeground()` 方法以显示新 Service 的用户可见通知。 如果应用在此时间限制内*未*调用 `startForeground()`，则系统将停止此 Service 并声明此应用为 [ANR](https://developer.android.com/training/articles/perf-anr)。

到Android12，则引入了更加严厉的限制：[前台服务启动限制  | Android 12 Beta 版  | Android Developers](https://developer.android.com/about/versions/12/foreground-services)



## 问题发生的场景

通过之前的限制，我们可以猜测，在如下情况下，可能会出现问题：

1. 调用 `startService()` 启动服务，然后调用 `startForeground()` 来将服务设置为前台；
2. 只调用 `Context.startForegroundService()`方法，但是不调用`startForeground()` ；
3. 只调用 `Context.startForegroundService()`方法，但是不在5s内调用 `startForeground()` ；

我们针对这几种场景分别编写测试代码，测试这几种情况下，系统分别会怎么处理；

测试设备：Emulator Pixel_4_XL_API_30 Android 11, API 30

###  调用 `startService()` 启动服务，然后调用 `startForeground()` 来将服务设置为前台；

```shell
正常运行
```

###  只调用 `Context.startForegroundService()`方法，但是不调用`startForeground()` ；

```shell
2021-07-11 23:48:39.102 11475-11491/cn.hanlyjiang.androidoserviceexception W/System: A resource failed to call close. 
2021-07-11 23:48:52.369 11475-11475/cn.hanlyjiang.androidoserviceexception D/AndroidRuntime: Shutting down VM
2021-07-11 23:48:52.371 11475-11475/cn.hanlyjiang.androidoserviceexception E/AndroidRuntime: FATAL EXCEPTION: main
    Process: cn.hanlyjiang.androidoserviceexception, PID: 11475
    android.app.RemoteServiceException: Context.startForegroundService() did not then call Service.startForeground(): ServiceRecord{846f722 u0 cn.hanlyjiang.androidoserviceexception/.FGService}
        at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2005)
        at android.os.Handler.dispatchMessage(Handler.java:106)
        at android.os.Looper.loop(Looper.java:223)
        at android.app.ActivityThread.main(ActivityThread.java:7656)
        at java.lang.reflect.Method.invoke(Native Method)
        at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
        at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
```



### 只调用 `Context.startForegroundService()`方法，但是不在5s内调用 `startForeground()` 

```shell
    --------- beginning of crash
2021-07-11 23:51:14.920 11762-11762/cn.hanlyjiang.androidoserviceexception E/AndroidRuntime: FATAL EXCEPTION: main
    Process: cn.hanlyjiang.androidoserviceexception, PID: 11762
    android.app.RemoteServiceException: Context.startForegroundService() did not then call Service.startForeground(): ServiceRecord{8862eb8 u0 cn.hanlyjiang.androidoserviceexception/.FGService}
        at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2005)
        at android.os.Handler.dispatchMessage(Handler.java:106)
        at android.os.Looper.loop(Looper.java:223)
        at android.app.ActivityThread.main(ActivityThread.java:7656)
        at java.lang.reflect.Method.invoke(Native Method)
        at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
        at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
```

需要注意的是，我们这里实际上延迟的时间不是5s，而是10s，其中测试了5-9秒都不能产生异常。（当然：这个数据因设备而异，不过可以确定的是，这个时间并不是严格的5s）



## 解决方案

* 通过消息来启动服务
* 绑定服务，然后调用 startForeground 方法