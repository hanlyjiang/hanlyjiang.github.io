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



