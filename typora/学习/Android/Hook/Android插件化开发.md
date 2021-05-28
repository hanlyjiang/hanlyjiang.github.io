# Android-Plugin-Framework源码阅读

## 问题&想法

### MethodHandler

1. 对于插件化中InvocationHandler的hook来说，hook实际上是为了修改原始对象的调用过程，但是实际上还是需要调用系统中原始对象的对应的方法；



### 动态代理的限制

* 只适合与接口

  ```shell
  Caused by: java.lang.IllegalArgumentException: class android.app.Instrumentation is not an interface
  ```

### 反射：getXXX 与 getDeclaredXXX的区别

* getDeclared： 返回 public, protected, default (package) 及 private 的字段或方法, 但是不包括 inherited 字段/方法. （就是不会查找父类/接口）

* get： 返回public的，会遍历父类的。

## 挑战&示例



## Hook 方案

### ActivityThread mH mCallback hook

#### hook思路分析

基于如下原理：

Looper中消息循环时，会调用	dispatchMessage 

```java
msg.target.dispatchMessage(msg);
```

dispatchMessage 的实现如下：

```java
    /**
     * Subclasses must implement this to receive messages.
     */
    public void handleMessage(@NonNull Message msg) {
    }
    
    /**
     * Handle system messages here.
     */
    public void dispatchMessage(@NonNull Message msg) {
        if (msg.callback != null) {
            handleCallback(msg);
        } else {
            if (mCallback != null) {
                if (mCallback.handleMessage(msg)) {
                    return;
                }
            }
            handleMessage(msg);
        }
    }
```

可以看到，只要消息中的callback为null，就会走到mCallback 中；（这里实际上可能有遗漏的部分）



我们考虑如何进行hook：

* 通过 ActivityThread#currentActivityThread  静态方法可以获取当前的ActivityThread对象，然后就可以获取`mH`

```java
// android.app.ActivityThread#currentActivityThread    
@UnsupportedAppUsage
    public static ActivityThread currentActivityThread() {
        return sCurrentActivityThread;
    }
```

* 再通过mH 来获取mCallback

不过在新版本中（33），没有特别明确的用于启动Activity的消息了，而是位于ClientTransaction中：

```java
// android.app.ActivityThread.H#EXECUTE_TRANSACTION
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



#### 总结

目前使用 mCallback 来 hook 不太稳定，建议使用 Instrumentation。

## 源码分析

### APF对Instrumentation的修改是如何实现的？

```java
PluginInjector.injectInstrumentation();
```

接下来

```java
//com.limpoxe.fairy.core.android.HackActivityThread#wrapInstrumentation

public static void wrapInstrumentation() {
    HackActivityThread hackActivityThread = get();
    if (hackActivityThread != null) {
        Instrumentation originalInstrumentation = hackActivityThread.getInstrumentation();
        if (!(originalInstrumentation instanceof PluginInstrumentionWrapper)) {
            hackActivityThread.setInstrumentation(new PluginInstrumentionWrapper(originalInstrumentation));
        }
    } else {
        LogUtil.e("wrapInstrumentation fail!!");
    }
}
```



