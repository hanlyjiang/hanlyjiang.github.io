# Android日志搜集

## 常用的logcat日志搜集命令

### 获取指定APP的日志

1. 打开APP

    ```shell
    # 打开APP
    # 设置包名
    PK_NAME=com.geo.jiujiangE_release
    ```

2. 获取PID

   ```shell
   APP_PID=$(adb shell ps -o PID -o NAME | grep "$PK_NAME$" |awk '{print $1}')
   echo "$PK_NAME UID=$APP_PID"
   ```
   
   如果没有获取到，可以尝试手动获取并赋值：
   
   ```shell
   # 获取pid
   adb shell ps | grep $PK_NAME
   # 全包名匹配
   $ adb shell ps | grep "$PK_NAME$"
   ```

3. 指定PID获取日志(通过`--pid`)

   ```shell
   adb logcat --pid=$APP_PID -v color
   ```

### 获取crash日志

* 执行 `adb logcat -b crash -v color | tee crash.log`；
* 对APP进行操作，使其Crash；

其他变体：

* 输出到文件：`adb logcat -b crash -f crash.log`





# [官方-Logcat 命令行工具](https://developer.android.google.cn/studio/command-line/logcat?hl=zh-cn)

Logcat 是一个命令行工具，用于转储系统消息日志，包括设备抛出错误时的堆栈轨迹，以及从您的应用使用 `Log` 类写入的消息。

本页介绍了命令行 Logcat 工具，但在 Android Studio 中，您也可以从 **Logcat** 窗口查看日志消息。如需了解如何在 Android Studio 中查看和过滤日志，请参阅[使用 Logcat 写入和查看日志](https://developer.android.google.cn/studio/debug/am-logcat?hl=zh-cn)。

## 日志记录系统概览

Android 日志记录系统是系统进程 `logd` 维护的一组结构化环形缓冲区。这组可用的缓冲区是固定的，并由系统定义。最相关的缓冲区为：`main`（用于存储大多数应用日志）、`system`（用于存储源自 Android 操作系统的消息）和 `crash`（用于存储崩溃日志）。每个日志条目都包含一个优先级（`VERBOSE`、`DEBUG`、`INFO`、`WARNING`、`ERROR` 或 `FATAL`）、一个标识日志来源的标记以及实际的日志消息。

日志记录系统的主接口是共享库 `liblog` 及其头文件 `<android/log.h>`。所有语言特定的日志记录工具最终都会调用函数 `__android_log_write`。默认情况下，它会调用函数 `__android_log_logd_logger`，该函数使用套接字将日志条目发送到 `logd`。从 API 级别 30 开始，可通过调用 `__android_set_log_writer` 更改日志记录函数。如需了解详情，请参阅 [NDK 文档](https://developer.android.google.cn/ndk/reference/group/logging?hl=zh-cn)。

运行 `adb logcat` 显示的日志要经过四个级别的过滤：

1. 编译时过滤：根据编译设置，某些日志可能会从二进制文件中完全移除。例如，可以将 ProGuard 配置为从 Java 代码中移除对 `Log.d` 的调用。

2. 系统属性过滤：`liblog` 会查询一组系统属性以确定要发送到 `logd` 的最低严重级别。如果日志具有 `MyApp` 标记，系统会检查以下属性，并且日志应包含最低严重级别的第一个字母（`V`、`D`、`I`、`W`、`E` 或 `S` 以停用所有日志）：

3. - `log.tag.MyApp`
   - `persist.log.tag.MyApp`
   - `log.tag`
   - `persist.log.tag`

4. 应用过滤：如果未设置任何属性，`liblog` 会使用 `__android_log_set_minimum_priority` 设置的最低优先级。默认设置为 `INFO`。

5. 显示过滤：`adb logcat` 支持其他可减少 `logd` 显示的日志数量的过滤条件。有关详情，[请参阅下文](https://developer.android.google.cn/studio/command-line/logcat?hl=zh-cn#filteringOutput)。

## 命令行语法

如需通过 adb shell 运行 Logcat，一般用法如下：

```
[adb] logcat [<option>] ... [<filter-spec>] ...
```

您可以将 `logcat` 作为 adb 命令运行，也可以直接在模拟器或关联设备的 shell 提示中运行。如需使用 adb 查看日志输出，请转到您的 SDK `platform-tools/` 目录并执行以下命令：

```
adb logcat
```

如需获取 `logcat` 在线帮助，请启动设备，然后执行以下命令：

```
adb logcat --help
```

您可以建立与设备的 shell 连接并执行以下命令：

```
$ adb shell
# logcat
```

### 选项

下表介绍了 `logcat` 的命令行选项。

| 选项                                                         | 说明                                                         |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| `-b <buffer>`                                                | 加载可供查看的备用日志缓冲区，例如 `events` 或 `radio`。默认使用 `main`、`system` 和 `crash` 缓冲区集。请参阅[查看备用日志缓冲区](https://developer.android.google.cn/tools/debugging/debugging-log?hl=zh-cn#alternativeBuffers)。 |
| `-c, --clear`                                                | 清除（清空）所选的缓冲区并退出。默认缓冲区集为 `main`、`system` 和 `crash`。如需清除所有缓冲区，请使用 `-b all -c`。 |
| `-e <expr>, --regex=<expr>`                                  | 只输出日志消息与 `<expr>` 匹配的行，其中 `<expr>` 是正则表达式。 |
| `-m <count>, --max-count=<count>`                            | 输出 `<count>` 行后退出。这样是为了与 `--regex` 配对，但可以独立运行。 |
| `--print`                                                    | 与 `--regex` 和 `--max-count` 配对，使内容绕过正则表达式过滤器，但仍能够在获得适当数量的匹配时停止。 |
| `-d`                                                         | 将日志转储到屏幕并退出。                                     |
| `-f <filename>`                                              | 将日志消息输出写入 `<filename>`。默认值为 `stdout`。         |
| `-g, --buffer-size`                                          | 输出指定日志缓冲区的大小并退出。                             |
| `-n <count>`                                                 | 将轮替日志的数量上限设置为 `<count>`。默认值为 4。需要使用 `-r` 选项。 |
| `-r <kbytes>`                                                | 每输出 `<kbytes>` 时轮替日志文件。默认值为 16。需要 `-f` 选项。 |
| `-s`                                                         | 相当于过滤器表达式 `'*:S'`；它将所有标记的优先级设为“静默”，并用于放在可添加内容的过滤器表达式列表之前。如需了解详情，请转到介绍[过滤日志输出](https://developer.android.google.cn/studio/command-line/logcat?hl=zh-cn#filteringOutput)的部分。 |
| `-v <format>`                                                | 设置日志消息的输出格式。默认格式为 `threadtime`。如需查看支持的格式列表，请参阅介绍[控制日志输出格式](https://developer.android.google.cn/studio/command-line/logcat?hl=zh-cn#outputFormat)的部分。 |
| `-D, --dividers`                                             | 输出各个日志缓冲区之间的分隔线。                             |
| `-c`                                                         | 清空（清除）整个日志并退出。                                 |
| `-t <count>`                                                 | 仅输出最新的行数。此选项包括 `-d` 功能。                     |
| `-t '<time>'`                                                | 输出自指定时间以来的最新行。此选项包括 `-d` 功能。如需了解如何引用带有嵌入空格的参数，请参阅 [-P 选项](https://developer.android.google.cn/studio/command-line/logcat?hl=zh-cn#quotes)。`adb logcat -t '01-26 20:52:41.820'` |
| `-T <count>`                                                 | 输出自指定时间以来的最新行数。此选项不包括 `-d` 功能。       |
| `-T '<time>'`                                                | 输出自指定时间以来的最新行。此选项不包括 `-d` 功能。如需了解如何引用带有嵌入空格的参数，请参阅 [-P 选项](https://developer.android.google.cn/studio/command-line/logcat?hl=zh-cn#quotes)。`adb logcat -t '01-26 20:52:41.820'` |
| `-L, -last`                                                  | 在最后一次重新启动之前转储日志。                             |
| `-B, --binary`                                               | 以二进制文件形式输出日志。                                   |
| `-S, --statistics`                                           | 在输出中包含统计信息，以帮助您识别和定位日志垃圾信息发送者。 |
| `-G <size>`                                                  | 设置日志环形缓冲区的大小。可以在结尾处添加 `K` 或 `M`，以指示单位为千字节或兆字节。 |
| `-p, --prune`                                                | 输出（读取）当前的允许 (`white`) 列表和拒绝 (`black`) 列表，不采用任何参数，如下所示：`adb logcat -p ` |
| `-P '<list> ...'--prune '<list> ...' -P '<white_and_black_list>'` | 写入（设置）允许 (`white`) 列表和拒绝 (`black`) 列表以出于特定目的调整日志记录内容。您可以提供允许 (`<white>`) 列表和拒绝 (`~<black>`) 列表条目的混合内容，其中 `<white>` 或 `<black>` 可以是 UID、UID/PID 或 /PID。在 Logcat 统计信息 (`logcat -S`) 的指导下，您可以考虑出于各种目的调整允许 (`white`) 列表和拒绝 (`black`) 列表，例如：<br/>- 通过 UID 选择使特定日志记录内容具有最长保留期限。<br/>阻止人 (UID) 或物 (PID) 消耗相应资源，以帮助增加日志跨度，从而更深入地了解正在诊断的问题。<br/><br/>默认情况下，日志记录系统会自动以动态方式阻止日志统计信息中最严重的违规内容，以便为新的日志消息腾出空间。一旦它用尽启发法，系统便会删除最旧的条目，以便为新消息腾出空间。<br/><br/>添加许可名单 (`whitelist`) 可保护您的 Android 识别码 (AID)，它会变成进程的 AID 和 GID，而不会被声明为违规内容；添加拒绝列表有助于在相应内容被视为最严重的违规内容之前即释放空间。您可以选择删除内容的程度和频率；也可以关闭删除功能，这样，系统便仅会移除各个日志缓冲区中最旧条目的内容。<br/><br/>**引号**<br/>`adb logcat` 不会保留引号，因此指定允许 (`white`) 列表和拒绝 (`black`) 列表的语法如下所示：<br/><br/>`adb logcat -P '"<white_and_blacklist>"'`<br/> 或者  `adb shell $ logcat -P '<white_and_blacklist>' `<br/><br/>以下示例指定了一个包含 PID 32676 和 UID 675 的允许 (`white`) 列表，以及一个包含 PID 32677 和 UID 897 的拒绝 (`black`) 列表。拒绝列表中的 PID 32677 经过加权处理，以便可以更快删除。<br/><br/>`adb logcat -P '"/32676 675 ~/32677 897"' `<br/>其他您可以使用的允许 (`white`) 列表和拒绝 (`black`) 列表命令变体如下所示：<br/><br/>`~! worst uid blacklist ~1000/! worst pid in system (1000) ` |
| `--pid=<pid> ...`                                            | 仅输出来自给定 PID 的日志。                                  |
| `--wrap`                                                     | 休眠 2 小时或者当缓冲区即将封装时（两者取其先）。通过提供即将封装唤醒来提高轮询的效率。 |

## 过滤日志输出（tag:优先级 过滤）

- 日志消息的标记是一个简短的字符串，指示消息所源自的系统组件（例如，“View”表示视图系统）。
- 优先级是以下字符值之一（按照从最低到最高优先级的顺序排列）：
- - `V`：详细（最低优先级）
  - `D`：调试
  - `I`：信息
  - `W`：警告
  - `E`：错误
  - `F`：严重错误
  - `S`：静默（最高优先级，绝不会输出任何内容）

通过运行 Logcat 并观察每条消息的前两列，您可以获取系统中使用的带有优先级的标记列表，格式为 `<priority>/<tag>`。

以下是使用 `logcat -v brief output` 命令获取的简短 Logcat 输出的示例。它表明消息与优先级“I”和标记“ActivityManager”相关：

```
I/ActivityManager(  585): Starting activity: Intent { action=android.intent.action...}
```

如要将日志输出降低到可管理的水平，您可以使用过滤器表达式限制日志输出。通过过滤器表达式，您可以向系统指明您感兴趣的标记/优先级组合，系统会针对指定的标记抑制其他消息。

过滤器表达式采用 `tag:priority ...` 格式，其中 `tag` 指示您感兴趣的标记，`priority` 指示可针对该标记报告的最低优先级。不低于指定优先级的标记的消息会写入日志。您可以在一个过滤器表达式中提供任意数量的 `tag:priority` 规范。一系列规范使用空格分隔。

以下是一个过滤器表达式的示例，该表达式会抑制除标记为“ActivityManager”、优先级不低于“信息”的日志消息，以及标记为“MyApp”、优先级不低于“调试”的日志消息以外的所有其他日志消息：

```
adb logcat ActivityManager:I MyApp:D *:S
```

上述表达式中最后一个元素 `*:S` 将所有标记的优先级设为“静默”，从而确保系统仅显示标记为“ActivityManager”和“MyApp”的日志消息。使用 `*:S` 是确保日志输出受限于您已明确指定的过滤器的绝佳方式，它可以让过滤器充当日志输出的“许可名单”。

以下过滤器表达式显示了优先级不低于“警告”的所有标记的所有日志消息：

```
adb logcat *:W
```

如果您从开发计算机运行 Logcat（相对于在远程 adb shell 上运行），则也可以通过导出环境变量 `ANDROID_LOG_TAGS` 的值设置默认过滤器表达式：

```
export ANDROID_LOG_TAGS="ActivityManager:I MyApp:D *:S"
```

请注意，如果您从远程 shell 或使用 `adb shell logcat` 运行 Logcat，系统不会将 `ANDROID_LOG_TAGS` 过滤器导出到模拟器/设备实例。

## 控制日志输出格式（-v）

除标记和优先级外，日志消息还包含许多元数据字段。您可以修改消息的输出格式，以便它们显示特定的元数据字段。为此，您可以使用 `-v` 选项，并指定下列某一受支持的输出格式。

- `brief`：显示优先级、标记以及发出消息的进程的 PID。
- `long`：显示所有元数据字段，并使用空白行分隔消息。
- `process`：仅显示 PID。
- `raw`：显示不包含其他元数据字段的原始日志消息。
- `tag`：仅显示优先级和标记。
- `thread:`：旧版格式，显示优先级、PID 以及发出消息的线程的 TID。
- `threadtime`（默认值）：显示日期、调用时间、优先级、标记、PID 以及发出消息的线程的 TID。
- `time`：显示日期、调用时间、优先级、标记以及发出消息的进程的 PID。

启动 Logcat 时，您可以使用 `-v` 选项指定所需的输出格式：

```
[adb] logcat [-v <format>]
```

以下示例显示了如何生成输出格式为 `thread` 的消息：

```
adb logcat -v thread
```

请注意，您只能使用 `-v` 选项指定一种输出格式，但可以指定任意数量的有意义的修饰符。Logcat 会忽略没有意义的修饰符。



### brief 

```shell
adb logcat -b crash -v color -v brief
--------- beginning of crash
F/libc    (  594): Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 594 (init), pid 594 (init)
F/libc    (  594): crash_dump helper failed to exec
F/libc    ( 1636): Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 1636 (init), pid 1636 (init)
F/libc    ( 1636): crash_dump helper failed to exec
E/AndroidRuntime( 6726): FATAL EXCEPTION: main
E/AndroidRuntime( 6726): Process: com.geostar.roboxtest:plugin, PID: 6726
E/AndroidRuntime( 6726): java.lang.IllegalAccessError: 本类仅在插件进程使用
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.manager.PluginManagerService.<init>(PluginManagerService.java:48)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.manager.PluginManagerProvider.onCreate(PluginManagerProvider.java:120)
E/AndroidRuntime( 6726): 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2421)
E/AndroidRuntime( 6726): 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2386)
E/AndroidRuntime( 6726): 	at android.app.ActivityThread.installProvider(ActivityThread.java:7635)
E/AndroidRuntime( 6726): 	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7113)
E/AndroidRuntime( 6726): 	at java.lang.reflect.Method.invoke(Native Method)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:81)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:67)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.android.HackActivityThread.installContentProviders(HackActivityThread.java:181)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginInjector.installContentProviders(PluginInjector.java:123)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher.callPluginApplicationOnCreate(PluginLauncher.java:226)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher.initApplication(PluginLauncher.java:168)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher.access$100(PluginLauncher.java:57)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:150)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:95)
E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.SyncRunnable.run(SyncRunnable.java:22)
E/AndroidRuntime( 6726): 	at android.os.Handler.handleCallback(Handler.java:938)
E/AndroidRuntime( 6726): 	at android.os.Handler.dispatchMessage(Handler.java:99)
E/AndroidRuntime( 6726): 	at android.os.Looper.loop(Looper.java:236)
E/AndroidRuntime( 6726): 	at android.app.ActivityThread.main(ActivityThread.java:8067)
E/AndroidRuntime( 6726): 	at java.lang.reflect.Method.invoke(Native Method)
E/AndroidRuntime( 6726): 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:656)
E/AndroidRuntime( 6726): 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:967)
```



### long

单独的行中显示了时间日期，进程PID及进程名称还有日志级别

```shell
adb logcat -b crash -v color -v long
--------- beginning of crash
[ 12-23 11:52:35.646   594:  594 F/libc     ]
Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 594 (init), pid 594 (init)

[ 12-23 11:52:35.658   594:  594 F/libc     ]
crash_dump helper failed to exec

[ 05-17 14:46:52.137  1636: 1636 F/libc     ]
Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 1636 (init), pid 1636 (init)

[ 05-17 14:46:52.206  1636: 1636 F/libc     ]
crash_dump helper failed to exec

[ 05-17 16:41:10.276  6726: 6726 E/AndroidRuntime ]
FATAL EXCEPTION: main
Process: com.geostar.roboxtest:plugin, PID: 6726
java.lang.IllegalAccessError: 本类仅在插件进程使用
	at com.limpoxe.fairy.manager.PluginManagerService.<init>(PluginManagerService.java:48)
	at com.limpoxe.fairy.manager.PluginManagerProvider.onCreate(PluginManagerProvider.java:120)
	at android.content.ContentProvider.attachInfo(ContentProvider.java:2421)
	at android.content.ContentProvider.attachInfo(ContentProvider.java:2386)
	at android.app.ActivityThread.installProvider(ActivityThread.java:7635)
	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7113)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:81)
	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:67)
	at com.limpoxe.fairy.core.android.HackActivityThread.installContentProviders(HackActivityThread.java:181)
	at com.limpoxe.fairy.core.PluginInjector.installContentProviders(PluginInjector.java:123)
	at com.limpoxe.fairy.core.PluginLauncher.callPluginApplicationOnCreate(PluginLauncher.java:226)
	at com.limpoxe.fairy.core.PluginLauncher.initApplication(PluginLauncher.java:168)
	at com.limpoxe.fairy.core.PluginLauncher.access$100(PluginLauncher.java:57)
	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:150)
	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:95)
	at com.limpoxe.fairy.core.SyncRunnable.run(SyncRunnable.java:22)
	at android.os.Handler.handleCallback(Handler.java:938)
	at android.os.Handler.dispatchMessage(Handler.java:99)
	at android.os.Looper.loop(Looper.java:236)
	at android.app.ActivityThread.main(ActivityThread.java:8067)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:656)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:967)
```

### process

注意每一行头部的 `E( 6726)` 和尾部的`(AndroidRuntime)`

```shell
adb logcat -b crash -v color -v process
--------- beginning of crash
F(  594) Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 594 (init), pid 594 (init)  (libc)
F(  594) crash_dump helper failed to exec  (libc)
F( 1636) Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 1636 (init), pid 1636 (init)  (libc)
F( 1636) crash_dump helper failed to exec  (libc)
E( 6726) FATAL EXCEPTION: main  (AndroidRuntime)
E( 6726) Process: com.geostar.roboxtest:plugin, PID: 6726  (AndroidRuntime)
E( 6726) java.lang.IllegalAccessError: 本类仅在插件进程使用  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.manager.PluginManagerService.<init>(PluginManagerService.java:48)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.manager.PluginManagerProvider.onCreate(PluginManagerProvider.java:120)  (AndroidRuntime)
E( 6726) 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2421)  (AndroidRuntime)
E( 6726) 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2386)  (AndroidRuntime)
E( 6726) 	at android.app.ActivityThread.installProvider(ActivityThread.java:7635)  (AndroidRuntime)
E( 6726) 	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7113)  (AndroidRuntime)
E( 6726) 	at java.lang.reflect.Method.invoke(Native Method)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:81)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:67)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.core.android.HackActivityThread.installContentProviders(HackActivityThread.java:181)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.core.PluginInjector.installContentProviders(PluginInjector.java:123)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.core.PluginLauncher.callPluginApplicationOnCreate(PluginLauncher.java:226)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.core.PluginLauncher.initApplication(PluginLauncher.java:168)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.core.PluginLauncher.access$100(PluginLauncher.java:57)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:150)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:95)  (AndroidRuntime)
E( 6726) 	at com.limpoxe.fairy.core.SyncRunnable.run(SyncRunnable.java:22)  (AndroidRuntime)
E( 6726) 	at android.os.Handler.handleCallback(Handler.java:938)  (AndroidRuntime)
E( 6726) 	at android.os.Handler.dispatchMessage(Handler.java:99)  (AndroidRuntime)
E( 6726) 	at android.os.Looper.loop(Looper.java:236)  (AndroidRuntime)
E( 6726) 	at android.app.ActivityThread.main(ActivityThread.java:8067)  (AndroidRuntime)
E( 6726) 	at java.lang.reflect.Method.invoke(Native Method)  (AndroidRuntime)
E( 6726) 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:656)  (AndroidRuntime)
E( 6726) 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:967)  (AndroidRuntime)
```



### raw

只有日志，不包含元数据

```shell
adb logcat -b crash -v color -v raw
--------- beginning of crash
Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 594 (init), pid 594 (init)
crash_dump helper failed to exec
Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 1636 (init), pid 1636 (init)
crash_dump helper failed to exec
FATAL EXCEPTION: main
Process: com.geostar.roboxtest:plugin, PID: 6726
java.lang.IllegalAccessError: 本类仅在插件进程使用
	at com.limpoxe.fairy.manager.PluginManagerService.<init>(PluginManagerService.java:48)
	at com.limpoxe.fairy.manager.PluginManagerProvider.onCreate(PluginManagerProvider.java:120)
	at android.content.ContentProvider.attachInfo(ContentProvider.java:2421)
	at android.content.ContentProvider.attachInfo(ContentProvider.java:2386)
	at android.app.ActivityThread.installProvider(ActivityThread.java:7635)
	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7113)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:81)
	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:67)
	at com.limpoxe.fairy.core.android.HackActivityThread.installContentProviders(HackActivityThread.java:181)
	at com.limpoxe.fairy.core.PluginInjector.installContentProviders(PluginInjector.java:123)
	at com.limpoxe.fairy.core.PluginLauncher.callPluginApplicationOnCreate(PluginLauncher.java:226)
	at com.limpoxe.fairy.core.PluginLauncher.initApplication(PluginLauncher.java:168)
	at com.limpoxe.fairy.core.PluginLauncher.access$100(PluginLauncher.java:57)
	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:150)
	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:95)
	at com.limpoxe.fairy.core.SyncRunnable.run(SyncRunnable.java:22)
	at android.os.Handler.handleCallback(Handler.java:938)
	at android.os.Handler.dispatchMessage(Handler.java:99)
	at android.os.Looper.loop(Looper.java:236)
	at android.app.ActivityThread.main(ActivityThread.java:8067)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:656)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:967)
```

### tag

仅显示tag及优先级

```shell
adb logcat -b crash -v color -v tag
--------- beginning of crash
F/libc    : Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 594 (init), pid 594 (init)
F/libc    : crash_dump helper failed to exec
F/libc    : Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 1636 (init), pid 1636 (init)
F/libc    : crash_dump helper failed to exec
E/AndroidRuntime: FATAL EXCEPTION: main
E/AndroidRuntime: Process: com.geostar.roboxtest:plugin, PID: 6726
E/AndroidRuntime: java.lang.IllegalAccessError: 本类仅在插件进程使用
E/AndroidRuntime: 	at com.limpoxe.fairy.manager.PluginManagerService.<init>(PluginManagerService.java:48)
E/AndroidRuntime: 	at com.limpoxe.fairy.manager.PluginManagerProvider.onCreate(PluginManagerProvider.java:120)
E/AndroidRuntime: 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2421)
E/AndroidRuntime: 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2386)
E/AndroidRuntime: 	at android.app.ActivityThread.installProvider(ActivityThread.java:7635)
E/AndroidRuntime: 	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7113)
E/AndroidRuntime: 	at java.lang.reflect.Method.invoke(Native Method)
E/AndroidRuntime: 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:81)
E/AndroidRuntime: 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:67)
E/AndroidRuntime: 	at com.limpoxe.fairy.core.android.HackActivityThread.installContentProviders(HackActivityThread.java:181)
E/AndroidRuntime: 	at com.limpoxe.fairy.core.PluginInjector.installContentProviders(PluginInjector.java:123)
E/AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher.callPluginApplicationOnCreate(PluginLauncher.java:226)
E/AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher.initApplication(PluginLauncher.java:168)
E/AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher.access$100(PluginLauncher.java:57)
E/AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:150)
E/AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:95)
E/AndroidRuntime: 	at com.limpoxe.fairy.core.SyncRunnable.run(SyncRunnable.java:22)
E/AndroidRuntime: 	at android.os.Handler.handleCallback(Handler.java:938)
E/AndroidRuntime: 	at android.os.Handler.dispatchMessage(Handler.java:99)
E/AndroidRuntime: 	at android.os.Looper.loop(Looper.java:236)
E/AndroidRuntime: 	at android.app.ActivityThread.main(ActivityThread.java:8067)
E/AndroidRuntime: 	at java.lang.reflect.Method.invoke(Native Method)
E/AndroidRuntime: 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:656)
E/AndroidRuntime: 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:967)
```

### thread

```shell
adb logcat -b crash -v color -v thread
--------- beginning of crash
F(  594:  594) Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 594 (init), pid 594 (init)
F(  594:  594) crash_dump helper failed to exec
F( 1636: 1636) Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 1636 (init), pid 1636 (init)
F( 1636: 1636) crash_dump helper failed to exec
E( 6726: 6726) FATAL EXCEPTION: main
E( 6726: 6726) Process: com.geostar.roboxtest:plugin, PID: 6726
E( 6726: 6726) java.lang.IllegalAccessError: 本类仅在插件进程使用
E( 6726: 6726) 	at com.limpoxe.fairy.manager.PluginManagerService.<init>(PluginManagerService.java:48)
E( 6726: 6726) 	at com.limpoxe.fairy.manager.PluginManagerProvider.onCreate(PluginManagerProvider.java:120)
E( 6726: 6726) 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2421)
E( 6726: 6726) 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2386)
E( 6726: 6726) 	at android.app.ActivityThread.installProvider(ActivityThread.java:7635)
E( 6726: 6726) 	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7113)
E( 6726: 6726) 	at java.lang.reflect.Method.invoke(Native Method)
E( 6726: 6726) 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:81)
E( 6726: 6726) 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:67)
E( 6726: 6726) 	at com.limpoxe.fairy.core.android.HackActivityThread.installContentProviders(HackActivityThread.java:181)
E( 6726: 6726) 	at com.limpoxe.fairy.core.PluginInjector.installContentProviders(PluginInjector.java:123)
E( 6726: 6726) 	at com.limpoxe.fairy.core.PluginLauncher.callPluginApplicationOnCreate(PluginLauncher.java:226)
E( 6726: 6726) 	at com.limpoxe.fairy.core.PluginLauncher.initApplication(PluginLauncher.java:168)
E( 6726: 6726) 	at com.limpoxe.fairy.core.PluginLauncher.access$100(PluginLauncher.java:57)
E( 6726: 6726) 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:150)
E( 6726: 6726) 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:95)
E( 6726: 6726) 	at com.limpoxe.fairy.core.SyncRunnable.run(SyncRunnable.java:22)
E( 6726: 6726) 	at android.os.Handler.handleCallback(Handler.java:938)
E( 6726: 6726) 	at android.os.Handler.dispatchMessage(Handler.java:99)
E( 6726: 6726) 	at android.os.Looper.loop(Looper.java:236)
E( 6726: 6726) 	at android.app.ActivityThread.main(ActivityThread.java:8067)
E( 6726: 6726) 	at java.lang.reflect.Method.invoke(Native Method)
E( 6726: 6726) 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:656)
E( 6726: 6726) 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:967)
```

### threadtime

默认

```shell
adb logcat -b crash -v color -v threadtime
--------- beginning of crash
12-23 11:52:35.646   594   594 F libc    : Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 594 (init), pid 594 (init)
12-23 11:52:35.658   594   594 F libc    : crash_dump helper failed to exec
05-17 14:46:52.137  1636  1636 F libc    : Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 1636 (init), pid 1636 (init)
05-17 14:46:52.206  1636  1636 F libc    : crash_dump helper failed to exec
05-17 16:41:10.276  6726  6726 E AndroidRuntime: FATAL EXCEPTION: main
05-17 16:41:10.276  6726  6726 E AndroidRuntime: Process: com.geostar.roboxtest:plugin, PID: 6726
05-17 16:41:10.276  6726  6726 E AndroidRuntime: java.lang.IllegalAccessError: 本类仅在插件进程使用
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.manager.PluginManagerService.<init>(PluginManagerService.java:48)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.manager.PluginManagerProvider.onCreate(PluginManagerProvider.java:120)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2421)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2386)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at android.app.ActivityThread.installProvider(ActivityThread.java:7635)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7113)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at java.lang.reflect.Method.invoke(Native Method)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:81)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:67)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.core.android.HackActivityThread.installContentProviders(HackActivityThread.java:181)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.core.PluginInjector.installContentProviders(PluginInjector.java:123)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher.callPluginApplicationOnCreate(PluginLauncher.java:226)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher.initApplication(PluginLauncher.java:168)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher.access$100(PluginLauncher.java:57)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:150)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:95)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.limpoxe.fairy.core.SyncRunnable.run(SyncRunnable.java:22)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at android.os.Handler.handleCallback(Handler.java:938)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at android.os.Handler.dispatchMessage(Handler.java:99)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at android.os.Looper.loop(Looper.java:236)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at android.app.ActivityThread.main(ActivityThread.java:8067)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at java.lang.reflect.Method.invoke(Native Method)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:656)
05-17 16:41:10.276  6726  6726 E AndroidRuntime: 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:967)
```



### time

- `time`：显示日期、调用时间、优先级、标记以及发出消息的进程的 PID。

```shell
adb logcat -b crash -v color -v time
--------- beginning of crash
12-23 11:52:35.646 F/libc    (  594): Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 594 (init), pid 594 (init)
12-23 11:52:35.658 F/libc    (  594): crash_dump helper failed to exec
05-17 14:46:52.137 F/libc    ( 1636): Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 1636 (init), pid 1636 (init)
05-17 14:46:52.206 F/libc    ( 1636): crash_dump helper failed to exec
05-17 16:41:10.276 E/AndroidRuntime( 6726): FATAL EXCEPTION: main
05-17 16:41:10.276 E/AndroidRuntime( 6726): Process: com.geostar.roboxtest:plugin, PID: 6726
05-17 16:41:10.276 E/AndroidRuntime( 6726): java.lang.IllegalAccessError: 本类仅在插件进程使用
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.manager.PluginManagerService.<init>(PluginManagerService.java:48)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.manager.PluginManagerProvider.onCreate(PluginManagerProvider.java:120)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2421)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at android.content.ContentProvider.attachInfo(ContentProvider.java:2386)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at android.app.ActivityThread.installProvider(ActivityThread.java:7635)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at android.app.ActivityThread.installContentProviders(ActivityThread.java:7113)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at java.lang.reflect.Method.invoke(Native Method)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:81)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.util.RefInvoker.invokeMethod(RefInvoker.java:67)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.android.HackActivityThread.installContentProviders(HackActivityThread.java:181)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginInjector.installContentProviders(PluginInjector.java:123)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher.callPluginApplicationOnCreate(PluginLauncher.java:226)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher.initApplication(PluginLauncher.java:168)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher.access$100(PluginLauncher.java:57)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:150)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.PluginLauncher$1.run(PluginLauncher.java:95)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.limpoxe.fairy.core.SyncRunnable.run(SyncRunnable.java:22)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at android.os.Handler.handleCallback(Handler.java:938)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at android.os.Handler.dispatchMessage(Handler.java:99)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at android.os.Looper.loop(Looper.java:236)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at android.app.ActivityThread.main(ActivityThread.java:8067)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at java.lang.reflect.Method.invoke(Native Method)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:656)
05-17 16:41:10.276 E/AndroidRuntime( 6726): 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:967)
```

## 格式修饰符（-v）

格式修饰符依据以下一个或多个修饰符的任意组合更改 Logcat 输出。如要指定格式修饰符，请使用 `-v` 选项，如下所示：

```
adb logcat -b all -v color -d
```

每个 Android 日志消息都有一个与之相关联的标记和优先级。您可以将任何格式修饰符与以下任一格式选项进行组合：`brief`、`long`、`process`、`raw`、`tag`、`thread`、`threadtime` 和 `time`。

您可以通过在命令行中输入 `logcat -v --help` 获取格式修饰符详细信息。

- `color`：使用不同的颜色来显示每个优先级。
- `descriptive`：显示日志缓冲区事件说明。此修饰符仅影响事件日志缓冲区消息，不会对其他非二进制文件缓冲区产生任何影响。事件说明取自 event-log-tags 数据库。
- `epoch`：显示自 1970 年 1 月 1 日以来的时间（以秒为单位）。
- `monotonic`：显示自上次启动以来的时间（以 CPU 秒为单位）。
- `printable`：确保所有二进制日志记录内容都进行了转义。
- `uid`：如果访问控制允许，则显示 UID 或记录的进程的 Android ID。
- `usec`：显示精确到微秒的时间。
- `UTC`：显示 UTC 时间。
- `year`：将年份添加到显示的时间。
- `zone`：将本地时区添加到显示的时间。

## 查看备用日志缓冲区（-b）

Android 日志记录系统为日志消息保留了多个环形缓冲区，而且并非所有的日志消息都会发送到默认的环形缓冲区。如要查看其他日志消息，您可以使用 `-b` 选项运行 `logcat` 命令，以请求查看备用的环形缓冲区。您可以查看下列任意备用缓冲区：

- `radio`：查看包含无线装置/电话相关消息的缓冲区。
- `events`：查看已经过解译的二进制系统事件缓冲区消息。
- `main`：查看主日志缓冲区（默认），不包含系统和崩溃日志消息。
- `system`：查看系统日志缓冲区（默认）。
- `crash`：查看崩溃日志缓冲区（默认）。
- `all`：查看所有缓冲区。
- `default`：报告 `main`、`system` 和 `crash` 缓冲区。

以下是 `-b` 选项的用法：

```
[adb] logcat [-b <buffer>]
```

以下示例显示了如何查看包含无线装置和电话相关消息的日志缓冲区。

```
adb logcat -b radio
```

此外，您也可以为要输出的所有缓冲区指定多个 `-b` 标记，如下所示：

```
logcat -b main -b radio -b events
```

您可以指定一个 `-b` 标记，后跟缓冲区逗号分隔列表，例如：

```
logcat -b main,radio,events
```

## 通过代码记录日志

通过 `Log` 类，您可以在代码中创建日志条目，而这些条目会显示在 Logcat 工具中。常用的日志记录方法包括：

- `Log.v(String, String)`（详细）
- `Log.d(String, String)`（调试）
- `Log.i(String, String)`（信息）
- `Log.w(String, String)`（警告）
- `Log.e(String, String)`（错误）

例如，使用以下调用：

[Kotlin](https://developer.android.google.cn/studio/command-line/logcat?hl=zh-cn#kotlin)[Java](https://developer.android.google.cn/studio/command-line/logcat?hl=zh-cn#java)

```kotlin
Log.i("MyActivity", "MyClass.getView() — get item number $position")
```

Logcat 输出类似如下：

```
I/MyActivity( 1557): MyClass.getView() — get item number 1
```