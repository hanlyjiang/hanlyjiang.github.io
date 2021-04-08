





* `bindService` : (`frameworks/base/core/java/android/app/ContextImpl.java`)

  ```java
      @Override
      public boolean bindService(Intent service, ServiceConnection conn, int flags) {
          warnIfCallingFromSystemProcess();
          return bindServiceCommon(service, conn, flags, null, mMainThread.getHandler(), null,
                  getUser());
      }
  
      @Override
      public boolean bindService(
              Intent service, int flags, Executor executor, ServiceConnection conn) {
          warnIfCallingFromSystemProcess();
          return bindServiceCommon(service, conn, flags, null, null, executor, getUser());
      }
  
  ```

* `bindServiceCommon`:  (`frameworks/base/core/java/android/app/ContextImpl.java`)

  ```java
  private boolean bindServiceCommon(Intent service, ServiceConnection conn, int flags,
              String instanceName, Handler handler, Executor executor, UserHandle user) {
          // Keep this in sync with DevicePolicyManager.bindDeviceAdminServiceAsUser.
          IServiceConnection sd;
          if (conn == null) {
              throw new IllegalArgumentException("connection is null");
          }
          if (handler != null && executor != null) {
              throw new IllegalArgumentException("Handler and Executor both supplied");
          }
          if (mPackageInfo != null) {
              if (executor != null) {
                  sd = mPackageInfo.getServiceDispatcher(conn, getOuterContext(), executor, flags);
              } else {
                  sd = mPackageInfo.getServiceDispatcher(conn, getOuterContext(), handler, flags);
              }
          } else {
              throw new RuntimeException("Not supported in system context");
          }
          validateServiceIntent(service);
          try {
              // WindowContext构造函数中的 WindowTokenClient
              IBinder token = getActivityToken();
              if (token == null && (flags&BIND_AUTO_CREATE) == 0 && mPackageInfo != null
                      && mPackageInfo.getApplicationInfo().targetSdkVersion
                      < android.os.Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
                  flags |= BIND_WAIVE_PRIORITY;
              }
              service.prepareToLeaveProcess(this);
              int res = ActivityManager.getService().bindIsolatedService(
                  mMainThread.getApplicationThread(), getActivityToken(), service,
                  service.resolveTypeIfNeeded(getContentResolver()),
                  sd, flags, instanceName, getOpPackageName(), user.getIdentifier());
              if (res < 0) {
                  throw new SecurityException(
                          "Not allowed to bind to service " + service);
              }
              return res != 0;
          } catch (RemoteException e) {
              throw e.rethrowFromSystemServer();
          }
      }
  ```

* ActivityManagerService.java : ()

  ```java
  public int bindIsolatedService(IApplicationThread caller, IBinder token, Intent service,
              String resolvedType, IServiceConnection connection, int flags, String instanceName,
              String callingPackage, int userId) throws TransactionTooLargeException {
  		// .... 
          synchronized(this) {
              // 调用Binder接口
              return mServices.bindServiceLocked(caller, token, service,
                      resolvedType, connection, flags, instanceName, callingPackage, userId);
          }
      }
  ```

*  `ActiveServices.bindServiceLocked`: (`frameworks/base/services/core/java/com/android/server/am/ActiveServices.java`)

  * 这个方法有点长，我们截取重要部分

  ```java
  int bindServiceLocked(IApplicationThread caller, IBinder token, Intent service,
              String resolvedType, final IServiceConnection connection, int flags,
              String instanceName, String callingPackage, final int userId)
              throws TransactionTooLargeException {
          final int callingPid = Binder.getCallingPid();
          final int callingUid = Binder.getCallingUid();
          final ProcessRecord callerApp = mAm.getRecordForAppLocked(caller);
          if (callerApp == null) {
              throw new SecurityException(
                      "Unable to find app for caller " + caller
                      + " (pid=" + callingPid
                      + ") when binding service " + service);
          }
  
          ActivityServiceConnectionsHolder<ConnectionRecord> activity = null;
          if (token != null) {
              activity = mAm.mAtmInternal.getServiceConnectionsHolder(token);
              if (activity == null) {
                  Slog.w(TAG, "Binding with unknown activity: " + token);
                  return 0;
              }
          }
  
          int clientLabel = 0;
          PendingIntent clientIntent = null;
          final boolean isCallerSystem = callerApp.info.uid == Process.SYSTEM_UID;
         
  
          final boolean callerFg = callerApp.setSchedGroup != ProcessList.SCHED_GROUP_BACKGROUND;
          final boolean isBindExternal = (flags & Context.BIND_EXTERNAL_SERVICE) != 0;
          final boolean allowInstant = (flags & Context.BIND_ALLOW_INSTANT) != 0;
  
          ServiceLookupResult res =
              retrieveServiceLocked(service, instanceName, resolvedType, callingPackage,
                      callingPid, callingUid, userId, true,
                      callerFg, isBindExternal, allowInstant);
          if (res == null) {
              return 0;
          }
          if (res.record == null) {
              return -1;
          }
          ServiceRecord s = res.record;
  
          try {
              if (unscheduleServiceRestartLocked(s, callerApp.info.uid, false)) {
                  if (DEBUG_SERVICE) Slog.v(TAG_SERVICE, "BIND SERVICE WHILE RESTART PENDING: "
                          + s);
              }
  
              if ((flags&Context.BIND_AUTO_CREATE) != 0) {
                  s.lastActivity = SystemClock.uptimeMillis();
                  if (!s.hasAutoCreateConnections()) {
                      // This is the first binding, let the tracker know.
                      ServiceState stracker = s.getTracker();
                      if (stracker != null) {
                          stracker.setBound(true, mAm.mProcessStats.getMemFactorLocked(),
                                  s.lastActivity);
                      }
                  }
              }
  
              if ((flags & Context.BIND_RESTRICT_ASSOCIATIONS) != 0) {
                  mAm.requireAllowedAssociationsLocked(s.appInfo.packageName);
              }
  
              mAm.startAssociationLocked(callerApp.uid, callerApp.processName,
                      callerApp.getCurProcState(), s.appInfo.uid, s.appInfo.longVersionCode,
                      s.instanceName, s.processName);
              // Once the apps have become associated, if one of them is caller is ephemeral
              // the target app should now be able to see the calling app
              mAm.grantImplicitAccess(callerApp.userId, service,
                      callerApp.uid, UserHandle.getAppId(s.appInfo.uid));
  
              AppBindRecord b = s.retrieveAppBindingLocked(service, callerApp);
              ConnectionRecord c = new ConnectionRecord(b, activity,
                      connection, flags, clientLabel, clientIntent,
                      callerApp.uid, callerApp.processName, callingPackage);
  
              IBinder binder = connection.asBinder();
              s.addConnection(binder, c);
              b.connections.add(c);
              if (activity != null) {
                  activity.addConnection(c);
              }
              b.client.connections.add(c);
              if (s.app != null) {
                  updateServiceClientActivitiesLocked(s.app, c, true);
              }
              ArrayList<ConnectionRecord> clist = mServiceConnections.get(binder);
              if (clist == null) {
                  clist = new ArrayList<>();
                  mServiceConnections.put(binder, clist);
              }
              clist.add(c);
  
              if ((flags&Context.BIND_AUTO_CREATE) != 0) {
                  s.lastActivity = SystemClock.uptimeMillis();
                  if (bringUpServiceLocked(s, service.getFlags(), callerFg, false,
                          permissionsReviewRequired) != null) {
                      return 0;
                  }
              }
  
              if (s.app != null && b.intent.received) {
                  // Service is already running, so we can immediately
                  // publish the connection.
                  try {
                      c.conn.connected(s.name, b.intent.binder, false);
                  } catch (Exception e) {
                      Slog.w(TAG, "Failure sending service " + s.shortInstanceName
                              + " to connection " + c.conn.asBinder()
                              + " (in " + c.binding.client.processName + ")", e);
                  }
              } else if (!b.intent.requested) {
                  requestServiceBindingLocked(s, b.intent, callerFg, false);
              }
          } finally {
          }
          return 1;
      }
  ```

  

# BBinder相关

BBinder 何时创建，如何设置到parcel的数据结构中？

## BBinder

* BBinder : `frameworks/native/include/binder/Binder.h`

  ```cpp
  class BBinder : public IBinder
  {
  public:
                          BBinder();
  
      virtual const String16& getInterfaceDescriptor() const;
      virtual bool        isBinderAlive() const;
      virtual status_t    pingBinder();
      virtual status_t    dump(int fd, const Vector<String16>& args);
  
      // NOLINTNEXTLINE(google-default-arguments)
      virtual status_t    transact(   uint32_t code,
                                      const Parcel& data,
                                      Parcel* reply,
                                      uint32_t flags = 0) final;
      virtual BBinder*    localBinder();
      
  }
  ```

## JavaBBinder

* JavaBBinder : `frameworks/base/core/jni/android_util_Binder.cpp`

  ```cpp
  class JavaBBinderHolder;
  
  class JavaBBinder : public BBinder
  {
  public:
      JavaBBinder(JNIEnv* env, jobject /* Java Binder */ object)
          : mVM(jnienv_to_javavm(env)), mObject(env->NewGlobalRef(object))
      {
          ALOGV("Creating JavaBBinder %p\n", this);
          gNumLocalRefsCreated.fetch_add(1, std::memory_order_relaxed);
          gcIfManyNewRefs(env);
      }
  
      bool    checkSubclass(const void* subclassID) const
      {
          return subclassID == &gBinderOffsets;
      }
  
      jobject object() const
      {
          return mObject;
      }
  ```

## JavaBBinderHolder

* JavaBBinderHolder :`frameworks/base/core/jni/android_util_Binder.cpp`

  ```cpp
  class JavaBBinderHolder
  {
  public:
      sp<JavaBBinder> get(JNIEnv* env, jobject obj)
      {
          AutoMutex _l(mLock);
          sp<JavaBBinder> b = mBinder.promote();
          if (b == NULL) {
              // 注意这里构造的 JavaBBinder
              b = new JavaBBinder(env, obj);
              if (mVintf) {
                  ::android::internal::Stability::markVintf(b.get());
              }
              if (mExtension != nullptr) {
                  b.get()->setExtension(mExtension);
              }
              mBinder = b;
              ALOGV("Creating JavaBinder %p (refs %p) for Object %p, weakCount=%" PRId32 "\n",
                   b.get(), b->getWeakRefs(), obj, b->getWeakRefs()->getWeakCount());
          }
  
          return b;
      }
  
  }
  ```

## JavaBBinderHolder 的初始化

* frameworks/base/core/jni/android_util_Binder.cpp

  ```java
  static const JNINativeMethod gBinderMethods[] = {
      { "getNativeBBinderHolder", "()J", (void*)android_os_Binder_getNativeBBinderHolder },
  };
  
  
  static jlong android_os_Binder_getNativeBBinderHolder(JNIEnv* env, jobject clazz)
  {
      JavaBBinderHolder* jbh = new JavaBBinderHolder();
      return (jlong) jbh;
  }
  ```

* Binder.java 构造函数: (`frameworks/base/core/java/android/os/Binder.java`)

  ```java
     /**
       * Constructor for creating a raw Binder object (token) along with a descriptor.
       *
       * The descriptor of binder objects usually specifies the interface they are implementing.
       * In case of binder tokens, no interface is implemented, and the descriptor can be used
       * as a sort of tag to help identify the binder token. This will help identify remote
       * references to these objects more easily when debugging.
       *
       * @param descriptor Used to identify the creator of this token, for example the class name.
       * Instead of creating multiple tokens with the same descriptor, consider adding a suffix to
       * help identify them.
       */
      public Binder(@Nullable String descriptor)  {
          // 获取Native的BBinder对象的指针
          mObject = getNativeBBinderHolder();
          NoImagePreloadHolder.sRegistry.registerNativeAllocation(this, mObject);
          // ...
          mDescriptor = descriptor;
      }
  
  
      private static native long getNativeBBinderHolder();
  ```

* 实际上，CPP中使用的 `gBinderOffsets.mObject` 就是上面分配的 `NativeBBinderHolder`

  ```java
  // (frameworks/base/core/jni/android_util_Binder.cpp)
  static struct bindernative_offsets_t
  {
      // Class state.
      jclass mClass;
      jmethodID mExecTransact;
      jmethodID mGetInterfaceDescriptor;
  
      // Object state.
      jfieldID mObject;
  
  } gBinderOffsets;
  ```

* 发现一个函数 ibinderForJavaObject ：(frameworks/base/core/jni/android_util_Binder.cpp)

  ```cpp
  sp<IBinder> ibinderForJavaObject(JNIEnv* env, jobject obj)
  {
      if (obj == NULL) return NULL;
  
      // Instance of Binder?
      if (env->IsInstanceOf(obj, gBinderOffsets.mClass)) {
          JavaBBinderHolder* jbh = (JavaBBinderHolder*)
              env->GetLongField(obj, gBinderOffsets.mObject);
          return jbh->get(env, obj);
      }
  
      // Instance of BinderProxy?
      if (env->IsInstanceOf(obj, gBinderProxyOffsets.mClass)) {
          return getBPNativeData(env, obj)->mObject;
      }
  
      ALOGW("ibinderForJavaObject: %p is not a Binder object", obj);
      return NULL;
  }
  ```

  

