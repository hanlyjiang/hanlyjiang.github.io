# JavaDoc 使用文档

参考：

*  [javadoc (oracle.com)](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javadoc.html)
* [Javadoc - Gradle DSL Version 7.1.1](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.javadoc.Javadoc.html)

用于生成 Java 源文件的API文档的HTML页面。



## 语法

**javadoc** {*packages*|*source-files*} [*options*] [*@argfiles*]

* *packages*

  ​	需要生成文档的包名，通过空格分割多个包名；通过 -subpackages 选项来指定子包名。

  ​	默认情况下javadoc 在当前目录和子目录中寻找对应的包名，不过通过  `-sourcepath` 选项可以指定搜索包的目录列表；

* *source-files*

  ​	源文件，通过空格分隔；

  ​	默认情况下在当前目录搜索源文件。可以通过绝对路径或者相对路径来指定。可以使用通配符。

* *options* 

   	命令行选项，通过空格分隔。参考下方说明。

如，运行下面的命令就可以读取当前目录下的所有java文件，然后在当前目录下生成 javadoc 的 html 文件

```shell
javadoc ./**/*.java
```



## 描述

javadoc 命令解析java源文件中的文档注释中的声明及文档，并生成HTML页面文件。默认情况下，会生成 public，protected级别的如下内容：类，嵌套类（不包括匿名内部类），接口，构造函数，方法和字段。

### Conformance

标准的 doclet 不会校验注释的内容，也不会尝试去纠正其中的错误。同时，输出的内容中也有可能包含一些类似Javascript的可执行内容。在运行 javadoc 命令时，标准的 docket 可以通过提供的 -Xdoclint 选项来帮助用于检测文档注释中的一些通用问题。不过，我们仍然建议你使用其他的工具来检测生成的内容。

### Process Source Files

* 处理java后缀的文件及源文件列表中指定的文件；
* 可以直接指定单独的源文件名称来直接指定需要处理的文件；
* 可以通过以下三种方式避免直接指定文件：
  * 指定包名
  * 通过 -subpackages 选项指定
  * 指定源文件时使用通配符；
* 通过以上三种非直接指定源文件的方式时，只有满足如下要求的文件会被处理
  * 文件名（不包括 .java 后缀）是一个有效的类名；
  * 相对于源码目录顶层的路径是一个可用的包名（将路径转换为.之后）
  * 包语句中包含可用的包名；

**Processing Links**

javadoc 可以在处理过程中为包/类/成员名称添加交叉引用。链接可以出现在如下地方：

* 声明（返回类型，参数类型，field类型）
* See Also 小结（通过@see标记指定）
* 内联文本 (通过`{@link}`生成)
*  通过 `@throws` 生成的异常名称
* *Specified by* links to interface members and *Overrides* links to class members. See [Method Comment Inheritance](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javadoc.html#CHDFAGJH).
* 用于列出包，类及成员的概览表格
* 包盒类的继承树
* 索引

> 可以通过 -link 及 -linkoffline 选项来在运行命令时添加已经链接；

**Processing Details**

javadoc 命令每次运行都会产生一个完整的文档，javadoc 不支持基于之前的成果增量构建，不过 javadoc 命令可以链接到其他运行成果；

javadoc 依赖于java编译器， javadoc 运行过程中会使用 javac 命令来变异声明并忽略成员的实现，会将类的层次生成对应的 HTML 文档。

Javadoc 运行于源文件的不包含方法体的桩文件，所以我们可以在真正实现代码之前使用 javadoc 生成对应的 API 文档。

Javadoc 构建文档的内部结构时，它需要加载所有引用到的类，所以javadoc 命令必须要能够找到所有被引用到的类，如：bootstrap 类，扩展，或者用户类。参考 http://docs.oracle.com/javase/8/docs/technotes/tools/findingclasses.html 了解 javadoc 如何查找类；

一般来说，你自己写的类也需要作为一个扩展被加载，或者把它们加入到 javadoc 命令的 classpath 之中；

### Javadoc Doclets

使用 docket 可以自定义 javadoc 命令输出的内容格式。默认有一个内建的 doclet，我们称之为标准的doclet。可以继承标准的doclet类，编写你自己的 doclet 来生成 HTML，XML，MIF，RTF或者任何你想要输出的格式。

通过 -doclet 来指定自定义的 doclet。如没有指定就使用默认的 doclet。



### Source Files - 源文件



