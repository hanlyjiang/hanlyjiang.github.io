---

---



基于android11源码，分析activity的启动流程。

<!-- more -->

# startActivity过程分析

这里我们为了简化，使用的测试场景是先启动一个应用，然后在应用中打开一个Activity，也就是说我们不关注进程的创建；

## 分析方法论

🤔如何能够将这个流程尽可能清晰的表达出来，分析的时候通过何种路径呢？

一些路径：

* 调用栈
* 主要对象单元及交互关系
* 不同进程之间的关系
* 单元划分，拆小模块，厘清模块功能，绘图图示

## 整体流程

涉及到两个侧，APP进程和系统进程，总的来说，需要APP进程先发起启动请求，然后由`ActivityTaskManagerService`来处理对应的启动请求，然后交由`ActivityManagerService`来处理，最终再转交给APP的ApplicationThread来启动；

我们依次梳理APP侧调用栈，系统进程的调用栈，梳理出其中的关键单元；

1️⃣ -> 2️⃣ -> S1️⃣ 

### 涉及进程

* APP进程
* system_process 进程（AMS，ATMS）

### 关键对象

**APP进程：**

* `ActivityThread$H` - Handler
* `ActivityThread`
* `Instrumentation`
* `TransactionExecutor`
* `ClientTransaction`

**系统进程：**

* `ActivityStackSupervisor`
* `ClientLifecycleManager`
* `ClientTransaction`
* `ActivityTaskManagerService`
* `ActivityManagerService`

### ==问题==

1. ==消息循环如何获取消息，消息从何而来？Binder线程吗？==
   * 猜测是系统的其他进程（如触摸事件接收器）触发了对应的机制，发送消息到当前APP，然后触发了消息；

2. 

## 调用栈

### 调用栈

==问题：点击按钮后究竟执行的什么代码？==

==startActivity什么时候调用？==

1️⃣ 点击启动Activity按钮（==APP进程==）

click -> Instrumentation.execStartActivity

```java
"main@20113" prio=5 tid=0x1 nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	  at android.app.Instrumentation.execStartActivity(Instrumentation.java:1693)
	  at android.app.Activity.startActivityForResult(Activity.java:5320)
	  at androidx.fragment.app.FragmentActivity.startActivityForResult(FragmentActivity.java:676)
	  at android.app.Activity.startActivityForResult(Activity.java:5278)
	  at androidx.fragment.app.FragmentActivity.startActivityForResult(FragmentActivity.java:663)
	  at android.app.Activity.startActivity(Activity.java:5664)
	  at android.app.Activity.startActivity(Activity.java:5617)
	  at cn.hanlyjiang.library.base.BaseLauncherActivity.lambda$initRecyclerView$0$BaseLauncherActivity(BaseLauncherActivity.java:93)
	  at cn.hanlyjiang.library.base.-$$Lambda$BaseLauncherActivity$MKYTwLhUAWT7N61b0xnxtE15MCs.onItemClick(lambda:-1)
	  at com.chad.library.adapter.base.BaseQuickAdapter.setOnItemClick(BaseQuickAdapter.java:989)
	  at com.chad.library.adapter.base.BaseQuickAdapter$5.onClick(BaseQuickAdapter.java:968)
	  at android.view.View.performClick(View.java:7448)
	  at android.view.View.performClickInternal(View.java:7425)
	  at android.view.View.access$3600(View.java:810)
	  at android.view.View$PerformClick.run(View.java:28305)
	  at android.os.Handler.handleCallback(Handler.java:938)
	  at android.os.Handler.dispatchMessage(Handler.java:99)
	  at android.os.Looper.loop(Looper.java:223)
	  at android.app.ActivityThread.main(ActivityThread.java:7660)
	  at java.lang.reflect.Method.invoke(Method.java:-1)
	  at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
	  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
```



2️⃣ 启动Activity（==ATMS==）

```java
"Binder:556_C@27969" prio=5 tid=0x8d nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	 blocks android.fg@27871
	 blocks android.display@27854
	 blocks android.anim@27874
	 blocks ActivityManager@27878
	 blocks LazyTaskWriterThread@27965
	  at com.android.server.wm.ActivityRecord.transferStartingWindow(ActivityRecord.java:3371)
	  at com.android.server.wm.ActivityRecord.addStartingWindow(ActivityRecord.java:1802)
	  at com.android.server.wm.ActivityRecord.showStartingWindow(ActivityRecord.java:5737)
	  at com.android.server.wm.ActivityStack.startActivityLocked(ActivityStack.java:2118)
	  at com.android.server.wm.ActivityStarter.startActivityInner(ActivityStarter.java:1701)
	  at com.android.server.wm.ActivityStarter.startActivityUnchecked(ActivityStarter.java:1522)
	  at com.android.server.wm.ActivityStarter.executeRequest(ActivityStarter.java:1186)
	  at com.android.server.wm.ActivityStarter.execute(ActivityStarter.java:669)
	  - locked <0x6dae> (a com.android.server.wm.WindowManagerGlobalLock)
	  at com.android.server.wm.ActivityTaskManagerService.startActivityAsUser(ActivityTaskManagerService.java:1096)
	  at com.android.server.wm.ActivityTaskManagerService.startActivityAsUser(ActivityTaskManagerService.java:1068)
	  at com.android.server.wm.ActivityTaskManagerService.startActivity(ActivityTaskManagerService.java:1043)
	  at android.app.IActivityTaskManager$Stub.onTransact(IActivityTaskManager.java:1422)
	  at android.os.Binder.execTransactInternal(Binder.java:1154)
	  at android.os.Binder.execTransact(Binder.java:1123)
      
// display线程
"android.display@27854" prio=5 tid=0x16 nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	 blocks NetworkStats@27912
	 blocks LazyTaskWriterThread@27965
	  at com.android.server.wm.RootWindowContainer.resumeFocusedStacksTopActivities(RootWindowContainer.java:2299)
	  at com.android.server.wm.ActivityStack.completePauseLocked(ActivityStack.java:1209)
	  at com.android.server.wm.ActivityRecord.activityPaused(ActivityRecord.java:4949)
	  at com.android.server.wm.ActivityRecord$1.run(ActivityRecord.java:712)
	  - locked <0x7042> (a com.android.server.wm.WindowManagerGlobalLock)
	  at android.os.Handler.handleCallback(Handler.java:938)
	  at android.os.Handler.dispatchMessage(Handler.java:99)
	  at android.os.Looper.loop(Looper.java:223)
	  at android.os.HandlerThread.run(HandlerThread.java:67)
	  at com.android.server.ServiceThread.run(ServiceThread.java:44)
```

3️⃣ 构造`Activity`(==APP进程==): -- ==有问题🤨==

* 首先进程启动后主线程即进入消息循环♻️；⌛️等待消息来临，有消息到来之后即开始处理；

```shell
"main@20113" prio=5 tid=0x1 nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	  at android.app.Instrumentation.newActivity(Instrumentation.java:1251)
	  at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3335)
	  at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3595)
	  at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:85)
	  at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:135)
	  at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:95)
	  at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2066)
	  at android.os.Handler.dispatchMessage(Handler.java:106)
	  at android.os.Looper.loop(Looper.java:223)
	  at android.app.ActivityThread.main(ActivityThread.java:7660)
	  at java.lang.reflect.Method.invoke(Method.java:-1)
	  at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
	  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
```

4️⃣ 创建 `Activity`（==APP进程==）-- ==有问题🤨==

```java

```

5️⃣ 接收到系统进程的回调（传递的 `TopResumedActivityChangeItem{onTop=false}` ）

```java
"main@20113" prio=5 tid=0x1 nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	  at android.app.ActivityThread.handleTopResumedActivityChanged(ActivityThread.java:4594)
	  at android.app.servertransaction.TopResumedActivityChangeItem.execute(TopResumedActivityChangeItem.java:39) 
	  at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:135) // 这里会取出对应的 ClientTransaction 对象，然后获取其中的 mActivityCallbacks（ClientTransactionItem），执行其execute方法
	  at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:95)
	  at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2066)
	  at android.os.Handler.dispatchMessage(Handler.java:106)
	  at android.os.Looper.loop(Looper.java:223)
	  at android.app.ActivityThread.main(ActivityThread.java:7660)
	  at java.lang.reflect.Method.invoke(Method.java:-1)
	  at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
	  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
```











ClientTransaction的可用类型如下：

```java
ClientTransactionItem (android.app.servertransaction)
    StubItem in TransactionExecutorTests (android.app.servertransaction)
        PostExecItem in TransactionExecutorTests (android.app.servertransaction)
    ActivityRelaunchItem (android.app.servertransaction)
    ConfigurationChangeItem (android.app.servertransaction)
    EnterPipRequestedItem (android.app.servertransaction)
    ActivityConfigurationChangeItem (android.app.servertransaction)
    LaunchActivityItem (android.app.servertransaction)
    NewIntentItem (android.app.servertransaction)
    ActivityLifecycleItem (android.app.servertransaction)
        DestroyActivityItem (android.app.servertransaction)
        PauseActivityItem (android.app.servertransaction)
        StartActivityItem (android.app.servertransaction)
        StopActivityItem (android.app.servertransaction)
        ResumeActivityItem (android.app.servertransaction)
    ActivityResultItem (android.app.servertransaction)
    MoveToDisplayItem (android.app.servertransaction)
    FixedRotationAdjustmentsItem (android.app.servertransaction)
    TopResumedActivityChangeItem (android.app.servertransaction)

```



```java
"main@20113" prio=5 tid=0x1 nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	  at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:135)
	  at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:95)
	  at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2066)
	  at android.os.Handler.dispatchMessage(Handler.java:106)
	  at android.os.Looper.loop(Looper.java:223)
	  at android.app.ActivityThread.main(ActivityThread.java:7660)
	  at java.lang.reflect.Method.invoke(Method.java:-1)
	  at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
	  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
```

### 系统进程

1️⃣ APP进程启动 `Activity` 的请求发送到`ATMS`后： -> APP 3️⃣

```java
/** Target client. */
private IApplicationThread mClient;
public void schedule() throws RemoteException {
    mClient.scheduleTransaction(this);
}

"Binder:561_10@28441" prio=5 tid=0x33f nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	 blocks android.fg@27925
	 blocks android.display@27928
	 blocks android.anim@27929
	  at android.app.servertransaction.ClientTransaction.schedule(ClientTransaction.java:136) -- 发回给APP进程
	  at com.android.server.wm.ClientLifecycleManager.scheduleTransaction(ClientLifecycleManager.java:47)
	  at com.android.server.wm.ClientLifecycleManager.scheduleTransaction(ClientLifecycleManager.java:69)
	  at com.android.server.wm.ActivityStack.startPausingLocked(ActivityStack.java:1105)
	  at com.android.server.wm.TaskDisplayArea.pauseBackStacks(TaskDisplayArea.java:1200)
	  at com.android.server.wm.ActivityStack.resumeTopActivityInnerLocked(ActivityStack.java:1658)
	  at com.android.server.wm.ActivityStack.resumeTopActivityUncheckedLocked(ActivityStack.java:1507)
	  at com.android.server.wm.RootWindowContainer.resumeFocusedStacksTopActivities(RootWindowContainer.java:2306)
	  at com.android.server.wm.ActivityStarter.startActivityInner(ActivityStarter.java:1733)
	  at com.android.server.wm.ActivityStarter.startActivityUnchecked(ActivityStarter.java:1522)
	  at com.android.server.wm.ActivityStarter.executeRequest(ActivityStarter.java:1186)
	  at com.android.server.wm.ActivityStarter.execute(ActivityStarter.java:669)
	  - locked <0x6e63> (a com.android.server.wm.WindowManagerGlobalLock)
	  at com.android.server.wm.ActivityTaskManagerService.startActivityAsUser(ActivityTaskManagerService.java:1096)
	  at com.android.server.wm.ActivityTaskManagerService.startActivityAsUser(ActivityTaskManagerService.java:1068)
	  at com.android.server.wm.ActivityTaskManagerService.startActivity(ActivityTaskManagerService.java:1043) -- 接收到APP进程的启动请求
	  at android.app.IActivityTaskManager$Stub.onTransact(IActivityTaskManager.java:1422) 
	  at android.os.Binder.execTransactInternal(Binder.java:1154)
	  at android.os.Binder.execTransact(Binder.java:1123)
```



```java
"Binder:561_10@28441" prio=5 tid=0x33f nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	 blocks android.display@27928
	 blocks android.anim@27929
	 blocks LazyTaskWriterThread@28023
	 blocks android.fg@27925
	  at android.app.servertransaction.ClientTransaction.schedule(ClientTransaction.java:136)
	  at com.android.server.wm.ClientLifecycleManager.scheduleTransaction(ClientLifecycleManager.java:47)
	  at com.android.server.wm.ActivityStackSupervisor.realStartActivityLocked(ActivityStackSupervisor.java:868)
	  at com.android.server.wm.RootWindowContainer.startActivityForAttachedApplicationIfNeeded(RootWindowContainer.java:1972)
	  at com.android.server.wm.RootWindowContainer.lambda$5fbF65VSmaJkPHxEhceOGTat7JE(RootWindowContainer.java:-1)
	  at com.android.server.wm.-$$Lambda$RootWindowContainer$5fbF65VSmaJkPHxEhceOGTat7JE.apply(lambda:-1)
	  at com.android.internal.util.function.pooled.PooledLambdaImpl.doInvoke(PooledLambdaImpl.java:315)
	  at com.android.internal.util.function.pooled.PooledLambdaImpl.invoke(PooledLambdaImpl.java:201)
	  at com.android.internal.util.function.pooled.OmniFunction.apply(OmniFunction.java:78)
	  at com.android.server.wm.ActivityRecord.forAllActivities(ActivityRecord.java:3623)
	  at com.android.server.wm.WindowContainer.forAllActivities(WindowContainer.java:1331)
	  at com.android.server.wm.WindowContainer.forAllActivities(WindowContainer.java:1324)
	  at com.android.server.wm.RootWindowContainer.attachApplication(RootWindowContainer.java:1949)
	  at com.android.server.wm.ActivityTaskManagerService$LocalService.attachApplication(ActivityTaskManagerService.java:6888)
	  - locked <0x6e63> (a com.android.server.wm.WindowManagerGlobalLock)
	  at com.android.server.am.ActivityManagerService.attachApplicationLocked(ActivityManagerService.java:5362)
	  at com.android.server.am.ActivityManagerService.attachApplication(ActivityManagerService.java:5442)
	  - locked <0x6f79> (a com.android.server.am.ActivityManagerService)
	  at android.app.IActivityManager$Stub.onTransact(IActivityManager.java:2336)
	  at com.android.server.am.ActivityManagerService.onTransact(ActivityManagerService.java:2867)
	  at android.os.Binder.execTransactInternal(Binder.java:1154)
	  at android.os.Binder.execTransact(Binder.java:1123)
```



显示线程参与：

```java
"android.display@27928" prio=5 tid=0x16 nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	 blocks android.fg@27925
	  at android.app.servertransaction.ClientTransaction.schedule(ClientTransaction.java:136)
	  at com.android.server.wm.ClientLifecycleManager.scheduleTransaction(ClientLifecycleManager.java:47)
	  at com.android.server.wm.ClientLifecycleManager.scheduleTransaction(ClientLifecycleManager.java:69)
	  at com.android.server.wm.ActivityRecord.stopIfPossible(ActivityRecord.java:5038)
	  at com.android.server.wm.ActivityStackSupervisor.processStoppingAndFinishingActivities(ActivityStackSupervisor.java:1863)
	  at com.android.server.wm.ActivityStackSupervisor.activityIdleInternal(ActivityStackSupervisor.java:1326)
	  at com.android.server.wm.ActivityStackSupervisor$ActivityStackSupervisorHandler.activityIdleFromMessage(ActivityStackSupervisor.java:2377)
	  at com.android.server.wm.ActivityStackSupervisor$ActivityStackSupervisorHandler.handleMessageInner(ActivityStackSupervisor.java:2406)
	  at com.android.server.wm.ActivityStackSupervisor$ActivityStackSupervisorHandler.handleMessage(ActivityStackSupervisor.java:2351)
	  - locked <0x6e63> (a com.android.server.wm.WindowManagerGlobalLock)
	  at android.os.Handler.dispatchMessage(Handler.java:106)
	  at android.os.Looper.loop(Looper.java:223)
	  at android.os.HandlerThread.run(HandlerThread.java:67)
	  at com.android.server.ServiceThread.run(ServiceThread.java:44)

"Binder:561_D@28027" prio=5 tid=0x92 nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	  at com.android.server.wm.ActivityTaskManagerService.startActivity(ActivityTaskManagerService.java:1043)
	  at android.app.IActivityTaskManager$Stub.onTransact(IActivityTaskManager.java:1422)
	  at android.os.Binder.execTransactInternal(Binder.java:1154)
	  at android.os.Binder.execTransact(Binder.java:1123)
```





![image-20210421152205392](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210421152205.png)





## 详细分析

我们通过加入断点，可以方便的获取调用栈

* 创建Activity

```java
"main@20113" prio=5 tid=0x1 nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	  at android.app.Instrumentation.newActivity(Instrumentation.java:1251) - 创建Activity
	  at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3335)
	  at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3595)
	  at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:85)
	  at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:135)
	  at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:95)
	  at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2066)
	  at android.os.Handler.dispatchMessage(Handler.java:106)
	  at android.os.Looper.loop(Looper.java:223)
	  at android.app.ActivityThread.main(ActivityThread.java:7660)
	  at java.lang.reflect.Method.invoke(Method.java:-1)
	  at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
	  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
```

* attach

  ```java
  "main@20113" prio=5 tid=0x1 nid=NA runnable
    java.lang.Thread.State: RUNNABLE
  	  at android.app.Activity.attach(Activity.java:7899)
  	  at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3383)
  	  at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3595)
  	  at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:85)
  	  at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:135)
  	  at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:95)
  	  at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2066)
  	  at android.os.Handler.dispatchMessage(Handler.java:106)
  	  at android.os.Looper.loop(Looper.java:223)
  	  at android.app.ActivityThread.main(ActivityThread.java:7660)
  	  at java.lang.reflect.Method.invoke(Method.java:-1)
  	  at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
  	  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
  ```

  * attach 时还创建了PhoneWindow

    ```java
    // android.app.Activity#attach
       @UnsupportedAppUsage
        final void attach(Context context, ActivityThread aThread,
                Instrumentation instr, IBinder token, int ident,
                Application application, Intent intent, ActivityInfo info,
                CharSequence title, Activity parent, String id,
                NonConfigurationInstances lastNonConfigurationInstances,
                Configuration config, String referrer, IVoiceInteractor voiceInteractor,
                Window window, ActivityConfigCallback activityConfigCallback, IBinder assistToken) {
            attachBaseContext(context);
    
            mFragments.attachHost(null /*parent*/);
    
            mWindow = new PhoneWindow(this, window, activityConfigCallback);
            mWindow.setWindowControllerCallback(mWindowControllerCallback);
            mWindow.setCallback(this);
            mWindow.setOnWindowDismissedCallback(this);
            mWindow.getLayoutInflater().setPrivateFactory(this);
            if (info.softInputMode != WindowManager.LayoutParams.SOFT_INPUT_STATE_UNSPECIFIED) {
                mWindow.setSoftInputMode(info.softInputMode);
            }
            if (info.uiOptions != 0) {
                mWindow.setUiOptions(info.uiOptions);
            }
            // 赋值UI线程和主线程
            mUiThread = Thread.currentThread();
    
            mMainThread = aThread;
            mInstrumentation = instr;
            mToken = token;
            mAssistToken = assistToken;
            mIdent = ident;
            mApplication = application;
            mIntent = intent;
            mReferrer = referrer;
            mComponent = intent.getComponent();
            mActivityInfo = info;
            mTitle = title;
            mParent = parent;
            mEmbeddedID = id;
            mLastNonConfigurationInstances = lastNonConfigurationInstances;
            if (voiceInteractor != null) {
                if (lastNonConfigurationInstances != null) {
                    mVoiceInteractor = lastNonConfigurationInstances.voiceInteractor;
                } else {
                    mVoiceInteractor = new VoiceInteractor(voiceInteractor, this, this,
                            Looper.myLooper());
                }
            }
    
            mWindow.setWindowManager(
                    (WindowManager)context.getSystemService(Context.WINDOW_SERVICE),
                    mToken, mComponent.flattenToString(),
                    (info.flags & ActivityInfo.FLAG_HARDWARE_ACCELERATED) != 0);
            if (mParent != null) {
                mWindow.setContainer(mParent.getWindow());
            }
            mWindowManager = mWindow.getWindowManager();
            mCurrentConfig = config;
    
            mWindow.setColorMode(info.colorMode);
            mWindow.setPreferMinimalPostProcessing(
                    (info.flags & ActivityInfo.FLAG_PREFER_MINIMAL_POST_PROCESSING) != 0);
    
            setAutofillOptions(application.getAutofillOptions());
            setContentCaptureOptions(application.getContentCaptureOptions());
        }
    ```

* 回调 callActivityOnCreate

  ```java
  "main@20113" prio=5 tid=0x1 nid=NA runnable
    java.lang.Thread.State: RUNNABLE
  	  at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1308)
  	  at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3404)
  	  at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3595)
  	  at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:85)
  	  at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:135)
  	  at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:95)
  	  at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2066)
  	  at android.os.Handler.dispatchMessage(Handler.java:106)
  	  at android.os.Looper.loop(Looper.java:223)
  	  at android.app.ActivityThread.main(ActivityThread.java:7660)
  	  at java.lang.reflect.Method.invoke(Method.java:-1)
  	  at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:592)
  	  at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:947)
  ```

  ```java
  // android.app.Instrumentation#callActivityOnCreate(android.app.Activity, android.os.Bundle)
      public void callActivityOnCreate(Activity activity, Bundle icicle) {
          prePerformCreate(activity);
          activity.performCreate(icicle);
          postPerformCreate(activity);
      }
  ```




* 进程创建后，执行ActivityThread的main方法，然后进入到消息循环；

* 等待消息来临，发现启动Activity的消息；

  ```java
  case EXECUTE_TRANSACTION:
      final ClientTransaction transaction = (ClientTransaction) msg.obj;
      mTransactionExecutor.execute(transaction);
      if (isSystem()) {
          // Client transactions inside system process are recycled on the client side
          // instead of ClientLifecycleManager to avoid being cleared before this
          // message is handled.
          transaction.recycle();
      }
      // TODO(lifecycler): Recycle locally scheduled transactions.
      break;
  ```

  transaction的内容如下：为一个ClientTransaction对象，其中包含了一个ActivityCallbacks，其类型为ClientTransactionItem，我们可以看到这个callback列表中有一个LaunchActivityItem；![image-20210420221251198](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210420221251.png)





## 源码流程

### ContextImpl#startActivity

```java
// frameworks/base/core/java/android/app/ContextImpl.java
// android.app.ContextImpl#startActivity(android.content.Intent, android.os.Bundle)
@Override
    public void startActivity(Intent intent, Bundle options) {
        warnIfCallingFromSystemProcess();

        // Calling start activity from outside an activity without FLAG_ACTIVITY_NEW_TASK is
        // generally not allowed, except if the caller specifies the task id the activity should
        // be launched in. A bug was existed between N and O-MR1 which allowed this to work. We
        // maintain this for backwards compatibility.
        final int targetSdkVersion = getApplicationInfo().targetSdkVersion;

        if ((intent.getFlags() & Intent.FLAG_ACTIVITY_NEW_TASK) == 0
                && (targetSdkVersion < Build.VERSION_CODES.N
                        || targetSdkVersion >= Build.VERSION_CODES.P)
                && (options == null
                        || ActivityOptions.fromBundle(options).getLaunchTaskId() == -1)) {
            throw new AndroidRuntimeException(
                    "Calling startActivity() from outside of an Activity "
                            + " context requires the FLAG_ACTIVITY_NEW_TASK flag."
                            + " Is this really what you want?");
        }
        mMainThread.getInstrumentation().execStartActivity(
                getOuterContext(), mMainThread.getApplicationThread(), null,
                (Activity) null, intent, -1, options);
    }
```

### Instrumentation#execStartActivity: 

```java
// android.app.Instrumentation#execStartActivity(android.content.Context, android.os.IBinder, android.os.IBinder, android.app.Activity, android.content.Intent, int, android.os.Bundle)
public ActivityResult execStartActivity(
            Context who, IBinder contextThread, IBinder token, Activity target,
            Intent intent, int requestCode, Bundle options) {
        IApplicationThread whoThread = (IApplicationThread) contextThread;
        Uri referrer = target != null ? target.onProvideReferrer() : null;
        if (referrer != null) {
            intent.putExtra(Intent.EXTRA_REFERRER, referrer);
        }
        if (mActivityMonitors != null) {
            synchronized (mSync) {
                final int N = mActivityMonitors.size();
                for (int i=0; i<N; i++) {
                    final ActivityMonitor am = mActivityMonitors.get(i);
                    ActivityResult result = null;
                    if (am.ignoreMatchingSpecificIntents()) {
                        result = am.onStartActivity(intent);
                    }
                    if (result != null) {
                        am.mHits++;
                        return result;
                    } else if (am.match(who, null, intent)) {
                        am.mHits++;
                        if (am.isBlocking()) {
                            return requestCode >= 0 ? am.getResult() : null;
                        }
                        break;
                    }
                }
            }
        }
        try {
            intent.migrateExtraStreamToClipData(who);
            intent.prepareToLeaveProcess(who);
            int result = ActivityTaskManager.getService().startActivity(whoThread,
                    who.getBasePackageName(), who.getAttributionTag(), intent,
                    intent.resolveTypeIfNeeded(who.getContentResolver()), token,
                    target != null ? target.mEmbeddedID : null, requestCode, 0, null, options);
            checkStartActivityResult(result, intent);
        } catch (RemoteException e) {
            throw new RuntimeException("Failure from system", e);
        }
        return null;
    }
```

### ActivityTaskManager.getService().startActivity

```java
// com.android.server.wm.ActivityTaskManagerService#startActivity    
@Override
    public final int startActivity(IApplicationThread caller, String callingPackage,
            String callingFeatureId, Intent intent, String resolvedType, IBinder resultTo,
            String resultWho, int requestCode, int startFlags, ProfilerInfo profilerInfo,
            Bundle bOptions) {
        return startActivityAsUser(caller, callingPackage, callingFeatureId, intent, resolvedType,
                resultTo, resultWho, requestCode, startFlags, profilerInfo, bOptions,
                UserHandle.getCallingUserId());
    }

// com.android.server.wm.ActivityTaskManagerService#startActivityAsUser(android.app.IApplicationThread, java.lang.String, java.lang.String, android.content.Intent, java.lang.String, android.os.IBinder, java.lang.String, int, int, android.app.ProfilerInfo, android.os.Bundle, int, boolean)
    private int startActivityAsUser(IApplicationThread caller, String callingPackage,
            @Nullable String callingFeatureId, Intent intent, String resolvedType,
            IBinder resultTo, String resultWho, int requestCode, int startFlags,
            ProfilerInfo profilerInfo, Bundle bOptions, int userId, boolean validateIncomingUser) {
        assertPackageMatchesCallingUid(callingPackage);
        enforceNotIsolatedCaller("startActivityAsUser");

        userId = getActivityStartController().checkTargetUser(userId, validateIncomingUser,
                Binder.getCallingPid(), Binder.getCallingUid(), "startActivityAsUser");

        // TODO: Switch to user app stacks here.
        return getActivityStartController().obtainStarter(intent, "startActivityAsUser")
                .setCaller(caller)
                .setCallingPackage(callingPackage)
                .setCallingFeatureId(callingFeatureId)
                .setResolvedType(resolvedType)
                .setResultTo(resultTo)
                .setResultWho(resultWho)
                .setRequestCode(requestCode)
                .setStartFlags(startFlags)
                .setProfilerInfo(profilerInfo)
                .setActivityOptions(bOptions)
                .setUserId(userId)
                .execute();

    }
```

### ActivityStartController#execute:

```java
   /**
     * Resolve necessary information according the request parameters provided earlier, and execute
     * the request which begin the journey of starting an activity.
     * @return The starter result.
     */
    int execute() {
        try {
            // Refuse possible leaked file descriptors
            if (mRequest.intent != null && mRequest.intent.hasFileDescriptors()) {
                throw new IllegalArgumentException("File descriptors passed in Intent");
            }

            final LaunchingState launchingState;
            synchronized (mService.mGlobalLock) {
                final ActivityRecord caller = ActivityRecord.forTokenLocked(mRequest.resultTo);
                launchingState = mSupervisor.getActivityMetricsLogger().notifyActivityLaunching(
                        mRequest.intent, caller);
            }

            // If the caller hasn't already resolved the activity, we're willing
            // to do so here. If the caller is already holding the WM lock here,
            // and we need to check dynamic Uri permissions, then we're forced
            // to assume those permissions are denied to avoid deadlocking.
            if (mRequest.activityInfo == null) {
                mRequest.resolveActivity(mSupervisor);
            }

            int res;
            synchronized (mService.mGlobalLock) {
                final boolean globalConfigWillChange = mRequest.globalConfig != null
                        && mService.getGlobalConfiguration().diff(mRequest.globalConfig) != 0;
                final ActivityStack stack = mRootWindowContainer.getTopDisplayFocusedStack();
                if (stack != null) {
                    stack.mConfigWillChange = globalConfigWillChange;
                }
                if (DEBUG_CONFIGURATION) {
                    Slog.v(TAG_CONFIGURATION, "Starting activity when config will change = "
                            + globalConfigWillChange);
                }

                final long origId = Binder.clearCallingIdentity();

                res = resolveToHeavyWeightSwitcherIfNeeded();
                if (res != START_SUCCESS) {
                    return res;
                }
                res = executeRequest(mRequest);

                Binder.restoreCallingIdentity(origId);

                if (globalConfigWillChange) {
                    // If the caller also wants to switch to a new configuration, do so now.
                    // This allows a clean switch, as we are waiting for the current activity
                    // to pause (so we will not destroy it), and have not yet started the
                    // next activity.
                    mService.mAmInternal.enforceCallingPermission(
                            android.Manifest.permission.CHANGE_CONFIGURATION,
                            "updateConfiguration()");
                    if (stack != null) {
                        stack.mConfigWillChange = false;
                    }
                    if (DEBUG_CONFIGURATION) {
                        Slog.v(TAG_CONFIGURATION,
                                "Updating to new configuration after starting activity.");
                    }
                    mService.updateConfigurationLocked(mRequest.globalConfig, null, false);
                }

                // Notify ActivityMetricsLogger that the activity has launched.
                // ActivityMetricsLogger will then wait for the windows to be drawn and populate
                // WaitResult.
                mSupervisor.getActivityMetricsLogger().notifyActivityLaunched(launchingState, res,
                        mLastStartActivityRecord);
                return getExternalResult(mRequest.waitResult == null ? res
                        : waitForResult(res, mLastStartActivityRecord));
            }
        } finally {
            onExecutionComplete();
        }
    }

```

### executeRequest:

```java
    /**
     * Executing activity start request and starts the journey of starting an activity. Here
     * begins with performing several preliminary checks. The normally activity launch flow will
     * go through {@link #startActivityUnchecked} to {@link #startActivityInner}.
     */
    private int executeRequest(Request request) {
        if (TextUtils.isEmpty(request.reason)) {
            throw new IllegalArgumentException("Need to specify a reason.");
        }
        mLastStartReason = request.reason;
        mLastStartActivityTimeMs = System.currentTimeMillis();
        mLastStartActivityRecord = null;

        final IApplicationThread caller = request.caller;
        Intent intent = request.intent;
        NeededUriGrants intentGrants = request.intentGrants;
        String resolvedType = request.resolvedType;
        ActivityInfo aInfo = request.activityInfo;
        ResolveInfo rInfo = request.resolveInfo;
        final IVoiceInteractionSession voiceSession = request.voiceSession;
        final IBinder resultTo = request.resultTo;
        String resultWho = request.resultWho;
        int requestCode = request.requestCode;
        int callingPid = request.callingPid;
        int callingUid = request.callingUid;
        String callingPackage = request.callingPackage;
        String callingFeatureId = request.callingFeatureId;
        final int realCallingPid = request.realCallingPid;
        final int realCallingUid = request.realCallingUid;
        final int startFlags = request.startFlags;
        final SafeActivityOptions options = request.activityOptions;
        Task inTask = request.inTask;

        int err = ActivityManager.START_SUCCESS;
        // Pull the optional Ephemeral Installer-only bundle out of the options early.
        final Bundle verificationBundle =
                options != null ? options.popAppVerificationBundle() : null;

        WindowProcessController callerApp = null;
        if (caller != null) {
            callerApp = mService.getProcessController(caller);
            if (callerApp != null) {
                callingPid = callerApp.getPid();
                callingUid = callerApp.mInfo.uid;
            } else {
                Slog.w(TAG, "Unable to find app for caller " + caller + " (pid=" + callingPid
                        + ") when starting: " + intent.toString());
                err = ActivityManager.START_PERMISSION_DENIED;
            }
        }

        final int userId = aInfo != null && aInfo.applicationInfo != null
                ? UserHandle.getUserId(aInfo.applicationInfo.uid) : 0;
        if (err == ActivityManager.START_SUCCESS) {
            Slog.i(TAG, "START u" + userId + " {" + intent.toShortString(true, true, true, false)
                    + "} from uid " + callingUid);
        }

        ActivityRecord sourceRecord = null;
        ActivityRecord resultRecord = null;
        if (resultTo != null) {
            sourceRecord = mRootWindowContainer.isInAnyStack(resultTo);
            if (DEBUG_RESULTS) {
                Slog.v(TAG_RESULTS, "Will send result to " + resultTo + " " + sourceRecord);
            }
            if (sourceRecord != null) {
                if (requestCode >= 0 && !sourceRecord.finishing) {
                    resultRecord = sourceRecord;
                }
            }
        }

        final int launchFlags = intent.getFlags();
        if ((launchFlags & Intent.FLAG_ACTIVITY_FORWARD_RESULT) != 0 && sourceRecord != null) {
            // Transfer the result target from the source activity to the new one being started,
            // including any failures.
            if (requestCode >= 0) {
                SafeActivityOptions.abort(options);
                return ActivityManager.START_FORWARD_AND_REQUEST_CONFLICT;
            }
            resultRecord = sourceRecord.resultTo;
            if (resultRecord != null && !resultRecord.isInStackLocked()) {
                resultRecord = null;
            }
            resultWho = sourceRecord.resultWho;
            requestCode = sourceRecord.requestCode;
            sourceRecord.resultTo = null;
            if (resultRecord != null) {
                resultRecord.removeResultsLocked(sourceRecord, resultWho, requestCode);
            }
            if (sourceRecord.launchedFromUid == callingUid) {
                // The new activity is being launched from the same uid as the previous activity
                // in the flow, and asking to forward its result back to the previous.  In this
                // case the activity is serving as a trampoline between the two, so we also want
                // to update its launchedFromPackage to be the same as the previous activity.
                // Note that this is safe, since we know these two packages come from the same
                // uid; the caller could just as well have supplied that same package name itself
                // . This specifially deals with the case of an intent picker/chooser being
                // launched in the app flow to redirect to an activity picked by the user, where
                // we want the final activity to consider it to have been launched by the
                // previous app activity.
                callingPackage = sourceRecord.launchedFromPackage;
                callingFeatureId = sourceRecord.launchedFromFeatureId;
            }
        }

        if (err == ActivityManager.START_SUCCESS && intent.getComponent() == null) {
            // We couldn't find a class that can handle the given Intent.
            // That's the end of that!
            err = ActivityManager.START_INTENT_NOT_RESOLVED;
        }

        if (err == ActivityManager.START_SUCCESS && aInfo == null) {
            // We couldn't find the specific class specified in the Intent.
            // Also the end of the line.
            err = ActivityManager.START_CLASS_NOT_FOUND;
        }

        if (err == ActivityManager.START_SUCCESS && sourceRecord != null
                && sourceRecord.getTask().voiceSession != null) {
            // If this activity is being launched as part of a voice session, we need to ensure
            // that it is safe to do so.  If the upcoming activity will also be part of the voice
            // session, we can only launch it if it has explicitly said it supports the VOICE
            // category, or it is a part of the calling app.
            if ((launchFlags & FLAG_ACTIVITY_NEW_TASK) == 0
                    && sourceRecord.info.applicationInfo.uid != aInfo.applicationInfo.uid) {
                try {
                    intent.addCategory(Intent.CATEGORY_VOICE);
                    if (!mService.getPackageManager().activitySupportsIntent(
                            intent.getComponent(), intent, resolvedType)) {
                        Slog.w(TAG, "Activity being started in current voice task does not support "
                                + "voice: " + intent);
                        err = ActivityManager.START_NOT_VOICE_COMPATIBLE;
                    }
                } catch (RemoteException e) {
                    Slog.w(TAG, "Failure checking voice capabilities", e);
                    err = ActivityManager.START_NOT_VOICE_COMPATIBLE;
                }
            }
        }

        if (err == ActivityManager.START_SUCCESS && voiceSession != null) {
            // If the caller is starting a new voice session, just make sure the target
            // is actually allowing it to run this way.
            try {
                if (!mService.getPackageManager().activitySupportsIntent(intent.getComponent(),
                        intent, resolvedType)) {
                    Slog.w(TAG,
                            "Activity being started in new voice task does not support: " + intent);
                    err = ActivityManager.START_NOT_VOICE_COMPATIBLE;
                }
            } catch (RemoteException e) {
                Slog.w(TAG, "Failure checking voice capabilities", e);
                err = ActivityManager.START_NOT_VOICE_COMPATIBLE;
            }
        }

        final ActivityStack resultStack = resultRecord == null
                ? null : resultRecord.getRootTask();

        if (err != START_SUCCESS) {
            if (resultRecord != null) {
                resultRecord.sendResult(INVALID_UID, resultWho, requestCode, RESULT_CANCELED,
                        null /* data */, null /* dataGrants */);
            }
            SafeActivityOptions.abort(options);
            return err;
        }

        boolean abort = !mSupervisor.checkStartAnyActivityPermission(intent, aInfo, resultWho,
                requestCode, callingPid, callingUid, callingPackage, callingFeatureId,
                request.ignoreTargetSecurity, inTask != null, callerApp, resultRecord, resultStack);
        abort |= !mService.mIntentFirewall.checkStartActivity(intent, callingUid,
                callingPid, resolvedType, aInfo.applicationInfo);
        abort |= !mService.getPermissionPolicyInternal().checkStartActivity(intent, callingUid,
                callingPackage);

        boolean restrictedBgActivity = false;
        if (!abort) {
            try {
                Trace.traceBegin(Trace.TRACE_TAG_WINDOW_MANAGER,
                        "shouldAbortBackgroundActivityStart");
                restrictedBgActivity = shouldAbortBackgroundActivityStart(callingUid,
                        callingPid, callingPackage, realCallingUid, realCallingPid, callerApp,
                        request.originatingPendingIntent, request.allowBackgroundActivityStart,
                        intent);
            } finally {
                Trace.traceEnd(Trace.TRACE_TAG_WINDOW_MANAGER);
            }
        }

        // Merge the two options bundles, while realCallerOptions takes precedence.
        ActivityOptions checkedOptions = options != null
                ? options.getOptions(intent, aInfo, callerApp, mSupervisor) : null;
        if (request.allowPendingRemoteAnimationRegistryLookup) {
            checkedOptions = mService.getActivityStartController()
                    .getPendingRemoteAnimationRegistry()
                    .overrideOptionsIfNeeded(callingPackage, checkedOptions);
        }
        if (mService.mController != null) {
            try {
                // The Intent we give to the watcher has the extra data stripped off, since it
                // can contain private information.
                Intent watchIntent = intent.cloneFilter();
                abort |= !mService.mController.activityStarting(watchIntent,
                        aInfo.applicationInfo.packageName);
            } catch (RemoteException e) {
                mService.mController = null;
            }
        }

        mInterceptor.setStates(userId, realCallingPid, realCallingUid, startFlags, callingPackage,
                callingFeatureId);
        if (mInterceptor.intercept(intent, rInfo, aInfo, resolvedType, inTask, callingPid,
                callingUid, checkedOptions)) {
            // activity start was intercepted, e.g. because the target user is currently in quiet
            // mode (turn off work) or the target application is suspended
            intent = mInterceptor.mIntent;
            rInfo = mInterceptor.mRInfo;
            aInfo = mInterceptor.mAInfo;
            resolvedType = mInterceptor.mResolvedType;
            inTask = mInterceptor.mInTask;
            callingPid = mInterceptor.mCallingPid;
            callingUid = mInterceptor.mCallingUid;
            checkedOptions = mInterceptor.mActivityOptions;

            // The interception target shouldn't get any permission grants
            // intended for the original destination
            intentGrants = null;
        }

        if (abort) {
            if (resultRecord != null) {
                resultRecord.sendResult(INVALID_UID, resultWho, requestCode, RESULT_CANCELED,
                        null /* data */, null /* dataGrants */);
            }
            // We pretend to the caller that it was really started, but they will just get a
            // cancel result.
            ActivityOptions.abort(checkedOptions);
            return START_ABORTED;
        }

        // If permissions need a review before any of the app components can run, we
        // launch the review activity and pass a pending intent to start the activity
        // we are to launching now after the review is completed.
        if (aInfo != null) {
            if (mService.getPackageManagerInternalLocked().isPermissionsReviewRequired(
                    aInfo.packageName, userId)) {
                final IIntentSender target = mService.getIntentSenderLocked(
                        ActivityManager.INTENT_SENDER_ACTIVITY, callingPackage, callingFeatureId,
                        callingUid, userId, null, null, 0, new Intent[]{intent},
                        new String[]{resolvedType}, PendingIntent.FLAG_CANCEL_CURRENT
                                | PendingIntent.FLAG_ONE_SHOT, null);

                Intent newIntent = new Intent(Intent.ACTION_REVIEW_PERMISSIONS);

                int flags = intent.getFlags();
                flags |= Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS;

                /*
                 * Prevent reuse of review activity: Each app needs their own review activity. By
                 * default activities launched with NEW_TASK or NEW_DOCUMENT try to reuse activities
                 * with the same launch parameters (extras are ignored). Hence to avoid possible
                 * reuse force a new activity via the MULTIPLE_TASK flag.
                 *
                 * Activities that are not launched with NEW_TASK or NEW_DOCUMENT are not re-used,
                 * hence no need to add the flag in this case.
                 */
                if ((flags & (FLAG_ACTIVITY_NEW_TASK | FLAG_ACTIVITY_NEW_DOCUMENT)) != 0) {
                    flags |= Intent.FLAG_ACTIVITY_MULTIPLE_TASK;
                }
                newIntent.setFlags(flags);

                newIntent.putExtra(Intent.EXTRA_PACKAGE_NAME, aInfo.packageName);
                newIntent.putExtra(Intent.EXTRA_INTENT, new IntentSender(target));
                if (resultRecord != null) {
                    newIntent.putExtra(Intent.EXTRA_RESULT_NEEDED, true);
                }
                intent = newIntent;

                // The permissions review target shouldn't get any permission
                // grants intended for the original destination
                intentGrants = null;

                resolvedType = null;
                callingUid = realCallingUid;
                callingPid = realCallingPid;

                rInfo = mSupervisor.resolveIntent(intent, resolvedType, userId, 0,
                        computeResolveFilterUid(
                                callingUid, realCallingUid, request.filterCallingUid));
                aInfo = mSupervisor.resolveActivity(intent, rInfo, startFlags,
                        null /*profilerInfo*/);

                if (DEBUG_PERMISSIONS_REVIEW) {
                    final ActivityStack focusedStack =
                            mRootWindowContainer.getTopDisplayFocusedStack();
                    Slog.i(TAG, "START u" + userId + " {" + intent.toShortString(true, true,
                            true, false) + "} from uid " + callingUid + " on display "
                            + (focusedStack == null ? DEFAULT_DISPLAY
                                    : focusedStack.getDisplayId()));
                }
            }
        }

        // If we have an ephemeral app, abort the process of launching the resolved intent.
        // Instead, launch the ephemeral installer. Once the installer is finished, it
        // starts either the intent we resolved here [on install error] or the ephemeral
        // app [on install success].
        if (rInfo != null && rInfo.auxiliaryInfo != null) {
            intent = createLaunchIntent(rInfo.auxiliaryInfo, request.ephemeralIntent,
                    callingPackage, callingFeatureId, verificationBundle, resolvedType, userId);
            resolvedType = null;
            callingUid = realCallingUid;
            callingPid = realCallingPid;

            // The ephemeral installer shouldn't get any permission grants
            // intended for the original destination
            intentGrants = null;

            aInfo = mSupervisor.resolveActivity(intent, rInfo, startFlags, null /*profilerInfo*/);
        }

        final ActivityRecord r = new ActivityRecord(mService, callerApp, callingPid, callingUid,
                callingPackage, callingFeatureId, intent, resolvedType, aInfo,
                mService.getGlobalConfiguration(), resultRecord, resultWho, requestCode,
                request.componentSpecified, voiceSession != null, mSupervisor, checkedOptions,
                sourceRecord);
        mLastStartActivityRecord = r;

        if (r.appTimeTracker == null && sourceRecord != null) {
            // If the caller didn't specify an explicit time tracker, we want to continue
            // tracking under any it has.
            r.appTimeTracker = sourceRecord.appTimeTracker;
        }

        final ActivityStack stack = mRootWindowContainer.getTopDisplayFocusedStack();

        // If we are starting an activity that is not from the same uid as the currently resumed
        // one, check whether app switches are allowed.
        if (voiceSession == null && stack != null && (stack.getResumedActivity() == null
                || stack.getResumedActivity().info.applicationInfo.uid != realCallingUid)) {
            if (!mService.checkAppSwitchAllowedLocked(callingPid, callingUid,
                    realCallingPid, realCallingUid, "Activity start")) {
                if (!(restrictedBgActivity && handleBackgroundActivityAbort(r))) {
                    mController.addPendingActivityLaunch(new PendingActivityLaunch(r,
                            sourceRecord, startFlags, stack, callerApp, intentGrants));
                }
                ActivityOptions.abort(checkedOptions);
                return ActivityManager.START_SWITCHES_CANCELED;
            }
        }

        mService.onStartActivitySetDidAppSwitch();
        mController.doPendingActivityLaunches(false);

        mLastStartActivityResult = startActivityUnchecked(r, sourceRecord, voiceSession,
                request.voiceInteractor, startFlags, true /* doResume */, checkedOptions, inTask,
                restrictedBgActivity, intentGrants);

        if (request.outActivity != null) {
            request.outActivity[0] = mLastStartActivityRecord;
        }

        return mLastStartActivityResult;
    }
```

### startActivityUnchecked:

```java
// com.android.server.wm.ActivityStarter#startActivityUnchecked  
/**
     * Start an activity while most of preliminary checks has been done and caller has been
     * confirmed that holds necessary permissions to do so.
     * Here also ensures that the starting activity is removed if the start wasn't successful.
     */
    private int startActivityUnchecked(final ActivityRecord r, ActivityRecord sourceRecord,
                IVoiceInteractionSession voiceSession, IVoiceInteractor voiceInteractor,
                int startFlags, boolean doResume, ActivityOptions options, Task inTask,
                boolean restrictedBgActivity, NeededUriGrants intentGrants) {
        int result = START_CANCELED;
        final ActivityStack startedActivityStack;
        try {
            mService.deferWindowLayout();
            Trace.traceBegin(Trace.TRACE_TAG_WINDOW_MANAGER, "startActivityInner");
            result = startActivityInner(r, sourceRecord, voiceSession, voiceInteractor,
                    startFlags, doResume, options, inTask, restrictedBgActivity, intentGrants);
        } finally {
            Trace.traceEnd(Trace.TRACE_TAG_WINDOW_MANAGER);
            startedActivityStack = handleStartResult(r, result);
            mService.continueWindowLayout();
        }

        postStartActivityProcessing(r, result, startedActivityStack);

        return result;
    }
```



### ActivityStarter#startActivityInner

```java

    // TODO(b/152429287): Make it easier to exercise code paths through startActivityInner
    @VisibleForTesting
    int startActivityInner(final ActivityRecord r, ActivityRecord sourceRecord,
            IVoiceInteractionSession voiceSession, IVoiceInteractor voiceInteractor,
            int startFlags, boolean doResume, ActivityOptions options, Task inTask,
            boolean restrictedBgActivity, NeededUriGrants intentGrants) {
        setInitialState(r, options, inTask, doResume, startFlags, sourceRecord, voiceSession,
                voiceInteractor, restrictedBgActivity);        
		mTargetStack.startActivityLocked(mStartActivity,
                topStack != null ? topStack.getTopNonFinishingActivity() : null, newTask,
                mKeepCurTransition, mOptions);
        if (mDoResume) {
            final ActivityRecord topTaskActivity =
                    mStartActivity.getTask().topRunningActivityLocked();
            if (!mTargetStack.isTopActivityFocusable()
                    || (topTaskActivity != null && topTaskActivity.isTaskOverlay()
                    && mStartActivity != topTaskActivity)) {
                // If the activity is not focusable, we can't resume it, but still would like to
                // make sure it becomes visible as it starts (this will also trigger entry
                // animation). An example of this are PIP activities.
                // Also, we don't want to resume activities in a task that currently has an overlay
                // as the starting activity just needs to be in the visible paused state until the
                // over is removed.
                // Passing {@code null} as the start parameter ensures all activities are made
                // visible.
                mTargetStack.ensureActivitiesVisible(null /* starting */,
                        0 /* configChanges */, !PRESERVE_WINDOWS);
                // Go ahead and tell window manager to execute app transition for this activity
                // since the app transition will not be triggered through the resume channel.
                mTargetStack.getDisplay().mDisplayContent.executeAppTransition();
            } else {
                // If the target stack was not previously focusable (previous top running activity
                // on that stack was not visible) then any prior calls to move the stack to the
                // will not update the focused stack.  If starting the new activity now allows the
                // task stack to be focusable, then ensure that we now update the focused stack
                // accordingly.
                if (mTargetStack.isTopActivityFocusable()
                        && !mRootWindowContainer.isTopDisplayFocusedStack(mTargetStack)) {
                    mTargetStack.moveToFront("startActivityInner");
                }
                mRootWindowContainer.resumeFocusedStacksTopActivities(
                        mTargetStack, mStartActivity, mOptions);
            }
        }
        mRootWindowContainer.updateUserStack(mStartActivity.mUserId, mTargetStack);

        // Update the recent tasks list immediately when the activity starts
        mSupervisor.mRecentTasks.add(mStartActivity.getTask());
        mSupervisor.handleNonResizableTaskIfNeeded(mStartActivity.getTask(),
                mPreferredWindowingMode, mPreferredTaskDisplayArea, mTargetStack);

        return START_SUCCESS;
    }
```

### com.android.server.wm.ActivityStack#startActivityLocked

```java
    void startActivityLocked(ActivityRecord r, @Nullable ActivityRecord focusedTopActivity,
            boolean newTask, boolean keepCurTransition, ActivityOptions options) {
        Task rTask = r.getTask();
        final boolean allowMoveToFront = options == null || !options.getAvoidMoveToFront();
        final boolean isOrhasTask = rTask == this || hasChild(rTask);
        // mLaunchTaskBehind tasks get placed at the back of the task stack.
        if (!r.mLaunchTaskBehind && allowMoveToFront && (!isOrhasTask || newTask)) {
            // Last activity in task had been removed or ActivityManagerService is reusing task.
            // Insert or replace.
            // Might not even be in.
            positionChildAtTop(rTask);
        }
        Task task = null;
        if (!newTask && isOrhasTask) {
            // Starting activity cannot be occluding activity, otherwise starting window could be
            // remove immediately without transferring to starting activity.
            final ActivityRecord occludingActivity = getOccludingActivityAbove(r);
            if (occludingActivity != null) {
                // Here it is!  Now, if this is not yet visible (occluded by another task) to the
                // user, then just add it without starting; it will get started when the user
                // navigates back to it.
                if (DEBUG_ADD_REMOVE) Slog.i(TAG, "Adding activity " + r + " to task " + task,
                        new RuntimeException("here").fillInStackTrace());
                rTask.positionChildAtTop(r);
                ActivityOptions.abort(options);
                return;
            }
        }

        // Place a new activity at top of stack, so it is next to interact with the user.

        // If we are not placing the new activity frontmost, we do not want to deliver the
        // onUserLeaving callback to the actual frontmost activity
        final Task activityTask = r.getTask();
        if (task == activityTask && mChildren.indexOf(task) != (getChildCount() - 1)) {
            mStackSupervisor.mUserLeaving = false;
            if (DEBUG_USER_LEAVING) Slog.v(TAG_USER_LEAVING,
                    "startActivity() behind front, mUserLeaving=false");
        }

        task = activityTask;

        // Slot the activity into the history stack and proceed
        if (DEBUG_ADD_REMOVE) Slog.i(TAG, "Adding activity " + r + " to stack to task " + task,
                new RuntimeException("here").fillInStackTrace());
        task.positionChildAtTop(r);

        // The transition animation and starting window are not needed if {@code allowMoveToFront}
        // is false, because the activity won't be visible.
        if ((!isHomeOrRecentsStack() || hasActivity()) && allowMoveToFront) {
            final DisplayContent dc = getDisplay().mDisplayContent;
            if (DEBUG_TRANSITION) Slog.v(TAG_TRANSITION,
                    "Prepare open transition: starting " + r);
            if ((r.intent.getFlags() & Intent.FLAG_ACTIVITY_NO_ANIMATION) != 0) {
                dc.prepareAppTransition(TRANSIT_NONE, keepCurTransition);
                mStackSupervisor.mNoAnimActivities.add(r);
            } else {
                int transit = TRANSIT_ACTIVITY_OPEN;
                if (newTask) {
                    if (r.mLaunchTaskBehind) {
                        transit = TRANSIT_TASK_OPEN_BEHIND;
                    } else if (getDisplay().isSingleTaskInstance()) {
                        // If a new task is being launched in a single task display, we don't need
                        // to play normal animation, but need to trigger a callback when an app
                        // transition is actually handled. So ignore already prepared activity, and
                        // override it.
                        transit = TRANSIT_SHOW_SINGLE_TASK_DISPLAY;
                        keepCurTransition = false;
                    } else {
                        // If a new task is being launched, then mark the existing top activity as
                        // supporting picture-in-picture while pausing only if the starting activity
                        // would not be considered an overlay on top of the current activity
                        // (eg. not fullscreen, or the assistant)
                        if (canEnterPipOnTaskSwitch(focusedTopActivity,
                                null /* toFrontTask */, r, options)) {
                            focusedTopActivity.supportsEnterPipOnTaskSwitch = true;
                        }
                        transit = TRANSIT_TASK_OPEN;
                    }
                }
                dc.prepareAppTransition(transit, keepCurTransition);
                mStackSupervisor.mNoAnimActivities.remove(r);
            }
            boolean doShow = true;
            if (newTask) {
                // Even though this activity is starting fresh, we still need
                // to reset it to make sure we apply affinities to move any
                // existing activities from other tasks in to it.
                // If the caller has requested that the target task be
                // reset, then do so.
                if ((r.intent.getFlags() & Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED) != 0) {
                    resetTaskIfNeeded(r, r);
                    doShow = topRunningNonDelayedActivityLocked(null) == r;
                }
            } else if (options != null && options.getAnimationType()
                    == ActivityOptions.ANIM_SCENE_TRANSITION) {
                doShow = false;
            }
            if (r.mLaunchTaskBehind) {
                // Don't do a starting window for mLaunchTaskBehind. More importantly make sure we
                // tell WindowManager that r is visible even though it is at the back of the stack.
                r.setVisibility(true);
                ensureActivitiesVisible(null, 0, !PRESERVE_WINDOWS);
                // Go ahead to execute app transition for this activity since the app transition
                // will not be triggered through the resume channel.
                getDisplay().mDisplayContent.executeAppTransition();
            } else if (SHOW_APP_STARTING_PREVIEW && doShow) {
                // Figure out if we are transitioning from another activity that is
                // "has the same starting icon" as the next one.  This allows the
                // window manager to keep the previous window it had previously
                // created, if it still had one.
                Task prevTask = r.getTask();
                ActivityRecord prev = prevTask.topActivityWithStartingWindow();
                if (prev != null) {
                    // We don't want to reuse the previous starting preview if:
                    // (1) The current activity is in a different task.
                    if (prev.getTask() != prevTask) {
                        prev = null;
                    }
                    // (2) The current activity is already displayed.
                    else if (prev.nowVisible) {
                        prev = null;
                    }
                }
                r.showStartingWindow(prev, newTask, isTaskSwitch(r, focusedTopActivity));
            }
        } else {
            // If this is the first activity, don't do any fancy animations,
            // because there is nothing for it to animate on top of.
            ActivityOptions.abort(options);
        }
    }
```

### com.android.server.wm.Task#positionChildAtTop

```java
    void positionChildAtTop(ActivityRecord child) {
        positionChildAt(child, POSITION_TOP);
    }

// com.android.server.wm.Task#positionChildAt(int, com.android.server.wm.WindowContainer, boolean)
    @Override
    void positionChildAt(int position, WindowContainer child, boolean includingParents) {
        position = getAdjustedChildPosition(child, position);
        super.positionChildAt(position, child, includingParents);

        // Log positioning.
        if (DEBUG_TASK_MOVEMENT) Slog.d(TAG_WM, "positionChildAt: child=" + child
                + " position=" + position + " parent=" + this);

        final int toTop = position >= (mChildren.size() - 1) ? 1 : 0;
        final Task task = child.asTask();
        if (task != null) {
            EventLogTags.writeWmTaskMoved(task.mTaskId, toTop, position);
        }
    }
```

### WindowContainer

```java
// com.android.server.wm.WindowContainer#positionChildAt    
/**
     * Move a child from it's current place in siblings list to the specified position,
     * with an option to move all its parents to top.
     * @param position Target position to move the child to.
     * @param child Child to move to selected position.
     * @param includingParents Flag indicating whether we need to move the entire branch of the
     *                         hierarchy when we're moving a child to {@link #POSITION_TOP} or
     *                         {@link #POSITION_BOTTOM}. When moving to other intermediate positions
     *                         this flag will do nothing.
     */
    @CallSuper
    void positionChildAt(int position, E child, boolean includingParents) {

        if (child.getParent() != this) {
            throw new IllegalArgumentException("positionChildAt: container=" + child.getName()
                    + " is not a child of container=" + getName()
                    + " current parent=" + child.getParent());
        }

        if (position >= mChildren.size() - 1) {
            position = POSITION_TOP;
        } else if (position <= 0) {
            position = POSITION_BOTTOM;
        }

        switch (position) {
            case POSITION_TOP:
                if (mChildren.peekLast() != child) {
                    mChildren.remove(child);
                    mChildren.add(child);
                    onChildPositionChanged(child);
                }
                if (includingParents && getParent() != null) {
                    getParent().positionChildAt(POSITION_TOP, this /* child */,
                            true /* includingParents */);
                }
                break;
            case POSITION_BOTTOM:
                if (mChildren.peekFirst() != child) {
                    mChildren.remove(child);
                    mChildren.addFirst(child);
                    onChildPositionChanged(child);
                }
                if (includingParents && getParent() != null) {
                    getParent().positionChildAt(POSITION_BOTTOM, this /* child */,
                            true /* includingParents */);
                }
                break;
            default:
                // TODO: Removing the child before reinserting requires the caller to provide a
                //       position that takes into account the removed child (if the index of the
                //       child < position, then the position should be adjusted). We should consider
                //       doing this adjustment here and remove any adjustments in the callers.
                if (mChildren.indexOf(child) != position) {
                    mChildren.remove(child);
                    mChildren.add(position, child);
                    onChildPositionChanged(child);
                }
        }
    }
```



## 参考文章

* [CSDN-Android的Activity启动流程分析](https://blog.csdn.net/u012267215/article/details/91406211)：比较多的图

