# Android-Gradle相关错误

## 参考文档

* [Android Gradle plugin API reference  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/reference/tools/gradle-api)



## offline mode

报错如下：

```shell
Execution failed for task ':lib_ui_prodialog:publishReleasePublicationToSonartypeRepository'.
> Failed to publish publication 'release' to repository 'Sonartype'
   > No cached resource 'https://oss.sonatype.org/service/local/staging/deploy/maven2/com/github/hanlyjiang/pro-dialog/0.0.1-SNAPSHOT/maven-metadata.xml' available for offline mode
```

新版关闭离线模式入口变化了，以前在settings中，现在位于单独的工具窗口

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202202232209102.png" alt="image-20220223220932048" style="zoom:50%;" />

偏好设置中的Gradle设置变这样了：

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202202232209935.png" alt="image-20220223220956903" style="zoom:50%;" />



### ♾️ 无限同步

表现为切换一个tab标签🏷️，就会自动同步gradle，然后报错，报错的文件不对，无法编辑真正需要编辑的文件。

关掉这个开关就可以了。

![image-20220312005939736](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202203120059806.png)
