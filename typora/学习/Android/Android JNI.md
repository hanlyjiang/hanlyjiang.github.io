# 相关资源

* [Android官方文档-JNI提示](https://developer.android.com/training/articles/perf-jni)
* [JAVA官方-Java 原生接口规范](http://docs.oracle.com/javase/7/docs/technotes/guides/jni/spec/jniTOC.html)
* [Binder系列7—framework层分析](http://gityuan.com/2015/11/21/binder-framework/)





> JNI 是指 Java 原生接口。它定义了 Android 从受管理代码（使用 Java 或 Kotlin 编程语言编写）编译的字节码与原生代码（使用 C/C++ 编写）互动的方式。JNI 不依赖于供应商，支持从动态共享库加载代码，虽然有时较为繁琐，但效率尚可。

## jclass、jmethodID 和 jfieldID

如果要通过原生代码访问对象的字段，请执行以下操作：

- 使用 `FindClass` 获取类的类对象引用
- 使用 `GetFieldID` 获取字段的字段 ID
- 使用适当函数获取字段的内容，例如 `GetIntField`

同样，如需调用方法，首先要获取类对象引用，然后获取方法 ID。方法 ID 通常只是指向内部运行时数据结构的指针。查找方法 ID 可能需要进行多次字符串比较，但一旦获取此类 ID，便可以非常快速地进行实际调用以获取字段或调用方法。

如果性能很重要，我们建议您查找一次这些值并将结果缓存在原生代码中。由于每个进程只能包含一个 JavaVM，因此将这些数据存储在静态本地结构中是一种合理的做法。



> - FindClassOrDie(env, kBinderPathName) 基本等价于 env->FindClass(kBinderPathName)
> - MakeGlobalRefOrDie() 等价于 env->NewGlobalRef()
> - GetMethodIDOrDie() 等价于 env->GetMethodID()
> - GetFieldIDOrDie() 等价于 env->GeFieldID()
> - RegisterMethodsOrDie() 等价于 Android::registerNativeMethods();