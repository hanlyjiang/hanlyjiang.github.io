# Kotlin 关键字 by

参考： 

* https://stackoverflow.com/questions/38250022/what-does-by-keyword-do-in-kotlin



In simple words, you can understand `by` keyword as **provided by\**.

From the perspective of property consumer, `val` is something that has getter (get) and `var` is something that has getter and setter (get, set). For each `var` property there is a default provider of get and set methods that we don't need to specify explicitly.

But, when using `by` keyword, you are stating that this getter/getter&setter is provided elsewhere (i.e. it's been delegated). It's *provided **by*** the function that comes after `by`.

So, instead of using this built-in get and set methods, you are delegating that job to some explicit function.

One very common example is the `by lazy` for lazy loading properties. Also, if you are using dependency injection library like Koin, you'll see many properties defined like this:

```kotlin
var myRepository: MyRepository by inject()  //inject is a function from Koin
```

In the class definition, it follows the same principle, it defines where some function is provided, but it can refer to any set of methods/properties, not just get and set.

```kotlin
class MyClass: SomeInterface by SomeImplementation, SomeOtherInterface
```

This code is saying: 'I am class MyClass and I offer functions of interface SomeInterface which are provided by SomeImplementation. I'll implement SomeOtherInterface by myself (that's implicit, so no `by` there).'

