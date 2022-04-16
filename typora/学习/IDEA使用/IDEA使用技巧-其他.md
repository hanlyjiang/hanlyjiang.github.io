## 查看层次

> https://www.jetbrains.com/help/idea/2020.3/viewing-structure-and-hierarchy-of-the-source-code.html

* 类型层次： ==⌃H==
* 方法层次：==⇧⌘H==
* 调用层次：==⌃⌥H==

## 复制

* 复制文件路径： ==⇧⌘C==

  `/Volumes/HIKVISION/android11/frameworks/base/services/core/java/com/android/server/wm/ActivityTaskManagerService.java`

* 复制方法全路径：==⇧⌥⌘C==

  `com.android.server.wm.ActivityTaskManagerService#startActivityAsUser(android.app.IApplicationThread, java.lang.String, java.lang.String, android.content.Intent, java.lang.String, android.os.IBinder, java.lang.String, int, int, android.app.ProfilerInfo, android.os.Bundle, int, boolean)`



## AndroidStudio 4.2.1 gradle 不显示任务列表

> [Gradle tasks are not showing in the gradle tool window in Android Studio 4.2 - Stack Overflow](https://stackoverflow.com/questions/67405791/gradle-tasks-are-not-showing-in-the-gradle-tool-window-in-android-studio-4-2)

OK, I found why I got this behaviour in android studio 4.2.

It is intended behaviour. I found the answer in this post: https://issuetracker.google.com/issues/185420705.

> Gradle task list is large and slow to populate in Android projects. This feature by default is disabled for performance reasons. You can re-enable it in: Settings | Experimental | Do not build Gradle task list during Gradle sync.

Reload the Gradle project by clicking the "Sync Project with gradle Files" icon and the tasks will appear.

It could be cool that this experimental change is put in the release note of android studio `4.2`.



## UML 插件安装

* [PlantUML integration - IntelliJ IDEs Plugin | Marketplace (jetbrains.com)](https://plugins.jetbrains.com/plugin/7017-plantuml-integration)

> macOS上可能需要安装Graphviz：
>
> `brew install Graphviz`

* [PlantUML Parser - IntelliJ IDEs Plugin | Marketplace (jetbrains.com)](https://plugins.jetbrains.com/plugin/15524-plantuml-parser)
* [PlantUML Diagram Generator - IntelliJ IDEs Plugin | Marketplace (jetbrains.com)](https://plugins.jetbrains.com/plugin/15991-plantuml-diagram-generator)



## Shared Indexes

![image-20211210103431370](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202112101034449.png)



## androidstudio 默认keystore

```shell
keytool -list -v -keystore $USER_HOME/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 命令行

- CMD + Enter 从命令行调用UI任务执行
- CMD + Enter + Shift ： debug gradle task



## 代码模板配置

### 文件头

1. 打开设置

<img src="/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20220412222117224.png" alt="image-20220412222117224" style="zoom: 50%;" />

2. 添加如下配置

   ```java
   /**
   * 
   * @author ${USER} at ${DATE} ${TIME}
   * @version 1.0
   */
   ```

   <img src="/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20220412222305883.png" alt="image-20220412222305883" style="zoom:50%;" />
   
   ### Live  Templates
   
   配置如下：
   
   ![image-20220412222929017](/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20220412222929017.png)

<img src="/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20220412222949569.png" alt="image-20220412222949569" style="zoom:50%;" />

```java
/**
* 
* @author $user$ at $date$ $time$
* @version 1.0
*/
```

