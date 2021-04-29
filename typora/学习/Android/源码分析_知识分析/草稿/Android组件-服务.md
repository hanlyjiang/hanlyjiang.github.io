# Android 服务

参考：

* [Google官方教程-服务概览](https://developer.android.google.cn/guide/components/services?hl=zh-cn)





## 服务类型

* **前台服务**
  * 执行用户能注意到的操作
  * 必须显示通知
* **后台**
  * 执行用户不会注意到的操作
  * Android26及以上系统对后台服务运行做了限制，应优先使用计划作业；
* **绑定服务**
  * 绑定服务提供客户端-服务器接口，以便组件与服务进行交互/发送请求/接收结果，可以利用IPC跨进程执行通讯操作；
  * 仅当与另外一个应用组件（Activity，Service，ContentProvider）绑定时，绑定服务才会运行；
  * 多个组件可同时绑定，全部取消绑定后，服务就会被销毁；
* 服务可以同时以两种方式运行，它可以是启动服务（无限期运行），也支持绑定；



## 服务和线程的抉择

1. 服务是一种即使用户未与应用交互也可以在后台运行的组件；
2. 服务在其托管进程的主线程中运行，如果服务中执行任何CPU密集型工作或耗时工作，应该在服务内启动新的线程来完成；

**抉择**

* 如果只有与用户交互时执行操作，则应创建新线程；可选：
  * Thread
  * AsyncTask
  * HandlerThread
* 如果需要在用户切换到其他应用了的时候还执行任务，就可使用服务；



## 使用方式

实现Service或继承其子类；



需要实现的回调方法：

| 方法               | 说明                                                         | 总结 |
| ------------------ | ------------------------------------------------------------ | ---- |
| `onStartCommand()` | 当另一个组件（如 Activity）请求启动服务时，系统会通过调用 startService() 来调用此方法。执行此方法时，服务即会启动并可在后台无限期运行。如果您实现此方法，则在服务工作完成后，您需负责通过调用 stopSelf() 或 stopService() 来停止服务。（如果您只想提供绑定，则无需实现此方法。） |      |
| `onBind()`         | 当另一个组件想要与服务绑定（例如执行 RPC）时，系统会通过调用 bindService() 来调用此方法。在此方法的实现中，您必须通过返回 IBinder 提供一个接口，以供客户端用来与服务进行通信。请务必实现此方法；但是，如果您并不希望允许绑定，则应返回 null。 |      |
| `onCreate()`       | 首次创建服务时，系统会（在调用 onStartCommand() 或 onBind() 之前）调用此方法来执行一次性设置程序。如果服务已在运行，则不会调用此方法。 |      |
| `onDestroy()`      | 当不再使用服务且准备将其销毁时，系统会调用此方法。服务应通过实现此方法来清理任何资源，如线程、注册的侦听器、接收器等。这是服务接收的最后一个调用。 |      |

> 测试发现：
>
> bind的service。在unbind之后，如果仍然持有其上一次绑定后的service引用，仍然可以调用到service



## 问题-启动的服务如何交互工作？

多次启动即可，每次都会调用 `onStartCommand` ，这时可以：

1. 启动多个线程进行处理，则服务可同时并行响应多个请求；
2. 将所有请求加入一个队列，使用一个线程逐一处理；（IntentService）



## Android 8.0 IntentService

IntentService is subject to all the background execution limits imposed with Android 8.0 (API level 26). Consider using `androidx.work.WorkManager` or `androidx.core.app.JobIntentService`, which uses jobs instead of services when running on Android 8.0 or higher.

Android 8.0 以上应该使用 `androidx.work.WorkManager` or `androidx.core.app.JobIntentService` 用于执行后台任务；





# WorkManager

底层实现方式：

* JobScheduler（API 23+）
* AlarmManager + BroadcastReceiver （API 14-22）