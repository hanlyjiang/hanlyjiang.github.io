---
title: 'JNI简要介绍'
date: 2021-03-20 10:18:50
tags: [Android,Gradle]
published: true
hideInList: false
feature: 
isTop: false
---





# 第二章-JNI简要介绍

本章将简单介绍JNI，及其中的基础概念，类型映射，签名，最后还介绍了Android中常用的JNI包装函数。

## JNI简介

>  可参考 [Java 原生接口规范](http://docs.oracle.com/javase/7/docs/technotes/guides/jni/spec/jniTOC.html) 

* 允许运行在JVM中的Java代码能够和其他语言（C/C++/汇编）编写的应用程序与库相互操作
* JNI能做到什么？
  * 在Java中调用native方法
  * 在native中调用Java
    * 创建、检查和更新Java对象（包括数组和字符串）
    * 调用Java方法
    * 抓住并抛出异常
    * 加载类，获取类信息
    * 执行运行时类型检查
* 如何加载并建立native到java的绑定关系？可通过如下两种方式
  * 加载： `System.loadLibrary()`
  * 绑定：
    * 根据native代码中的方法名称来绑定到对应的java类的方法（命名规则约定匹配）
    * native代码中自行执行`RegisterNatives`方法注册，一般在JNI_OnLoad调用时。
* 重要概念：接口指针
  * 原生代码通过调用JNI函数访问Java VM功能。JNI函数可以通过接口指针获得。
  * 接口指针是指向指针的指针。该指针指向一个指针数组，每个指针指向一个接口函数。每个接口函数都位于数组内部的预定义偏移量。
  * ![image-20210405105655533](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210405105655.png)
  * JNI接口指针仅在当前线程中有效。实现JNI的虚拟机可以在JNI接口指针指向的区域分配和存储线程本地数据。
  * 原生方法接收JNI接口指针作为参数。当虚拟机从同一个Java线程多次调用本机方法时，它保证将相同的接口指针传递给本机方法。然而，本机方法可以从不同的Java线程调用，因此可能会接收不同的JNI接口指针。
  * 原生方法接收JNI接口指针作为参数。当虚拟机从同一个Java线程多次调用本机方法时，它保证将相同的接口指针传递给本机方法。然而，本机方法可以从不同的Java线程调用，因此可能会接收不同的JNI接口指针。
  * 接口指针的类型时JNIEnv
* native方法参数说明：
  * 第一个参数为接口指针
  * 第二个参数为java类的引用（静态方法）或者java对象的引用（非静态方法）
  * 其他参数为Java方法的参数
* 引用说明：
  * Java对象传递给JNI时，通过引用传递，VM必须跟踪所有传递给native的对象，以确保对象不会被GC回收。同时也需要在对象不在被使用时，通知VM回收。
  * 每次Java调用native方法时，JVM会创建一个注册表键本地引用映射到java对象，所有传递给native方法的对象及返回值都会自动添加到注册表中。native方法返回后，注册表将会被删除，其中引用的对象即允许被GC回收。这种默认机制下的引用即为本地引用，即仅在native方法调用期间引用，调用返回后即不再引用。
  * 同时还有其他两种类型的引用：
    * 全局引用：方法返回后仍然可用，需要主动调用DeleteGlobalRef来删除引用
    * 全局弱引用：一种特殊类型的引用，允许底层引用的java对象被GC回收。

## JNI类型及类型签名

* **原始类型**

  | Java类型 | Native 类型 | Description      |
  | -------- | ----------- | ---------------- |
  | boolean  | jboolean    | unsigned 8 bits  |
  | byte     | jbyte       | signed 8 bits    |
  | char     | jchar       | unsigned 16 bits |
  | short    | jshort      | signed 16 bits   |
  | int      | jint        | signed 32 bits   |
  | long     | jlong       | signed 64 bits   |
  | float    | jfloat      | 32 bits          |
  | double   | jdouble     | 64 bits          |
  | void     | void        | N/A              |

  ```c
  #define JNI_FALSE  0 
  #define JNI_TRUE   1 
  ```

  jsize 整型类型用于描述索引和大小

  ```c
  typedef jint jsize; 
  ```

* **引用类型：**

  引用类型的类型层次如下图：

  ![image-20210405110528062](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210405110528.png)

  

* 类型签名：在调用JNI对应方法来查找方法或者字段时，需要通过name和签名来查找，各java类型对应的类型签名如下：

  | Type 签名                 | Java 类型             |
  | ------------------------- | --------------------- |
  | Z                         | boolean               |
  | B                         | byte                  |
  | C                         | char                  |
  | S                         | short                 |
  | I                         | int                   |
  | J                         | long                  |
  | F                         | float                 |
  | D                         | double                |
  | L fully-qualified-class ; | fully-qualified-class |
  | [ type                    | type[]                |
  | ( arg-types ) ret-type    | method type           |

  

## JNI常用接口函数

前面说过，native代码通过JNI接口指针来访问JavaVM的功能。接口指针是指向一个函数的指针，所有的函数存储在一个函数表中，VM会初始化这个函数表，并在所有的JNI接口指针之间共享。

这些JNI接口包含以下类型：

* 版本信息接口
* 类操作接口
* 异常操作接口
* 引用操作接口（包括本地引用，全局引用，全局弱引用）
* 对象操作接口
* 字段访问接口（包括静态和非静态字段）
* 方法调用接口（包括静态和非静态方法）
* 字符串操作接口
* 数组操作接口
* 注册/取消注册Native方法接口
* 监视器接口
* NIO支持接口
* 反射支持接口
* JavaVM接口

下面列举一些常用的接口：

| 接口方法                                                     | 说明                                     |
| ------------------------------------------------------------ | ---------------------------------------- |
| `jclass FindClass(JNIEnv *env, const char *name);`           | 加载类                                   |
| `jfieldID GetFieldID(JNIEnv *env, jclass clazz,<br/>const char *name, const char *sig);` | 通过名称和签名返回一个类的非静态的字段ID |
| `jmethodID GetMethodID(JNIEnv *env, jclass clazz, const char *name, const char *sig);` | 获取类的非静态的方法ID                   |
| `jmethodID GetStaticMethodID(JNIEnv *env, jclass clazz,<br/>const char *name, const char *sig);` | 获取累的静态方法的ID                     |
| `jobject NewGlobalRef(JNIEnv *env, jobject obj);`            | 建立一个新的全局引用（引用obj参数）      |
| `jint RegisterNatives(JNIEnv *env, jclass clazz, const JNINativeMethod *methods, jint nMethods);` | native方法注册到指定的类中               |

## Android JNI常用辅助函数介绍

Androidd导入了一些辅助函数，对JNIEnv的一些接口调用进行了简单的包装，以下为一些常见的方法总结。

| 方法                  | 实际动作                                                     | 总结                             |
| --------------------- | ------------------------------------------------------------ | -------------------------------- |
| FindClassOrDie        | `env->FindClass(class_name)`                                 | 加载类                           |
| GetFieldIDOrDie       | `env->GetFieldID(clazz, field_name, field_signature)`        | 获取字段id                       |
| GetMethodIDOrDie      | `env->GetMethodID(clazz, method_name, method_signature)`     | 获取方法id                       |
| GetStaticFieldIDOrDie | `env->GetStaticMethodID(clazz, method_name, method_signature)` | 获取静态方法id                   |
| MakeGlobalRefOrDie    | `template <typename T>`<br/>`env->NewGlobalRef(T)`           | 创建全局引用                     |
| RegisterMethodsOrDie  | `AndroidRuntime::registerNativeMethods`<br/>`env->RegisterNatives(jclass, gMethods, numMethods)` | 注册native方法到哪种             |
| getStringField        | 读取指定字段，并转换为`std::string`返回                      | 获取对象的字段的值并转换为string |



下面为所有包装方法的源码

* `frameworks/base/core/jni/core_jni_helpers.h`

  ```cpp
  #ifndef CORE_JNI_HELPERS
  #define CORE_JNI_HELPERS
  
  #include <nativehelper/JNIHelp.h>
  #include <nativehelper/scoped_local_ref.h>
  #include <nativehelper/scoped_utf_chars.h>
  #include <android_runtime/AndroidRuntime.h>
  
  // Host targets (layoutlib) do not differentiate between regular and critical native methods,
  // and they need all the JNI methods to have JNIEnv* and jclass/jobject as their first two arguments.
  // The following macro allows to have those arguments when compiling for host while omitting them when
  // compiling for Android.
  #ifdef __ANDROID__
  #define CRITICAL_JNI_PARAMS
  #define CRITICAL_JNI_PARAMS_COMMA
  #else
  #define CRITICAL_JNI_PARAMS JNIEnv*, jclass
  #define CRITICAL_JNI_PARAMS_COMMA JNIEnv*, jclass,
  #endif
  
  namespace android {
  
  // Defines some helpful functions.
  
  static inline jclass FindClassOrDie(JNIEnv* env, const char* class_name) {
      jclass clazz = env->FindClass(class_name);
      LOG_ALWAYS_FATAL_IF(clazz == NULL, "Unable to find class %s", class_name);
      return clazz;
  }
  
  static inline jfieldID GetFieldIDOrDie(JNIEnv* env, jclass clazz, const char* field_name,
                                         const char* field_signature) {
      jfieldID res = env->GetFieldID(clazz, field_name, field_signature);
      LOG_ALWAYS_FATAL_IF(res == NULL, "Unable to find static field %s with signature %s", field_name,
                          field_signature);
      return res;
  }
  
  static inline jmethodID GetMethodIDOrDie(JNIEnv* env, jclass clazz, const char* method_name,
                                           const char* method_signature) {
      jmethodID res = env->GetMethodID(clazz, method_name, method_signature);
      LOG_ALWAYS_FATAL_IF(res == NULL, "Unable to find method %s with signature %s", method_name,
                          method_signature);
      return res;
  }
  
  static inline jfieldID GetStaticFieldIDOrDie(JNIEnv* env, jclass clazz, const char* field_name,
                                               const char* field_signature) {
      jfieldID res = env->GetStaticFieldID(clazz, field_name, field_signature);
      LOG_ALWAYS_FATAL_IF(res == NULL, "Unable to find static field %s with signature %s", field_name,
                          field_signature);
      return res;
  }
  
  static inline jmethodID GetStaticMethodIDOrDie(JNIEnv* env, jclass clazz, const char* method_name,
                                                 const char* method_signature) {
      jmethodID res = env->GetStaticMethodID(clazz, method_name, method_signature);
      LOG_ALWAYS_FATAL_IF(res == NULL, "Unable to find static method %s with signature %s",
                          method_name, method_signature);
      return res;
  }
  
  template <typename T>
  static inline T MakeGlobalRefOrDie(JNIEnv* env, T in) {
      jobject res = env->NewGlobalRef(in);
      LOG_ALWAYS_FATAL_IF(res == NULL, "Unable to create global reference.");
      return static_cast<T>(res);
  }
  
  static inline int RegisterMethodsOrDie(JNIEnv* env, const char* className,
                                         const JNINativeMethod* gMethods, int numMethods) {
      int res = AndroidRuntime::registerNativeMethods(env, className, gMethods, numMethods);
      LOG_ALWAYS_FATAL_IF(res < 0, "Unable to register native methods.");
      return res;
  }
  
  /**
   * Read the specified field from jobject, and convert to std::string.
   * If the field cannot be obtained, return defaultValue.
   */
  static inline std::string getStringField(JNIEnv* env, jobject obj, jfieldID fieldId,
          const char* defaultValue) {
      ScopedLocalRef<jstring> strObj(env, jstring(env->GetObjectField(obj, fieldId)));
      if (strObj != nullptr) {
          ScopedUtfChars chars(env, strObj.get());
          return std::string(chars.c_str());
      }
      return std::string(defaultValue);
  }
  
  }  // namespace android
  
  #endif  // CORE_JNI_HELPERS
  ```

* `frameworks/ex/framesequence/jni/utils/log.h`： `LOG_ALWAYS_FATAL_IF`

  ```cpp
  #define CONDITION(cond)     (__builtin_expect((cond)!=0, 0))
  
  #ifndef LOG_ALWAYS_FATAL_IF
  #define LOG_ALWAYS_FATAL_IF(cond, ...) \
      ( (CONDITION(cond)) \
      ? ((void)android_printAssert(#cond, LOG_TAG, ## __VA_ARGS__)) \
      : (void)0 )
  #endif
  ```

  > __builtin_expect() 是 GCC (version >= 2.96）提供给程序员使用的，目的是将“分支转移”的信息提供给编译器，这样编译器可以对代码进行优化，以减少指令跳转带来的性能下降。通过这种方式，编译器在编译过程中，会将可能性更大的代码紧跟着前面的代码，从而减少指令跳转带来的性能上的下降。
  >
  > * builtin_expect((x),1)表示 x 的值为真的可能性更大
  >
  > * builtin_expect((x),0)表示 x 的值为假的可能性更大
  >
  > 链接：https://www.jianshu.com/p/cf453250015c

* `frameworks/base/core/jni/AndroidRuntime.cpp`: registerNativeMethods

  ```cpp
  /*
   * Register native methods using JNI.
   */
  /*static*/ int AndroidRuntime::registerNativeMethods(JNIEnv* env,
      const char* className, const JNINativeMethod* gMethods, int numMethods)
  {
      return jniRegisterNativeMethods(env, className, gMethods, numMethods);
  }
  ```

* `libnativehelper/JNIHelp.cpp`:  jniRegisterNativeMethods

  ```cpp
  int jniRegisterNativeMethods(C_JNIEnv* env, const char* className,
      const JNINativeMethod* gMethods, int numMethods)
  {
      JNIEnv* e = reinterpret_cast<JNIEnv*>(env);
  
      ALOGV("Registering %s's %d native methods...", className, numMethods);
  
      scoped_local_ref<jclass> c(env, findClass(env, className));
      ALOG_ALWAYS_FATAL_IF(c.get() == NULL,
                           "Native registration unable to find class '%s'; aborting...",
                           className);
  
      int result = e->RegisterNatives(c.get(), gMethods, numMethods);
      ALOG_ALWAYS_FATAL_IF(result < 0, "RegisterNatives failed for '%s'; aborting...",
                           className);
  
      return 0;
  }
  
  // 存储一个本地类的引用，同时记录及关联的JNIEnv，方便后续获取对象及删除本地引用
  template<typename T>
  class scoped_local_ref final {
  public:
      explicit scoped_local_ref(C_JNIEnv* env, T localRef = NULL)
      : mEnv(env), mLocalRef(localRef)
      {
      }
  
      ~scoped_local_ref() {
          reset();
      }
  
      void reset(T localRef = NULL) {
          if (mLocalRef != NULL) {
              (*mEnv)->DeleteLocalRef(reinterpret_cast<JNIEnv*>(mEnv), mLocalRef);
              mLocalRef = localRef;
          }
      }
  
      T get() const {
          return mLocalRef;
      }
  ```

## 参考

* [Java 原生接口规范](http://docs.oracle.com/javase/7/docs/technotes/guides/jni/spec/jniTOC.html)
* [GoogleAndroid开发文档-JNI提示](https://developer.android.google.cn/training/articles/perf-jni?hl=zh-cn)

