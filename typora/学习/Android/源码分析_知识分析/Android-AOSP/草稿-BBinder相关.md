

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

  

