# Kotlin 文档写法

## 简介

Kotlin 文档使用 KDoc 进行编写，使用 [Dokka](https://github.com/Kotlin/dokka) 生成，Dokka 有Gradle插件可供使用。

KDoc 结合了JavaDoc语法格式的**块标签**及**Markdown**，其中，块标签针对Kotlin的特殊结构进行了扩展，Markdown则用于**行内标记**。

> **名词：**
>
> - block tags： 块标签
> - inline markup： 行内标记
>
> **参考：**
>
>  [Document Kotlin code: KDoc and Dokka | Kotlin (kotlinlang.org)](https://kotlinlang.org/docs/kotlin-doc.html)

## KDoc 语法格式

* **形式：**使用和JavaDoc 类似的形式作为注释

  ```kotlin
  /** 起始
  * 	中间
  * 	中间
  */  结束
  ```

* **内容**：

  * 第一个段落为**简要描述**；
  * 其他的为**详细描述**，简要描述和详细描述使用一个空行分隔；
  * **块标签**使用一个以 `@`开头的新行开始

  ```kotlin
  /**
   * A group of *members*.
   *
   * This class has no useful logic; it's just a documentation example.
   *
   * @param T the type of a member in this group.
   * @property name the name of this group.
   * @constructor Creates an empty group.
   */
  class Group<T>(val name: String) {
      /**
       * Adds a [member] to this group.
       * @return the new size of the group.
       */
      fun add(member: T): Int { ... }
  }
  ```

## 块标签

### @param name

#### 标记内容： 

- 函数参数
- 类的类型参数
- 函数的属性

#### 格式

有如下两种等价写法：

* `@param name 描述`
* `@param[name] 描述`

### @return

标记函数返回值

### @constructor

标记类的**主构造函数**

### @receiver

标记扩展函数的接收器

### @property name

- 标记类属性

- 用途：可用于**标记主构造函数中的属性**（因为不方便直接在主构造函数的属性定义前面添加文档注释）



### @throws class, @exception class﻿

- 标记方法可能抛出的异常

> 由于Kotlin中没有受检异常，所以不知道所有可能抛出的异常，这个注解主要用于对外提供拥有的信息

### @sample identifier﻿

直接在文档中嵌入identifier﻿所指向的函数体，用于说明用法。

### @see identifier

添加一个链接到指定的类或者方法

### @author

作者

### @since

指定引入该元素时的软件版本

### @suppress﻿

将元素从生成的文档中排除。用于非公开但是希望对对比可见的API

### @Deprecated

同Java 的 `@deprecated`





## 行内标记

KDoc 使用正常的Markdown格式作为行内标记的书写形式，同时添加了链接到代码中其他元素的简便的书写格式。

### 链接到元素

**支持：**

- 类
- 方法
- 属性
- 参数

**写法：**

- 方括号包裹对应元素的名称
- 基本写法：` Use the method [foo] for this purpose.`
- 自定义链接的标签：`Use [this method][foo] for this purpose.`
- 直接指定限定名：`Use [kotlin.reflect.KClass.properties] to enumerate the properties of the class.`
  - 不需要JavaDoc中的#号
  - 导入过的包在文档中也可以不用通过限定名引用
  - 不支持区分重载方法

## 模块及包文档

- 用于给整个模块或者模块中的一个包提供文档。
- 通过独立的Markdown文件提供，通过 include 传递文件路径到 Dokka 命令行或者对应的Gradle/Ant/Maven插件

文件写法：

- 使用一级标题说明包及模块，一级标题必须使用 `Module <module name>` 或 `Package <package qualified name>` 的形式。

示例：

```markdown
# Module kotlin-demo

The module shows the Dokka syntax usage.

# Package org.jetbrains.kotlin.demo

Contains assorted useful stuff.

## Level 2 heading

Text after this heading is also part of documentation for `org.jetbrains.kotlin.demo`

# Package org.jetbrains.kotlin.demo2

Useful stuff in another package.