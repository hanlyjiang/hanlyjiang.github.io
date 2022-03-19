# Android 单元测试研究



## 相关资料

* [Android单元测试研究与实践 - 美团技术团队 (meituan.com)](https://tech.meituan.com/2015/12/24/android-unit-test.html)





## 覆盖率统计（jacoco）

使用jacoco进行覆盖率统计。同时我们需要合并 androidTest 及 test 的覆盖率结果。

### 使用

直接 apply 一个构建脚本

```groovy
apply from: "https://github.com/hanlyjiang/AndroidTestSample/raw/main/jacoco.gradle"
```

### AGP版本导致的问题

- library 模块中 testDebugUnitTest 生成的exec 文件有误，从大小就可以看出来，生成的文件大小就不对，只有48B，而release的有几十KB。

  ```shell
  ~/Wksp/project/AndroidTestSample/lib-mod/build/outputs/unit_test_code_coverage/debugUnitTest $ ll
  -rw-r--r--  1 hanlyjiang  staff    48B Mar 17 22:50 testDebugUnitTest.exec
  ```

导致后续合并exec也会有问题。所以我们直接使用release的任务生成合并报告。

### 其他技巧

#### 覆盖率执行文件AS查看





## 问题解决记录

### 版本

- [Gradle | Releases](https://gradle.org/releases/)

### AGP 7.2.0-beta04 版本 app 模块执行问题

#### 错误日志

```shell
2022-03-17 21:50:56.712 31177-31177/com.github.hanlyjiang.sample.test E/AndroidRuntime: FATAL EXCEPTION: main
    Process: com.github.hanlyjiang.sample.test, PID: 31177
    java.lang.NoClassDefFoundError: Failed resolution of: Lorg/jacoco/agent/rt/internal_3570298/Offline;
        at androidx.test.core.app.InstrumentationActivityInvoker$BootstrapActivity.$jacocoInit(Unknown Source:13)
        at androidx.test.core.app.InstrumentationActivityInvoker$BootstrapActivity.<clinit>(Unknown Source:0)
        at java.lang.Class.newInstance(Native Method)
        at android.app.AppComponentFactory.instantiateActivity(AppComponentFactory.java:95)
        at android.app.Instrumentation.newActivity(Instrumentation.java:1285)
        at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3618)
        at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3882)
        at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:102)
        at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:135)
        at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:95)
        at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2272)
        at android.os.Handler.dispatchMessage(Handler.java:106)
        at android.os.Looper.loopOnce(Looper.java:201)
        at android.os.Looper.loop(Looper.java:288)
        at android.app.ActivityThread.main(ActivityThread.java:7902)
        at java.lang.reflect.Method.invoke(Native Method)
        at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:548)
        at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:933)
     Caused by: java.lang.ClassNotFoundException: Didn't find class "org.jacoco.agent.rt.internal_3570298.Offline" on path: DexPathList[[zip file "/data/app/~~rKi1913l8PkDBbNaJi6jZQ==/com.github.hanlyjiang.sample.test-NPx4e6i6BThTT6AeEB2wAw==/base.apk"],nativeLibraryDirectories=[/data/app/~~rKi1913l8PkDBbNaJi6jZQ==/com.github.hanlyjiang.sample.test-NPx4e6i6BThTT6AeEB2wAw==/lib/x86_64, /system/lib64, /system_ext/lib64]]
        at dalvik.system.BaseDexClassLoader.findClass(BaseDexClassLoader.java:259)
        at java.lang.ClassLoader.loadClass(ClassLoader.java:379)
        at java.lang.ClassLoader.loadClass(ClassLoader.java:312)
        at androidx.test.core.app.InstrumentationActivityInvoker$BootstrapActivity.$jacocoInit(Unknown Source:13) 
        at androidx.test.core.app.InstrumentationActivityInvoker$BootstrapActivity.<clinit>(Unknown Source:0) 
        at java.lang.Class.newInstance(Native Method) 
        at android.app.AppComponentFactory.instantiateActivity(AppComponentFactory.java:95) 
        at android.app.Instrumentation.newActivity(Instrumentation.java:1285) 
        at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3618) 
        at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3882) 
        at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:102) 
        at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:135) 
        at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:95) 
        at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2272) 
        at android.os.Handler.dispatchMessage(Handler.java:106) 
        at android.os.Looper.loopOnce(Looper.java:201) 
        at android.os.Looper.loop(Looper.java:288) 
        at android.app.ActivityThread.main(ActivityThread.java:7902) 
        at java.lang.reflect.Method.invoke(Native Method) 
        at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:548) 
        at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:933) 
```

#### 已测试有问题版本

- 7.2.0-betaxx

就是修好了 library模块，又破坏了 app 模块。

所以还是老老实实的用稳定版本吧。等待新的稳定版本发布后再使用。

