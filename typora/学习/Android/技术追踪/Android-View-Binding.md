# Android View Binding使用

> [视图绑定  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/topic/libraries/view-binding?hl=zh-cn)

## 启用

在build.gradle 中添加如下配置：

```groovy
    buildFeatures {
        viewBinding true
    }
```

然后重新同步Gradle即可；



## 编码使用

其中ViewBinding之后，布局文件会自动编译处一个Binding类，如 activity_main 的布局文件会生成 `ActivityMainBinding` 的辅助类，在代码中使用这个类即可；

XXXBinding类有三个静态方法，都返回一个 XXXBinding类型的对象：

1. ` bind(@NonNull android.view.View view)`
2.  `ActivityMainBinding inflate(LayoutInflater)`  
3. ` ActivityMainBinding inflate(LayoutInflater, ViewGroup, boolean)`

第一个从View对象生成Binding对象，而后面两个则从

```java
```

