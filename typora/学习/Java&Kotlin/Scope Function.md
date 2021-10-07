# Scope Function

参考： https://kotlinlang.org/docs/scope-functions.html



## 简介

Kotlin标准库函数，唯一目的就是在一个对象的上下文中执行一段代码。当在对象上调用这种方法并传递一个 lambda 表达式时，会形成一个临时领域。访问对象的名字时可以省略名称。这种函数称之为 Scope 函数。

有五种Scope函数：

* let
* run
* with
* apply
* also

**相同点：** 在对象在执行一个代码块

**区别：** 代码块中对象如何访问，整个表达式的返回值



## 如何选择函数

> 区别： 
>
> 1. 返回值
> 2. 对象引用方式

| Function | 对象引用 | 返回值         | 是否扩展函数                 |
| -------- | -------- | -------------- | ---------------------------- |
| `let`    | `it`     | Lambda result  | Yes                          |
| `run`    | `this`   | Lambda result  | Yes                          |
| `run`    | -        | Lambda result  | No: 调用时无需使用上下文对象 |
| `with`   | `this`   | Lambda result  | No: 上下文对象作为参数       |
| `apply`  | `this`   | Context object | Yes                          |
| `also`   | `it`     | Context object | Yes                          |

选择策略：

- 在非空对象上执行一个lambda表达式: `let`
- 局部范围中将表达式作为一个变量: `let`
- 配置对象: `apply`
- 配置对象并计算结果： `run`
- 运行需要表达式的语句: non-extension `run`
- 附加效果: `also`
- 组织对象上的函数调用t: `with`