# Android插件化框架问题解决

## 问题

![C4093E75BD1AF826BA935C7FE548E963](../../../../../../../../Containers/com.tencent.qq/Data/Library/Caches/Images/C4093E75BD1AF826BA935C7FE548E963.png)

![1091DA40B8F3268BD56147798D66F604](../../../../../../../../Containers/com.tencent.qq/Data/Library/Caches/Images/1091DA40B8F3268BD56147798D66F604.png)

华为核心错误：

```shell
AndroidRuntime: java.lang.NullPointerException: Attempt to invoke interface method 'boolean com.huawei.android.view.IHwWindowManager.isAppControlPolicyExists()' on a null object reference 
at com.huawei.android.view.HwWindowManager.isAppControlPolicyExists(HwWindowManager.java:504) 
at android.app.Dialog.show(Dialog.java:388)
```



```shell
    Process: com.geostar.futian:plugin, PID: 17041
    java.lang.RuntimeException: Unable to start activity ComponentInfo{com.geostar.futian/com.geostar.georobox.stub.PluginStubActivityS10}: java.lang.RuntimeException:  activity : com.limpoxe.fairy.core.PluginClassLoader[DexPathList[[],nativeLibraryDirectories=[/system/lib, /system_ext/lib, /vendor/lib, /odm/lib]]] pluginContainer : null, process : true
        at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3692)
        at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3859)
        at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:85)
        at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:140)
        at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:100)
        at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2289)
        at com.limpoxe.fairy.core.PluginAppTrace.handleMessage(PluginAppTrace.java:45)
        at android.os.Handler.dispatchMessage(Handler.java:102)
        at android.os.Looper.loop(Looper.java:254)
        at android.app.ActivityThread.main(ActivityThread.java:8215)
        at java.lang.reflect.Method.invoke(Native Method)
        at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:612)
        at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1006)
     Caused by: java.lang.RuntimeException:  activity : com.limpoxe.fairy.core.PluginClassLoader[DexPathList[[],nativeLibraryDirectories=[/system/lib, /system_ext/lib, /vendor/lib, /odm/lib]]] pluginContainer : null, process : true
        at com.limpoxe.fairy.core.PluginInstrumentionWrapper.callActivityOnCreate(PluginInstrumentionWrapper.java:356)
        at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3661)
        at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3859) 
        at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:85) 
        at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:140) 
        at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:100) 
        at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2289) 
        at com.limpoxe.fairy.core.PluginAppTrace.handleMessage(PluginAppTrace.java:45) 
        at android.os.Handler.dispatchMessage(Handler.java:102) 
        at android.os.Looper.loop(Looper.java:254) 
        at android.app.ActivityThread.main(ActivityThread.java:8215) 
        at java.lang.reflect.Method.invoke(Native Method) 
        at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:612) 
        at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1006) 
     Caused by: java.lang.NullPointerException: Attempt to invoke interface method 'boolean android.os.IBinder.transact(int, android.os.Parcel, android.os.Parcel, int)' on a null object reference
        at android.view.OplusWindowManager.getNavBarOplusFromAdaptation(OplusWindowManager.java:532)
        at com.oplus.statusbar.OplusStatusBarController.getBarColorFromAdaptation(OplusStatusBarController.java:129)
        at com.oplus.statusbar.OplusStatusBarController.caculateSystemBarColor(OplusStatusBarController.java:73)
        at com.android.internal.policy.PhoneWindow.generateLayout(PhoneWindow.java:2498)
        at com.android.internal.policy.PhoneWindow.installDecor(PhoneWindow.java:2724)
        at com.android.internal.policy.PhoneWindow.getDecorView(PhoneWindow.java:2134)
        at android.support.v7.app.AppCompatDelegateImpl.createSubDecor(AppCompatDelegateImpl.java:575)
        at android.support.v7.app.AppCompatDelegateImpl.ensureSubDecor(AppCompatDelegateImpl.java:518)
        at android.support.v7.app.AppCompatDelegateImpl.findViewById(AppCompatDelegateImpl.java:403)
        at android.support.v7.app.AppCompatActivity.findViewById(AppCompatActivity.java:191)
        at com.geo.event.base.BaseActivity.setContentView(BaseActivity.java:145)
        at com.geo.event.base.BaseLoginActivity.onCreate(BaseLoginActivity.java:25)
        at android.app.Activity.performCreate(Activity.java:8146)
        at android.app.Activity.performCreate(Activity.java:8130)
        at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1310)
        at com.limpoxe.fairy.core.PluginInstrumentionWrapper.callActivityOnCreate(PluginInstrumentionWrapper.java:351)
        at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3661) 
        at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3859) 
        at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:85) 
        at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:140) 
        at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:100) 
        at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2289) 
        at com.limpoxe.fairy.core.PluginAppTrace.handleMessage(PluginAppTrace.java:45) 
        at android.os.Handler.dispatchMessage(Handler.java:102) 
        at android.os.Looper.loop(Looper.java:254) 
        at android.app.ActivityThread.main(ActivityThread.java:8215) 
        at java.lang.reflect.Method.invoke(Native Method) 
        at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:612) 
        at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1006) 
17041-17041 E/SFSDK-SangforAuth: [SangforAuth:vpnLogout:191] call logout failed, VPN没有初始化
```



## 解决

参考： [Android-Plugin-Framework-v0.70 · 标签 · 开发部 / 移动组 / 历史项目 / robox · GitLab](http://172.17.0.205/Development/Mobile/history/robox/-/tags/Android-Plugin-Framework-v0.70)

