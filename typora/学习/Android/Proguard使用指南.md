# [Proguard 使用手册](https://www.guardsquare.com/manual/configuration/usage)

## 简介

一个开源的Java类文件的压缩，优化，混淆及验证工具。通过Proguard处理之后的应用及库文件体积更小，运行更快，并且难以被反向工程。

其工作流程如下：

![image-20210907221405981](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210907221410.png)

有如下几个流程：

* shrink： 压缩-检测并移除无用的类，字段，方法，和属性；
* optimize：优化-对字节码进行优化，移除无用的指令；
* obfuscate：混淆-将前面步骤保留下来的类，字段，方法进行重命名，使用短的没有意义的名称来替换原有的名称；
* preverify：预验证-给类添加验证信息。（Java6及以上版本需要）

上述每个过程都是可选的，我们可以选择只执行其中的几个步骤。



## 配置选项

### 配置选项概览

这里我们主要介绍如下配置选项：

* Keep 选项
* 压缩选项
* 优化选项
* 混淆选项
* 通用选项

其他更多选项可以参考[官方手册](https://www.guardsquare.com/manual/configuration/usage)。



### 入口点

为了决定哪些代码需要保留或移除，哪些代码需要混淆，需要指定指向你的代码的一个或多个入口点。

除了预验证阶段不需要用到入口点，其他三个阶段都涉及：

* 对于压缩步骤来说，Proguard 以定义的入口点开始，循环查找使用到的类及类成员，**所有没有被引用到的其他类及类成员都会被移除**。
* 在优化步骤中，Proguard进一步优化代码。**对于不是入口点的类及方法**，它们可能会被设置为private，static或者final，那些没有被使用的参数可能被移除，而某些方法也可能被转换成内联方法。
* 在混淆步骤中，Proguard会**重命名那些不是入口点的类及类成员**。在整个处理过程中，保留入口点可以确保它们仍然可以按原来的名称被访问。

总结如下：

| 元素/过程              | 压缩 | 优化                                                         | 混淆              | 预验证 |
| ---------------------- | :--- | ------------------------------------------------------------ | ----------------- | ------ |
| **入口点**             | 保留 | 保持原样                                                     | 保持原样          | -      |
| **被引用的非入口点**   | 保留 | 被优化<br/>设置为private/static/final，<br/>未被使用的参数移除<br/>方法转换成内联方法 | 重命名-短名称替代 | -      |
| **未被引用的类及成员** | 移除 | 不涉及-上个阶段已经被移除了                                  |                   | -      |



### 类名规格

类规范是类和类成员（字段和方法）的模板。它用于各种[`-keep`](https://www.guardsquare.com/manual/configuration/usage#keep)选项和`-assumenosideeffects`选项。相应的选项仅适用于与模板匹配的类和类成员。

看起来和java类似，不过引入了一些通配符的扩展，完整的语法描述如下：

```java
[@annotationtype] [[!]public|final|abstract|@ ...] [!]interface|class|enum classname
    [extends|implements [@annotationtype] classname]
[{
    [@annotationtype]
    [[!]public|private|protected|static|volatile|transient ...]
    <fields> | (fieldtype fieldname [= values]);

    [@annotationtype]
    [[!]public|private|protected|static|synchronized|native|abstract|strictfp ...]
    <methods> | <init>(argumenttype,...) | classname(argumenttype,...) | (returntype methodname(argumenttype,...) [return values]);
}]
```

**特殊符号：**

* 方括号“[]”表示其内容是可选的。
* 省略号“...”表示可以指定前面任何数量的项目。
* 垂直条“|”分隔了两种选择。
* 括号“()”只是将规范中属于一起的部分分组。
* 缩进试图澄清预期含义，但空白在实际配置文件中无关紧要。

**关键字：**

-  `class` 关键字引用任意接口或者类；
-  `interface` 则限制了只能引用接口类；
-  `enum` 则限制只能匹配到枚举类；
- `interface` 和  `enum` 前面可以放置一个 `!` 来限制匹配哪些不是借口或者枚举的类。

**类名：**

* 类名必须是完全限定的，如 `java.lang.String`
* 内部类由美元符号“`$`”分隔，例如`java.lang.Thread$State`
* 类名可以指定为包含以下通配符的正则表达式：

    | 通配符 | 意味着                                             | 示例                                                         |
    | :----- | :------------------------------------------------- | ------------------------------------------------------------ |
    | `?`    | 匹配类名中的任意单个支付，不包含包名分隔符；       | "`com.example.Test?` 匹配 `com.example.Test1` 及 `com.example.Test2` 但是不匹配 `com.example.Test12` |
    | `*`    | 匹配类名中的任意的多个字符，但是不包含包名分隔符； | `com.example.*Test*` 匹配 `com.example.Test` 及 `com.example.YourTestApplication`, 但是无法匹配`com.example.mysubpackage.MyTest`"。`com.example.*`匹配包`com.example`中的所有类，但是不包含子包中的类 |
    | `**`   | 匹配类名中的任意多个字符，可以包含包名分隔符；     | `**.Test` 匹配 `Test` 除了root包中的所有名为Test的类。`com.example.**`可匹配`com.example`包及其下属包中的所有类 |
    | `<n>`  | 匹配同一个选项中的第N个匹配到的通配符              | `com.example.*Foo<1>`匹配`com.example.BarFooBar`             |



**继承&实现&注解：**

* `extend` 和 `implements` 一般用于限制使用了通配符的类。目前这两个关键字是等价的。指定一个间接或者直接继承或者实现某个借口或类的类时，指定的类本身不会包含在这个集合中。这个接口/类需要使用单独的选项来指定；
* `@` 用于将类限定为使用了指定注释类型的类及类成员，指定注解名的方式同指定类名的语法一致；

**字段&方法：**

* 指定字段和方法的方式和java非常相似，不过方法参数列表不包含参数名称

* 可以使用如下通配符：

  | 通配符      | 含义                 |
  | :---------- | :------------------- |
  | `<init>`    | 匹配任何构造函数。   |
  | `<fields>`  | 匹配任何字段。       |
  | `<methods>` | 匹配任何方法。       |
  | `*`         | 匹配任何字段或方法。 |
  * 上述通配符都没有返回类型
  * `<init>` 通配符没有参数列表

* 字段和方法也可以使用正则表达式指定：

  | 通配符 | 含义                                |
  | :----- | :---------------------------------- |
  | `?`    | 匹配方法名中的任何单个字符。        |
  | `*`    | 匹配方法名称的任何部分。            |
  | `<n>`  | 匹配同一选项中第*n个*匹配的通配符。 |

* 描述符中的类型可以包含以下通配符：

  | 通配符 | 含义                                                         |
  | :----- | :----------------------------------------------------------- |
  | `%`    | 匹配任意原始数据类型 (`boolean`, `int`, 等等，但是不包括`void`). |
  | `?`    | 匹配类名中的任何单个字符。                                   |
  | `*`    | 匹配类名中不包含包分隔符的任何部分。                         |
  | `**`   | 匹配类名的任何部分，可能包含任意数量的包分隔符。             |
  | `***`  | 匹配任何类型（原始或非原始、数组或非数组）。                 |
  | `...`  | 匹配任意类型的任意数量的参数。                               |
  | `<n>`  | 匹配同一选项中第*n个*匹配的通配符。                          |
  * 其中 `?`、`*`和`**`通配符永远不会匹配原始类型。
  * 只有`***`通配符将匹配任何维度的数组类型。例如，“`** get*()`”匹配“`java.lang.Object getObject()`”，但不匹配“`float getFloat()`”或“`java.lang.Object[] getObjects()`

* 类访问修饰符和类成员访问修饰符一般用于限制通配符匹配到的类及类成员。
  * 设置了对应的修饰符的类及成员会被匹配到
  * 通过前置一个 `!` 表示相应的访问标志应该被取消
* 可以连接多个标志（如：public static），
  * 多个标志连接时需要同时满足条件才可以被匹配到。除非多个修饰符发生冲突。（冲突之后怎么选择？）



### 保留选项修饰符

- `includedescriptorclasses`

  指定任何由-keep选项保留的方法和字段的类型描述符中的所有类也应该保留。这通常有用[保留本地方法名称](https://www.guardsquare.com/manual/configuration/examples#native)，以确保本机方法的参数类型也没有重命名。然后，他们的签名保持不变，并与本机库兼容。

- `includecode`

  指定方法的代码属性，[-保持](https://www.guardsquare.com/manual/configuration/usage#keep)选项保存也应保留，即可能不会优化或混淆。**这通常对已经优化或混淆的类有用，以确保它们的代码在优化期间不会被修改**。

- `allowshrinking`

  指定在[-保持](https://www.guardsquare.com/manual/configuration/usage#keep)即使必须以其他方式保留，选项也可能缩小。也就是说，**在缩小步骤中，入口点可能会被移除，**但如果它们真的有必要，它们可能不会被优化或混淆。

- `allowoptimization`

  指定在[-保持](https://www.guardsquare.com/manual/configuration/usage#keep)选项可能会被优化，即使它们必须保存。也就是说，**在优化步骤中，入口点可能会被更改**，但它们可能不会被删除或混淆。此修饰符仅用于实现异常需求。

- `allowobfuscation`

  指定在[-保持](https://www.guardsquare.com/manual/configuration/usage#keep)选项可能会被混淆，即使它们必须以其他方式保留。也就是说，**在混淆步骤中，入口点可能会重命名**，但它们可能不会被删除或优化。此修饰符仅用于实现异常需求。

### Keep 选项

* `-keep`【[，*修饰符*](https://www.guardsquare.com/manual/configuration/usage#keepoptionmodifiers)，...][*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定要保留为代码入口点的类和类成员（字段和方法）。

  例如，为了[保留应用程序](https://www.guardsquare.com/manual/configuration/examples#application)，您可以指定主类及其主方法。为了[处理库](https://www.guardsquare.com/manual/configuration/examples#library)，您应该指定所有可公开访问的元素。



* `-keepclassmembers`【[，*修饰符*](https://www.guardsquare.com/manual/configuration/usage#keepoptionmodifiers)，...][*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定要保留的类成员，如果他们的类也保留。

  例如，您可能想[保留所有序列化字段和方法](https://www.guardsquare.com/manual/configuration/examples#serializable) of classes that implement the `Serializable` interface.



* `-keepclasseswithmembers`【[，*修饰符*](https://www.guardsquare.com/manual/configuration/usage#keepoptionmodifiers)，...][*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定要保留的类和类成员，条件是所有指定的类成员都存在。

  例如，您可能想[保留所有应用程序](https://www.guardsquare.com/manual/configuration/examples#applications)具有主要方法，而无需明确列出它们。



* `-keepnames` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  缩写[`-keep`](https://www.guardsquare.com/manual/configuration/usage#keep)，[`allowshrinking`](https://www.guardsquare.com/manual/configuration/usage#allowshrinking) [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)指定名称将被保留的类和类成员，如果它们在缩小阶段没有被删除。

  例如，您可能想[保留所有类名](https://www.guardsquare.com/manual/configuration/examples#serializable) of classes that implement the `Serializable` interface, so that the processed code remains compatible with any originally serialized classes. Classes that aren't used at all can still be removed. Only applicable when obfuscating.

  

* `-keepclassmembernames` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  缩写[`-keepclassmembers`](https://www.guardsquare.com/manual/configuration/usage#keepclassmembers)，[`allowshrinking`](https://www.guardsquare.com/manual/configuration/usage#allowshrinking) [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)指定其名称将被保留的类成员，如果它们在收缩阶段没有被删除。

  例如，您可能希望在[处理图书馆](https://www.guardsquare.com/manual/configuration/examples#library)由JDK 1.2或更高版本编译，因此混淆者在处理使用已处理库的应用程序时可以再次检测到它（尽管ProGuard本身不需要这个）。仅在混淆时适用。



* `-keepclasseswithmembernames` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  缩写[`-keepclasseswithmembers`](https://www.guardsquare.com/manual/configuration/usage#keepclasseswithmembers)，[`allowshrinking`](https://www.guardsquare.com/manual/configuration/usage#allowshrinking) [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)指定名称将被保留的类和类成员，条件是所有指定的类成员在收缩阶段后都存在。

  例如，您可能想[保留所有本机方法名称](https://www.guardsquare.com/manual/configuration/examples#native)以及它们的类的名称，这样处理后的代码仍然可以与本机库代码链接。完全不用的原生方法仍然可以删除。如果使用类文件，但没有一个本机方法使用，其名称仍将被混淆。仅在混淆时适用。



* `-if` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定激活后续保留选项（[`-keep`](https://www.guardsquare.com/manual/configuration/usage#keep)，[`-keepclassmembers`](https://www.guardsquare.com/manual/configuration/usage#keepclassmembers)，...）。该条件和后续保留选项可以共享通配符和通配符的引用。

  例如，您可以将类保留在项目中存在具有相关名称的类的条件，并使用类似[匕首](https://www.guardsquare.com/manual/configuration/examples#dagger)和[黄油刀](https://www.guardsquare.com/manual/configuration/examples#butterknife)。

  

* `-printseeds`【[*文件名*](https://www.guardsquare.com/manual/configuration/usage#filename)】

  指定详尽列出由各种`-keep`选项匹配的类和类成员。列表打印到标准输出或给定文件。该列表可用于验证是否真的找到了预期的类成员，特别是如果您正在使用通配符。

  例如，您可能希望列出所有[应用程序](https://www.guardsquare.com/manual/configuration/examples#applications)或者所有[小程序](https://www.guardsquare.com/manual/configuration/examples#applets)你保留的。



### 压缩选项

* `-dontshrink`

  指定不缩小输入。默认情况下，ProGuard会缩小代码：它会删除所有未使用的类和类成员。它只保留各种列出的[`-keep`](https://www.guardsquare.com/manual/configuration/usage#keep)直接或间接地选择，以及它们所依赖的选项。它还在每个优化步骤后应用一个收缩步骤，因为一些优化可能会打开删除更多类和类成员的可能性。

* `-printusage`【[*文件名*](https://www.guardsquare.com/manual/configuration/usage#filename)】

  指定列出输入类列表的文件名称。列表打印到标准输出或给定文件。

  例如，你可以[列出一个应用程序未使用的代码](https://www.guardsquare.com/manual/configuration/examples#deadcode)。仅在收缩时适用。

* `-whyareyoukeeping` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定打印有关为什么给定的类和类成员处于收缩步骤的详细信息。如果您想知道为什么输出中存在某些给定元素，这非常有用。一般来说，原因可能很多。此选项为每个指定的类和类成员将最短的方法链打印到指定的种子或入口点。*在当前的实现中，打印出来的最短链有时可能包含循环演绎——这些不反映实际的收缩过程。*如果[`-verbose`](https://www.guardsquare.com/manual/configuration/usage#verbose)如果指定，则跟踪包括完整字段和方法签名。仅在收缩时适用。



### 优化选项

* `-dontoptimize`

  指定不优化输入类文件。默认情况下，ProGuard会优化所有代码。它内化和合并类和类成员，并在字节码级别优化所有方法。

  

* `-optimizations` [*优化_过滤器*](https://www.guardsquare.com/manual/configuration/optimizations)

  指定在更细粒度级别上启用和禁用的优化。仅在优化时适用。*这是一个专家选项*

  

* `-optimizationpasses` *n*

  指定要执行的优化处理的次数。默认情况下，将执行一次优化处理。多次处理可能导致进一步优化。如果优化通过后没有发现任何改进，优化将结束。仅在优化时适用。

  

* `-assumenosideeffects` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定没有任何副作用的方法，但可能返回值之外。例如，该方法返回值，但它没有任何副作用。在优化步骤中，如果 ProGuard 能够确定未使用返回值，则可以删除此类方法的调用。ProGuard 将分析您的程序代码，以便自动找到此类方法。它不会分析库代码，因此此选项可能很有用。例如，您可以指定方法，以便删除任何空闲调用。小心翼翼，您也可以使用该选项`System.currentTimeMillis()``System.currentTimeMillis()`[删除记录代码](https://www.guardsquare.com/manual/configuration/examples#logging).请注意，ProGuard 将该选项应用于指定方法的整个层次结构。仅适用于优化时。一般来说，作出假设可能是危险的：您可以轻松地打破已处理的代码。*只有当您知道自己在做什么时，才使用此选项！*

  

* `-assumenoexternalsideeffects` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定没有任何副作用的方法，但可能涉及其称为实例的方法。此语句弱于[`-assumenosideeffects`](https://www.guardsquare.com/manual/configuration/usage#assumenosideeffects)，因为它允许对参数或堆的副作用。例如，这些方法有副作用，但没有外部副作用。这是有用的，当`StringBuffer#append`[删除记录代码](https://www.guardsquare.com/manual/configuration/examples#logging)，也删除任何相关的字符串联代码。仅适用于优化时。作出假设可能是危险的;您可以轻松地打破已处理的代码。*只有当您知道自己在做什么时，才使用此选项！*

  

* `-assumenoescapingparameters` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定不允许其参考参数逃到堆中的方法。此类方法可以使用、修改或返回参数，但不能直接或间接地将其存储在任何领域。例如，该方法不会让其参考参数逸出，但方法确实如此。仅适用于优化时。作出假设可能是危险的;您可以轻松地打破已处理的代码。*只有当您知道自己在做什么时，才使用此选项！*`System.arrayCopy``System.setSecurityManager`

  

* `-assumenoexternalreturnvalues` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定不返回呼叫时已经堆在堆上的参考值的方法。例如，返回参考值，但它是尚未上堆的新实例。仅适用于优化时。作出假设可能是危险的;您可以轻松地打破已处理的代码。*只有当您知道自己在做什么时，才使用此选项！*`ProcessBuilder#start``Process`

  

* `-assumevalues` [*class_specification*](https://www.guardsquare.com/manual/configuration/usage#classspecification)

  指定原始字段和方法的固定值或值范围。例如，您可以[优化您的应用程序给定的安卓 Sdk 版本](https://www.guardsquare.com/manual/configuration/examples#androidversions)通过指定版本常数中支持的范围。然后，ProGuard 可以优化旧版本的代码路径。作出假设可能是危险的;您可以轻松地打破已处理的代码。*只有当您知道自己在做什么时，才使用此选项！*

  

* `-allowaccessmodification`

  规定在处理过程中可以扩大类和类成员的访问修饰器。这可以改进优化步骤的结果。例如，在为公共获取器进行衬里时，可能也有必要将访问字段公之于众。虽然 Java 的二进制兼容性规范正式不需要此 （cfr.[爪哇语规范，第三版](http://docs.oracle.com/javase/specs/jls/se12/html/index.html),[第13.4.6节](http://docs.oracle.com/javase/specs/jls/se12/html/jls-13.html#jls-13.4.6)），否则，一些虚拟计算机会与处理过的代码有问题。仅适用于优化时（以及混淆[`-repackageclasses`](https://www.guardsquare.com/manual/configuration/usage#repackageclasses)选项）。*反指示：*在处理用作库的代码时，您可能不应该使用此选项，因为未设计为在 API 中公开的类和类成员可能会公开。

  

* `-mergeinterfacesaggressively`

  指定界面可以合并，即使其实施类不执行所有接口方法。这可以通过减少类总数来减少输出的大小。请注意，Java 的二进制兼容性规范允许此类构造 （cfr.[爪哇语规范，第三版](http://docs.oracle.com/javase/specs/jls/se12/html/index.html),[第13.5.3节](http://docs.oracle.com/javase/specs/jls/se12/html/jls-13.html#jls-13.5.3)），即使他们不允许在爪哇语（cfr.[爪哇语规范，第三版](http://docs.oracle.com/javase/specs/jls/se12/html/index.html),[第8.1.4节](http://docs.oracle.com/javase/specs/jls/se12/html/jls-8.html#jls-8.1.4)).仅适用于优化时。

  *反指示：*设置此选项可以降低某些 JVM 上处理代码的性能，因为提前的即时编译往往有利于使用更少的实施类的更多接口。更糟的是，一些合资企业可能无法处理生成的代码。特别是：

  - Sun 的 JRE 1.3 可能会在课堂上遇到超过 256 种*Miranda*方法（没有实现的接口方法）时抛出一个。`InternalError`

### 混淆选项

- `-dontobfuscate`

  指定不要混淆输入类文件。默认情况下，ProGuard 混淆了代码：它为类和类成员分配了新的短随机名称。它删除仅可用于调试的内部属性，例如源文件名称、可变名称和行号。

- `-printmapping` [[*文件名*](https://www.guardsquare.com/manual/configuration/usage#filename)]

  指定打印已重命名的班级和班级成员从旧名称到新名称的映射。映射打印到标准输出或给定文件。例如，后续需要这样做[增量混淆](https://www.guardsquare.com/manual/configuration/examples#incremental)，或者如果你想再次有意义的[模糊的堆栈痕迹](https://www.guardsquare.com/manual/configuration/examples#stacktrace).仅适用于混淆时。

- `-applymapping` [*文件名*](https://www.guardsquare.com/manual/configuration/usage#filename)

  指定重用在 ProGuard 以前的混淆运行中打印出来的给定名称映射。映射文件中列出的类和类成员将接收与他们一起指定的名称。未提及的班级和班级成员将收到新名称。映射可能指输入类以及库类。此选项可用于[增量混淆](https://www.guardsquare.com/manual/configuration/examples#incremental)，即对现有代码进行附加组件或小补丁处理。如果代码结构发生根本变化，ProGuard 可能会打印出应用映射导致冲突的警告。您可以通过指定选项来降低此风险[`-useuniqueclassmembernames`](https://www.guardsquare.com/manual/configuration/usage#useuniqueclassmembernames)在两个混淆运行。只允许使用单个映射文件。仅适用于混淆时。

- `-obfuscationdictionary` [*文件名*](https://www.guardsquare.com/manual/configuration/usage#filename)

  指定文本文件，所有有效单词都用作混淆字段和方法名称。默认情况下，诸如"a"，"b"等短名称被用作模糊的名称。使用混淆字典，您可以指定保留的关键词列表，或者带有外国字符的标识符，例如。空白、标点符号、重复单词和标志后的评论被忽略。请注意，混淆字典很难改善混淆。体面的编译器可以自动替换它们，并且效果可以通过用更简单的名称再次混淆来相当简单地被撤消。最有用的应用程序是指定通常已经存在于类文件中的字符串（如"代码"），从而减少类文件大小只是多一点。仅适用于混淆时。`#`

- `-classobfuscationdictionary` [*文件名*](https://www.guardsquare.com/manual/configuration/usage#filename)

  指定文本文件，所有有效单词都用作混淆的类名称。混淆字典类似于其中一个选项[`-obfuscationdictionary`](https://www.guardsquare.com/manual/configuration/usage#obfuscationdictionary).仅适用于混淆时。

- `-packageobfuscationdictionary` [*文件名*](https://www.guardsquare.com/manual/configuration/usage#filename)

  指定文本文件，所有有效单词都用作混淆的包名。混淆字典类似于其中一个选项[`-obfuscationdictionary`](https://www.guardsquare.com/manual/configuration/usage#obfuscationdictionary).仅适用于混淆时。

- `-overloadaggressively`

  指定在混淆时应用激进的超载。然后，多个字段和方法可以获得相同的名称，只要其参数和返回类型不同，如 Java 字形码要求（而不仅仅是其参数，根据 Java 语言的要求）。此选项可以使处理过的代码更小（且难以理解）。仅适用于混淆时。*反指示：*生成的类文件属于 Java 字节代码规范 （cfr） 。[爪哇虚拟机规范](http://docs.oracle.com/javase/specs/jvms/se12/html/index.html)，第一段[第4.5节](http://docs.oracle.com/javase/specs/jvms/se12/html/jvms-4.html#jvms-4.5)和[第4.6节](http://docs.oracle.com/javase/specs/jvms/se12/html/jvms-4.html#jvms-4.6)），即使这种超载是不允许在爪哇语（cfr.[爪哇语规范，第三版](http://docs.oracle.com/javase/specs/jls/se12/html/index.html),[第8.3节](http://docs.oracle.com/javase/specs/jls/se12/html/jls-8.html#jls-8.3)和[第8.4.5节](http://docs.oracle.com/javase/specs/jls/se12/html/jls-8.html#jls-8.4.5)).尽管如此，一些工具还是有问题。特别是：Sun 的 JDK 1.2.2 编译器在用此类库（cfr） 编译时会产生异常。`javac`[错误#4216736](http://bugs.sun.com/view_bug.do?bug_id=4216736)).您可能不应该使用此选项处理库。太阳的JRE 1.4和后来未能序列化对象与超载的原始字段。据报道，Sun 的 JRE 1.5 工具存在超载班员的问题。`pack200`类无法处理超载方法。`java.lang.reflect.Proxy`谷歌的达尔维克 VM 无法处理超载静态字段。

- `-useuniqueclassmembernames`

  指定将相同的混淆名称分配给名称相同的类成员，将不同的混淆名称分配给具有不同名称的类成员（针对每个给定的类成员签名）。如果没有选项，可以将更多班级成员映射到相同的短名称，如"a"，"b"等。因此，该选项会稍微增加生成代码的大小，但它确保保存的混淆名称映射在随后的增量混淆步骤中始终能够得到尊重。例如，考虑两个不同的界面，其中包含同名和签名的方法。如果没有此选项，这些方法可能会在第一个混淆步骤中获得不同的混淆名称。如果添加了包含实现两个接口的类的补丁，ProGuard 将不得不在增量混淆步骤中对两种方法强制执行相同的方法名称。更改原始模糊代码，以保持生成的代码一致。在*初始混淆步骤中*，此选项将永远不会需要重命名。此选项仅适用于混淆时。事实上，如果您正计划执行增量混淆，您可能希望完全避免收缩和优化，因为这些步骤可能会删除或修改对以后添加至关重要的代码部分。

- `-dontusemixedcaseclassnames`

  指定在混淆时不要生成混合案例类名称。默认情况下，混淆的类名称可以包含大案字符和小案例字符的组合。这创建完全可以接受和可用的罐子。只有当一个罐子在带有对案件不敏感的归档系统（如 Windows）的平台上拆开时，拆包工具才能让类似命名的类文件相互覆盖。拆包时自毁的代码！真正想要在 Windows 上拆开罐子的开发人员可以使用此选项关闭此行为。因此，混淆的罐子会变大一点。仅适用于混淆时。

- `-keeppackagenames` [*[package_filter](https://www.guardsquare.com/manual/configuration/usage#filters)*]

  指定不要混淆给定的包名。可选滤镜是一个逗号分离的包名列表。包装名称可以包含**？，\***和***\***通配符，他们可以前面有**！**否定者。仅适用于混淆时。

- `-flattenpackagehierarchy` [*package_name*]

  指定通过将它们移动到单个给定父包来重新包装所有重命名的包。没有参数或空字符串 （'），包被移动到根包。此选项是进一步示例之一[混淆包名](https://www.guardsquare.com/manual/configuration/examples#repackaging).它可以使处理过的代码更小，更难以理解。仅适用于混淆时。

- `-repackageclasses` [*package_name*]

  指定通过将它们移动到单个给定包中重新包装所有已重命名的类文件。无需争论或使用空字符串 （'），包将被完全删除。此选项覆盖[`-flattenpackagehierarchy`](https://www.guardsquare.com/manual/configuration/usage#flattenpackagehierarchy)选择。这是另一个例子[混淆包名](https://www.guardsquare.com/manual/configuration/examples#repackaging).它可以使处理过的代码更小，更难以理解。其弃名是。仅适用于混淆时。`-defaultpackage`*反指示：*如果将资源文件转移到别处，则在其包目录中查找资源文件的类将不再正常工作。有疑问时，只需不使用此选项，就不要对包装造成影响。*注意：*在 Android 上，当活动、视图等类可能重命名时，您不应使用空字符串。Android 运行时间会自动将 XML 文件中的无封装名称与应用程序包名称或与 。这是不可避免的，但它打破了在这种情况下的应用程序。`android.view`

- `-keepattributes` [*[attribute_filter](https://www.guardsquare.com/manual/configuration/attributes)*]

  指定要保留的任何可选属性。属性可以用一个或多个属性来指定[`-keepattributes`](https://www.guardsquare.com/manual/configuration/usage#keepattributes)指令。可选滤镜是逗式分离列表[属性名称](https://www.guardsquare.com/manual/configuration/attributes)爪哇虚拟机和 ProGuard 支持。属性名称可以包含**？，** *****和***\***通配符， 他们可以前面有**！**否定者。例如，您至少应该保留"何时"和"属性"`Exceptions``InnerClasses``Signature`[处理库](https://www.guardsquare.com/manual/configuration/examples#library).您还应保留其属性和属性`SourceFile``LineNumberTable`[生成有用的混淆堆栈痕迹](https://www.guardsquare.com/manual/configuration/examples#stacktrace).最后，您可能想要[保留注释](https://www.guardsquare.com/manual/configuration/examples#annotations)如果你的代码取决于他们。仅适用于混淆时。

- `-keepparameternames`

  指定保留参数名称和保存的方法类型。此选项实际上保留了调试属性的修剪版本和 。它可以是有用的，当`LocalVariableTable``LocalVariableTypeTable`[处理库](https://www.guardsquare.com/manual/configuration/examples#library).某些 ID 可以使用这些信息来帮助使用库的开发人员，例如工具提示或自动完成。仅适用于混淆时。

- `-renamesourcefileattribute` [*字符串*]

  指定要放在类文件属性（和属性）中的恒定字符串。请注意，属性必须存在开始，所以它也必须明确保留使用`SourceFile``SourceDir`[`-keepattributes`](https://www.guardsquare.com/manual/configuration/usage#keepattributes)命令。例如，您可能需要制作经过处理的库和应用程序[有用的混淆堆栈痕迹](https://www.guardsquare.com/manual/configuration/examples#stacktrace).仅适用于混淆时。

- `-keepkotlinmetadata`

  指定在存在时处理注释。目前只支持缩小和混淆其内容。如果启用了此选项，则应从优化中删除包含此类注释的类。`kotlin.Metadata`

- `-adaptclassstrings` [*[class_filter](https://www.guardsquare.com/manual/configuration/usage#filters)*]

  指定对应类名称的字符串常数也应混淆。如果没有过滤器，所有对应类名称的字符串常数都会进行调整。使用过滤器时，只有与过滤器匹配的类中的字符串常数才进行调整。例如，如果您的代码包含大量用于类的硬编码字符串，并且您不想保留它们的名称，则可能需要使用此选项。主要适用于混淆时，虽然相应的类自动保持在缩小的步骤了。

- `-adaptresourcefilenames` [*[file_filter](https://www.guardsquare.com/manual/configuration/usage#filefilters)*]

  根据相应类文件的模糊名称（如果有的话）指定要重命名的资源文件。如果没有筛选器，所有与类文件对应的资源文件都会重命名。有了筛选器，只有匹配的文件才会重命名。例如，请参阅[处理资源文件](https://www.guardsquare.com/manual/configuration/examples#resourcefiles).仅适用于混淆时。

- `-adaptresourcefilecontents` [*[file_filter](https://www.guardsquare.com/manual/configuration/usage#filefilters)*]

  指定内容要更新的资源文件和本地库。资源文件中提及的任何类名称均根据相应类的混淆名称（如果有）重命名。本地库中的任何功能名称均根据相应原生方法的混淆名称（如果有）重命名。如果没有过滤器，所有资源文件的内容都会更新。通过筛选器，仅更新匹配的文件。资源文件使用 UTF-8 编码进行解析和编写。例如，请参阅[处理资源文件](https://www.guardsquare.com/manual/configuration/examples#resourcefiles).仅适用于混淆时。*注意事项：*您可能只想将此选项应用于文本文件和原生库，因为解析和调整一般二进制文件作为文本文件可能会导致意外问题。因此，请确保指定足够窄的过滤器。



## 配置示例集锦



