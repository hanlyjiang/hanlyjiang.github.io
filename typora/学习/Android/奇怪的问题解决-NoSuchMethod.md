# AAR Java8 接口 NoSuchMethodError 错误解决记录

遇到一个初看时非常诡异的问题，现已解决，特记录一下解决过程。

## 🙋‍♀️ 是什么问题呢？

APP运行过程中，忽然报了一个莫名其妙的错误： `NoSuchMethodError`, 报错的地方是 rxjava3 的 `Disposable.disposed()`

```shell
```



> **⏰ Tip**
>
> 实际上还有遇到过一个 `AbstractMethodError` 的错误



## 尝试路径

- dexCache 找到的class.dex 是和apk里面对应的（classes2.dex）
- FAT-AAR无关：是否使用fat-aar合并无影响，直接使用非fat-aar合并的aar直接依赖
- AGP 版本无关：尝试了多个版本，均有问题
  - 实际上AGP版本也有关系，只不过可能要到3.4.0（就是没引入D8的时候），但是测试起来比较麻烦



## 解决方案

### 解法1

gradle.properties 文件中添加属性：

```properties
android.enableDexingArtifactTransform.desugaring=false
```

### 解法2 

修改 aar 的依赖方式，将name+ext的方式修改为 files

```groovy
		implementation(name: 'libmod-release', ext: 'aar')
```

修改之后

```groovy
        // 必须使用 files('AAR path') 的方式引入aar依赖，否则如果aar中有使用到了三方库，而该三方库使用了java8的新特性（如接口的默认方法及静态方法等）
        // 则在编译过程中进行 desugaring（即：class->DEX） 操作时，该AAR的相关class 字节码可能无法正确完成 desugaring 操作，APP可能会在运行时崩溃
        // 如： 对于使用到 Java8 接口默认方法及静态方法的，会报出 java.lang.NoSuchMethodError 错误或者 java.lang.AbstractMethodError 错误
        implementation(files('libs/libmod-release.aar'))

```



## 原因

AGP 启用 D8 ，根据POM依赖信息来寻找对应的依赖，然后加入到 desurge classpath，而 aar 不具备这些POM依赖信息，所以无法还原。



### 还原指什么？

看看添加了 `desugaring=false`  前后的差别：

我们定义了一个ViewUtils类，使用了 Disposable 类，他们定义如下：

```java
public class ViewUtils {

    public static io.reactivex.rxjava3.disposables.Disposable throttleFirstClicksRxJava3() {
        return io.reactivex.rxjava3.disposables.Disposable.disposed();
    }
}

// io.reactivex.rxjava3.disposables
public interface Disposable {

    void dispose();

    boolean isDisposed();
    
    // ...

    @NonNull
    static Disposable disposed() {
        return EmptyDisposable.INSTANCE;
    }
}
```

使用AndroidStudio查看apk类dex的字节码，下面为 添加了配置之后的：

```java
.class public Lcom/test/libmod/ViewUtils;
.super Ljava/lang/Object;
.source "ViewUtils.java"


# direct methods
.method public constructor <init>()V
    .registers 1

    .line 9
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static throttleFirstClicksRxJava3()Lio/reactivex/rxjava3/disposables/Disposable;
    .registers 1

    .line 35
    invoke-static {}, Lio/reactivex/rxjava3/disposables/Disposable$-CC;->disposed()Lio/reactivex/rxjava3/disposables/Disposable;

    move-result-object v0

    return-object v0
.end method
```

**注意上面的 `Disposable$-CC`**

添加 gradle 配置之前的：

```java
.class public Lcom/test/libmod/ViewUtils;
.super Ljava/lang/Object;
.source "ViewUtils.java"


# direct methods
.method public constructor <init>()V
    .registers 1

    .line 9
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static throttleFirstClicksRxJava3()Lio/reactivex/rxjava3/disposables/Disposable;
    .registers 1

    .line 35
    invoke-static {}, Lio/reactivex/rxjava3/disposables/Disposable;->disposed()Lio/reactivex/rxjava3/disposables/Disposable;

    move-result-object v0

    return-object v0
.end method

```



我们的rxjava3的class被编译为了 

* Disposable： 包含接口方法的定义
* Disposable$-CC ： 包含Disposable.java 源码中接口内部定义的static方法

而此时实际上应该把我们AAR中对**Disposable中静态方法的调用替换为  Disposable$-CC** ，但是由于无法通过AAR找到我们AAR对rxjava3的依赖信息，所以这个事情就没干。

> 将类文件编译成 dex 代码的过程中执行字节码转换，这种转换称为 `desugar`

但是，我们设置 desurging=false之后，又干了是怎么回事？



## 继续了解

- [d8  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/studio/command-line/d8)
- [使用 Java 8 语言功能和 API  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/studio/write/java8-support)
- [使用 Java 8 语言功能和 API  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/studio/write/java8-support#library-desugaring)
- [Android Gradle 插件版本说明  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/studio/releases/gradle-plugin)

`d8` 是一种命令行工具，Android Studio 和 Android Gradle 插件使用该工具来将项目的 Java 字节码编译为在 Android 设备上运行的 DEX 字节码，该工具支持您在应用的代码中使用 Java 8 语言功能。

`d8` 还作为独立工具纳入了 Android 构建工具 28.0.1 及更高版本中：`android_sdk/build-tools/version/`。

默认情况下，`d8` 会将 Java 字节码编译为优化的 DEX 文件，并在其中包含相关的调试信息，以供您在运行时用于调试代码。然而，您也可以添加可选标记来执行各种操作，例如执行增量构建、指定应编译到主 DEX 文件中的类，以及指定使用 Java 8 语言功能所需的其他资源对应的路径。

`d8` 通过一个叫做“脱糖”的编译过程，使您能够在代码中[使用 Java 8 语言功能](https://developer.android.google.cn/studio/write/java8-support)，此过程会将这些实用的语言功能转换为可以在 Android 平台上运行的字节码。

Android Studio 和 Android Gradle 插件包含了 `d8` 为您启用脱糖所需的类路径资源。



另一个资源是您项目的部分已编译的 Java 字节码，您目前不打算将这部分字节码编译为 DEX 字节码，但在将其他类编译为 DEX 字节码时需要用到这些字节码。例如，如果代码使用[默认和静态接口方法](https://docs.oracle.com/javase/tutorial/java/IandI/defaultmethods.html)（一种 Java 8 语言功能），则您需要使用此标记来指定您项目的所有 Java 字节码的路径，即使您不打算将所有 Java 字节码都编译为 DEX 字节码也是如此。这是因为 `d8` 需要根据这些信息来理解您项目的代码并解析对接口方法的调用。

```
d8 MainActivity.class --intermediate --file-per-class --output ~/build/intermediate/dex
--lib android_sdk/platforms/api-level/android.jar
--classpath ~/build/javac/debug
```