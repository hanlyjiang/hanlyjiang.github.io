# Why are you here

* 想要更好的理解Android是如何工作的
  * Intent，ContentProviders，Messenger
  * 访问系统服务
  * 生命周期回调方法
  * 安全
* 模块化你自己的业务逻辑，通过一个高效且低延迟的IPC框架让来跨越应用程序的边界
* 想要添加一个新的系统服务，所以想了解如何将服务暴露给开发者
* 仅仅是因为对IPC和Binder感兴趣
* 没有其他事情可做了？







# 目录

* Binder 概览
* IPC
* Binder 的优点
* Binder vs Intent/ContentProvider/Messenger-based IPC
* Binder 相关名词
* Binder 通讯和发现
* AIDL
* Binder 对象引用映射
* 通过示例了解Binder
* 异步Binder
* 内存共享
* Binder的限制
* 安全



# 我是谁？

* 从1997年开始，做服务端Java和Linux
* 从2009年开始，Android/嵌入式 Java和Linux开发
* Android Internals and Security培训的开发人员和讲师
* 旧金山Android用户组（sfandroid.org）的创始人和联合组织者 
* 旧金山Java用户组（sfjava.org）的创始人和联合组织者 
* 旧金山HTML5用户组的联合创始人和联合组织者 （sfhtml5.org） 
* 在AnDevCon，AndroidOpen，Android Builders Summit等大会上担任演讲嘉宾。 





# Binder 是什么？

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326091444.png" alt="image-20210326091443982" style="zoom: 50%;" />

* 一个用于开发面向对象的系统服务的IPC/组件系统
  * 非面向对象的内核，而是可以在传统内核（如Linux）上运行的面向对象的操作系统环境。
* 在Android中非常重要
* 来自 OpenBinder
  * 从Be，Inc.开始，作为“下一代BeOS”的关键部分（〜2001年） 
  * 被PalmSource收购 
  * 最初在Palm Cobalt（基于微内核的操作系统）中首次实现；
  * 之后Palm切换到Linux，因此将Binder移植到了Linux，开源（〜2005） 
  * Google聘请了OpenBinder的主要工程师Dianne Hackborn加入Android团队。
  * 最初按原样使用在Android中，不过后来完全重写（〜2008年）
  * OpenBinder不再维护-Binder依然保持活力！
* 专注于可扩展性，稳定性，灵活性，低延迟/开销，易于编程的模型 





# IPC

* 进程间通信（IPC）是跨多个进程交换信号和数据的框架 
* 用于消息传递，同步，共享内存和远程过程调用（RPC） 
* 实现**信息共享**，计算加速，**模块化**，便利性，**特权分离**，**数据隔离**，稳定性 
  * 每个进程都有自己的（沙盒）地址空间，通常在唯一的系统ID下运行 
* 许多IPC选项 
  * 文件（包括映射的内存） 
  * Signals-讯号 
  * 套接字（UNIX域，TCP/IP） 
  * 管道（包括命名管道） 
  * 信号量-Semaphores 
  * 共享内存 
  * 消息传递（包括队列，消息总线）
  * Intent，ContentProviders，Messenger 
  * Binder！



# 为什么是Binder？

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326091544.png" alt="image-20210326091544520" style="zoom:50%;" />

* 出于安全性，稳定性和内存管理的原因，Android应用程序和系统服务在单独的进程中运行，但它们需要进行通信和共享数据！ 
  * 安全性：每个进程都经过沙盒测试，并在不同的系统标识下运行 
  * 稳定性：如果某个进程行为不当（例如崩溃），则不会影响其他任何进程 
  * 内存管理：删除“不需要的”进程以释放资源（主要是内存）以供新进程使用 
  * 实际上，单个Android应用程序可以使其组件在单独的进程中运行 

* IPC降临
  * 但是我们需要避免传统IPC的开销并避免拒绝服务问题 
* Android的libc（又称bionic）不支持System V IPC，
  * 没有SysV信号量，共享内存段，消息队列等。 
  * 当进程“忘记”在终止时释放共享的IPC资源时，System V IPC易于发生内核资源泄漏。
  * Buggy，恶意代码或行为良好的应用程序，该应用程序是低内存**SIGKILL**编写的 

> System V IPC机制简介: Unix System V 中的三种进程间通信机制: 消息队列 信号量(信号灯) 共享内存 这几个System V IPC 对象的访问权限是对象创建者通过系统调用设定的.访问这些System V IPC 对象首先要经过权限检查,就如同访问文件要经过权限检查一样.
>
> 来源：[System V IPC机制简介 - 简书](https://www.jianshu.com/p/5c970093b07c#:~:text=System V IPC机制简介 Unix System V 中的三种进程间通信机制%3A 消息队列,共享内存 这几个System V IPC 对象的访问权限是对象创建者通过系统调用设定的.访问这些System V IPC 对象首先要经过权限检查%2C就如同访问文件要经过权限检查一样.)

* Binder 降临
  * 它内置的“对象”引用计数引用和死亡通知机制使其适用于“敌对-hostile”环境（低内存杀手漫游） 
  * 当任何客户不再引用Binder服务时，将自动通知其所有者可以处理该Binder服务 

* 其他许多功能： 

  * “线程迁移”风格的编程模型： 
    * 自动管理线程池 
    * 可以像对待本地对象一样调用远程对象上的方法-该thread似乎“跳”到另一个进程
    * 同步和异步（`oneway`）调用模型 

  * 安全：可以鉴别发送者到接收者（通过UID / PID）
  * 跨过程边界的唯一对象映射 
    * 对远程对象的引用可以传递到另一个进程，并且可以用作标识令牌 
  * 跨进程边界发送文件描述符的能力 
  * 简单的Android接口定义语言（AIDL） 
  * 内建对许多常见数据类型的编组（marshalling）支持 
  * 通过自动生成的Proxy（代理）和Stub（存根）简化了事务调用模型（仅Java） 
  * 跨进程的递归-即在本地对象上调用方法时的行为与递归语义相同 
  * 如果客户端和服务恰好在同一进程中，则为本地执行模式（不进行IPC/数据编组） 

* 但是

  * 不支持RPC（仅限本地） 
  * 基于客户端服务消息的通信-不适合流式传输
  * 未由POSIX或任何其他标准定义 

* 大多数应用程序和核心系统服务都依赖于Binder

  * 大多数应用程序组件的生命周期回调（例如onResume，onDestory等）均通过基于基于Binder的ActivityManagerService调用 
  * 关闭活页夹，整个系统停止运行（无显示，无音频，无输入，无传感器， ...） 
  * 在某些情况下使用了Unix域套接字（例如RILD） 



# **IPC with** Intents and ContentProviders?

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326104842.png" alt="image-20210326104842698" style="zoom:50%;" />

* Android支持通过Intents和ContentProviders执行一种简单形式的IPC
* Intent消息传递是Android组件之间异步通信的框架 
  * 这些组件可以在相同或跨不同的应用程序（即进程）中运行 
  * 支持点对点以及发布-订阅消息传递域 
  * Intent表示一条消息，其中包含要执行的操作的描述以及要传递给接收者的数据 
  * 隐式Intent支持松耦合的API 
* ContentResolver通过固定（CRUD）API与ContentProviders（通常在独立的应用程序中运行）同步通信 
* 所有的android组件都可以充当发送者，而大多数可以充当接收者 
* 所有通讯都在Looper（又称为Main）线程上进行（默认情况下） 
* 不过：
  * 并不是真正的面向对象 
  * 基于意图的通信的仅异步模型不适用于低延迟 
  * 由于API的定义过于宽松，因此容易出现运行时错误。
  * 所有基础通信均基于Binder！ 
  * 实际上，Intents和ContentProvider只是对Binder的更高层次的抽象 
  * 通过ActivityManagerService和PackageManagerService 等系统服务方便：

示例：

`src/com/marakana/shopping/UpcLookupActivity.java`:

```java
//...
public class ProductLookupActivity extends Activity {
	private static final int SCAN_REQ = 0; 
    // ...
    public void onClick(View view) {
        Intent intent = new Intent("com.google.zxing.client.android.SCAN"); //  (1)
        intent.setPackage("com.google.zxing.client.android"); //  (1)
        intent.putExtra("SCAN_MODE", "PRODUCT_MODE"); // (2)
        super.startActivityForResult(intent, SCAN_REQ); // (3)
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) { // (4)
        if (requestCode == SCAN_REQ && resultCode == RESULT_OK) { //  (5)
            String barcode = data.getStringExtra("SCAN_RESULT"); //   (6)
            String format = data.getStringExtra("SCAN_RESULT_FORMAT"); //   (6)
            // ...
            super.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://www.upcdatabase.com/item/" + barcode))); //  (7)
        }
        // ... 
    }
}
```

`src/com/google/zxing/client/android/CaptureActivity.java`:

```java
public class CaptureActivity extends Activity {
    // ...
    private void handleDecodeExternally(Result rawResult, ...) {
        Intent intent = new Intent(getIntent().getAction()); 
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET); 
        intent.putExtra(Intents.Scan.RESULT, rawResult.toString()); // (8)
        intent.putExtra(Intents.Scan.RESULT_FORMAT,
        rawResult.getBarcodeFormat().toString()); 
        ...
        super.setResult(Activity.RESULT_OK, intent);
    	super.finish(); // (9)
    }
}
 
```

（1）指定想要通信的对象

（2）指定调用的输入参数

（3）异步的初始化调用

（4）通过回调接收响应

（5）验证响应是否是我们期望的

（6）获取响应

（7）初始化另外一个IPC请求，但是不期望获取结果

（8）在服务端将结果放进一个新的Intent中

（9）设置返回结果（异步）





# Messenger IPC

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326150329.png" alt="image-20210326150329439" style="zoom:50%;" />

* Android的Messenger代表对Handler的引用，该Handler可以通过Intent发送请求到远程进程 
* 可以使用前面提到的IPC机制通过Intent发送对Messenger的引用 
* 远程进程通过Messenger发送的消息将传递到本地处理程序 
* 消息就像意图，因为它们可以 指定“操作”（aMessage.what）和数据（aMessage.getData（）） 
* 仍然是异步的，但延迟/开销较低 
* 非常适合从服务到客户端的有效回调。
* 默认情况下，消息在Looper线程上处理 
* 所有基础通信仍基于Binder！ 

示例：

`src/com/marakana/android/download/client/DownloadClientActivity.java`:

```java
...
public class DownloadClientActivity extends Activity {
    private static final int CALLBACK_MSG = 0; ...
    @Override
    public void onClick(View view) {
        Intent intent = new Intent( "com.marakana.android.download.service.SERVICE"); // (1)
        ArrayList<Uri> uris = ...
        intent.putExtra("uris", uris); // (2)
        Messenger messenger = new Messenger(new ClientHandler(this)); // (3)
        intent.putExtra("callback-messenger", messenger); // (4)
        super.startService(intent); // (5)
    }
    private static class ClientHandler extends Handler {
        private final WeakReference<DownloadClientActivity> clientRef; // (6)
        public ClientHandler(DownloadClientActivity client) {
            this.Ref = new WeakReference<DownloadClientActivity>(client);
        }
        @Override
        public void handleMessage(Message msg) { // (7)
            Bundle data = msg.getData();
            DownloadClientActivity client = clientRef.get();
            if (client != null && msg.what == CALLBACK_MSG && data != null) {
                Uri completedUri = data.getString("completed-uri"); // (8)
                // client now knows that completedUri is done
...
            } }
    } }
```



(1) 指定我们要呼叫的人（使用Intent！）
(2) 指定调用的输入参数
(3) 在处理程序上创建一个Messenger
(4) 将Messenger传递为输入参数
(5) 异步发起调用
(6) 处理程序记住对客户端的引用
(7) 通过处理程序上的回调接收响应
(8) 获取响应数据

**服务：**

`src/com/marakana/android/download/service/DownloadService.java`:

```java
...
public class MessengerDemoService extends IntentService {
    private static final int CALLBACK_MSG = 0;
...
    @Override
    protected void onHandleIntent(Intent intent) { // (1)
        ArrayList<Uri> uris = intent.getParcelableArrayListExtra("uris"); //  (2)
    Messenger messenger = intent.getParcelableExtra("callback-messenger"); //  (3)
    for (Uri uri : uris) {
		// download the uri
		...
        if (messenger != null) {
            Message message = Message.obtain(); //    (4)
            message.what = CALLBACK_MSG;
            Bundle data = new Bundle(1);
            data.putParcelable("completed-uri", uri); //  (5)
            message.setData(data); // (4)
            try {
            	messenger.send(message); // (6)
			} catch (RemoteException e) {
    		...
            } finally {
                message.recycle(); //  (4)
            }
          } 
        }
} }
```

1. 处理来自我们的客户端的请求（可以是本地的也可以是远程的）
2. 获取请求数据
3. 获取对Messenger的引用
4. 使用消息作为我们数据的通用信封
5. 设置我们的回复
6. 发送我们的回复



# Binder 相关技术术语

![image-20210326151044882](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326151044.png)

* **Binder（Framework）：** 全局IPC架构
* **Binder Driver：** 内核级驱动程序，支持进程间通信
* **Binder 协议** ： 用于与Binder驱动程序进行通信的基于ioctl的低级协议
* **IBinder 接口：** Binder对象必须实现的明确定义的行为（即方法）
* **AIDL：**： Android接口定义语言，用于描述IBinder接口上的业务操作 
* **Binder（对象）：** IBinder接口的通用实现
* **Binder Token：** 一个抽象的32位整数值，该值唯一地标识系统上所有进程中的Binder对象 
* **Binder Service：** Binder（对象）的实际实现，用于实现业务操作 
* **Binder Client：** 想要利用`Binder Service`提供的方法的对象 
* **Binder 事务（Transaction）：** 通过Binder协议在远程Binder对象上调用操作（即方法）的行为，可能涉及发送/接收数据
* **Parcel-包裹:** “可以通过IBinder发送的消息（数据和对象引用）的容器。” 可交换的数据单元-一个用于出站请求，另一个用于入站回复 
* **Marshalling-编组**： 一种将较高级别的应用程序数据结构（即请求/响应参数）转换为小包以将其嵌入到Binder Transaction中的过程 
* **Unmarshalling-解组:** 从通过Binder事务接收的parcel中重新构建更高级别的应用程序数据结构（即请求/响应参数）的过程 
* **Proxy：**AIDL接口的实现，用于取消/封送数据并将方法调用映射到通过包装的IBinder引用对Binder对象提交的事务 
* **Stub：**AIDL接口的部分实现，在取消/编组数据时将事务映射到Binder Service方法调用 
* **Context Manager (即servicemanager)：**具有已知句柄（注册为句柄0）的特殊Binder对象，用作其他Binder对象（名称→句柄映射）的注册表/查找服务 



# Binder 通讯与发现

* 就客户端而言，它只想使用该服务： 

  

![image-20210326152711707](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326152711.png)

* 但是进程无法直接在其他进程上调用操作（或读取/写入数据），不过内核可以，因此它们可以使用Binder驱动程序： 

  ![image-20210326152758803](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326152758.png)

> 由于服务可能会收到来自多个客户端的并发请求，因此它需要保护（同步访问）其可变状态。 

* Binder驱动程序通过`/dev/binder`公开，并提供了一个相对简单的API，基于打开-open，释放-release，轮询-poll，mmap，刷新-flush和ioctl操作。

* 实际上，大多数通信都是通过`ioctl（binderFd，BINDER_WRITE_READ，＆bwd）`进行的，其中`bwd`定义为：

  ```c++
   struct binder_write_read {
      signed long write_size; /* bytes to write */
      signed long write_consumed; /* bytes consumed by driver */ unsigned long write_buffer;
      signed long read_size; /* bytes to read */
      signed long read_consumed; /* bytes consumed by driver */ unsigned long read_buffer;
  };
  ```

* `write_buffer`包含一系列供驱动程序执行的命令 

  * `book-keeping` 命令，例如 增加/减少`Binder`对象引用，请求/清除死亡通知等 
  * 有的命令需要一个response，例如`BC_TRANSACTION`. 

* 返回时，`read_buffer` 将包含用于用户空间的命令
  * 以执行相同的簿记命令 
  * 请求处理响应的命令（即`BC_REPLY`）或执行嵌套（递归）操作的请求 

* 客户端通过事务与服务进行通信，事务包含Binder Token，要执行的方法的code，原始数据缓冲区和发送方PID/UID（由驱动程序添加） 

* 最底层的操作和数据结构（即`Parcel`）由`libbinder`抽象（在本机级别），这就是客户端和服务使用的。 

* 由于客户端和服务端都不希望了解有关Binder协议和libbinder的任何知识，因此它们使用proxies和stubs： 

  ![image-20210326155415608](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326155415.png)

> 基于Java的proxy和stub可以由AIDL工具针对AIDL描述的服务自动生成。 

* 实际上，大多数client甚至都不知道自己正在使用IPC，更不用说Binder或代理了，他们依靠**managers**为他们抽象出所有这些复杂性： 

  ![image-20210326155600851](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326155600.png)

> 对于系统服务尤其如此，系统服务通常仅通过其管理器向客户端公开其API的子集。 

* 那么客户端如何获取想要使用的服务的handle？ 只需询问服务经理（Binder的`CONTEXT_MGR`），并希望该服务已在其中注册： 

  ![image-20210326155934564](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326155934.png)

> 出于安全/理智的原因，绑定程序驱动程序将仅接受一次/一次性`CONTEXT_MGR`注册，这就是为什么`servicemanager`是最早在Android上启动的服务之一的原因。 

> 可以通过如下命令获取当前注册到 servicemanager 的服务列表：
>
> ```shell
> $ adb shell service list
> ```

* 另外一种视角

  ![image-20210326160408806](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326160408.png)





# 示例：Location Service

![image-20210326160627612](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326160627.png)



# AIDL

* Android接口定义语言是一种Android特定语言，用于定义基于Binder的服务接口 

* AIDL遵循类Java的接口语法，并允许我们声明“业务”方法 

* 每个基于Binder的服务都在一个单独的`.aidl`文件中定义，该文件通常名为`IFooService.aidl`， 并保存在`src/`目录中 

  `src/com/example/app/IFooService.aidl`

  ```java
  package com.example.app; 
  import com.example.app.Bar; 
  interface IFooService {
  	void save(inout Bar bar); 
      Bar getById(int id);
  	void delete(in Bar bar); 
      List<Bar> getAll();
  }
  ```

* `aidl`构建工具（Android SDK的一部分）用于从每个`.aidl`文件中提取真实的Java接口（以及提供Android的android.os.IBinder的Stub），并将其放入我们的`gen/`目录 

  `gen/com/example/app/IFooService.java`

  ```java
  package com.example.app;
  
  public interface IFooService extends android.os.IInterface {
      public static abstract class Stub extends android.os.Binder implements com.example.app.IFooService {
          // ...
          public static com.example.app.IFooService asInterface(
                  android.os.IBinder obj) {
  // ...
              return new com.example.app.IFooService.Stub.Proxy(obj);
          }
  
          // ...
          public boolean onTransact(int code, android.os.Parcel data, android.os.Parcel reply, int
                  flags) throws android.os.RemoteException {
              switch (code) {
  // ...
                  case TRANSACTION_save: {
  // ...
                      com.example.app.Bar _arg0;
  // ...
                      _arg0 = com.example.app.Bar.CREATOR.createFromParcel(data);
                      this.save(_arg0);
  // ...
                  }
              }
          }
  
          // ...
          private static class Proxy implements com.example.app.IFooService {
              private android.os.IBinder mRemote;
  
              // ...
              public void save(com.example.app.Bar bar) throws android.os.RemoteException {
  // ...
                  android.os.Parcel _data = android.os.Parcel.obtain();
  // ...
                  bar.writeToParcel(_data, 0);
  // ...
                  mRemote.transact(Stub.TRANSACTION_save, _data, _reply, 0); // ...
              }
          }
      }
  
      void save(com.example.app.Bar bar) throws android.os.RemoteException;
  
      com.example.app.Bar getById(int id) throws android.os.RemoteException;
  
      void delete(com.example.app.Bar bar) throws android.os.RemoteException;
  
      java.util.List<Bar> getAll() throws android.os.RemoteException;
  }
  
  ```

* AIDL 支持如下类型：

  * `null`

  * `boolean, boolean[], byte, byte[], char[], int, int[], long, long[], float, float[], double, double[]`

  * `java.lang.CharSequence`, `java.lang.String` (以 UTF-16 发送)

  * `java.io.FileDescriptor`-作为原始文件描述符的dup传输（指向相同的基础流和位置） 

  * `java.io.Serializable` - 效率不高（太冗长） 

  * `java.util.Map<String,Object>`-支持的类型（总是重构为 `java.util.HashMap`） 

  * `android.os.Bundle`-专门的Map-wrapper，仅接受AIDL支持的数据类型 

  * `java.util.List`-受支持的类型（总是重新构造为`java.util.ArrayList`） 

  * `java.lang.Object[]`-受支持的类型（包括原始数据类型的包装器） 

  * `android.util.SparseArray, android.util.SparseBooleanArray`

  * `android.os.IBinder`，`android.os.IInterface`-通过（全局唯一的）引用（作为“strong binder”，也称为handle）传输，可用于回调发送者 

  * `android.os.Parcelable`-允许自定义类型： 

    `src/com/example/app/Bar.java`

    ```java
    package com.example.app;
    
    import android.os.Parcel;
    import android.os.Parcelable;
    
    public class Bar implements Parcelable {
        private int id;
        private String data;
    
        public Bar(int id, String data) {
            this.id = id;
            this.data = data;
        }
    // getters and setters omitted
    ...
    
        public int describeContents() {
            return 0;
        }
    
        public void writeToParcel(Parcel parcel, int flags) {
            parcel.writeInt(this.id);
            parcel.writeString(this.data);
        }
    
        public void readFromParcel(Parcel parcel) {
            this.id = parcel.readInt();
            this.data = parcel.readString();
        }
    
        public static final Parcelable.Creator<Bar> CREATOR = new Parcelable.Creator<Bar>() {
            public Bar createFromParcel(Parcel parcel) {
                return new Bar(parcel.readInt(), parcel.readString());
            }
    
            public Bar[] newArray(int size) {
                return new Bar[size];
            }
        };
    }
    ```

    > 在此，Parcelable接口未定义公共`void readFromParcel(Parcel)`方法。 相反，由于Bar被认为是可变的，因此在此处是必需的-也就是说，我们希望远程端能够在`void save(inout Bar bar)`方法中对其进行更改。 
    >
    > 同样，Parcelable接口也没有定义公共静态最终`Parcelable.Creator <Bar> CREATOR`字段。 它从save事务中的`_data` parcel和getById操作中的`_reply` parcel重构Bar。 

  * 自定义的类需要在它自己的 .aidl 文件中声明

    `src/com/example/app/Bar.aidl`

    ```java
    package com.example.app; 
    parcelable Bar;
    ```

    > 即使它们在同一包中，AIDL接口必须显式地导入parcelable自定义类。在前面的示例中，如果它引用了`com.example.app.Bar`，即使它们在同一包中，`src/com/example/app/IFooService.aidl`中也必须导入`com.example.app.Bar`;  

* AIDL定义的方法可以采用零个或多个参数，并且必须返回值或void 
* 所有非原始数据类型的参数都需要一个方向标记，用于指示数据的处理方式，可以设置为 ：`in` 或 `inout`
  * 原始数据类型的方向始终为`in` （故可以省略） 
  * 方向标签会告诉Binder什么时候marshal数据，因此其使用会对性能产生直接影响 
* 所有`.aidl`注释都将复制到生成的Java接口（`import`和`package`语句之前的注释除外）。 
* 默认仅支持以下异常：`SecurityException`，`BadParcelableException`，`IllegalArgumentException`，`NullPointerException`和`IllegalStateException` 
* `.aidl`文件中不支持静态字段

> 问：原始数据类型包含哪些呢？



# 跨进程边界的Binder对象参考映射 

**Binder Object Reference Mapping Across Process Boundaries**

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326164734.png" alt="image-20210326164734738" style="zoom:50%;" />

* Binder对象引用是下列对象之一：
  * 同一进程中的Binder对象的实际虚拟内存地址  
  * 另一个进程中的Binder对象的一个抽象的32位句柄 

* 在每一次transaction中，Binder驱动程序自动将本地地址映射到远程Binder句柄，并将远程Binder句柄映射到本地地址 

* 此映射在以下位置完成： 
  * Binder transaction的目标 
  * 跨进程边界共享的IBinder对象引用作为参数或返回值（嵌入在事务数据中） 

* 为了这个能够工作
  * Binder驱动程序维护进程之间的本地地址和远程句柄的映射（每个进程中使用一个二叉树记录），后续可根据此记录执行转换
  * 根据客户端在提交事务时提供的偏移量发现事务数据中嵌入的引用，然后就地重写

* Binder驱动程序无法了解哪些从未与远程进程共享过的Binder对象 
  * 一旦在事务中找到新的Binder对象引用，Binder便会记住该引用。
  * 每次与另一个进程共享该引用时，其引用计数都会增加
  * 当进程终止时，显式或自动减少引用计数 
  * 当不再需要引用时，将通知其所有者可以释放该引用，并且Binder会删除其映射 

> 没有看太懂



# 示例： 构建一个基于Binder的服务端和客户端

![image-20210326172049453](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210326172049.png)

为了演示一个基于Binder的服务和客户端（基于Fibonacci），我们将会创建三个独立的项目：

1. `FibonacciCommon` 库项目 - 用于定义我们的AIDL接口以及作为参数和返回值的自定义类型；
2. `FibonacciService` 项目 - 用于实现我们的AIDL接口，并将其暴露给客户端；
3. `FibonacciClient` 项目 - 连接到我们通过AIDL定义的服务，并且使用它

代码可以在这里找到：

* https://github.com/twitter-university/FibonacciBinderDemo





# 示例： 同步Binder IPC

* Binder允许通过AIDL接口上的`oneway`关键字声明在客户端与其服务之间进行异步通信 
* 不过，我们仍然是关心结果的，所以通常将异步调用与回调配合使用-（一般通过侦听器完成）
* 当客户端将自己作为回调侦听器提供引用时，则在调用侦听器时角色将互换：客户端的侦听器成为服务，而服务成为这些侦听器的客户端
* 最好通过一个示例（基于斐波那契）来解释 
* 相关代码可以在这里找到：
  * https://github.com/twitter-university/FibonacciAsyncBinderDemo



# 定义一个 oneway AIDL 服务

* 首先，我们需要一个监听器，它本身是一个 `oneway` AIDL 定义的服务

  `FibonacciCommon/src/com/marakana/android/fibonaccicommon/IFibonacciServiceResponseListener.aidl`

  ```java
  package com.marakana.android.fibonaccicommon;
  import com.marakana.android.fibonaccicommon.FibonacciRequest;
  import com.marakana.android.fibonaccicommon.FibonacciResponse;
  oneway interface IFibonacciServiceResponseListener { 
      void onResponse(in FibonacciResponse response);
  }
  ```

  > 注意接口声明前面的oneway 
  >
  > **oneway** interface IFibonacciServiceResponseListener

* 现在，我们可以创建一个 `oneway` 接口：

  `FibonacciCommon/src/com/marakana/android/fibonaccicommon/IFibonacciService.aidl`

  ```java
  package com.marakana.android.fibonaccicommon;
  import com.marakana.android.fibonaccicommon.FibonacciRequest;
  import com.marakana.android.fibonaccicommon.FibonacciResponse;
  import com.marakana.android.fibonaccicommon.IFibonacciServiceResponseListener;
  // 注意前面的oneway关键字
  oneway interface IFibonacciService {
  	void fib(in FibonacciRequest request, in IFibonacciServiceResponseListener listener);
  }
  ```

  > 注意接口声明前面的oneway 
  >
  > **oneway** interface IFibonacciService

  # 实现我们的异步AIDL服务

* 我们的服务的实现将调用侦听器，而不是返回结果：

  `FibonacciService/src/com/marakana/android/fibonacciservice/IFibonacciServiceImpl.java:`

  ```java
  package com.marakana.android.fibonacciservice;
  
  import android.os.RemoteException;
  import android.os.SystemClock;
  import android.util.Log;
  
  import com.marakana.android.fibonaccicommon.FibonacciRequest;
  import com.marakana.android.fibonaccicommon.FibonacciResponse;
  import com.marakana.android.fibonaccicommon.IFibonacciService;
  import com.marakana.android.fibonaccicommon.IFibonacciServiceResponseListener;
  import com.marakana.android.fibonaccinative.FibLib;
  
  public class IFibonacciServiceImpl extends IFibonacciService.Stub {
      private static final String TAG = "IFibonacciServiceImpl";
  
      @Override
      public void fib(FibonacciRequest request,
                      IFibonacciServiceResponseListener listener) throws RemoteException {
          long n = request.getN();
          Log.d(TAG, "fib(" + n + ")");
          long timeInMillis = SystemClock.uptimeMillis();
          long result;
          switch (request.getType()) {
              case ITERATIVE_JAVA:
                  result = FibLib.fibJI(n);
                  break;
              case RECURSIVE_JAVA:
                  result = FibLib.fibJR(n);
                  break;
              case ITERATIVE_NATIVE:
                  result = FibLib.fibNI(n);
                  break;
              case RECURSIVE_NATIVE:
                  result = FibLib.fibNR(n);
                  break;
              default:
                  result = 0;
          }
          timeInMillis = SystemClock.uptimeMillis() - timeInMillis;
          Log.d(TAG, String.format("Got fib(%d) = %d in %d ms", n, result,
                  timeInMillis));
          // ⚠️注意这里调用了listener.onResponse
          listener.onResponse(new FibonacciResponse(result, timeInMillis));
      }
  }
  
   
  ```

  > 在等待监听器返回的时候，服务不会阻塞并等待，因为监听器也是 oneway的。



# 实现我们的异步AIDL客户端

最后，我们实现我们的客户端，该客户端本身也必须将侦听器实现为Binder服务： 

`FibonacciClient/src/com/marakana/android/fibonacciclient/FibonacciActivity.java:`

```java
package com.marakana.android.fibonacciclient;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.RemoteException;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.marakana.android.fibonaccicommon.FibonacciRequest;
import com.marakana.android.fibonaccicommon.FibonacciResponse;
import com.marakana.android.fibonaccicommon.IFibonacciService;
import com.marakana.android.fibonaccicommon.IFibonacciServiceResponseListener;

public class FibonacciActivity extends Activity implements OnClickListener, ServiceConnection {
    private static final String TAG = "FibonacciActivity"; // the id of a message to our response handler
    private static final int RESPONSE_MESSAGE_ID = 1;
    // the id of a progress dialog that we'll be creating
    private static final int PROGRESS_DIALOG_ID = 1;
    private EditText input; // our input n
    private Button button; // trigger for fibonacci calcualtion private RadioGroup type; // fibonacci implementation type private TextView output; // destination for fibonacci result private IFibonacciService service; // reference to our service // the responsibility of the responseHandler is to take messages
    // from the responseListener (defined below) and display their content // in the UI thread
    private final Handler responseHandler = new Handler() {
        @Override
        public void handleMessage(Message message) {
            switch (message.what) {
                case RESPONSE_MESSAGE_ID:
                    Log.d(TAG, "Handling response");
                    FibonacciActivity.this.output.setText((String) message.obj);
                    FibonacciActivity.this.removeDialog(PROGRESS_DIALOG_ID);
                    break;
            }
        }
    };
    // the responsibility of the responseListener is to receive call-backs // from the service when our FibonacciResponse is available
    private final IFibonacciServiceResponseListener responseListener = new
            IFibonacciServiceResponseListener.Stub() {
                // this method is executed on one of the pooled binder threads
                @Override
                public void onResponse(FibonacciResponse response)
                        throws RemoteException {
                    String result = String.format("%d in %d ms", response.getResult(),
                            response.getTimeInMillis());
                    Log.d(TAG, "Got response: " + result);
// since we cannot update the UI from a non-UI thread,
// we'll send the result to the responseHandler (defined above) Message message = FibonacciActivity.this.responseHandler
.obtainMessage(RESPONSE_MESSAGE_ID, result);
                    FibonacciActivity.this.responseHandler.sendMessage(message);
                }
            };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        super.setContentView(R.layout.main);
// connect to our UI elements
        this.input = (EditText) super.findViewById(R.id.input);
        this.button = (Button) super.findViewById(R.id.button);
        this.type = (RadioGroup) super.findViewById(R.id.type);
        this.output = (TextView) super.findViewById(R.id.output); // request button click call-backs via onClick(View) method this.button.setOnClickListener(this);
// the button will be enabled once we connect to the service
        this.button.setEnabled(false);
    }

    @Override
    protected void onStart() {
        Log.d(TAG, "onStart()'ed");
        super.onStart();
// Bind to our FibonacciService service, by looking it up by its name // and passing ourselves as the ServiceConnection object
// We'll get the actual IFibonacciService via a callback to
// onServiceConnected() below
        if (!super.bindService(new Intent(IFibonacciService.class.getName()),
                this, BIND_AUTO_CREATE)) {
            Log.w(TAG, "Failed to bind to service");
        }

    }

    @Override
    protected void onStop() {
        Log.d(TAG, "onStop()'ed");
        super.onStop();
// No need to keep the service bound (and alive) any longer than // necessary
        super.unbindService(this);
    }

    public void onServiceConnected(ComponentName name, IBinder service) {
        Log.d(TAG, "onServiceConnected()'ed to " + name);
// finally we can get to our IFibonacciService
        this.service = IFibonacciService.Stub.asInterface(service);
// enable the button, because the IFibonacciService is initialized
        this.button.setEnabled(true);
    }

    public void onServiceDisconnected(ComponentName name) {
        Log.d(TAG, "onServiceDisconnected()'ed to " + name);
// our IFibonacciService service is no longer connected this.service = null;
// disabled the button, since we cannot use IFibonacciService
        this.button.setEnabled(false);
    }

    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
            case PROGRESS_DIALOG_ID:
// this dialog will be opened in onClick(...) and
// dismissed/removed by responseHandler.handleMessage(...) ProgressDialog dialog = new ProgressDialog(this); dialog.setMessage(super.getText(R.string.progress_text)); dialog.setIndeterminate(true);
                return dialog;
            default:
                return super.onCreateDialog(id);
        }
    }

    // handle button clicks
    public void onClick(View view) {
// parse n from input (or report errors) final long n;
        String s = this.input.getText().toString();
        if (TextUtils.isEmpty(s)) {
            return;
        }
        try {
            n = Long.parseLong(s);
        } catch (NumberFormatException e) {
            this.input.setError(super.getText(R.string.input_error));
            return;
        }
// build the request object
        final FibonacciRequest.Type type;
        switch (FibonacciActivity.this.type.getCheckedRadioButtonId()) {
            case R.id.type_fib_jr:
                type = FibonacciRequest.Type.RECURSIVE_JAVA;

                break;
            case R.id.type_fib_ji:
                type = FibonacciRequest.Type.ITERATIVE_JAVA;
                break;
            case R.id.type_fib_nr:
                type = FibonacciRequest.Type.RECURSIVE_NATIVE;
                break;
            case R.id.type_fib_ni:
                type = FibonacciRequest.Type.ITERATIVE_NATIVE;
                break;
            default:
                return;
        }
        final FibonacciRequest request = new FibonacciRequest(n, type);
        try {
            Log.d(TAG, "Submitting request...");
            long time = SystemClock.uptimeMillis();
// submit the request; the response will come to responseListener 
            this.service.fib(request, this.responseListener);
            time = SystemClock.uptimeMillis() - time;
            Log.d(TAG, "Submited request in " + time + " ms");
// this dialog will be dismissed/removed by responseHandler 
            super.showDialog(PROGRESS_DIALOG_ID);
        } catch (RemoteException e) {
            Log.wtf(TAG, "Failed to communicate with the service", e);
        }
    }
}
```

> 我们的监听器不应保留对该活Activity的强引用（因为它是匿名内部类，所以会保留该引用），但在上面的示例中，为简洁起见，我们忽略了正确性。



# 通过Binder共享内存

* Binder交换数据是在进行通信的各方之间复制的-如果我们要发送的数据很多，使用这种方式的效果是不理想的
  
  * 实际上，Binder对我们可以通过交易发送的数据量做了限制
* 如果我们要共享的数据来自文件，那么我们应该只发送文件描述符
  
  * 这就是我们要求媒体播放器为我们播放音频/视频文件的方式-我们只是将其发送给FD 
* 如果我们要发送的数据位于内存中，则可以发送多个但较小的块，而不是尝试一次发送所有数据
  
* 但是这样使我们的设计复杂化了 
  
* 另外，我们可以利用Android的ashmem（匿名共享内存）功能 

  * 它的Java包装器`android.os.MemoryFile`不适用于来自第三方应用程序的内存共享 

  * 放到本地（通过JNI）并直接使用ashmem？ 

  * > 这里要如何使用？

* 通过`frameworks/base/libs/binder/Parcel.cpp`实现的本机内存共享： 
  * `void Parcel::writeBlob(size_t len，WritableBlob * outBlob)`
  * `status_t Parcel::readBlob(size_t len，ReadableBlob * outBlob)`

* 大致实现如下：

  客户端：

  ```cpp
  size_t len = 4096;
  int fd = ashmem_create_region("Parcel Blob", len); 
  ashmem_set_prot_region(fd, PROT_READ | PROT_WRITE);
  void* ptr = mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0); ashmem_set_prot_region(fd, PROT_READ);
  writeFileDescriptor(fd, true);
  // write into ptr for len as desired
  ...
  munmap(ptr, len);
  close(fd);
  ```

  服务：

  ```java
  int fd = readFileDescriptor();
  void* ptr = mmap(NULL, len, PROT_READ, MAP_SHARED, fd, 0); 
  // read from ptr up to len as desired
  ...
  munmap(ptr, len);
  ```

  > 移除了错误处理部分代码，另外  `writeFileDescriptor(...)` and `readFileDescriptor(...)` 由 libbinder 提供



# Binder 的限制

* Binder在每个进程中最多支持15各binder线程

  `frameworks/base/libs/binder/ProcessState.cpp`

  ```java
  static int open_driver() {
      int fd = open("/dev/binder", O_RDWR); 
      if (fd >= 0) {
      	...
  	    size_t maxThreads = 15;
      	result = ioctl(fd, BINDER_SET_MAX_THREADS, &maxThreads); 
          ...
      } else { 
          ...
  	}
  	return fd; 
  }
  ```

  * 需要避免阻塞Binder线程
  * 如果我们需要执行长时间运行的任务，最好生成我们自己的线程

* Binder将所有并发事务中每个进程的事务缓冲区的大小限制为1Mb 

  * 如果参数/返回值太大而无法放入此缓冲区，则抛出TransactionTooLargeException异常；
  * 由于此缓冲区是在给定流程中的所有事务之间共享的，因此许多中等大小的事务也可能耗尽其限制
  * 引发此异常时，我们无法判断是发送请求失败还是接收响应失败 
  * 保持较小的事务数据量 或 使用共享内存（ashmem） 





# Binder - 安全

* Binder直接处理“安全”问题，它启用了“受信任的”执行环境和DAC

* Binder驱动程序仅允许单个`CONTEXT_MGR`（即`servicemanager`）进行注册： 

  `drivers/staging/android/binder.c:`

  ```cpp
  static long binder_ioctl(struct file *filp, unsigned int cmd, unsigned long arg) 
  {
      ...
      switch (cmd) {
      ...
      case BINDER_SET_CONTEXT_MGR:
          if (binder_context_mgr_node != NULL) {
          printk(KERN_ERR "binder: BINDER_SET_CONTEXT_MGR already set\n"); 
          ret = -EBUSY;
          goto err;
      }
      ...
      binder_context_mgr_node = binder_new_node(proc, NULL, NULL); ...
  }
  ```

* 反过来，servicemanager仅允许从受信任的UID（例如`system`，`radio`，`media` 等等）：

  [`frameworks/base/cmds/servicemanager/service_manager.c:`](https://android.googlesource.com/platform/frameworks/base/+/master/cmds/servicemanager/service_manager.c)

  ```cpp
   ...
  static struct {
  unsigned uid;
  const char *name; } allowed[] = {
  #ifdef LVMX
  { AID_MEDIA,
  #endif
  { AID_MEDIA, { AID_MEDIA, { AID_MEDIA, { AID_MEDIA, { AID_DRM,
  { AID_NFC,
  { AID_RADIO, { AID_RADIO, { AID_RADIO, { AID_RADIO,
  "com.lifevibes.mx.ipc" },
  "media.audio_flinger" }, "media.player" }, "media.camera" }, "media.audio_policy" }, "drm.drmManager" }, "nfc" },
  "radio.phone" }, "radio.sms" }, "radio.phonesubinfo" }, "radio.simphonebook" },
  /* TODO: remove after phone services are updated: */ { AID_RADIO, "phone" },
  { AID_RADIO, "sip" },
  { AID_RADIO, "isms" },
  { AID_RADIO, "iphonesubinfo" },
  { AID_RADIO, "simphonebook" }, };
  ...
  int svc_can_register(unsigned uid, uint16_t *name) {
  unsigned n;
  if ((uid == 0) || (uid == AID_SYSTEM))
  return 1;
  for (n = 0; n < sizeof(allowed) / sizeof(allowed[0]); n++)
  if ((uid == allowed[n].uid) && str16eq(name, allowed[n].name))
  return 1; return 0;
  }
  ...
  int do_add_service(struct binder_state *bs,
  uint16_t *s, unsigned len, void *ptr, unsigned uid)
  {
  ...
  if (!svc_can_register(uid, s)) {
  LOGE("add_service('%s',%p) uid=%d - PERMISSION DENIED\n",
  str8(s), ptr, uid); return -1;
  }
  ... }
  ```

* 每个 Binder transaction 中都包含发送者的UID和PID，我们可以通过如下方法轻松地访问它们： 

  * `android.os.Binder.getCallingPid()`
  * `android.os.Binder.getCallingUid()`

* 在我们获取到了调用进程的UID之后，可以通过如下方法来获取其包名：
  
  * `PackageManager.getPackagesForUid(int uid)`
  
* 在我们获取到了调用方的app的包名之后，我们可以使用 `PackageManager.GET_PERMISSIONS` 标记 调用 `PackageManager.getPackageInfo(String packageName, int flags)` 查询该应用是否具有对应的权限；

* 不过，检查权限有一种更加简单的方式：
  * 使用 `Context.checkCallingOrSelfPermission(String permission)` ，如果返回 `PackageManager.PERMISSION_GRANTED` 则表示有权限，如果返回   `PackageManager.PERMISSION_DENIED` 这表示没有权限；
  * 也可以使用 `Context.enforceCallingPermission(String permission, String message)` 来检查权限，使用此方法时，如果没有权限，则会抛出一个 `SecurityException` 异常；

* 这就是许多应用程序框架服务强制执行其权限的过程

  <img src="../../../../../../../Application Support/typora-user-images/image-20210327110306188.png" alt="image-20210327110306188" style="zoom: 40%;" />

* 示例

  `frameworks/base/services/java/com/android/server/VibratorService.java`

  ```java
  package com.android.server;
      ...
  
  public class VibratorService extends IVibratorService.Stub {
      ...
  
      public void vibrate(long milliseconds, IBinder token) {
          if (mContext.checkCallingOrSelfPermission(android.Manifest.permission.VIBRATE) 
              != PackageManager.PERMISSION_GRANTED) {
              throw new SecurityException("Requires VIBRATE permission");
          }
      ...
      }
  ...
  }
  ```

  `frameworks/base/services/java/com/android/server/LocationManagerService.java`:

  ```java
  package com.android.server;
  ...
  
  public class LocationManagerService extends ILocationManager.Stub implements Runnable {
  ...
      private static final String ACCESS_FINE_LOCATION =
              android.Manifest.permission.ACCESS_FINE_LOCATION;
      private static final String ACCESS_COARSE_LOCATION =
              android.Manifest.permission.ACCESS_COARSE_LOCATION; ...
  
      private void checkPermissionsSafe(String provider) {
          if ((LocationManager.GPS_PROVIDER.equals(provider)
                  || LocationManager.PASSIVE_PROVIDER.equals(provider))
                  && (mContext.checkCallingOrSelfPermission(ACCESS_FINE_LOCATION)
                  != PackageManager.PERMISSION_GRANTED)) {
              throw new SecurityException("Provider " + provider
                      + " requires ACCESS_FINE_LOCATION permission");
          }
          if (LocationManager.NETWORK_PROVIDER.equals(provider)
                  && (mContext.checkCallingOrSelfPermission(ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED)
                  && (mContext.checkCallingOrSelfPermission(ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED)) {
              throw new SecurityException("Provider " + provider
                      + " requires ACCESS_FINE_LOCATION or ACCESS_COARSE_LOCATION permission");
          }
      }
  ...
  
      private Location _getLastKnownLocationLocked(String provider) {
          checkPermissionsSafe(provider);
  ...}
  ...
  
      public Location getLastKnownLocation(String provider) {
  ...
      	_getLastKnownLocationLocked(provider); 
      ...
      }
  }
   
  ```

  
  
  # Binder 死亡通知
  
  要给一个`IBinder` 对象引用，我们可以：
  
  * 通过 `Binder.isBinderAlive()` 和`Binder.pingBinder()` 来检查远程对象是否还是活的
  * 通过 `Binder.linkToDeath(IBinder.DeathRecipient recipient, int flags)` 请求注册监听.
  
  > 待补充



# Binder Reporting

Binder驱动通过 /proc/binder 来报告活动的/失败的事物中各种各样的状态：

* /proc/binder/failed_transaction_log
* /proc/binder/state
* /proc/binder/stats
* /proc/binder/transaction_log
* /proc/binder/transactions
* /proc/binder/proc/<pid>

> 如果设备上启用了 debugfs，则需要将 `/proc/binder` 替换为 `/sys/kernel/debug/kernel` 

