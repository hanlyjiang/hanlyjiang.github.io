# Android 单元测试集合篇

## Android 单元测试简介

### 单元测试类型 

这里引用官方文档中关于本地单元测试和插桩单元测试的概念说明。

> #### 本地单元测试
>
> 尽可能使用 AndroidX Test API，以便您的单元测试可以在设备或模拟器上运行。对于始终在由 JVM 驱动的开发计算机上运行的测试，您可以使用 [Robolectric](http://robolectric.org/)。
>
> Robolectric 会模拟 Android 4.1（API 级别 16）或更高版本的运行时环境，并提供由社区维护的虚假对象（称为“影子”）。通过此功能，您可以测试依赖于框架的代码，而无需使用模拟器或[模拟对象](https://developer.android.google.cn/training/testing/fundamentals#test-doubles)。Robolectric 支持 Android 平台的以下几个方面：
>
> - 组件生命周期
> - 事件循环
> - 所有资源
>
> ####  插桩单元测试
>
> 您可以在物理设备或模拟器上运行插桩单元测试。不过，这种形式的测试所用的执行时间明显多于本地单元测试，因此，最好只有在必须根据实际设备硬件评估应用的行为时才依靠此方法。
>
> 运行插桩测试时，AndroidX Test 会使用以下线程：
>
> - 主线程，也称为“界面线程”或“Activity 线程”，界面交互和 Activity 生命周期事件发生在此线程上。
> - 插桩线程，大多数测试都在此线程上运行。当您的测试套件开始时，`AndroidJUnitTest` 类将启动此线程。
>
> 如果您需要在主线程上执行某个测试，请使用 [`@UiThreadTest`](https://developer.android.google.cn/reference/androidx/test/annotation/UiThreadTest) 注释该测试。
>
> 
>
> 感兴趣的可查看官方文档： [测试基础知识  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/training/testing/fundamentals)

**简单补充几总结下：**

有两种测试类型；

1. **本地单元测试：** 运行于电脑上，速度快；
   1. 由于本地单元测试运行在电脑上，没有对应的Android上下文环境，所以一般用于测试Android不相关的纯Java代码；
   2. 如果想在本地单元测试中测试涉及Android相关对象的代码，可以使用 Robolectric 框架。 

2. **插桩单元测试：** 运行于设备或者模拟器上，速度慢；
   1. 一般用于测试界面或其他Android组件；


### 测试框架概览

#### 单元测试 

为了方便我们进行测试，需要使用一些测试框架。

- 测试要做的事情是，给出输入，验证输出/状态改变。当然还需要组织测试代码，运行测试；
- 由于被测试的对象可能依赖其他对象，但是单元测试只聚焦于当前类或者方法，所以我们可能还需要一些 mock 框架，可以提供假的依赖对象；

对于 **本地单元测试** 来说，一般会使用如下框架：

- [JUnit](https://junit.org/junit5/) :  单元测试运行及验证；
- [Mockito](https://site.mockito.org/)： mock 框架，支持mock。
- [PowerMockito](https://github.com/powermock/powermock/wiki/Mockito)：对 Mockito 的补充，如支持 mock final 类，static 方法等 mockito 不支持的情况。

对于 **插桩单元测试** 来说，一般需要使用 AndroidX 提供的测试框架，当然本地单元测试中的一些框架也是可以使用的：

- android-test core/rule ： 提供Android测试的Runner，Rule等；
- [Espresso](https://developer.android.google.cn/training/testing/espresso)： 用于Android的各种组件的测试，如Activity，Fragment 等。如：启动一个Activity，点击界面中的某个按钮，验证界面是否按预期的显示了某些view等等。
- Mockito-Android ： Mockito 的 android支持

另外，对于一些不同的情况，可能使用到的其他的框架有：

- [MockWebServer](https://square.github.io/okhttp/#mockwebserver)： 模拟请求服务器

#### 覆盖率统计

有时我们需要可能统计我们的单元测试的代码覆盖率。

- 对于本地单元测试来说，可以通过IDEA自带的运行界面进行统计（支持IDEA默认和Jacoco两种）。

- 对于插桩单元测试来说，通过开启对应的配置也可以生成统计报告（基于jacoco的）。

由于 Android 插桩单元测试无法使用IDEA自带的统计方式进行统计覆盖率，所以我们最好统一使用jacoco进行覆盖率统计。

关于Jacoco覆盖率统计的配置，可参考文章： [Android Jacoco覆盖率统计配置 ](https://hanlyjiang.github.io/post/android-jacoco-gradle-config/)

## 项目配置&运行单元测试

### 项目配置

这里的配置主要指 依赖的配置。

#### 本地单元测试

```kotlin
dependencies {
    val mockitoVersion = "3.3.3"
    val powerMockitoVersion = "2.0.9"
    // 测试依赖
    testImplementation("junit:junit:4.13.2")
    testImplementation("com.squareup.okhttp3:mockwebserver:4.9.3")
    testImplementation("org.mockito:mockito-core:$mockitoVersion")
    testImplementation("org.powermock:powermock-api-mockito2:$powerMockitoVersion")
    testImplementation("org.powermock:powermock-api-junit4:$powerMockitoVersion")
}
```

#### 插桩单元测试

插桩单元测试的配置可参考：[针对 AndroidX Test 设置项目  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/training/testing/set-up-project)

```kotlin
android {
    defaultConfig {
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
}

dependencies {
  	val mockitoVersion = "3.3.3"
		// Android Test Others
    // 架构组件测试
    androidTestImplementation("android.arch.core:core-testing:1.1.1")
    // Mockito-android
    androidTestImplementation("org.mockito:mockito-android:$mockitoVersion")
    // Android test and test-ext
    val androidTestVersion = "1.4.0"
    val extTruthVersion = "1.4.0"
    val extJunitVersion = "1.1.3"
    androidTestImplementation("androidx.test:core:$androidTestVersion")
    androidTestImplementation("androidx.test:runner:$androidTestVersion")
    androidTestImplementation("androidx.test:rules:$androidTestVersion")
    androidTestImplementation("androidx.test.ext:truth:$extTruthVersion")
    androidTestImplementation("androidx.test.ext:junit:$extJunitVersion")
    androidTestImplementation("androidx.test.ext:junit-ktx:$extJunitVersion")
    // Espresso dependencies
    val espressoVersion = "3.4.0"
    androidTestImplementation("androidx.test.espresso:espresso-core:$espressoVersion")
    androidTestImplementation("androidx.test.espresso:espresso-contrib:$espressoVersion")
    androidTestImplementation("androidx.test.espresso:espresso-intents:$espressoVersion")
    androidTestImplementation("androidx.test.espresso:espresso-accessibility:$espressoVersion")
    androidTestImplementation("androidx.test.espresso:espresso-web:$espressoVersion")
    androidTestImplementation("androidx.test.espresso.idling:idling-concurrent:$espressoVersion")
    // The following Espresso dependency can be either "implementation"
    // or "androidTestImplementation", depending on whether you want the
    // dependency to appear on your APK's compile classpath or the test APK
    // classpath.
    androidTestImplementation("androidx.test.espresso:espresso-idling-resource:$espressoVersion")
}
```

### 运行单元测试



