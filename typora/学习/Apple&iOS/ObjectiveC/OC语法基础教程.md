# Objective-C基础教程

>  相关资源链接：
>
>  * https://www.yiibai.com/objective_c/objective_c_numbers.html#article-start 
>  * [官方Objective-C编程指南](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)

## 常见问题

### 变量定义

### 字符串写法

### @是什么用法？

`@` 是Objective-C在标准C语言基础上添加的特性之一，`@`符号意味着引号内的字符串应作为Cocoa的NSString元素来处理；

### NSString是什么？

`NSString`是Cocoa中的字符串，NSString元素集成了大量的特性，在需要使用字符串时，通过Cocoa可以随时使用它们。部分功能如下：

1. 字符串长度
2. 字符串比较；
3. 转换为整型或浮点值；

### [pool drain]; 是做什么用的？



### `#import`和 `#include` 

* #include 是C的标准用法
* #import 是Objective-C引入的，可以避免重复引入

> * [Objective-C 中的 import 和 Search Paths - 简书 (jianshu.com)](https://www.jianshu.com/p/75e18591ca24)
> * [objective c - @import vs #import - iOS 7 - Stack Overflow](https://stackoverflow.com/questions/18947516/import-vs-import-ios-7)



### Objective-C 函数前面的`+` 和 `-` 的含义

加号 是可以通过类名直接调用这个方法,

而减号则要实例化逸个对象,然后通过实例化的对象来调用该方法!

（+ 和java中的static 方法相似）

即：

* `+` （class methods）表明方法是声明在类对象本身上的；通过类名调用；
* `-` （instance method）表明方法是声明在类的实例上的；需要通过实例对象调用；

> 参考：
>
> * 关于+ ： [Defining Classes (apple.com)#Objective-C Classes Are also Objects](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/DefiningClasses/DefiningClasses.html#//apple_ref/doc/uid/TP40011210-CH3-SW18)
> * 关于- ： [Defining Classes (apple.com)#Method Declarations Indicate the Messages an Object Can Receive](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/DefiningClasses/DefiningClasses.html#//apple_ref/doc/uid/TP40011210-CH3-SW8)

### 对象构造时new 和 alloc





### base64 编码及解码 & MD5

####  MD5

MD5数字校验NSString对象



```objectivec
+ (NSString *)md5EncodeFromStr:(NSString *)str {
    if (str.length == 0) {
        return nil;
    }
    // 初始化C字符数组
    const char* original_str = (const char *)[[str dataUsingEncoding:NSUTF8StringEncoding] bytes];
    // 盛放数字校验的字符数组（长度为16bytes）
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    //        NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    NSMutableString* outPutStr = [NSMutableString new];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x",digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    NSLog(@"outPutStr=========%@",outPutStr);
    return outPutStr;
}
```

MD5数字校验NSData对象



```objectivec
+ (NSString *)md5EncodeFromData:(NSData *)data {
    if (!data) {
        return nil;
    }
    //需要MD5变量并且初始化
    CC_MD5_CTX  md5;
    CC_MD5_Init(&md5);
    //开始加密(第一个参数：对md5变量去地址，要为该变量指向的内存空间计算好数据，第二个参数：需要计算的源数据，第三个参数：源数据的长度)
    CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
    //声明一个无符号的字符数组，用来盛放转换好的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //将数据放入result数组
    CC_MD5_Final(result, &md5);
    //将result中的字符拼接为OC语言中的字符串，以便我们使用。
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X",result[i]];
    }
    NSLog(@"resultString=========%@",resultString);
    return resultString;
}
```

MD5数字加盐校验NSString对象



```objectivec
+ (NSString *)md5EncodeFromStr:(NSString *)str
                      withSalt:(NSString *)saltStr {
    if (str.length == 0) {
        return nil;
    }
    NSString *newStr = [str stringByAppendingString:saltStr];
    // 初始化C字符数组
    const char* original_str = (const char *)[[newStr dataUsingEncoding:NSUTF8StringEncoding] bytes];
    // 盛放数字校验的字符数组（长度为16bytes）
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    //        NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    NSMutableString* outPutStr = [NSMutableString new];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02X",digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    NSLog(@"outPutStr=========%@",outPutStr);
    return outPutStr;
}
```

#### Base64加密

Base64 加密



```objectivec
#pragma mark -- Base64加密data数据
+ (NSString *)base64EncodeWithData:(NSData *)sourceData {
    if (!sourceData) {
        return nil;
    }
    NSString *resultStr = [sourceData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return resultStr;
}
```

Base64 解密



```objectivec
#pragma mark -- Base64解密数据
+ (NSData *)base64DecodeWithString:(NSString *)sourceString {
    if (!sourceString) {
        return nil;
    }
    // 解密
    NSData *resultData = [[NSData alloc] initWithBase64EncodedString:sourceString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //    NSLog(@"%@",resultData);
    return resultData;
}
```



> 作者：CarsonChen
> 链接：https://www.jianshu.com/p/bdcd1c5f2685
> 来源：简书
> 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。









# C 语言基础

## 变量及声明与定义

变量声明向编译器保证变量以指定的类型和名称存在，这样编译器在不需要知道变量完整细节的情况下也能继续进一步的编译。变量声明只在编译时有它的意义，在程序连接时编译器需要实际的变量声明。

变量的声明有两种情况：

- 1、一种是需要建立存储空间的。例如：int a 在声明的时候就已经建立了存储空间。
- 2、另一种是不需要建立存储空间的，通过使用extern关键字声明变量名而不定义它。 例如：extern int a 其中变量 a 可以在别的文件中定义的。
- ==除非有extern关键字，否则都是变量的定义==。

```c
extern int i; //声明，不是定义
int i; //声明，也是定义
```

## 常量的定义

在 C 中，有两种简单的定义常量的方式：

1. 使用 **#define** 预处理器。
2. 使用 **const** 关键字。



### #define 预处理器

下面是使用 #define 预处理器定义常量的形式：

```
#define identifier value
```

### const 关键字

您可以使用 **const** 前缀声明指定类型的常量，如下所示：

```c
const type variable = value;
```

![img](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210514143017.png)



## 函数的声明与定义

函数**声明**告诉编译器函数的名称、返回类型和参数。函数**定义**提供了函数的实际主体。

C 语言中的函数定义的一般形式如下：

```c
return_type function_name( parameter list )
{
   body of the function
}
```

### 函数声明

函数**声明**会告诉编译器函数名称及如何调用函数。函数的实际主体可以单独定义。

函数声明包括以下几个部分：

```c
return_type function_name( parameter list );
```

针对上面定义的函数 max()，以下是函数声明：

```c
int max(int num1, int num2);
```

在函数声明中，参数的名称并不重要，只有参数的类型是必需的，因此下面也是有效的声明：

```c
int max(int, int);
```

当您在一个源文件中定义函数且在另一个文件中调用函数时，函数声明是必需的。在这种情况下，您应该在调用函数的文件顶部声明函数。

### 调用函数

创建 C 函数时，会定义函数做什么，然后通过调用函数来完成已定义的任务。

当程序调用函数时，程序控制权会转移给被调用的函数。被调用的函数执行已定义的任务，当函数的返回语句被执行时，或到达函数的结束括号时，会把程序控制权交还给主程序。

调用函数时，传递所需参数，如果函数返回一个值，则可以存储返回值。







# Objective-C概述

## 介绍

Objective-C语言是一种通用的，面向对象的编程语言，Smalltalk风格消息传送到C编程语言。它是使用苹果OS X和iOS操作系统及彼等各自的API， Cocoa 和Cocoa Touch主要的编程语言。

最初，Objective-C是由NeXT为其NeXTSTEP操作系统开发的，之后苹果公司使用它来开发iOS和Mac OS X，并接管了Objective-C。

==Objective-C是C语言的超集。提供了面向对象的能力和动态运行时，Objective-C继承了C的语法格式，原始数据类型，控制流语句，添加了定义类和方法的语法格式。添加了语言级别的对对象graph管理及对象常量，同时也提供了动态类型和绑定，‎将许多责任推迟到运行时间‎==

总结下来有如下几点：（面向对象的能力和动态运行时）

1. defining classes and methods
2. object graph management 
3. object literals
4. dynamic typing and binding

> [About Objective-C (apple.com)](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)

## 面向对象的编程

Objective-C完全支持面向对象的编程，包括面向对象开发的四大特性 - 

- 封装
- 数据隐藏
- 继承
- 多态性

## 基础框架

Foundation Framework提供了大量函数功能，如下所示。

- 它包括一个扩展数据类型列表，如：`NSArray`，`NSDictionary`，`NSSet`等。
- 它由一组丰富的函数组成，用于处理文件，字符串等。
- 它提供了URL处理功能，日期格式化，数据处理，错误处理等实用程序。

## Hello World示例

```objective-c
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}

```





# 开发环境搭建

直接使用xcode即可。





# 程序结构

Objective-C程序基本上由以下部分组成 -

- 预处理程序命令
- 接口
- 实现
- 方法
- 变量
- 声明和表达
- 注释



```objective-c
#import <Foundation/Foundation.h>

@interface SampleClass:NSObject
- (void)sampleMethod;
@end

@implementation SampleClass

- (void)sampleMethod {
   NSLog(@"Hello, World! \n");
}

@end

int main() {
   /* my first program in Objective-C */
   SampleClass *sampleClass = [[SampleClass alloc]init];
   [sampleClass sampleMethod];
   return 0;
}
```

下面对上述程序的各个部分进行解释 -

- 程序的第一行:`#import <Foundation/Foundation.h>`是一个预处理程序命令，它告诉Objective-C编译器在进行实际编译之前包含`Foundation.h`头文件。
- 下一行`@interface SampleClass:NSObject` 用于创建接口。它继承了`NSObject`，此类是所有对象的基类。
- 下一行`- (void)sampleMethod;` 用于声明一个方法。
- 下一行`@end`标记了接口的结束。
- 下一行`@implementation SampleClass`用于指示它实现了接口`SampleClass`。
- 下一行`- (void)sampleMethod{}`用于指示实现`sampleMethod`方法。
- 下一行`@end`指示实现的结束。
- 下一行`int main()`是程序执行入口的主函数。
- 下一行`/*...*/`表示注释，它将被编译器忽略，并且已经在程序中添加了其他注释。 所以这些行在程序中称为注释。
- 下一行`NSLog(...)`是Objective-C中可用的另一个函数，它会生成消息`“Hello，World！”`并显示在屏幕上。
- 下一行`return 0;`，终止`main()`函数并返回值`0`。

**编译和执行Objective-C程序**
现在，当编译并运行程序时，将得到以下结果：

```shell
2018-10-13 07:48:42.120 demo[25832] Hello, World!
```



# 基本语法

## Objective-C令牌

Objective-C程序由各种令牌组成，令牌可以是关键字，标识符，常量，字符串文字或符号。 例如，以下Objective-C语句由六个令牌组成 -

```objc
NSLog(@"Hello, World! \n");
```

单个标记是 -

```objectivec
NSLog
@
(
   "Hello, World! \n"
)
;
```

## 分号`;`

在Objective-C程序中，分号是语句终止符。也就是说，每个单独的语句必须以分号结束。 它表示一个逻辑实体的结束。

例如，以下是两个不同的语句 -

```objectivec
NSLog(@"Hello, World! \n");
return 0;
```

## 注释

注释就像Objective-C程序中的帮助文本一样，编译器会忽略它们。它们以`/*`开头并以字符`*/`结尾，如下所示 -

```objectivec
/* my first program in Objective-C */
```

## 标识符

Objective-C标识符是用于标识变量，函数或其他用户定义项的名称。 标识符以字母`A`到`Z`或`a`到`z`或下划线`_`开头，后跟零个或多个字母，下划线和数字(`0`到`9`)。

Objective-C不允许标识符中的标点符号，如`@`，`$`和`%`。 Objective-C是一种区分大小写的编程语言。 因此，`Manpower`和`manpower`是Objective-C中的两个不同的标识符。 以下是符合要求标识符的一些示例 -

```objective
mohd       zara    abc   move_name  a_123
myname50   _temp   j     a23b9      retVal
```

## 关键字

以下列表显示了Objective-C中的一些保留字。 这些保留字不能用作常量或变量或任何其他标识符名称。

| `auto`     | `else`              | `long`      | `switch`         |
| ---------- | ------------------- | ----------- | ---------------- |
| `break`    | `enum`              | `register`  | `typedef`        |
| `case`     | `extern`            | `return`    | `union`          |
| `char`     | `float`             | `short`     | `unsigned`       |
| `const`    | `for`               | `signed`    | `void`           |
| `continue` | `goto`              | `sizeof`    | `volatile`       |
| `default`  | `if`                | `static`    | `while`          |
| `do`       | `int`               | `struct`    | `_Packed`        |
| `double`   | `protocol`          | `interface` | `implementation` |
| `NSObject` | `NSInteger`         | `NSNumber`  | `CGFloat`        |
| `property` | `nonatomic`         | `retain`    | `strong`         |
| `weak`     | `unsafe_unretained` | `readwrite` | `readonly`       |

## Objective-C空白格

只包含空格(可能带有注释)的行称为空行，而Objective-C编译器完全忽略它。

*Whitespace* 是Objective-C中用于描述空格，制表符，换行符和注释的术语。空格将语句的一部分与另一部分分开，并使编译器能够识别语句中的一个元素(如`int`)的结束位置以及下一个元素的开始位置。 因此，在以下声明中 -

```objective
int age;


Objective
```

在`int`和`age`之间必须至少有一个空格字符(通常是空格)，以便编译器能够区分它们。 另一方面，在以下声明中，

```objective
fruit = apples + oranges;   // get the total fruit


Objective
```

`fruit`和`=`之间，或`=`和`apples`之间可以不需要加空白格字符，但如果希望出于可读性目的，可以自由添加一些空白字符。



# Objective-C数据类型

在Objective-C编程语言中，数据类型是指用于声明不同类型的变量或函数的扩展系统。 变量的类型决定了它在存储中占用的空间大小以及如何解释存储的位模式。

Objective-C中的类型可分为以下几类 -

| 编号 | 类型     | 描述                                                         |
| ---- | -------- | ------------------------------------------------------------ |
| 1    | 基本类型 | 它们是算术类型，由两种类型组成：(a)整数类型和(b)浮点类型。   |
| 2    | 枚举类型 | 它们又是算术类型，用于定义只能在整个程序中分配某些离散整数值的变量。 |
| 3    | void类型 | 类型说明符`void`表示没有可用的值。                           |
| 4    | 派生类型 | 它们包括(a)指针类型，(b)数组类型，(c)结构类型，(d)联合类型和 (e)函数类型。 |

数组类型和结构类型统称为聚合类型。 函数的类型指定函数返回值的类型。 我们将在下一节中看到基本类型，而其他类型将在后续章节中介绍。

## 整数类型

下表提供了有关标准整数类型的存储大小和值范围的详细信息 -

| 类型             | 存储大小 | 值范围                                                 |
| ---------------- | -------- | ------------------------------------------------------ |
| `char`           | 1字节    | `-128 ~ 127` 或 `0 ~ 255`                              |
| `unsigned char`  | 1字节    | `0 ~ 255`                                              |
| `signed char`    | 1字节    | `-128 ~ 127`                                           |
| `int`            | 2或4字节 | `-32,768 ~ 32,767` 或 `-2,147,483,648 ~ 2,147,483,647` |
| `unsigned int`   | 2或4字节 | `0 ~ 65,535` 或 `0 ~ 4,294,967,295`                    |
| `short`          | 2字节    | `-32,768 ~ 32,767`                                     |
| `unsigned short` | 2字节    | `0 ~ 65,535`                                           |
| `long`           | 4字节    | `-2,147,483,648 ~ 2,147,483,647`                       |
| `unsigned long`  | 4字节    | `0 ~ 4,294,967,295`                                    |

要在特定平台上获取类型或变量的确切大小，可以使用`sizeof`运算符。 表达式`sizeof(type)`产生对象或类型的存储大小(以字节为单位)。 以下是在任何机器上获取`int`类型大小的示例代码 -

```objectivec
#import <Foundation/Foundation.h>

int main() {
   NSLog(@"Storage size for int : %d \n", sizeof(int));
   return 0;
}


Objective
```

编译并执行上述程序时，它在Linux上生成以下结果 -

```shell
2018-11-14 01:03:20.930 main[118460] Storage size for int : 4
```

## 浮点类型

下表提供了有关标准浮点类型的存储大小和值范围及其精度的详细信息 -

| 类型          | 存储大小 | 值范围                  | 精度     |
| ------------- | -------- | ----------------------- | -------- |
| `float`       | 4字节    | `1.2E-38 ~ 3.4E+38`     | 6位小数  |
| `double`      | 8字节    | `2.3E-308 ~ 1.7E+308`   | 15位小数 |
| `long double` | 10字节   | `3.4E-4932 ~ 1.1E+4932` | 19位小数 |

头文件`float.h`定义了一些宏，可使用这些值以及有关程序中实数的二进制表示的其他详细信息。 以下示例将打印浮点类型占用的存储空间及其范围值 -

```objectivec
#import <Foundation/Foundation.h>

int main() {
   NSLog(@"Storage size for float : %d , maxval=%f \n", sizeof(float), FLT_MAX);
   return 0;
}
```



执行上面示例代码，得到以下结果：

```shell
2018-11-14 01:10:18.270 main[44023] Storage size for float : 4 , maxval=340282346638528859811704183484
```

注：有关 *float.h* 中定义的一些宏如下所示 - 

```c
#define FLT_DIG         6                       /* # of decimal digits of precision */
#define FLT_EPSILON     1.192092896e-07F        /* smallest such that 1.0+FLT_EPSILON != 1.0 */
#define FLT_GUARD       0
#define FLT_MANT_DIG    24                      /* # of bits in mantissa */
#define FLT_MAX         3.402823466e+38F        /* max value */
#define FLT_MAX_10_EXP  38                      /* max decimal exponent */
#define FLT_MAX_EXP     128                     /* max binary exponent */
#define FLT_MIN         1.175494351e-38F        /* min positive value */
#define FLT_MIN_10_EXP  (-37)                   /* min decimal exponent */
#define FLT_MIN_EXP     (-125)                  /* min binary exponent */
#define FLT_NORMALIZE   0
#define FLT_RADIX       2                       /* exponent radix */
#define FLT_ROUNDS      1                       /* addition rounding: near */
```

## void类型

`void`类型指定没有可用的值。它用于以下两种情况 -

| 编号 | 类型               | 描述                                                         |
| ---- | ------------------ | ------------------------------------------------------------ |
| 1    | 函数指定返回`void` | Objective-C中有各种函数，它们不需要返回值，或者也可以说它们返回`void`。 没有返回值的函数的返回类型为`void`。 例如，`void exit(int status);` |
| 2    | 函数参数为`void`   | Objective-C中有各种函数不接受任何参数。没有参数的函数可以指示接受`void`类型。 例如，`int rand(void);` |

如果此时还无法理解`void`类型也没有关系，可在后面的章节中看到更多介绍这个概念和示例。



## 枚举类型-待补充



## 派生类型-待补充



# Objective-C变量

变量是程序可以操作的存储区域的名称。 Objective-C中的每个变量都有一个特定的类型，它决定了变量内存的大小和布局; 可存储在内存中的值的范围; 以及可以应用于变量的操作集。

变量的名称可以由字母，数字和下划线(`_`)字符组成。 它必须以字母或下划线开头，它是区分大小写的，即：大写和小写字母是不同的变量。 根据前一章解释的基本类型，有以下几种基本变量类型 -

| 编号 | 类型     | 描述                                           |
| ---- | -------- | ---------------------------------------------- |
| 1    | `char`   | 通常它是一个八位(一个字节)，这是一个整数类型。 |
| 2    | `int`    | 机器最自然的整数大小，一般是2字节或4字节       |
| 3    | `float`  | 单精度浮点值。                                 |
| 4    | `double` | 双精度浮点值。                                 |
| 5    | `void`   | 表示不存在类型(什么类型也不是)                 |

Objective-C编程语言还允许定义各种其他类型的变量，这些将在后续章节中介绍，其他类型如：枚举，指针，数组，结构，联合等。在本章中，只学习基本变量类型。

## Objective-C变量定义

变量定义告诉编译器为变量创建存储的位置和数量。 变量定义指定数据类型，并包含该类型的一个或多个变量的列表，如下所示 -

```objective-c
type variable_list;
```

这里，`type`必须是有效的Objective-C数据类型，它包括：`char`，`w_char`，`int`，`float`，`double`，`bool`或任何用户定义的对象等，`variable_list`可以包含一个或多个用逗号分隔的标识符名称。下面显示了一些有效的声明 -

```objective-c
int    i, j, k;
char   c, ch;
float  f, salary;
double d;
```

第一行：`int i，j，k;`声明并定义变量`i`，`j`和`k`; 它指示编译器创建名为`i`，`j`和`k`的`int`类型变量。

变量可以在声明时初始化(分配初始值)。 初始化程序包含一个等号，后跟一个常量表达式，如下所示 -

```objective-c
type variable_name = value;
```

下面是变量声明的一些例子 -

```objective-c
extern int d = 3, f = 5;    // declaration of d and f. 
int d = 3, f = 5;           // definition and initializing d and f. 
byte z = 22;                // definition and initializes z. 
char x = 'x';               // the variable x has the value 'x'.
```

对于没有初始化变量的定义：具有静态存储持续时间的变量用`NULL`隐式初始化(所有字节的值都为`0`); 所有其他变量的初始值未定义。



## Objective-C变量声明/函数声明

变量声明为编译器提供了保证，即存在一个具有给定类型和名称的变量，以便编译器继续进行进一步编译，而无需完整的变量详细信息。变量声明仅在编译时有意义，编译器在链接程序时需要实际的变量声明。

当使用多个文件并在其中一个文件中定义变量时，变量声明很有用，这些文件在链接程序时可用。 使用`extern`关键字在任何地方声明变量。 虽然可以在Objective-C程序中多次声明变量，但它只能在文件，函数或代码块中定义一次。

**示例**
尝试以下示例，变量已在顶部声明，但它们在主函数内定义和初始化 -

```objective-c
#import <Foundation/Foundation.h>

// Variable declaration:
extern int a, b;
extern int c;
extern float f;

int main () {
  /* variable definition: */
  int a, b;
  int c;
  float f;

  /* actual initialization */
  a = 10;
  b = 20;

  c = a + b;
  NSLog(@"value of c : %d \n", c);

  f = 80.0/3.0;
  NSLog(@"value of f : %f \n", f);

  return 0;
}
```

编译并执行上述代码时，它将产生以下结果 -

```shell
2018-11-14 01:44:55.382 main[141586] value of c : 30 
2018-11-14 01:44:55.383 main[141586] value of f : 26.666666
```

同样的概念适用于函数声明，在声明时提供函数名称，并且可在其他任何位置给出其实际定义。 在下面的示例中，使用C函数进行了解释，Objective-C也支持C样式函数 -

```objective-c
// 函数声明
int func();

int main() {
   // 调用函数
   int i = func();
}

// 函数定义
int func() {
   return 99;
}
```

## Objective-C的左值和右值

Objective-C中有两种表达式 -

- **左值** - 引用内存位置的表达式称为“左值”表达式。左值可以显示为赋值的左侧或右侧。
- **右值** - 术语右值是指存储在内存中某个地址的数据值。右值是一个不能赋值给它的表达式，这意味着右值可能出现在赋值的右边但不是左边。

变量是左值，因此可能出现在赋值的左侧。 数字文字是右值，因此无法分配，也不能出现在左侧。 以下是有效的声明 -

```c
int g = 20;
```

但是以下不是有效的语句，会产生编译时错误 -

```c
10 = 20;
```



# Objective-C常量

常量指的是程序在执行期间不会改变的固定值。这些固定值也称为文字。
常量可以是任何基本数据类型，如整数常量，浮点常量，字符常量或字符串文字。还有枚举常量。
常量被视为常规变量，只不过它们的值在定义后无法修改。

## 整数常量

整数常量可以是十进制，八进制或十六进制常量。前缀指定基数或基数：十六进制为`0x`或`0X`，八进制为`0`，十进制为空。

整数常量也可以有一个后缀，它是`U`和`L`的组合，分别对于`unsigned`和`long`。后缀可以是大写或小写，可以按任何顺序排列。

以下是整数常量的一些示例 -

```c
212         /* 合法有效 */
215u        /* 合法有效 */
0xFeeL      /* 合法有效 */
078         /* 非法无效: 8 不是八进制数字 */
032UU       /* 非法无效: 不能重复后缀*/
```

以下是各种类型的整数常量的一些示例 -

```c
85         /* decimal */
0213       /* octal */
0x4b       /* hexadecimal */
30         /* int */
30u        /* unsigned int */
30l        /* long */
30ul       /* unsigned long */
```

## 浮点文字

浮点文字有整数部分，小数点，小数部分和指数部分。 可以以十进制形式或指数形式表示浮点文字。

在使用小数形式表示时，必须包括小数点，指数或两者，并且在使用指数形式表示时，必须包括整数部分，小数部分或两者。 带符号的指数由`e`或`E`引入。

以下是浮点文字的一些示例 -

```c
3.14159       /* 合法有效 */
314159E-5L    /* 合法有效 */
510E          /* 非法无效: 不完整的指数 */
210f          /* 非法无效: 没有小数或指数 */
.e55          /* 非法无效: 缺少整数或分数 */
```

## 字符常量

字符文字用单引号括起来，例如`'x'`，可以存储在`char`类型的变量中。
字符文字可以是普通字符(例如，`'x'`)，转义序列(例如，`'\t'`)，或通用字符(例如，`'\u02C0'`)。

C中有某些字符，当它们以反斜杠进行时，它们具有特殊含义，它们用于表示换行符(`\n`)或制表符(`\t`)。 在这里，有一些此类转义序列代码的列表 -

| 转义序列                                                     | 表示含义               |
| ------------------------------------------------------------ | ---------------------- |
| `\\`                                                         | `\`字符                |
| ![img](https://www.yiibai.com/uploads/images/2018/11/14/100051_84282.png) | `'`字符                |
| ![img](https://www.yiibai.com/uploads/images/2018/11/14/100249_56102.png) | `"`字符                |
| `\?`                                                         | `?`字符                |
| `\a`                                                         | 警报或铃声             |
| `\b`                                                         | 退格                   |
| `\f`                                                         | 换页                   |
| `\n`                                                         | 换行                   |
| `\r`                                                         | 回车                   |
| `\t`                                                         | 水平制表               |
| `\v`                                                         | 水直制表               |
| `\ooo`                                                       | 八进制数字的一到三位数 |

以下是显示一些转义序列字符的示例 -

```objectivec
#import <Foundation/Foundation.h>

int main() {
   NSLog(@"Yiibai\t.com\n\n");
   return 0;
}


Objective-C
```

执行上面示例代码，得到以下结果：

```shell
Yiibai    .com
```

## 字符串文字

字符串文字或常量用双引号(`""`)括起来。字符串包含与字符文字类似的字符：普通字符，转义序列和通用字符。 可以使用字符串文字将长的一行分成多行，并使用空格分隔它们。
以下是字符串文字的一些示例。 这三种形式都是表示相同的字符串。

```objectivec
"hello, dear"

"hello, \

dear"

"hello, " "d" "ear"
```

## 定义常量

Objetive-C中有两种简单的方法来定义常量 -

- 使用`#define`预处理器。
- 使用`const`关键字。

### 使用#define预处理器

以下是使用`#define`预处理器定义常量的形式 -

```c
#define identifier value
```

通过以下示例代码理解 -

```objectivec
#import <Foundation/Foundation.h>

#define LENGTH 10   
#define WIDTH  25
#define NEWLINE '\n'

int main() {
   int area;
   area = LENGTH * WIDTH;
   NSLog(@"value of area : %d", area);
   NSLog(@"%c", NEWLINE);

   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-14 02:12:14.492 main[10613] value of area : 250
2018-11-14 02:12:14.494 main[10613]
```

### const关键字

使用`const`关键字作为前缀来声明具有特定类型的常量，如下所示 -

```c
const type variable = value;
```

通过以下示例代码理解 -

```objectivec
#import <Foundation/Foundation.h>

int main() {
   const int  LENGTH = 10;
   const int  WIDTH  = 15;
   const char NEWLINE = '\n';
   int area;  

   area = LENGTH * WIDTH;
   NSLog(@"value of area : %d", area);
   NSLog(@"%c", NEWLINE);

   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-14 02:15:15.421 main[170983] value of area : 150
2018-11-14 02:15:15.422 main[170983]
```

请注意，使用使用大写字母来定义常量是一种很好的编程习惯。





# Objective-C运算符

运算符是一个符号，告诉编译器执行特定的数学或逻辑操作。 Objective-C语言内置很多运算符，提供如下类型的运算符 -

- 算术运算符
- 关系运算符
- 逻辑运算符
- 按位运算符
- 分配运算符
- 其它运算符

本教程将逐一解释算术，关系，逻辑，按位，赋值和其他运算符。

## 算术运算符

下表显示了Objective-C语言支持的所有算术运算符。 假设变量`A=10`，变量`B=20`，则 - 

| 运算符 | 描述                         | 示例              |
| ------ | ---------------------------- | ----------------- |
| `+`    | 两个操作数相加               | `A + B = 30`      |
| `-`    | 从第一个减去第二个操作数     | `A - B = -10`     |
| `*`    | 两个操作数相乘               | `A * B = 200`     |
| `/`    | 分子除以分母                 | `B / A = 2`       |
| `%`    | 模数运算符，整数除法后的余数 | `B % A = 0`       |
| `++`   | 递增运算符，将整数值增加`1`  | `A++`，结果为`11` |
| `--`   | 递减运算符，将整数值减`1`    | `A--`，结果为`9`  |

## 关系运算符

下表显示了Objective-C语言支持的所有关系运算符。假设变量`A=10`，变量`B=20`，则 -

| 运算符 | 描述                                                         | 示例                      |
| ------ | ------------------------------------------------------------ | ------------------------- |
| `==`   | 比较两个操作数的值是否相等; 如果相等，则条件成立。           | `(A == B)`结果为：`false` |
| `!=`   | 比较两个操作数的值是否相等; 如果不相等，则条件成立。         | `(A != B)`结果为：`true`  |
| `>`    | 比较左操作数的值是否大于右操作数的值; 如果是，则条件成立。   | `(A > B)`结果为：`false`  |
| `<`    | 比较左操作数的值是否小于右操作数的值; 如果是，则条件成立。   | `(A < B)`结果为：`true`   |
| `>=`   | 比较左操作数的值是否大于等于右操作数的值; 如果是，则条件成立。 | `(A >= B)`结果为：`false` |
| `<=`   | 比较左操作数的值是否小于等于右操作数的值; 如果是，则条件成立。 | `(A <= B)`结果为：`true`  |

[关系运算符示例](https://www.yiibai.com/objective_c/objective_c_relational_operators.html)

## 逻辑运算符

下表显示了Objective-C语言支持的所有逻辑运算符。 假设变量`A=1`，而变量`B=0`，则 -

| 运算符 | 描述                                                         | 示例                      |
| ------ | ------------------------------------------------------------ | ------------------------- |
| `&&`   | 逻辑“与”运算符。 如果两个操作数都不为零，则条件成立。        | `(A && B)`结果为：`false` |
| ΙΙ     | 逻辑“或”运算符。如果两个操作数中的任何一个不为零，则条件变为`true`。 | (A ΙΙ B)结果为：`true`    |
| `!`    | 逻辑“非”运算符。 用于反转其操作数的逻辑状态。 如果条件为`true`，则逻辑“非”运算符后将为`false`。 | `!(A && B)`结果为：`true` |

[逻辑运算符示例](https://www.yiibai.com/objective_c/objective_c_logical_operators.html)

## 按位运算符

按位运算符处理位并执行逐位运算。 `＆`，`|`和`^`的真值表如下 -

![img](https://www.yiibai.com/uploads/images/2018/11/14/105238_43032.png)

假设`A = 60`和`B = 13`，现在以二进制格式，它们按位运算将如下 -

```
A = 0011 1100

B = 0000 1101

-----------------

A&B = 0000 1100

A|B = 0011 1101

A^B = 0011 0001

~A  = 1100 0011
```

Objective-C语言支持按位运算符。假设变量`A=60`，变量`B=13`，如下表所示 -

| 运算符 | 描述                                                         | 示例                                      |
| ------ | ------------------------------------------------------------ | ----------------------------------------- |
| `&`    | 二进制AND运算符，如果两个操作数同位上存在`1`，则它会将结果复制到结果中。 | `(A & B) = 12`, 也就是：`0000 1100`       |
| Ι      | 二进制OR运算符，如果存在于任一操作数中，则复制`1`位。        | (A Ι B) = 12 , 也就是：`0011 1101`        |
| `^`    | 二进制异或运算符，如果在一个操作数中设置，但不在两个操作数中设置，则复制该位。 | `(A ^ B) = 49`, 也就是：`0011 0001`       |
| `~`    | 二元补语运算符是一元的，具有“翻转”位的效果。                 | `(~A )`结果为：`-61`, 也就是：`1100 0011` |
| `<<`   | 二进制左移运算符。左操作数值向左移动右操作数指定的位数。     | `A << 2 = 240`, 也就是：`1111 0000`       |
| `>>`   | 二进制右移运算符。左操作数值向右移动右操作数指定的位数。     | `A >> 2 = 15`, 也就是：`0000 1111`        |

[按位运算符示例](https://www.yiibai.com/objective_c/objective_c_bitwise_operators.html)

## 赋值运算符

Objective-C语言支持以下赋值运算符 -

| 运算符 | 描述                                                         | 示例                                |
| ------ | ------------------------------------------------------------ | ----------------------------------- |
| `=`    | 简单赋值运算符，将右侧操作数的值分配给左侧操作数             | `C = A + B`是将`A + B`的值分配给`C` |
| `+=`   | 相加和赋值运算符，它将右操作数添加到左操作数并将结果赋给左操作数 | `C += A` 相当于 `C = C + A`         |
| `-=`   | 相减和赋值运算符，它从左操作数中减去右操作数，并将结果赋给左操作数 | `C -= A` 相当于 `C = C - A`         |
| `*=`   | 相乘和赋值运算符，它将右操作数与左操作数相乘，并将结果赋给左操作数 | `C *= A` 相当于 `C = C * A`         |
| `/=`   | 除以和赋值运算符，它将左操作数除以右操作数，并将结果赋给左操作数 | `C /= A` 相当于 `C = C / A`         |
| `%=`   | 模数和赋值运算符，它使用两个操作数获取模数，并将结果赋给左操作数 | `C %= A` 相当于 `C = C % A`         |
| `<<=`  | 左移和赋值运算符                                             | `C <<= 2` 相当于 `C = C << 2`       |
| `>>=`  | 右移和赋值运算符                                             | `C >>= 2` 相当于 `C = C >> 2`       |
| `&=`   | 按位并赋值运算符                                             | `C &= 2` 相当于 `C = C & 2`         |
| `^=`   | 按位异或和赋值运算符                                         | `C ^= 2` 相当于 `C = C ^ 2`         |
| Ι      | 按位包含OR和赋值运算符                                       | C Ι= 2 相当于 C = C Ι 2             |

[赋值运算符示例](https://www.yiibai.com/objective_c/objective_c_assignment_operators.html)

## 其他运算符：sizeof和三元运算符

还有其他一些重要的运算符，包括`sizeof`和`?:`三元运算符，Objective-C语言也都支持。

| 运算符     | 描述             | 示例                                                |
| ---------- | ---------------- | --------------------------------------------------- |
| `sizeof()` | 返回变量的大小   | `sizeof(a)`, 这里如果变量`a`是整数，则将返回：`4`。 |
| `&`        | 返回变量的地址。 | `&a`将返回变量的实际地址。                          |
| `*`        | 指向变量的指针。 | `*a`将指向变量。                                    |
| `? :`      | 条件表达式       | 如果条件为真？然后是`X`值：否则为`Y`值              |

[sizeof和三元运算符示例](https://www.yiibai.com/objective_c/objective_c_sizeof_operator.html)

## Objective-C运算符优先级

运算符优先级确定表达式中的术语分组。这会影响表达式的计算方式。 某些运算符优先级高于其他运算符; 例如，乘法运算符的优先级高于加法运算符 - 

例如，`x = 7 + 3 * 2`; 这里，`x`被赋值为`13`，而不是`20`，因为 `*`运算符的优先级高于`+`运算符，所以它首先乘以`3 * 2`然后加上`7`。

此处，具有最高优先级的运算符显示在下表的顶部，具有最低优先级的运算符显示在下表底部。 在表达式中，将首先评估更高优先级的运算符。

| 分类    | 运算符                                                | 关联性 |
| ------- | ----------------------------------------------------- | ------ |
| 后缀    | `()` `[]` `->` `.` `++` `--`                          | 左到右 |
| 一元    | `+` `-` `!` `~` `++` `--` `(type)*` `&` `sizeof`      | 右到左 |
| 相乘    | `*` `/` `%`                                           | 左到右 |
| 相加    | `+` `-`                                               | 左到右 |
| 位移    | `<<` `>>`                                             | 左到右 |
| 关系    | `<` `<=` `>` `>=`                                     | 左到右 |
| 相等    | `==` `!=`                                             | 左到右 |
| 按位XOR | `^`                                                   | 左到右 |
| 按位OR  | Ι                                                     | 左到右 |
| 逻辑AND | `&&`                                                  | 左到右 |
| 逻辑OR  | ΙΙ                                                    | 左到右 |
| 条件    | `?:`                                                  | 右到左 |
| 分配    | `=` `+=` `-=` `*=` `/=` `%=` `>>=` `<<=` `&=` `^=` Ι= | 右到左 |
| 逗号    | `,`                                                   | 左到右 |



# Objective-C循环

当需要多次执行同一代码块时，可以使用循环来解决。 通常，语句按顺序执行：首先执行函数中的第一个语句，然后执行第二个语句，依此类推。 编程语言提供各种控制结构，允许更复杂的执行路径。循环语句可用于多次执行语句或语句组，以下是大多数编程语言中循环语句的一般形式 -

![img](https://www.yiibai.com/uploads/article/2018/11/14/135032_34890.jpg)

Objective-C编程语言提供以下类型的循环来处理循环需求。单击以下相应链接来查看其详细信息。

| 编号 | 循环类型                                                     | 描述                                                         |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | [while循环](https://www.yiibai.com/objective_c/objective_c_while_loop.html) | 在给定条件为真时重复语句或语句组，它在执行循环体之前测试条件。 |
| 2    | [for循环](https://www.yiibai.com/objective_c/objective_c_for_loop.html) | 多次执行一系列语句，并缩写管理循环变量的代码。               |
| 3    | [do…while循环](https://www.yiibai.com/objective_c/objective_c_do_while_loop.html) | 像`while`循环语句一样，但它在循环体的末尾测试条件。          |
| 4    | [嵌套循环](https://www.yiibai.com/objective_c/objective_c_nested_loops.html) | 在任何其他循环内使用一个或多个循环，`while`，`for`或`do...while`循环。 |

## 循环控制语句

循环控制语句将执行从其正常序列更改。 当执行离开作用域时，将销毁在该作用域中创建的所有自动对象。

Objective-C支持以下控制语句，单击以下链接以查看其详细信息。

| 编号 | 控制语句                                                     | 描述                                                         |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | [break语句](https://www.yiibai.com/objective_c/objective_c_break_statement.html) | 用来终止循环或`switch`语句，并在循环或切换后立即将执行转移到语句。 |
| 2    | [continue语句](https://www.yiibai.com/objective_c/objective_c_continue_statement.html) | 导致循环跳过其主体的其余部分，并在重复之前立即重新测试其状态。 |

## 无限循环

如果条件永远不会变为假，则循环变为无限循环。`for`循环传统上用于此目的。 由于不需要构成`for`循环的三个表达式，因此可以通过将条件表达式留空来创建无限循环。

```objectivec
#import <Foundation/Foundation.h>

int main () {

   for( ; ; ) {
      NSLog(@"This loop will run forever.\n");
   }

   return 0;
}


Objective-C
```

当条件表达式不存在时，程序假定条件为真。可选有一个初始化和增量表达式，但Objective-C程序员更常使用`for(;;)`构造来表示无限循环。



# Objective-C决策

​					 				 				 				 			

决策结构要求程序员指定一个或多个要由程序评估或测试的条件，以及在条件被确定为真时要执行的一个或多个语句，以及可选的，如果条件要执行的其他语句 被认定是假的。

以下是大多数编程语言中的典型决策结构的一般形式 -
![img](https://www.yiibai.com/uploads/images/2018/11/14/154849_75071.jpg)

Objective-C编程语言将任何非零和非`null`假定为`true`，如果它为零或`null`，则将其假定为`false`。
Objective-C编程语言提供以下类型的决策制定语句。 单击以下链接查看其详细信息 -

| 编号 | 语句                                                         | 描述                                                         |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | [if语句](https://www.yiibai.com/objective_c/if_statement_in_objective_c.html) | `if`语句是由布尔表达式后跟一个或多个语句组成。               |
| 2    | [if…else语句](https://www.yiibai.com/objective_c/if_else_statement_in_objective_c.html) | `if`语句后面可以跟一个可选的`else`语句，该语句在if布尔条件表达式为`false`时执行。 |
| 3    | [嵌套if语句](https://www.yiibai.com/objective_c/nested_if_statements_in_objective_c.html) | 在一个`if`或`else if`语句中可使用`if`或`else if`语句。       |
| 4    | [switch语句](https://www.yiibai.com/objective_c/switch_statement_in_objective_c.html) | `switch`语句用于测试变量与值列表的相等性。                   |
| 5    | [嵌套switch语句](https://www.yiibai.com/objective_c/nested_switch_statements_in_objective_c.html) | 在一个`switch`语句中使用一个`switch`语句。                   |

## `?:`运算符

前面我们讲过了条件运算符`?:`，条件运算符可以用来替换`if...else`语句。它的一般形式如下 -

```c
Exp1 ? Exp2 : Exp3;
```

`Exp1`，`Exp2`和`Exp3`都是表达式。 注意冒号的使用和放置。

`?`表达式的确定方式如下：评估`Exp1`。 如果结果为`true`，那么`Exp2`会被评估并成为整个值`?`表达式的值。 如果`Exp1`评估为`false`，则计算`Exp3`，`Exp3`的结果值将成为表达式的值。



# Objective-C函数

函数是一组一起执行任务的语句。 每个Objective-C程序都有一个C函数，也就是`main()`函数，所有最简单的程序都可以定义为函数。

可将代码划分为单独的函数。如何在不同的函数之间划分代码取决于程序员，但逻辑上这个划分通常是这样，每个函数执行一个特定的任务。

函数声明告诉编译器函数的名称，返回类型和参数。 函数定义提供函数的实际主体。

在Objective-C中，基本上会将函数称为方法。

Objective-C基础框架提供了程序可以调用的许多内置方法。 例如，`appendString()`方法将字符串附加到另一个字符串。
已知一种方法具有各种名称，如函数或子程序或程序等。

## 1. 定义方法

Objective-C编程语言中方法定义的一般形式如下 -

```objectivec
- (return_type) method_name:( argumentType1 )argumentName1 
    joiningArgument2:( argumentType2 )argumentName2 ... 
    joiningArgumentn:( argumentTypen )argumentNamen {
    body of the function
}
```

Objective-C编程语言中的方法定义由方法头和方法体组成。 以下是方法的所有部分 -

- **返回类型** - 方法可以返回值。`return_type`是函数返回的值的数据类型。 某些方法执行所需的操作而不返回值。 在这种情况下，`return_type`是关键字`void`。
- **方法名称** - 这是方法的实际名称。方法名称和参数列表一起构成方法签名。
- **参数** - 参数就像一个占位符。调用函数时，将值传递给参数。该值称为实际参数或参数。参数列表指的是方法的参数的类型，顺序和数量。 参数是可选的; 也就是说，方法可能不包含任何参数。
- **连接参数** - 一个连接的参数是让它更易于阅读并在调用时清楚地表达它。
- **方法体** - 方法体包含一组语句，用于定义方法的作用。

**示例**
以下是名为`max()`的方法的源代码。 这个方法有两个参数`num1`和`num2`，并返回两个参数的最大值 -

```objectivec
/* 返回两个参数的最大值 */
- (int) max:(int) num1 secondNumber:(int) num2 {

   /* 局部变量声明 */
   int result;

   if (num1 > num2) {
      result = num1;
   } else {
      result = num2;
   }

   return result; 
}
```

## 方法声明

方法声明告诉编译器有关函数名称以及如何调用该方法的信息。 函数的实际主体可以单独定义。

方法声明包含以下部分 -

```objectivec
- (return_type) function_name:( argumentType1 )argumentName1 
joiningArgument2:( argumentType2 )argumentName2 ... 
joiningArgumentn:( argumentTypen )argumentNamen;
```

对于上面定义的`max()`函数，以下是方法声明 -

```objectivec
-(int) max:(int)num1 andNum2:(int)num2;
```

在一个源文件中定义方法并在另一个文件中调用该方法时，需要方法声明。 在这种情况下，应该在调用该函数的文件顶部声明该函数。

## 3. 调用方法

在创建Objective-C方法时，可以定义函数必须执行的操作。 要使用方法，必须调用该函数来执行定义的任务。
当程序调用函数时，程序控制将转移到被调用的方法。 被调用的方法执行已定义的任务，当执行其返回语句或达到其函数结束右括号时，它将程序控制返回给主程序。
要调用方法，只需要传递必需的参数和方法名称，如果方法返回值，则可以存储返回的值。 例如 -

```objectivec
#import <Foundation/Foundation.h>

@interface SampleClass:NSObject
/* 方法声明 */
- (int)max:(int)num1 andNum2:(int)num2;
@end

@implementation SampleClass

/* 返回两个数的最大值 */
- (int)max:(int)num1 andNum2:(int)num2 {

   /* 声明局部变量 */
   int result;

   if (num1 > num2) {
      result = num1;
   } else {
      result = num2;
   }

   return result; 
}

@end

int main () {

   /* 定义局部变量 */
   int a = 119;
   int b = 199;
   int ret;

   SampleClass *sampleClass = [[SampleClass alloc]init];

   /* 调用方法来获取最大值 */
   ret = [sampleClass max:a andNum2:b];

   NSLog(@"Max value is : %d\n", ret );
   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-15 01:18:49.962 main[43680] Max value is : 199
```

> 🙄 方法调用的语法真奇怪！

## 函数参数

这些变量称为函数的形式参数。形式参数的行为与函数内部的其他局部变量相似，并在进入函数时创建，并在退出时销毁。
在调用函数时，有两种方法可以将参数传递给函数 -

| 编号 | 调用类型                                                     | 描述                                                         |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | [按值调用](https://www.yiibai.com/objective_c/objective_c_function_call_by_value.html) | 此方法将参数的实际值复制到函数的形式参数中。在这种情况中，对函数内部参数所做的更改不会对参数产生影响。 |
| 2    | [按引用调用](https://www.yiibai.com/objective_c/objective_c_function_call_by_reference.html) | 此方法将参数的地址复制到形式参数中。在函数内部，该地址用于访问调用中使用的实际参数。对参数所做的更改会影响参数。 |

默认情况下，Objective-C使用**按值调用**来传递参数。 所以函数内的代码改变用于调用函数的参数不会反应到函数外部，而上述示例在调用`max()`函数时使用相同的方法。



# Objective-C块

Objective-C类定义了一个将数据与相关行为相结合的对象。 有时，仅表示单个任务或行为单元而不是方法集合是有意义的。

块是C，Objective-C和C++等编程语言中的高级功能，它允许创建不同的代码段，这些代码段可以传递给方法或函数，就像它们是值一样。 块是Objective-C对象，因此它们可以添加到`NSArray`或`NSDictionary`等集合中。 它们还能够从封闭范围中捕获值，使其类似于其他编程语言中的闭包或`lambda`。

**简单块声明语法**

```objectivec
returntype (^blockName)(argumentType);
```

简单的块实现 - 

```objectivec
returntype (^blockName)(argumentType)= ^{
};
```

下面是一个简单的示例代码 - 

```objectivec
void (^simpleBlock)(void) = ^{
   NSLog(@"This is a block");
};
```

调用上面块的示例代码 - 

```shell
simpleBlock();
```

#### 块接受参数和返回值

块也可以像方法和函数一样获取参数和返回值。
下面是一个使用参数和返回值实现和调用块的简单示例。

```objectivec
double (^multiplyTwoValues)(double, double) = 
   ^(double firstValue, double secondValue) {
      return firstValue * secondValue;
   };

double result = multiplyTwoValues(2,4); 
NSLog(@"The result is %f", result);
```

#### 使用类型定义块

这是一个在块中使用`typedef`的简单示例。 请注意，此示例不适用于在线编译器。 它是使用XCode运行的。

```objectivec
#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)();
@interface SampleClass:NSObject
- (void)performActionWithCompletion:(CompletionBlock)completionBlock;
@end

@implementation SampleClass

- (void)performActionWithCompletion:(CompletionBlock)completionBlock {

   NSLog(@"Action Performed");
   completionBlock();
}

@end

int main() {

   /* 第一个Objective-C程序 */
   SampleClass *sampleClass = [[SampleClass alloc]init];
   [sampleClass performActionWithCompletion:^{
      NSLog(@"Completion is called to intimate action is performed.");
   }];

   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-10 08:14:57.105 demo[184:323] Action Performed
2018-11-10 08:14:57.108 demo[184:323] Completion is called to intimate action is performed.
```

> 😯还挺牛逼，支持传递代码块

块在iOS应用程序和Mac OS X中使用得更多。因此，了解块的用法更为重要。



# Objective-C数字

在Objective-C编程语言中，要以对象形式保存基本数据类型，如：`int`，`float`，`bool`。Objective-C提供了一系列与`NSNumber`一起使用的方法，一些常用重要的方法列在下表中。

| 编号 | 方法                                               | 描述                                                         |
| ---- | -------------------------------------------------- | ------------------------------------------------------------ |
| 1    | `+ (NSNumber *)numberWithBool:(BOOL)value`         | 创建并返回包含给定值的`NSNumber`对象，将其视为`BOOL`。       |
| 2    | `+ (NSNumber *)numberWithChar:(char)value`         | 创建并返回包含给定值的`NSNumber`对象，将其视为`signed char`。 |
| 3    | `+ (NSNumber *)numberWithDouble:(double)value`     | 创建并返回包含给定值的`NSNumber`对象，将其视为`double`。     |
| 4    | `+ (NSNumber *)numberWithFloat:(float)value`       | 创建并返回包含给定值的`NSNumber`对象，将其视为`float`。      |
| 5    | `+ (NSNumber *)numberWithInt:(int)value`           | 创建并返回包含给定值的`NSNumber`对象，将其视为`signed int`。 |
| 6    | `+ (NSNumber *)numberWithInteger:(NSInteger)value` | 创建并返回包含给定值的`NSNumber`对象，将其视为`NSInteger`。  |
| 7    | `- (BOOL)boolValue`                                | 以`BOOL`形式返回接收的值。                                   |
| 8    | `- (char)charValue`                                | 以`char`形式返回接收的值。                                   |
| 9    | `- (double)doubleValue`                            | 以`double`形式返回接收的值。                                 |
| 10   | `- (float)floatValue`                              | 以`float`形式返回接收的值。                                  |
| 11   | `- (NSInteger)integerValue`                        | 将接收的值作为`NSInteger`返回。                              |
| 12   | `- (int)intValue`                                  | 以`int`形式返回接收的值。                                    |
| 13   | `- (NSString *)stringValue`                        | 将接收的值作为人类可读的字符串形式返回。                     |

下面是一个使用`NSNumber`的简单示例，它将两个数的乘积返回。

```objectivec
#import <Foundation/Foundation.h>

@interface SampleClass:NSObject
- (NSNumber *)multiplyA:(NSNumber *)a withB:(NSNumber *)b;
@end

@implementation SampleClass

- (NSNumber *)multiplyA:(NSNumber *)a withB:(NSNumber *)b {
   float number1 = [a floatValue];
   float number2 = [b floatValue];
   float product = number1 * number2;
   NSNumber *result = [NSNumber numberWithFloat:product];
   return result;
}

@end

int main() {
    // 构造对象的写法
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

   SampleClass *sampleClass = [[SampleClass alloc]init];
    // 方法的调用
   NSNumber *a = [NSNumber numberWithFloat:10.5];
   NSNumber *b = [NSNumber numberWithFloat:10.0];   
   NSNumber *result = [sampleClass multiplyA:a withB:b];
   NSString *resultString = [result stringValue];
   NSLog(@"The product is %@",resultString);
	// 这又是啥？
   [pool drain];
   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-15 02:16:26.277 main[43604] The product is 105
```



# Objective-C数组

Objective-C编程语言提供了一种叫作数组的数据结构，它可以存储相同类型的固定大小顺序元素的集合。数组用于存储数据集合，但将数组视为相同类型的变量集合通常更有用。

可以声明一个数组变量(例如`numbers`)并使用`numbers[0]`，`numbers[1]`和`...`，`numbers[99]`来表示单个变量，例如：`number0`，`number1`，`...`和`number99`，而不是声明单个变量。 使用索引来访问数组中的特定元素。

所有数组都包含连续的内存位置。 最低地址对应于第一个元素，最高地址对应于最后一个元素。

![img](https://www.yiibai.com/uploads/article/2018/11/15/102413_69680.jpg)

## 声明数组

在Objective-C中声明一个数组，程序员需要指定元素的类型和数组所需的元素数量，如下所示 -

```objectivec
type arrayName [ arraySize ];
```

这称为一维数组。 `arraySize`必须是大于零的整数常量，`type`可以是任何有效的Objective-C数据类型。 例如，要声明一个名称为`balance`的`double`类型的`10`元素数组，请使用此语句 -

```objectivec
double balance[10];
```

现在，`balance`是一个变量数组，最多可容纳`10`个`double`类型。

## 初始化数组

可以逐个初始化Objective-C中的数组，也可以使用单个语句，如下所示 -

```objectivec
double balance[5] = {1000.0, 2.0, 3.4, 17.0, 50.0};
```

大括号`{}`之间的值的数量不能大于在方括号`[]`之间为数组声明的元素的数量。以下是分配数组的单个元素的示例 -
如果省略数组的大小，则会创建一个足以容纳初始化的数组。 因此，如果这样写 -

```objectivec
double balance[] = {1000.0, 2.0, 3.4, 17.0, 50.0};
```

这将创建与上一示例中完全相同的数组。

```objectivec
balance[4] = 50.0;
```

上面的语句将数组中的第`5`元素赋值为`50.0`。 具有第四个索引的数组它拥有`5`个元素，因为所有数组都将`0`作为第一个元素的索引，也称为基本索引。 以下是上面讨论的相同数组的图形表示 -

![img](https://www.yiibai.com/uploads/article/2018/11/15/103351_77103.jpg)

## 访问数组元素

通过索引数组名称来访问元素。通过将元素的索引放在数组名称后面的方括号中来完成的。 例如 -

```objectivec
double salary = balance[9];
```

上面的语句将从数组中取出第`10`个元素，并将值赋给`salary`变量。 以下是一个例子，它将使用上述所有三个概念，即数组声明，分配和访问数组 -

```objectivec
#import <Foundation/Foundation.h>

int main () {
   int n[ 10 ];   /* n 是10个整数的数组 */
   int i,j;

   /* 从 n 到 0 初始化数组的值 */         
   for ( i = 0; i < 10; i++ ) {
      n[ i ] = i + 100;    /* 从i 至 i + 100 设置数组元素的值  */
   }

   /* 输出每个数组元素的值 */
   for (j = 0; j < 10; j++ ) {
      NSLog(@"Element[%d] = %d\n", j, n[j] );
   }

   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-15 02:52:00.725 main[97171] Element[0] = 100
2018-11-15 02:52:00.727 main[97171] Element[1] = 101
2018-11-15 02:52:00.727 main[97171] Element[2] = 102
2018-11-15 02:52:00.727 main[97171] Element[3] = 103
2018-11-15 02:52:00.728 main[97171] Element[4] = 104
2018-11-15 02:52:00.728 main[97171] Element[5] = 105
2018-11-15 02:52:00.728 main[97171] Element[6] = 106
2018-11-15 02:52:00.728 main[97171] Element[7] = 107
2018-11-15 02:52:00.728 main[97171] Element[8] = 108
2018-11-15 02:52:00.728 main[97171] Element[9] = 109
```

## Objective-C数组详细介绍

数组对Objective-C很重要，需要更多细节。 以下几个与数组相关的重要概念应该对Objective-C程序员清楚 -

| 编号 | 概念                                                         | 描述                                                         |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | [多维数组](https://www.yiibai.com/objective_c/objective_c_multi_dimensional_arrays.html) | Objective-C支持多维数组，多维数组的最简单形式是二维数组。    |
| 2    | [将数组传递给函数](https://www.yiibai.com/objective_c/objective_c_passing_arrays_to_functions.html) | 通过指定不带索引的数组名称来向函数传递指向数组的指针。       |
| 3    | [从函数返回数组](https://www.yiibai.com/objective_c/objective_c_return_arrays_from_function.html) | Objective-C允许函数返回一个数组。                            |
| 4    | [指向数组的指针](https://www.yiibai.com/objective_c/objective_c_pointer_to_an_array.html) | 只需指定数组名称即可生成指向数组第一个元素的指针，而无需任何索引。 |



## Objective-C多维数组

bjective-C编程语言允许多维数组，下面是多维数组声明的一般形式 -

```objectivec
type name[size1][size2]...[sizeN];


Objective-C
```

例如，以下声明创建一个三维：`5`,`10`,`4`整数数组 -

```objectivec
int threedim[5][10][4];


Objective-C
```

### 二维数组

多维数组的最简单形式是二维数组。 实质上，二维数组是一维数组的列表。 要声明一个大小为`x`，`y`的二维整数数组，可以参考如下代码 -

```c
type arrayName [ x ][ y ];


C
```

其中，`type`可以是任何有效的Objective-C数据类型，`arrayName`是有效的Objective-C标识符。可将二维数组视为一个表格，其中包含`x`行和`y`列。包含`3`行`4`列的二维数组`a`，如下所示 -

![img](https://www.yiibai.com/uploads/article/2018/11/15/111316_48409.jpg)

因此，数组`a`中的每个元素都由`a[i][j]`形式的元素名称标识，其中`a`是数组的名称，`i`和`j`是唯一标识数组`a`中每个元素的下标。

### 初始化二维数组

通过为每行指定括号值来初始化多维数组。以下是一个包含`3`行的数组，每行有`4`列。

```objectivec
int a[3][4] = {  
   {0, 1, 2, 3} ,   /*  第0行索引的初始值设定项  */
   {4, 5, 6, 7} ,   /*  第1行索引的初始值设定项  */
   {8, 9, 10, 11}   /*  第2行索引的初始值设定项  */
};


Objective-C
```

指示预期行的嵌套大括号是可选的。 以下初始化数组等同于前面的示例 -

```c
int a[3][4] = {0,1,2,3,4,5,6,7,8,9,10,11};


C
```

### 访问二维数组元素

通过使用下标(即，数组的行索引和列索引)来访问二维数组中的元素。 例如 -

```objectivec
int val = a[2][3];
```

上面的语句将从数组的第`3`行获取第`4`个元素。可以在上图中验证它，阅读下面的程序，使用嵌套循环来处理(访问)二维数组 -

```objectivec
#import <Foundation/Foundation.h>

int main () {

   /* 定义一个 5行 2 列的二维数组 */
   int a[5][2] = { {0,0}, {1,2}, {2,4}, {3,6},{4,8}};
   int i, j;

   /* 输出每个元素的值 */
   for ( i = 0; i < 5; i++ ) {
      for ( j = 0; j < 2; j++ ) {
         NSLog(@"a[%d][%d] = %d\n", i,j, a[i][j] );
      }
   }

   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-15 03:19:28.766 main[119405] a[0][0] = 0
2018-11-15 03:19:28.768 main[119405] a[0][1] = 0
2018-11-15 03:19:28.768 main[119405] a[1][0] = 1
2018-11-15 03:19:28.768 main[119405] a[1][1] = 2
2018-11-15 03:19:28.768 main[119405] a[2][0] = 2
2018-11-15 03:19:28.768 main[119405] a[2][1] = 4
2018-11-15 03:19:28.768 main[119405] a[3][0] = 3
2018-11-15 03:19:28.768 main[119405] a[3][1] = 6
2018-11-15 03:19:28.768 main[119405] a[4][0] = 4
2018-11-15 03:19:28.768 main[119405] a[4][1] = 8
```

如上所述，可以拥有任意数量的数组，但创建的大多数数组一般都是一维或二维。

## Object-C将数组作为函数参数传递

如果要将一维数组作为参数传递给函数，则必须以下列三种方式之一声明函数形式参数，并且所有三种声明方法都会产生类似的结果，因为每个都告诉编译器接受一个整数指针。类似地，可以将多维数组作为形式参数传递。

#### 方式-1

使用指针形式参数如下(在下一章学习指针的用法)。

```c
- (void) myFunction(int *) param {
.
.
.
}
```

#### 方式-2

使用大小数组的形式参数如下 -

```c
- (void) myFunction(int [10] )param {
.
.
.
}
```

#### 方式-3

形式参数作为未指定大小数组如下 -

```c
-(void) myFunction: (int []) param {
.
.
.
```

#### 示例

现在，考虑以下函数，它将数组作为参数与另一个参数一起使用，并根据传递的参数，它将返回通过数组传递的数值的平均值，如下所示 -

```objectivec
-(double) getAverage:(int []) arr andSize:(int) size {
   int    i;
   double avg;
   double sum;

   for (i = 0; i < size; ++i) {
      sum += arr[i];
   }

   avg = sum / size;
   return avg;
}
```

现在，将上述函数调用如下 -

```objectivec
#import <Foundation/Foundation.h>

@interface SampleClass:NSObject

/* 函数声明 */
-(double) getAverage:(int []) arr andSize:(int) size;

@end

@implementation SampleClass

-(double) getAverage:(int []) arr andSize:(int) size {
   int    i;
   double avg;
   double sum =0;

   for (i = 0; i < size; ++i) {
      sum += arr[i];
   }

   avg = sum / size;
   return avg;
}

@end
int main () {

   /* 一个拥有 5 个元素的数组 */
   int balance[5] = {1000, 2, 3, 17, 50};
   double avg;

   SampleClass *sampleClass = [[SampleClass alloc]init];
   /* 将指针传递给数组作为参数 */
   avg = [sampleClass getAverage:balance andSize: 5] ;

   /* 输出返回值 */
   NSLog( @"Average value is: %f ", avg );

   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-15 03:28:08.265 main[86840] Average value is: 214.400000
```

如上所见，就函数而言，数组的长度无关紧要，因为Objective-C不对形式参数执行边界检查。



## Objective-C从函数返回数组

Objective-C编程语言不允许将整个数组作为参数返回给函数。 但是，可以通过指定不带索引的数组名称来返回指向数组的指针。 我们将在下一节学习指针，读者可可以跳过本节，直到理解Objective-C中的指针概念，然后再返回学习本节内容。

如果要从函数返回一维数组，则必须声明一个返回指针的函数，如下例所示 -

```objectivec
int * myFunction() {
.
.
.
}
```

要注意的是Objective-C不主张将局部变量的地址返回到函数外部，因此必须将局部变量定义为静态变量。

现在，考虑以下函数，它将生成`10`个随机数，并将它们放入数组返回，调用此函数如下 -

```objectivec
#import <Foundation/Foundation.h>

@interface SampleClass:NSObject
- (int *) getRandom;
@end

@implementation SampleClass

/* 用于生成和返回随机数的函数 */
- (int *) getRandom {
   static int  r[10];
   int i;

   /* 设置随机种子 */
   srand( (unsigned)time( NULL ) );
   for ( i = 0; i < 10; ++i) {
      r[i] = rand();
      NSLog( @"r[%d] = %d\n", i, r[i]);
   }

   return r;
}

@end

/* 调用上面定义的函数的主函数 */
int main () {

   /* 一个指向int的指针 */
   int *p;
   int i;

   SampleClass *sampleClass = [[SampleClass alloc]init];
   p = [sampleClass getRandom];
   for ( i = 0; i < 10; i++ ) {
      NSLog( @"*(p + %d) : %d\n", i, *(p + i));
   }

   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-15 03:34:00.443 main[117032] r[0] = 932030458
2018-11-15 03:34:00.445 main[117032] r[1] = 1604274933
2018-11-15 03:34:00.445 main[117032] r[2] = 996406515
2018-11-15 03:34:00.445 main[117032] r[3] = 1073657342
2018-11-15 03:34:00.445 main[117032] r[4] = 1208715588
2018-11-15 03:34:00.445 main[117032] r[5] = 611149669
2018-11-15 03:34:00.445 main[117032] r[6] = 417647883
2018-11-15 03:34:00.445 main[117032] r[7] = 1140301536
2018-11-15 03:34:00.445 main[117032] r[8] = 95760175
2018-11-15 03:34:00.445 main[117032] r[9] = 2100150993
2018-11-15 03:34:00.445 main[117032] *(p + 0) : 932030458
2018-11-15 03:34:00.445 main[117032] *(p + 1) : 1604274933
2018-11-15 03:34:00.445 main[117032] *(p + 2) : 996406515
2018-11-15 03:34:00.445 main[117032] *(p + 3) : 1073657342
2018-11-15 03:34:00.445 main[117032] *(p + 4) : 1208715588
2018-11-15 03:34:00.445 main[117032] *(p + 5) : 611149669
2018-11-15 03:34:00.445 main[117032] *(p + 6) : 417647883
2018-11-15 03:34:00.445 main[117032] *(p + 7) : 1140301536
2018-11-15 03:34:00.445 main[117032] *(p + 8) : 95760175
2018-11-15 03:34:00.445 main[117032] *(p + 9) : 2100150993
```

## Objective-C指向数组的指针

在学习与Objective-C中的指针相关的章节之前，您理解本章很可能有点吃力。

因此，在学习本节之前，我们假设您对Objective-C编程语言中的指针有一点了解。数组名称是指向数组第一个元素的常量指针。 因此，在声明中 -

```c
double balance[50];
```

`balance`是指向`&balance [0]`的指针，它是`balance`数组的第一个元素的地址。 因此，以下程序片段为`p`分配第一个`balance`元素的地址 -

```objectivec
double *p;
double balance[10];

p = balance;
```

将数组名称用作常量指针是合法的，反之亦然。 因此，`*(balance + 4)`是`balance[4]`访问数据的合法方式。

将第一个元素的地址存储在`p`中后，可以使用`* p`，`*(p + 1)`，`*(p + 2)`等访问数组元素。 以下是显示上述所有概念的示例 -

```objectivec
#import <Foundation/Foundation.h>

int main () {

   /* 一个拥有 5 个元素的数组 */
   double balance[5] = {1000.0, 2.0, 3.4, 17.0, 50.0};
   double *p;
   int i;

   p = balance;

   /* 输出数组中所有元素的值 */
   NSLog( @"Array values using pointer\n");
   for ( i = 0; i < 5; i++ ) {
      NSLog(@"*(p + %d) : %f\n",  i, *(p + i) );
   }

   NSLog(@"Array values using balance as address\n");
   for ( i = 0; i < 5; i++ ) {
      NSLog(@"*(balance + %d) : %f\n",  i, *(balance + i) );
   }

   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-15 03:49:56.217 main[177516] Array values using pointer
2018-11-15 03:49:56.220 main[177516] *(p + 0) : 1000.000000
2018-11-15 03:49:56.220 main[177516] *(p + 1) : 2.000000
2018-11-15 03:49:56.220 main[177516] *(p + 2) : 3.400000
2018-11-15 03:49:56.220 main[177516] *(p + 3) : 17.000000
2018-11-15 03:49:56.220 main[177516] *(p + 4) : 50.000000
2018-11-15 03:49:56.220 main[177516] Array values using balance as address
2018-11-15 03:49:56.220 main[177516] *(balance + 0) : 1000.000000
2018-11-15 03:49:56.220 main[177516] *(balance + 1) : 2.000000
2018-11-15 03:49:56.220 main[177516] *(balance + 2) : 3.400000
2018-11-15 03:49:56.220 main[177516] *(balance + 3) : 17.000000
2018-11-15 03:49:56.220 main[177516] *(balance + 4) : 50.000000
```

在上面的例子中，`p`是一个指向`double`的指针，它可以存储`double`类型变量的地址。当在`p`中有地址，那么`*p`将给出在`p`中存储的地址可用的值，正如在上面的例子中所示的那样。



# Objective-C日志处理

为了打印日志，可使用Objective-C编程语言中的`NSLog`方法，首先在`HelloWorld`示例中使用了这个方法。

下面来看一下打印“Hello World”字样的简单代码 -

```objectivec
#import <Foundation/Foundation.h>

int main() {
   NSLog(@"Hello, World! \n");
   return 0;
}


Objective-C
```

现在，当编译并运行程序时，将得到以下结果 - 

```shell
2018-11-15 09:53:09.761 main[22707] Hello, World!


Shell
```

## 在实时应用程序中禁用日志

由于在应用程序中经常使用`NSLog`，它将日志信息打印在设备的日志中，并且在实时构建中打印日志是不好的。 因此，使用类型定义来打印日志，如下所示。

```objectivec
#import <Foundation/Foundation.h>

#define DEBUG 1

#if DEBUG == 0
#define DebugLog(...)
#elif DEBUG == 1
#define DebugLog(...) NSLog(__VA_ARGS__)
#endif

int main() {
   DebugLog(@"Debug log, our custom addition gets \
   printed during debug only" );
   NSLog(@"NSLog gets printed always" );     
   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-15 09:50:28.903 main[11115] Debug log, our custom addition gets printed during debug only
2018-11-15 09:50:28.903 main[11115] NSLog gets printed always
```

现在，当在发布模式下编译并运行程序时，将得到以下结果 -

```shell
2018-11-15 09:50:28.903 main[11115] NSLog gets printed always
```





# Objective-C指针

# Objective-C 类和对象

Objective-C编程语言的主要目的是为C编程语言添加面向对象，类是Objective-C的核心特性，支持面向对象编程，通常称为用户定义类型。

类用于指定对象的形式，它将数据表示和方法组合在一起，以便将数据操作到一个整齐的包中。 类中的数据和方法称为类的成员。

##  Objective-C特征

- 类定义在两个不同的部分，即`@interface`和`@implementation`。
- 几乎所有东西都是对象的形式。
- 对象接收消息，对象通常称为接收者。
- 对象包含实例变量。
- 对象和实例变量具有范围。
- 类隐藏对象的实现。
- 属性用于提供用于其他类对此类实例变量的访问。

## Objective-C类定义

定义类时，可以为数据类型定义蓝图(或模板)。 但实际上并没有定义任何数据，但它确实定义了类名的含义，即类的对象将包含什么以及可以对这样的对象执行什么操作。

类定义以关键字`@interface`开头，后跟接口(类)名称; 和一个由一对花括号括起来的类体。 在Objective-C中，**所有类都派生自名为`NSObject`的基类**。 它是所有Objective-C类的超类。 它提供了内存分配和初始化等基本方法。 例如，使用关键字`class`定义`Box`类，如下所示 -

```objectivec
@interface Box:NSObject {
   //实例变量
   double length;    // Length of a box
   double breadth;   // Breadth of a box
}
@property(nonatomic, readwrite) double height;  // Property

@end
```

实例变量是私有的，只能在类实现中访问。

> **问题：** 
>
> 1. 属性是什么？实例变量私有，属性可在外部访问

## 分配和初始化Objective-C对象

类提供对象的蓝图，因此基本上是从类创建对象。声明一个类的对象与声明基本类型变量的声明完全相同。以下语句声明了`Box`类的两个对象 -

```objectivec
Box box1 = [[Box alloc] init];     // Create box1 object of type Box
Box box2 = [[Box alloc] init];     // Create box2 object of type Box
```

`box1`和`box2`这两个对象都有自己的数据成员副本。

## 访问数据成员

使用成员访问运算符(`.`)访问类对象的属性。尝试下面的例子来理解 -

```objectivec
#import <Foundation/Foundation.h>

@interface Box:NSObject {
   double length;    // Length of a box
   double breadth;   // Breadth of a box
   double height;    // Height of a box
}

@property(nonatomic, readwrite) double height;  // Property
// 声明一个方法
-(double) volume;
@end

@implementation Box

@synthesize height; 

-(id)init {
   self = [super init];
   length = 1.0;
   breadth = 1.0;
   return self;
}

-(double) volume {
   return length*breadth*height;
}

@end

int main() {
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];    
   Box *box1 = [[Box alloc] init];    // Create box1 object of type Box
   Box *box2 = [[Box alloc] init];    // Create box2 object of type Box

   double volume = 0.0;             // Store the volume of a box here

   // box 1 分配值
   box1.height = 15.0; 

   // box 2 分配值
   box2.height = 20.0;

   // volume of box 1
   volume = [box1 volume];
   NSLog(@"Volume of Box1 : %f", volume);

   // volume of box 2
   volume = [box2 volume];
   NSLog(@"Volume of Box2 : %f", volume);

   [pool drain];
   return 0;
}

```

执行上面示例代码，得到以下结果：

```shell
$main
2018-11-16 01:29:42.781 main[106799] Volume of Box1 : 15.000000
2018-11-16 01:29:42.782 main[106799] Volume of Box2 : 20.000000
```

## 属性

在Objective-C中引入了属性，以确保可以在类外部访问类的实例变量。

各部分属性声明如下 - 

- 属性以`@property`开头，它是一个关键字
- 接下来是访问说明符，它们是非原子，读写或只读，强，不安全或不完整。 这取决于变量的类型。 对于任何指针类型，可以使用`strong`，`unsafe_unretained`或`weak`。 类似地，对于其他类型，可以使用`readwrite`或`readonly`。
- 接下来是变量的数据类型。
- 最后，将属性名称以分号结束。
- 在实现类中添加`synthesize`语句。 但是在最新的`XCode`中，合成部分由`XCode`处理，不需要包含`synthesize`语句。

只有属性才能访问类的实例变量。 实际上，为属性创建了内部`getter`和`setter`方法。
例如，假设有一个属性`@property(nonatomic，readonly)BOOL isDone`。 创建了`setter`和`getter`，如下所示。

```shell
-(void)setIsDone(BOOL)isDone;
-(BOOL)isDone;
```

> **补充说明：**
>
> 1. **property 和 sythesize关键字**
>
> * `@property`是让编译器自动产生setter与getter的函数声明
>
> * `@sythesize`就是让编译器自动实现setter与getter函数
>
> ​    参考： [Objective-C中的@property、@synthesize及点语法_出头天-CSDN博客_objective-c](https://blog.csdn.net/jobtong/article/details/8454037)



# Objective-C继承

面向对象编程中最重要的概念之一是**继承**。继承允许根据一个类定义另一个类，这样可以更容易地创建和维护一个应用程序。 这也提供了重用代码功能和快速实现时间的机会。

在创建类时，程序员可以指定新类应该继承现有类的成员，而不是编写全新的数据成员和成员函数。 此现有类称为基类，新类称为派生类。

继承的想法实现了这种关系。 例如，哺乳动物是一个种类的动物，狗是一种哺乳动物，因此狗是一个动物等等。

## 1. 基础和派生类

Objective-C只允许多级继承，即它只能有一个基类但允许多级继承。 Objective-C中的所有类都派生自超类`NSObject`。

语法如下 - 

```objectivec
@interface derived-class: base-class
```

考虑一个基类`Person`及其派生类`Employee`的继承关系实现如下 -

```objectivec
#import <Foundation/Foundation.h>

@interface Person : NSObject {
   NSString *personName;
   NSInteger personAge;
}

- (id)initWithName:(NSString *)name andAge:(NSInteger)age;
- (void)print;

@end

@implementation Person

- (id)initWithName:(NSString *)name andAge:(NSInteger)age {
   personName = name;
   personAge = age;
   return self;
}

- (void)print {
   NSLog(@"Name: %@", personName);
   NSLog(@"Age: %ld", personAge);
}

@end

@interface Employee : Person {
   NSString *employeeEducation;
}

- (id)initWithName:(NSString *)name andAge:(NSInteger)age 
  andEducation:(NSString *)education;
- (void)print;
@end

@implementation Employee

- (id)initWithName:(NSString *)name andAge:(NSInteger)age 
   andEducation: (NSString *)education {
      personName = name;
      personAge = age;
      employeeEducation = education;
      return self;
   }

- (void)print {
   NSLog(@"姓名: %@", personName);
   NSLog(@"年龄: %ld", personAge);
   NSLog(@"文化: %@", employeeEducation);
}

@end

int main(int argc, const char * argv[]) {
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];        
   NSLog(@"基类Person对象");
   Person *person = [[Person alloc]initWithName:@"Maxsu" andAge:25];
   [person print];
   NSLog(@"继承类Employee对象");
   Employee *employee = [[Employee alloc]initWithName:@"Yii bai" 
   andAge:26 andEducation:@"MBA"];
   [employee print];        
   [pool drain];
   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-16 01:51:21.279 main[138079] 基类Person对象
2018-11-16 01:51:21.280 main[138079] Name: Maxsu
2018-11-16 01:51:21.281 main[138079] Age: 25
2018-11-16 01:51:21.281 main[138079] 继承类Employee对象
2018-11-16 01:51:21.281 main[138079] 姓名: Yii bai
2018-11-16 01:51:21.281 main[138079] 年龄: 26
2018-11-16 01:51:21.281 main[138079] 文化: MBA
```

## 访问控制和继承

如果派生类在接口类中定义，则它可以访问其基类的所有私有成员，但它不能访问在实现文件中定义的私有成员。

可以通过以下方式访问它们来执行不同的访问类型。派生类继承所有基类方法和变量，但以下情况除外 -

- 无法访问在扩展帮助下在实现文件中声明的变量。
- 无法访问在扩展帮助下在实现文件中声明的方法。
- 如果继承的类在基类中实现该方法，则执行继承类中的方法。



# Objective-C多态性

多态性这个词表示有许多形式。 通常，当存在类的层次结构并且通过继承相关时，会发生多态性。

Objective-C多态表示对成员函数的调用将导致执行不同的函数，具体取决于调用该函数的对象的类型。

考虑下面一个例子，有一个基类`Shape`类，它为所有形状提供基本接口。 `Square`和`Rectangle`类派生自基`Shape`类。

下面使用`printArea`方法来展示OOP特征多态性。

```objectivec
#import <Foundation/Foundation.h>

@interface Shape : NSObject {
   CGFloat area;
}

- (void)printArea;
- (void)calculateArea;
@end

@implementation Shape
- (void)printArea {
   NSLog(@"The area is %f", area);
}

- (void)calculateArea {

}

@end

@interface Square : Shape {
   CGFloat length;
}

- (id)initWithSide:(CGFloat)side;
- (void)calculateArea;

@end

@implementation Square
- (id)initWithSide:(CGFloat)side {
   length = side;
   return self;
}

- (void)calculateArea {
   area = length * length;
}

- (void)printArea {
   NSLog(@"The area of square is %f", area);
}

@end

@interface Rectangle : Shape {
   CGFloat length;
   CGFloat breadth;
}

- (id)initWithLength:(CGFloat)rLength andBreadth:(CGFloat)rBreadth;
@end

@implementation Rectangle
- (id)initWithLength:(CGFloat)rLength andBreadth:(CGFloat)rBreadth {
   length = rLength;
   breadth = rBreadth;
   return self;
}

- (void)calculateArea {
   area = length * breadth;
}

@end

int main(int argc, const char * argv[]) {
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   Shape *square = [[Square alloc]initWithSide:10.0];
   [square calculateArea];
   [square printArea];
   Shape *rect = [[Rectangle alloc]
   initWithLength:10.0 andBreadth:5.0];
   [rect calculateArea];
   [rect printArea];        
   [pool drain];
   return 0;
}
```

执行上面示例代码，得到以下结果 - 

```shell
2018-11-16 02:02:22.096 main[159689] The area of square is 100.000000
2018-11-16 02:02:22.098 main[159689] The area is 50.000000
```

在上面的示例中，`calculateArea`和`printArea`方法的可用性，无论是基类中的方法还是执行派生类。

多态性基于两个类的方法实现来处理基类和派生类之间的方法切换。



# Objective-C数据封装

所有Objective-C程序都由以下两个基本要素组成 -

- **程序语句(代码)** - 这是执行操作的程序的一部分，它们被称为方法(函数)。
- **程序数据** - 数据是受程序功能影响的程序信息。

封装是一种面向对象的编程概念，它将操作数据的数据和功能绑定在一起，并保护其免受外部干扰和误用。 数据封装导致了重要的OOP数据隐藏概念。

数据封装是捆绑数据和使用函数的机制，数据抽象是一种仅暴露接口并从用户隐藏实现细节的机制。

Objective-C通过创建用户定义类型(称为类)来支持封装和数据隐藏的属性。 例如 -

```objectivec
@interface Adder : NSObject {
   NSInteger total;
}

- (id)initWithInitialNumber:(NSInteger)initialNumber;
- (void)addNumber:(NSInteger)newNumber;
- (NSInteger)getTotal;

@end


Objective-C
```

变量`total`是私有的，因此无法从类外部访问。只能由`Adder`类的其他成员访问它们，而不能由程序的任何其他部分访问。这是实现封装的一种方式。

接口文件中的方法是可访问的，并且在范围内是公共的。

有一些私有方法，这些方法是在扩展的帮助下编写的，我们将在后面的章节中学习。

## 数据封装示例

任何使用公共和私有成员变量实现类的Objective-C程序都是数据封装和数据抽象的一个例子。 考虑以下示例 -

```objectivec
#import <Foundation/Foundation.h>

@interface Adder : NSObject {
   NSInteger total;
}

- (id)initWithInitialNumber:(NSInteger)initialNumber;
- (void)addNumber:(NSInteger)newNumber;
- (NSInteger)getTotal;

@end

@implementation Adder
-(id)initWithInitialNumber:(NSInteger)initialNumber {
   total = initialNumber;
   return self;
}

- (void)addNumber:(NSInteger)newNumber {
   total = total + newNumber;
}

- (NSInteger)getTotal {
   return total;
}

@end

int main(int argc, const char * argv[]) {
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];        
   Adder *adder = [[Adder alloc]initWithInitialNumber:10];
   [adder addNumber:15];
   [adder addNumber:14];

   NSLog(@"The total is %ld",[adder getTotal]);
   [pool drain];
   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-16 02:19:46.326 main[52227] The total is 39
```

上面的类将数字值相加并返回总和。 公共成员`addNum`和`getTotal`是外部接口，用户需要知道它们才能使用该类。 私有成员`total`是对外界隐藏的东西，但是此类需要正常运作。

## 设计策略

除非真的需要公开它们，否则大多数人都会通过经验来学习默认情况下将类成员设为私有。 这只是很好的封装。

了解数据封装非常重要，因为它是所有面向对象编程(OOP)语言(包括Objective-C)的核心功能之一。



# Objective-C类别

​					 				 				 				 			

有时，可能会发现希望通过添加仅在某些情况下有用的行为来**扩展现有类**。 **要向现有类添加此类扩展，Objective-C提供了类别和扩展**。

如果需要向现有类添加方法，或许为了添加功能以便在应用程序中更容易地执行某些操作，最简单的方法是使用类别。

声明类别的语法使用`@interface`关键字，就像标准的Objective-C类描述一样，但不表示子类的任何继承。在括号中指定类别的名称，如下所示 -

```objectivec
@interface ClassName (CategoryName)

@end
```

## 类别的特征

即使没有原始实现源代码，也可以为任何类声明类别。**在类别中声明的任何方法都可用于原始类的所有实例，以及原始类的任何子类**。
**在运行时，类别添加的方法与原始类实现的方法之间没有区别**。

现在，来看一个类别实现的示例。在Cocoa类`NSString`中添加一个类别。此类别将使可以添加一个新方法`getCopyRightString`，它返回版权字符串。 如下所示 -

```objectivec
#import <Foundation/Foundation.h>

@interface NSString(MyAdditions)
+(NSString *)getCopyRightString;
@end

@implementation NSString(MyAdditions)

+(NSString *)getCopyRightString {
   return @"Copyright y ii bai.com 2019";
}

@end

int main(int argc, const char * argv[]) {
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   NSString *copyrightString = [NSString getCopyRightString];
   NSLog(@"Accessing Category: %@",copyrightString);

   [pool drain];
   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-16 02:45:34.949 main[131207] Accessing Category: Copyright y ii bai.com 2019
```

即使类别添加的任何方法都可用于类及其子类的所有实例，仍需要在任何源代码文件中导入类别头文件，否则将遇到编译器警告和错误。

在上面示例中，由于只有一个类，因此没有包含任何头文件，在这种情况下应该包含如上所述的头文件。



# Objective-C Posing(冒充)

Posing，顾名思义，意思是“冒充”，它跟`categories`类似，**但本质上不一样，Posing存在的目的在于子类可以冒充父类，使得后续的代码无需把父类修改为子类，就可以很方便的让父类表现成子类的行为，从而实现非常方便的冒充，这在一般的语言中是难以想象的**。

在开始在Objective-C中进行构建之前，提醒读者注意，**在Mac OS X 10.5中声明已经弃用了冒充(*Posing*)，并且之后无法使用它。** 因此对于那些不关心这些弃用方法的人可以跳过本章。

Objective-C允许类完全替换程序中的另一个类。替换类被称为“冒充”目标类。 对于支持冒充的版本，发送到目标类的所有消息都由冒充类接收。

`NSObject`包含`poseAsClass` - 使我们能够替换现有类的方法，如上所述。

它允许扩展一个类，并且全面的冒充这个超类，比如：有一个扩展`NSArray`的`NSArrayChild`对象，如果让`NSArrayChild`冒充`NSArray`，则程序代码所在的`NSArray`都会自动替换为`NSArrayChild`。
注意，这里不是指代码替换，而是`NSArray`所在地方的行为都跟`NSArrayChild`一样了。

#### 冒充限制

- 一个类只能构成其直接或间接超类之一。
- 冒充类不得定义目标类中不存在的任何新实例变量(尽管它可以定义或覆盖方法)。
- 目标类在冒充之前可能没有收到任何消息。
- 冒充类可以通过`super`调用重写的方法，从而结合目标类的实现。
- 冒充类可以覆盖类别中定义的方法。

示例代码：

```objectivec
#import <Foundation/Foundation.h>

@interface MyString : NSString

@end

@implementation MyString

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target
withString:(NSString *)replacement {
   NSLog(@"The Target string is %@",target);
   NSLog(@"The Replacement string is %@",replacement);
}

@end

int main() {
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   [MyString poseAsClass:[NSString class]];
   NSString *string = @"Test";
   [string stringByReplacingOccurrencesOfString:@"a" withString:@"c"];

   [pool drain];
   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2018-11-22 21:23:44.729 Posing[372:306] The Target string is a
2018-11-22 21:23:44.730 Posing[372:306] The Replacement string is c
```

在上面的例子中，只是用实现污染了原始方法，并且这将通过上述方法在所有`NSString`操作中受到影响。





# Objective-C扩展

**类扩展与类别有一些相似之处，但它只能添加到编译时具有源代码的类中(类与类扩展同时编译)**。

类扩展声明的方法是在原始类的实现块中实现的，因此不能在框架类上声明类扩展，例如`Cocoa`或`Cocoa Touch`类，如`NSString`。

扩展名实际上是没有类别名称的类别，它通常被称为匿名类别。

声明扩展的语法使用`@interface`关键字，就像标准的Objective-C类描述一样，但不表示子类的任何继承。 它只是添加括号，如下所示 -

```objectivec
@interface ClassName ()

@end
```

#### 扩展的特征

- 不能为任何类声明扩展，仅适用于原始实现源代码的类。
- 扩展是添加仅特定于类的私有方法和私有变量。
- 扩展内部声明的任何方法或变量即使对于继承的类也是不可访问的。

#### 扩展示例

创建一个具有扩展名的`SampleClass`类。 在扩展中，有一个私有变量`internalID`。
然后，有一个方法`getExternalID`，它在处理`internalID`后返回`externalID`。

示例代码如下所示 - 

```objectivec
#import <Foundation/Foundation.h>

@interface SampleClass : NSObject {
   NSString *name;
}

- (void)setInternalID;
- (NSString *)getExternalID;

@end

@interface SampleClass() {
   NSString *internalID;
}

@end

@implementation SampleClass

- (void)setInternalID {
   internalID = [NSString stringWithFormat: 
   @"UNIQUEINTERNALKEY%dUNIQUEINTERNALKEY",arc4random()%100];
}

- (NSString *)getExternalID {
   return [internalID stringByReplacingOccurrencesOfString: 
   @"UNIQUEINTERNALKEY" withString:@""];
}

@end

int main(int argc, const char * argv[]) {
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   SampleClass *sampleClass = [[SampleClass alloc]init];
   [sampleClass setInternalID];
   NSLog(@"ExternalID: %@",[sampleClass getExternalID]);        
   [pool drain];
   return 0;
}
```

执行上面示例代码，得到以下结果：

```shell
2019-11-22 12:18:32.124 Extensions[121:313] ExternalID: 51
```

在上面的示例中，可以看到不直接返回`internalID`。在这里删除了`UNIQUEINTERNALKEY`，并且只为方法`getExternalID`提供了剩余的值。
上面的示例只使用字符串操作，但它可以具有许多功能，如加密/解密等。



# Objective-C协议

​					 				 				 				 			

**Objective-C允许定义协议，声明预期用于特定情况的方法。 协议在符合协议的类中实现。**

一个简单的例子是网络`URL`处理类，它将具有一个协议，其中包含`processCompleted`委托方法等方法，当网络URL提取操作结束，就会调用类。

协议的语法如下所示 - 

```objectivec
@protocol ProtocolName
@required
// list of required methods
@optional
// list of optional methods
@end
```

关键字`@required`下的方法必须在符合协议的类中实现，并且`@optional`关键字下的方法是可选的。

以下是符合协议的类的语法 - 

```objectivec
@interface MyClass : NSObject <MyProtocol>
...
@end
```

`MyClass`的任何实例不仅会响应接口中特定声明的方法，而且`MyClass`还会为`MyProtocol`中的所需方法提供实现。 没有必要在类接口中重新声明协议方法 - 采用协议就足够了。

如果需要一个类来采用多个协议，则可以将它们指定为以逗号分隔的列表。下面有一个委托对象，它包含实现协议的调用对象的引用。

一个例子如下所示 - 

```objectivec
#import <Foundation/Foundation.h>

@protocol PrintProtocolDelegate
- (void)processCompleted;

@end

@interface PrintClass :NSObject {
   id delegate;
}

- (void) printDetails;
- (void) setDelegate:(id)newDelegate;
@end

@implementation PrintClass
- (void)printDetails {
   NSLog(@"Printing Details");
   [delegate processCompleted];
}

- (void) setDelegate:(id)newDelegate {
   delegate = newDelegate;
}

@end

@interface SampleClass:NSObject<PrintProtocolDelegate>
- (void)startAction;

@end

@implementation SampleClass
- (void)startAction {
   PrintClass *printClass = [[PrintClass alloc]init];
   [printClass setDelegate:self];
   [printClass printDetails];
}

-(void)processCompleted {
   NSLog(@"Printing Process Completed");
}

@end

int main(int argc, const char * argv[]) {
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   SampleClass *sampleClass = [[SampleClass alloc]init];
   [sampleClass startAction];
   [pool drain];
   return 0;
}
```

执行上面示例代码，得到以下结果 - 

```shell
2018-11-16 03:10:19.639 main[18897] Printing Details
2018-11-16 03:10:19.641 main[18897] Printing Process Completed
```

在上面的例子中，已经看到了如何调用和执行委托方法。 它以`startAction`开始，当进程完成，就会调用委托方法`processCompleted`以使操作完成。

在任何iOS或Mac应用程序中，如果没有代理，将永远不会实现程序。 因此，要是了解委托的用法。 委托对象应使用`unsafe_unretained`属性类型以避免内存泄漏。



# Objective-C动态绑定

**动态绑定确定在运行时而不是在编译时调用的方法。 动态绑定也称为后期绑定。 在Objective-C中，所有方法都在运行时动态解析。执行的确切代码由方法名称(选择器)和接收对象确定。**

动态绑定可实现多态性。例如，考虑一组对象，包括`Rectangle`和`Square`。 每个对象都有自己的`printArea`方法实现。

在下面的代码片段中，表达式`[anObject printArea]`执行的实际代码是在运行时确定的。 运行时系统使用方法运行的选择器来识别`anObject`的任何类中的适当方法。

下面来看一下解释动态绑定的简单代码 -

```objectivec
#import <Foundation/Foundation.h>

@interface Square:NSObject {
   float area;
}

- (void)calculateAreaOfSide:(CGFloat)side;
- (void)printArea;
@end

@implementation Square
- (void)calculateAreaOfSide:(CGFloat)side {
   area = side * side;
}

- (void)printArea {
   NSLog(@"The area of square is %f",area);
}

@end

@interface Rectangle:NSObject {
   float area;
}

- (void)calculateAreaOfLength:(CGFloat)length andBreadth:(CGFloat)breadth;
- (void)printArea;
@end

@implementation  Rectangle

- (void)calculateAreaOfLength:(CGFloat)length andBreadth:(CGFloat)breadth {
   area = length * breadth;
}

- (void)printArea {
   NSLog(@"The area of Rectangle is %f",area);
}

@end

int main() {
   Square *square = [[Square alloc]init];
   [square calculateAreaOfSide:8.0];

   Rectangle *rectangle = [[Rectangle alloc]init];
   [rectangle calculateAreaOfLength:10.0 andBreadth:20.0];

   NSArray *shapes = [[NSArray alloc]initWithObjects: square, rectangle,nil];
   id object1 = [shapes objectAtIndex:0];
   [object1 printArea];

   id object2 = [shapes objectAtIndex:1];
   [object2 printArea];

   return 0;
}
```

执行上面示例代码，得到以下结果 - 

```shell
2018-11-16 03:16:53.399 main[53860] The area of square is 64.000000
2018-11-16 03:16:53.401 main[53860] The area of Rectangle is 200.000000
```

正如在上面的示例中所看到的，`printArea`方法是在运行时动态选择调用的。 它是动态绑定的一个示例，在处理类似对象时在很多情况下非常有用。



# Objective-C复合对象

在Objective-C中，可以在类集群中创建子类，该类集合定义了一个嵌入在其中的类。 这些类对象是复合对象。你可能想知道什么是类集群，下面首先了解什么是类集群。

## 1. 类集群

类集群是基础框架广泛使用的设计模式。 类集群在公共抽象超类下组合了许多私有具体子类。 以这种方式对类进行分组简化了面向对象框架的公开可见体系结构，而不会降低其功能丰富性。 类集群基于抽象工厂设计模式。

为了简单起见，创建了一个基于输入值处理它的单个类，而不是为类似的函数创建多个类。

例如，在`NSNumber`中有许多类的集群，如`char`，`int`，`bool`等。将它们全部组合到一个类中，该类负责处理单个类中的类似操作。 `NSNumber`实际上将这些原始类型的值包装到对象中。

## 2. 什么是复合对象？

通过在设计的对象中嵌入私有集群对象，创建一个复合对象。 此复合对象可以依赖于集群对象的基本功能，仅拦截复合对象希望以某种特定方式处理的消息。 此体系结构减少了必须编写的代码量，并允许利用Foundation Framework提供的测试代码。

如下图中解释 -
![img](https://www.yiibai.com/uploads/article/2018/11/16/112827_22762.png)

复合对象必须声明自己是集群的抽象超类的子类。 作为子类，它必须覆盖超类的原始方法。 它也可以覆盖派生方法，但这不是必需的，因为派生方法通过原始方法工作。

`NSArray`类的`count`方法就是一个例子; 介入对象的覆盖方法的实现可以实现简单如下 -

```objectivec
- (unsigned)count  {
   return [embeddedObject count];
}


Objective-C
```

在上面的例子中，嵌入对象实际上是`NSArray`类型。

## 复合对象示例

现在，为了看到一个完整的示例，请看下面给出的Apple文档中的示例。

```objectivec
#import <Foundation/Foundation.h>

@interface ValidatingArray : NSMutableArray {
   NSMutableArray *embeddedArray;
}

+ validatingArray;
- init;
- (unsigned)count;
- objectAtIndex:(unsigned)index;
- (void)addObject:object;
- (void)replaceObjectAtIndex:(unsigned)index withObject:object;
- (void)removeLastObject;
- (void)insertObject:object atIndex:(unsigned)index;
- (void)removeObjectAtIndex:(unsigned)index;

@end

@implementation ValidatingArray
- init {
   self = [super init];
   if (self) {
      embeddedArray = [[NSMutableArray allocWithZone:[self zone]] init];
   }
   return self;
}

+ validatingArray {
   return [[self alloc] init] ;
}

- (unsigned)count {
   return [embeddedArray count];
}

- objectAtIndex:(unsigned)index {
   return [embeddedArray objectAtIndex:index];
}

- (void)addObject:(id)object {
   if (object != nil) {
      [embeddedArray addObject:object];
   }
}

- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)object; {
   if (index <[embeddedArray count] && object != nil) {
      [embeddedArray replaceObjectAtIndex:index withObject:object];
   }
}

- (void)removeLastObject; {
   if ([embeddedArray count] > 0) {
      [embeddedArray removeLastObject];
   }
}

- (void)insertObject:(id)object atIndex:(unsigned)index; {
   if (object != nil) {
      [embeddedArray insertObject:object atIndex:index];
   }
}

- (void)removeObjectAtIndex:(unsigned)index; {
   if (index <[embeddedArray count]) {
      [embeddedArray removeObjectAtIndex:index];
   }
}

@end

int main() {
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   ValidatingArray *validatingArray = [ValidatingArray validatingArray];

   [validatingArray addObject:@"Object1"];
   [validatingArray addObject:@"Object2"];
   [validatingArray addObject:[NSNull null]];
   [validatingArray removeObjectAtIndex:2];
   NSString *aString = [validatingArray objectAtIndex:1];
   NSLog(@"The value at Index 1 is %@",aString);
   [pool drain];

   return 0;
}


Objective-C
```

执行上面示例代码，得到以下结果：

```shell
2018-11-28 22:03:54.124 main[3247] The value at Index 1 is Object2


Shell
```

在上面的例子中，可以看到验证数组的一个函数不允许添加会导致正常情况下崩溃的空对象。 但验证数组负责处理它。 类似地，验证数组中的每个方法都添加了除正常操作序列之外的验证过程。

//原文出自【易百教程】，商业转载请联系作者获得授权，非商业转载请保留原文链接：https://www.yiibai.com/objective_c/objective_c_composite_objects.html#article-start 



# Objective_C基础框架

如果您参考Apple文档，应该会看到`Foundation`框架的详细信息，如下所示。

`Foundation`框架定义了Objective-C类的基础层。 除了提供一组有用的原始对象类之外，它还引入了几个定义Objective-C语言未涵盖的功能的范例。 `Foundation`框架的设计考虑了这些目标 -

- 提供一小组基本实用程序类。
- 通过为解除分配等事项引入一致的约定，使软件开发更容易。
- 支持Unicode字符串，对象持久性和对象分发。
- 提供一定程度的操作系统独立性以增强可移植性。

该框架由*NeXTStep* 开发，后者被Apple收购，这些基础类成为Mac OS X和iOS的一部分。 由NeXTStep开发，它的类前缀为“NS”。

在所有示例程序中都使用了`Foundation`框架，在使用Objective-C语言开发应用程序时，使用`Foundation`框架几乎是必须的。

通常，我们使用`#import <Foundation/NSString.h>`之类的东西来导入Objective-C类，但是为了避免手写导入的类太多，使用`#import <Foundation/Foundation.h>`导入即可。

`NSObject`是所有对象的基类，包括基础工具包类。 它提供了内存管理的方法。 它还提供了运行时系统的基本接口以及表现为Objective-C对象的能力。它没有任何基类，是所有类的根。

## 基础类的功能

| 编号 | 功能                                                         | 描述                                                         |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | [数据存储](https://www.yiibai.com/objective_c/objective_c_data_storage.html) | `NSArray`，`NSDictionary`和`NSSet`为Objective-C任何类的对象提供存储。 |
| 2    | [文本和字符串](https://www.yiibai.com/objective_c/objective_c_texts_and_strings.html) | `NSCharacterSet`表示`NSString`和`NSScanner`类使用的各种字符分组。`NSString`类表示文本字符串，并提供搜索，组合和比较字符串的方法。 `NSScanner`对象用于扫描`NSString`对象中的数字和单词。 |
| 3    | [日期和时间](https://www.yiibai.com/objective_c/objective_c_dates_and_times.html) | `NSDate`，`NSTimeZone`和`NSCalendar`类存储时间和日期并表示日历信息。它们提供了计算日期和时间差异的方法。它们与`NSLocale`一起提供了以多种格式显示日期和时间以及根据世界中的位置调整时间和日期的方法。 |
| 4    | [异常处理](https://www.yiibai.com/objective_c/objective_c_exception_handling.html) | 异常处理用于处理意外情况，它在Objective-C中提供`NSException`类对象。 |
| 5    | [文件处理](https://www.yiibai.com/objective_c/objective_c_file_handling.html) | 文件处理是在`NSFileManager`类的帮助下完成的。                |
| 6    | [URL加载系统](https://www.yiibai.com/objective_c/objective_c_url_loading_system.html) | 一组提供对常见Internet协议访问的类和协议。                   |







# 枚举类型

## 总结

1. 本质是无符号整数；
2. 定义：`enum 枚举类型名称 { 值声明 }`
3. 使用： `enum `

## 内容

> 作者：14cat
> 链接：https://www.jianshu.com/p/5aa02051ff10
> 来源：简书
> 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

- 枚举的作用在于规范并语义化的定义代码中的状态、选项等常量。
- 如果一个变量只有几种可能的值，比如星期几的变量，只有星期一、星期二、星期三、星期四、星期五、星期六、星期天这7个值，就可以使用枚举类型（春夏秋冬、上下左右、东西南北等）
- 枚举类型的定义以关键字enum开头，之后是枚举数据类型的名称，最后是在一对花括号内的选项标识符序列。 （实现枚举所用的数据类型取决于编译器。除了使用默认类型，还可以指明用何种“底层数据类型”来保存枚举类型的变量）

```objective-c
enum Direction {up, down, left, right};
enum Direction : UNSInteger {up, down, left, right};
```

- 编译器会为枚举分配一个独有的编号，从0开始，每个枚举递增1。（可以手动指定某个枚举成员所对应的值，接下来的枚举值会在上一个的基础上递增1）
- 枚举变量的**本质就是无符号整数**（%u占位符）

```objective-c
// up=1,down=2,left=3,right=4
enum Direction {up = 1, down, left, right};

// 定义匿名枚举类型，并定义两个枚举变量
enum {male, female} me, you;
```

- 使用关键字`typedef`重新定义枚举，目的是为了简化枚举的声明，不需要每次都写enum

```objective-c
// 使用关键字typedef定义枚举类型
enum Direction {up, down, left, right} ;
typedef enum Direction Direction;

// 使用Direction代替完整的enum Direction
Direction var1, var2;
```

基础使用方法：

```objective-c
typedef enum _State {
  StateOK = 0,
  StateError,
  StateUnknow
} State;

// 指明枚举类型
State status = StateOK;

- (void)dealWithState:(State)state {
  switch(state) {
    case StateOK:
        break;
    case StateError:
        break;
    case StateUnknow:
        break;
  } 
}
```

- 枚举的另一种使用方式是定义为按位掩码，当定义选项的时候，若这些选项可以彼此组合，则在设置特定的枚举值后，各选项间就可通过“按位或”来组合。因为每个枚举值所对应的二进制表示中，只有1个二进制位的值是1，所以多个选项“按位或”后的组合值是唯一的，且将某一选项与组合值做“按位与”操作，即可判断出组合值中是否包含该选项。

```objective-c
enum Direction {
   up = 1 << 0, 
   down = 1 << 1, 
   left = 1 << 2, 
   right = 1 << 3
};
```

选项使用方法

```objectivec
//方向，可同时支持一个或多个方向
typedef enum _Direction {
    DirectionNone = 0,
    DirectionTop = 1 << 0        // 0001
    DirectionLeft = 1 << 1,      // 0010
    DirectionRight = 1 << 2,     // 0100
    DirectionBottom = 1 << 3     // 1000
} Direction;

//用“或”运算同时赋值多个选项
Direction direction = DirectionTop | DirectionLeft | DirectionBottom;  // 1011
//用“与”运算取出对应位
if (direction & DirectionTop) {  // 1011 & 0001
    NSLog(@"top");
}
if (direction & DirectionLeft) {  // 1011 & 0010 
    NSLog(@"left");
}
if (direction & DirectionRight) {  // 1011 & 0100
    NSLog(@"right");
}
if (direction & DirectionBottom) {  // 1011 & 1000
    NSLog(@"bottom");
}
/*
打印的结果
2017-10-30 16:39:35.584816+0800 OBJC_TEST[5215:236112] top
2017-10-30 16:39:35.584825+0800 OBJC_TEST[5215:236112] left
2017-10-30 16:39:35.584831+0800 OBJC_TEST[5215:236112] bottom
*/
```

## enum在Objective-C中的“升级版”

- 从C++ 11开始，我们可以为枚举指定其实际的存储类型

```objectivec
enum State : NSInteger {/*...*/};
```

- 保证枚举类型的兼容性，推荐使用`NS_ENUM`和`NS_OPTIONS`

```objectivec
// NS_ENUM，定义状态等普通枚举类型
typedef NS_ENUM(NSUInteger, State) {
    StateOK = 0,
    StateError,
    StateUnknow
};
// NS_OPTIONS，定义可组合选项的枚举类型
typedef NS_OPTIONS(NSUInteger, Direction) {
    DirectionNone = 0,
    DirectionTop = 1 << 0,
    DirectionLeft = 1 << 1,
    DirectionRight = 1 << 2,
    DirectionBottom = 1 << 3
};
```



## 枚举转型



# NSDictionary

`NSDictionary` 和 `NSMutableDictionary`

## 是什么？

字典：(关键字+值) 的集合



## 基础用法

### dictionary

```objective-c 
+ (instancetype)dictionary;
```

主要用于mutable的子类的实例创建；

### 创建

1. 使用字面量语法；
2. `initWithObjectsAndKeys`: 



## 常见问题

### [<__NSDictionary0 0x604000013580> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key testKey.

原因是因为 给 NSDictionary 声明的类型添加新的key-value对。

即使是指向的实际类型为NSMutableDictionary的子类实例也会报这个错误；



# NSString

