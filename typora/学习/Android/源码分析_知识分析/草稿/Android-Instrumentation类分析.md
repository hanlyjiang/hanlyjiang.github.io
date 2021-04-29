---
title: 'Android-Instrumentation类分析'
date: 2021-04-10 10:18:50
tags: [Android,源码分析]
published: false
hideInList: false
feature: 
isTop: true
---



## 提出问题

* 用途？
* 哪些主要方法？
* 在什么过程中使用了？
* Application的用途？





## 用途

实现应用程序插装代码的基类。在启动插装的情况下运行时，这个类将在任何应用程序代码之前为您实例化，允许您监视系统与应用程序之间的所有交互。通过AndroidManifest.xml的<Instrumentation>标签向系统描述了一个Instrumentation实现。





### 主要属性

```java
    private final Object mSync = new Object();
    private ActivityThread mThread = null;
    private MessageQueue mMessageQueue = null;
    private Context mInstrContext;
    private Context mAppContext;
    private ComponentName mComponent;
    private Thread mRunner;
    private List<ActivityWaiter> mWaitingActivities;
    private List<ActivityMonitor> mActivityMonitors;
    private IInstrumentationWatcher mWatcher;
    private IUiAutomationConnection mUiAutomationConnection;
    private boolean mAutomaticPerformanceSnapshots = false;
    private PerformanceCollector mPerformanceCollector;
    private Bundle mPerfMetrics = new Bundle();
    private UiAutomation mUiAutomation;
    private final Object mAnimationCompleteLock = new Object();
```

