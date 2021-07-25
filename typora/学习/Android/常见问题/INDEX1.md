# 常见问题1

## "xxx" is translated here but not found in default locale

### 解决方案

#### 方案零

如果说,并没有添加其他语言的配置可以尝试这么做，看能不能恢复；

1. 打开 `Translation Editor`, 然后关闭;
2. 打开,然后关闭 Strings.xml;
3. 关闭项目,然后重新打开;

> [使用 Translations Editor 本地化界面  | Android 开发者  | Android Developers](https://developer.android.com/studio/write/translations-editor#editaddtext)

#### 方案一

第一个是使用Gradle配置lintOptions来关闭指定的问题检查

```groovy
lintOptions {
     disable 'ExtraTranslation'
}
```

#### 方案二

第二个则是直接在strings.xml的`<resources>`中补上忽略

```xml
<resources tools:ignore="ExtraTranslation" xmlns:tools="http://schemas.android.com/tools">
```



#### 方案三 

直接单条忽略，添加 `translatable="false"` 即可；

```xml
<string name="demo_for_device_fit23" translatable="false">设备信息获取相关API2</string>
```



**参考：** 

> * https://blog.csdn.net/nishigesb123/article/details/90898029
> * 使用 Translations Editor 本地化界面  | Android 开发者  | Android Developers
