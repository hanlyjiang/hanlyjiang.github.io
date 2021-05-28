# Android Hook 技术——动态代理

参考：

* [Android Hook 技术——动态代理 - 简书 (jianshu.com)](https://www.jianshu.com/p/381256a35a90)
* [Android 动态代理以及利用动态代理实现 ServiceHook_Shawn_Dut的专栏-CSDN博客_android 动态代理](https://blog.csdn.net/self_study/article/details/55050627)
* [Android 静态代理和动态代理 看这一篇就够了_Android_大佬的博客-CSDN博客_android动态代理](https://blog.csdn.net/weixin_39079048/article/details/98852947)

## 如何正确理解反射和动态代理

- **反射** 主要是指程序可以访问，检测和修改它本身状态或行为的一种能力，并能根据自身行为的状态和结果，调整或修改应用所描述行为的状态和相关的语义
- **动态代理** 主要使用`反射机制`为其他对象提供一种代理以控制对这个对象的访问。某些情况下，一个对象不适合或者不能直接引用另一个对象，而代理对象可以再两者之间起到中介作用。运行阶段才指定代理哪个对象。



## 组成

- 抽象类接口
- 被代理类（具体实现抽象类接口的类）
- 动态代理类，实际调用被代理类的方法和属性



## 实现步骤

1. 定义一个委托类和公共接口。

2. 自己定义一个类（调用处理器类，即实现 `InvocationHandler 接口`），这个类的目的是**指定运行时将生成的代理类需要完成的具体任务，即代理类调用任何方法都会经过这个调用处理器类**。

3. 生成代理对象（当然也会生成代理类），需要为他指定
    (1) 委托对象
    (2) 实现的一系列接口
    (3) 调用处理器类的实例。因此可以看出一个代理对象对应一个委托对象，对应一个调用处理器实例。



## 动态代理 Proxy **/** InvocationHandler

在java的动态代理机制中，有两个重要的类和接口，一个是 InvocationHandler(Interface)、另一个则是 Proxy(Class)，这一个类和接口是实现我们动态代理所必须用到的。

每一个动态代理类都必须要实现InvocationHandler这个接口（代码中的中介），并且每个代理类的实例都关联到了一个handler，当我们通过代理对象调用一个方法的时候，这个方法的调用就会被转发为由InvocationHandler这个接口的 invoke（对方法的增强就写在这里面） 方法来进行调用。

### Java 实现动态代理主要涉及以下几个类：

java.lang.reflect.Proxy`: 这是生成代理类的主类，通过 `Proxy类` 生成的代理类都继承了 `Proxy 类

`java.lang.reflect.InvocationHandler`: 这里称他为"调用处理器"，他是一个接口，我们动态生成的代理类需要完成的具体内容需要自己定义一个类，而这个类必须实现`InvocationHandler 接口`。







## 问题

1. 代理了什么？类的方法？

### Proxy

提供用于创建动态代理类和实例的静态方法，也是通过此静态方法创建的动态代理类的父类；

创建某个接口的代理：

```java
     InvocationHandler handler = new MyInvocationHandler(...);
     Class<?> proxyClass = Proxy.getProxyClass(Foo.class.getClassLoader(), Foo.class);
     Foo f = (Foo) proxyClass.getConstructor(InvocationHandler.class).
                     newInstance(handler);
```

简单的写法：

```java
     Foo f = (Foo) Proxy.newProxyInstance(Foo.class.getClassLoader(),
                                          new Class<?>[] { Foo.class },
                                          handler);
```

动态代理类（以下简称为代理类）是一种类，该类实现创建类时在运行时指定的接口列表，其行为如下所述。

*代理接口* 是代理类实现的接口。

*代理实例* 是代理类的一个实例。

每个代理实例有一个相关联的 invocation handler对象，该对象实现了InvocationHandler接口。

通过代理接口调用代理实例的一个方法时，将会被分发到关联的invocation Handler对象的 `InvocationHandler#invoke` 方法上，同时将当前的代理实例，一个 标识当前所调用的方法的`java.lang.reflect.Method` 类型的对象及调用参数传递给invoke方法。

`InvocationHandler#invoke` 这处理方法调用，并且其返回值会作为代理实例的方法调用的返回值；





# 反射相关

## 杂项

设置静态成员的值：

```java
Field field = clazz.getDeclaredField(fieldName);
if (!field.isAccessible()) {
    field.setAccessible(true);
}
// 如果要设置的field是静态的，那么target会被忽略
field.set(target, fieldValue);
```







# 实例解决

错误日志：

```shell
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: Process: com.geo.mcp:plugin, PID: 14452[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: java.lang.NullPointerException: Attempt to invoke interface method 'boolean com.huawei.android.view.IHwWindowManager.isAppControlPolicyExists()' on a null object reference[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at com.huawei.android.view.HwWindowManager.isAppControlPolicyExists(HwWindowManager.java:504)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.app.Dialog.show(Dialog.java:388)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.app.ProgressDialog.show(ProgressDialog.java:190)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.app.ProgressDialog.show(ProgressDialog.java:164)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at com.geo.mcp.ui.LoginActivity.onStartLogin(LoginActivity.java:444)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at com.geo.mcp.ui.LoginActivity$LoginAsyncTask.onPreExecute(LoginActivity.java:615)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.os.AsyncTask.executeOnExecutor(AsyncTask.java:708)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.os.AsyncTask.execute(AsyncTask.java:655)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at com.geo.mcp.ui.LoginActivity.login(LoginActivity.java:286)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at com.geo.mcp.ui.LoginActivity.access$000(LoginActivity.java:62)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at com.geo.mcp.ui.LoginActivity$2.onClick(LoginActivity.java:183)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.view.View.performClick(View.java:7192)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.view.View.performClickInternal(View.java:7166)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.view.View.access$3500(View.java:824)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.view.View$PerformClick.run(View.java:27592)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.os.Handler.handleCallback(Handler.java:888)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.os.Handler.dispatchMessage(Handler.java:100)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.os.Looper.loop(Looper.java:213)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at android.app.ActivityThread.main(ActivityThread.java:8178)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at java.lang.reflect.Method.invoke(Native Method)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:513)[0m
[38;5;196m05-17 17:24:32.497 14452 14452 E AndroidRuntime: 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1101)[0m

```

主要错误片段：

```shell
AndroidRuntime: java.lang.NullPointerException: Attempt to invoke interface method 'boolean com.huawei.android.view.IHwWindowManager.isAppControlPolicyExists()' on a null object reference 
at com.huawei.android.view.HwWindowManager.isAppControlPolicyExists(HwWindowManager.java:504) 
at android.app.Dialog.show(Dialog.java:388)
```

及调用Dialog.show 时，WindowManager（HwWindowManager） 为空。



解决方法来说：

1. 插件中获取WindowManager的代码修正；
2. Dialog创建时修正其WindowManager；



问题：

1. 插件进程中如何获取的WindowManager？



# Android-Plugin-Framework源码阅读



源码地址： [limpoxe/Android-Plugin-Framework: Android插件框架，免安装运行插件APK ，支持独立插件和非独立插件 (github.com)](https://github.com/limpoxe/Android-Plugin-Framework)

## 源码阅读

### 如何给独立进程断点？

> [【Android】【代码调试】多进程情况下进行调试_命运之手-CSDN博客](https://blog.csdn.net/u013718730/article/details/105808604)
>
> [(1条消息) Android-0.调试技巧相关简介_hgy413的专栏-CSDN博客](https://blog.csdn.net/hgy413/article/details/94601730)

```java
Debug.waitForDebugger();
```



### 问题-1 插件进程创建时，使用的Application是哪个？

如下入口源码，发现其中有区分插件和宿主进程的插件初始化逻辑。那么我们只声明了一个Application，插件进程也会使用这个Application吗？

```java
public class DemoApplication extends Application {

   @Override
   protected void attachBaseContext(Context base) {
      super.attachBaseContext(base);

      //这个地方之所以这样写，是因为如果是插件进程，initloader必须在applicaiotn启动时执行
      //而如果是宿主进程，initloader可以在这里执行，也可以在需要时再在宿主的其他组件中执行，
      // 例如点击宿主的某个Activity中的button后再执行这个方法来启动插件框架。

      //总体原则有3点：
      //1、插件进程和宿主进程都必须有机会执行initloader
      //2、在插件进程和宿主进程的initloader方法都执行完毕之前，不可和插件交互
      //3、在插件进程和宿主进程的initlaoder方法都执行完毕之前启动的组件，即使在initloader都执行完毕之后，也不可和插件交互

      //如果initloader都在进程启动时就执行，自然很轻松满足上述条件。
      if (ProcessUtil.isPluginProcess(this)) {
         //插件进程，必须在这里执行initLoader
         PluginLoader.initLoader(this);
      } else {
         //宿主进程，可以在这里执行，也可以选择在宿主的其他地方在需要时再启动插件框架
         PluginLoader.initLoader(this);
      }
   }

   /**
    * 重写这个方法是为了支持Receiver,否则会出现ClassCast错误
    */
   @Override
   public Context getBaseContext() {
      return PluginLoader.fixBaseContextForReceiver(super.getBaseContext());
   }
}
```

根据我们之前的源码阅读可知，进程一定会对应一个Application对象，

## 插件原理总结

### 插件apk的class

```
通过构造插件apk的Dexclassloader来加载插件apk中的类。

DexClassLoader的parent设置为宿主程序的classloader，即可将主程序和插件程序的class贯通。

若是独立插件，将parent设置为宿主程序的classloader的parent，可隔离宿主class和插件class，此时宿主和插件可包含同名的class。
```

### 插件apk的Resource

```
直接构造插件apk的AssetManager和Resouce对象即可，需要注意的是，

通过addAssetsPath方法添加资源的时候，需要同时添加插件程序的资源文件和宿主程序的资源，

以及其依赖的资源。这样可以将Resource合并到一个Context里面去，解决资源访问时需要切换上下文的问题。
```

### 插件apk中的资源id冲突

```
完成上述第二点以后，宿主程序资源id和插件程序id可能有重复而参数冲突。
我们知道，资源id是在编译时生成的，其生成的规则是0xPPTTNNNN

PP段，是用来标记apk的，默认情况下系统资源PP是01f，应用程序的PP是07f

TT段，是用来标记资源类型的，比如图标、布局等，相同的类型TT值相同，但是同一个TT值

不代表同一种资源，例如这次编译的时候可能使用03作为layout的TT，那下次编译的时候可能
会使用06作为TT的值，具体使用那个值，实际上和当前APP使用的资源类型的个数是相关联的。
NNNN则是某种资源类型的资源id，默认从1开始，依次累加。

那么我们要解决资源id问题，就可从TT的值开始入手，只要将每次编译时的TT值固定，即可是资
源id达到分组的效果，从而避免重复。例如将宿主程序的layout资源的TT固定为33，将插件程序
资源的layout的TT值固定为03（也可不对插件程序的资源id做任何处理，使其使用编译出来的原生的值）, 即可解决资源id重复的问题了。

固定资源id的TT值的办法也非常简单，提供一份public.xml，在public.xml中指定什么资源类型以
什么TT值开头即可。具体public.xml如何编写，可参考FairyPlugin/public.xml，是用来固定宿主程序资源id范围的。

还有一个方法是通过定制过的aapt在编译插件时指定id范围来解决冲突（For-gradle-with-aapt分支采用的方案）
此方案需要替换sdk原生的aapt，且要区分多平台，buildTools版本更新后需同步升级aapt。
定制的aapt由 openAtlasExtention@github 项目提供，目前的版本是基于22.0.1，将项目中的BuildTools替换
到本地Android Sdk中相应版本的BuildTools中，并指定gradle的buildTools version为对应版本即可。
```

### 插件apk的Context和LayoutInfalter

```
构造一个Context对象即可，具体的Context实现请参考PluginContextTheme.java
关键是要重写几个获取资源、主题的方法，以及重写getClassLoader方法，再从构造粗来的context中获取LayoutInfalter
```

### 插件代码无约定无规范约束。

```
要做到这一点，主要有几点：
    
    1、上诉第4步骤，
    
    2、在classloader树中插入自己的Classloader，在loadclass时进行映射

    3、替换ActivityThread的的Instrumentation对象和Handle CallBack对象，用来拦截组件的创建过程。
    
    4、利用反射修改成员变量，注入Context。利用反射调用隐藏方法。
    
    5、插件中Activity等不在宿主manifest中注册即拥有完整生命周期的方法。

由于Activity等是系统组件，必须在manifest中注册才能被系统唤起并拥有完整生命周期。
通过反射代理方式实现的实际是伪生命周期，并非完整生命周期。要实现插件组件免注册有2个方法。

前提：宿主中预注册几个组件。预注册的组件可实际存在也可不存在。

a、替换classloader。适用于所有组件。
    App安装时，系统会扫描app的Manifest并缓存到一个xml中，activity启动时，系统会现在查找缓存的xml，
    如果查到了，再通过classLoad去load这个class，并构造一个activity实例。那么我们只需要将classload
    加载这个class的时候做一个简单的映射，让系统以为加载的是A class，而实际上加载的是B class，达到挂羊头买狗肉的效果，
    即可将预注册的A组件替换为未注册的插件中的B组件，从而实现插件中的组件
    完全被系统接管，而拥有完整生命周期。其他组件同理。


b、替换Instrumention。

    这种方式仅适用于Activity。通过修改Instrumentation进行拦截，可以利用Intent传递参数。

    如果是Receiver和Service，利用Handler Callback进行拦截，再配合Classloader在loadclass时进行映射
```

### 通过activity代理方式实现加载插件中的activity是如何实现的

```
要实现这一点，同样是基于上述第4点，构造出插件的Context后，通过attachBaseContext的方式，
替换代理Activiyt的context即可。

另外还需要在获得插件Activity对象后，通过反射给Activity的attach()方法中attach的成员变量赋值。

更新：activity代理方式已放弃，不再支持，要了解实现可以查看历史版本
```

### 插件主题

```
重要实现原理仍然基于上述第2、3点。
```

### 插件Activity的LaunchMode

```
要实现插件Activity的LaunchMode，需要在宿主程序中预埋若干个（standard只需1个）相应launchMode的Activity（预注
册的组件可实际存在也可不存在），在运行时进行动态映射选择。core工程的manifest中配置
```

### 对多Service的支持

```
Service的启动模式类似于Activity的singleInstance，因此为了支持插件多service，采用了和上述第12像类似的做法。
```

