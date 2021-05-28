# GitlabRunner使用

## Docker Runner的构建加速（配置数据卷）

Docker的Runner非常适合用于作为通用的构建机器，以执行各种不同类型的语言及不同打包工具的编译任务，比方说gradle,maven，npm等等。

一般来说，我们的项目都会使用很多第三方的依赖，而且这些依赖只是在构建需要时从网络上获取，然后构建工具会将这些包缓存在某个目录中，如：

* gradle 一般放置在 `~/.gradle` 目录中，同时也会存储 gradle 的各种版本；
* mvn 一般放置于 `~/.m2` 目录中；

使用容器构建时，这些缓存目录都位于容器内部，也就是每次都需要重新下载，非常浪费时间。所以我们需要能让这些目录可以



## 更改shell执行器的执行shell环境

修改config.toml文件中的runner的配置，明确指定所使用的shell，所有支持的shell可以参考：[Shells supported by GitLab Runner | GitLab](https://docs.gitlab.com/runner/shells/#shells-supported-by-gitlab-runner)

```yaml
...
[[runners]]
  name = "shell executor runner"
  executor = "shell"
  shell = "bash"
...
```

参考： [Shell | GitLab](https://docs.gitlab.com/runner/executors/shell.html#selecting-your-shell)

## 问题

### gitlab-runner的shell执行失败，但是直接机器上执行可以成功

> * [Shells supported by GitLab Runner | GitLab](https://docs.gitlab.com/runner/shells/index.html)
>
> * [Shell | GitLab](https://docs.gitlab.com/runner/executors/shell.html)
> * https://github.com/koalaman/shellcheck/wiki/SC2207

现象非常奇怪，以下情况均成功：

* 直接在机器上执行脚本（通过bash）
* 直接在机器上执行脚本（通过sh）

通过gitlab-runner均失败：

* runner 的shell设置为sh
* runner 的shell设置为bash



修复方式： 将数组的存储变量方式改为直接使用

```shell
#  file_list=($(find . -type f -name "*.yml" -print0 | xargs -0 -I {} grep -H "$service *: *$" {} | grep -v "arm" | awk -F: '{print $1}' | tr "\n" " "))
# 上面变量的写法在gitlab-runner上有问题
#  for file in "${file_list[@]}"; do

# 以下正常工作
  for file in $(find . -type f -name "*.yml" -print0 | xargs -0 -I {} grep -H "$service *: *$" {} | grep -v "arm" | awk -F: '{print $1}' | tr "\n" " "); do
    logInfo 开始修改文件:"$file"
  done
```

#### 补充：shell 在gitlab-runner上的执行方式

ci 文件中定义的script生成一个脚本，然后通过如下方式送到bash中去执行：

```shell
# This command is used if the build should be executed in context
# of another user (the shell executor)
cat generated-bash-script | su --shell /bin/bash --login user

# This command is used if the build should be executed using
# the current user, but in a login environment
cat generated-bash-script | /bin/bash --login

# This command is used if the build should be executed in
# a Docker environment
cat generated-bash-script | /bin/bash
```

> 参考： [Shells supported by GitLab Runner | GitLab](https://docs.gitlab.com/runner/shells/#shbash-shells)