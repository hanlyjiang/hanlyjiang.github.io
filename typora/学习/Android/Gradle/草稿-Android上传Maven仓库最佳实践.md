# Android上传Maven仓库最佳实践

我们开发库时，需要将其上传到 maven 仓库，这个时候一般需要使用 maven-publish 插件，这里我们总结此过程中的 gradle 配置的最佳实践方案。

我们主要有如下考虑：

* 最简单的配置
* 能够上传 javadoc，源码，mapping文件（企业内部）
* 支持记录当前的版本信息：我们通过gradle任务上传版本，但是如果需要定位特定版本的问题，我们如何根据版本找到对应的仓库提交呢？

接下来，我们分步骤来定义各个内容段，最后给出完整的配置，另外，后续我们可以考虑将这些配置提取到一个 gradle 插件之中，以简化配置流程；

使用 gradle kotlin dsl 能够提供更好的体验，我们使用 kotlin dsl 的配置来做示例。建议将 gradle 配置切换到 kotlin dsl。

## 定义 javadoc 任务

首先，我们需要定一个一个 javadoc 的任务，以生成对应的 javadoc ，在库模块的 build 脚本中定义一个任务：

```kotlin
```



