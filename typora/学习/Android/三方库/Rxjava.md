# Rxjava

## **Observable 类别** 

可用的 Observable 有如下几种：

1. `Single`
2. `Completable`
3. `Maybe`
4. `Flowable/ConnecteableFlowable`
5. `Observable/ConnecteableObservable`

如下，一般的方法都有如下几种变体，用于支持不同的 Observable ：

<img src="/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20220328205859596.png" alt="image-20220328205859596" style="zoom:50%;" />

### Single

- 协议： `onSubscribe (onSuccess | onError)?`
- Single 只能发出**单个值** **成功**｜**异常**
- cold： `Single`
- hot： `SingleSubject`

### Completable

* 协议： `onSubscribe (onError | onComplete)?`
* 延迟的计算行为，并且发出**单个值**，只能发出 **完成** ｜ **异常**
* cold： `Completable`
* hot：`CompletableSubject`
* 由于不关心计算结果，所以只能从Runnable，Action等创建。



### Maybe

* 协议： `onSubscribe (onSuccess | onError | onComplete)?`
* 延迟的计算行为，发出 **单个值**｜异常 ｜ 没有值



### Flowable

- 协议：  `onSubscribe onNext* (onError | onComplete)?`

- 实现响应式流和发布订阅模式

- 提供工厂方法，中间运算符还有消费响应式数据流的能力。

- Flowables 支持背压并要求订阅者通过 `Subscription.request(long) `发出需求信号。

  

### Observable

- 协议： `onSubscribe onNext* (onError | onComplete)?`
- observable 类是非背压的、可选的多值反应基类，它提供工厂方法、中间运算符以及使用同步和/或异步反应数据流的能力。



### 总结

* `Flowable `和 `Obserable` 的区别在于一个支持 *backpressure* 操作符，一个不支持。
  * 背压操作符指： strategies for coping with Observables that produce items more rapidly than their observers consume them
  * 就是生产快过消费时的应对策略。
* `Obserable` 和 `Single/Completable/Maybe `的区别在于
  * **后几者只支持发送单个值，并不能形成流。**
  * 后几者都不支持`onNext`，只支持其它几种订阅事件中的若干中。
    * `onSuccess(T)`： 有 value
    * `onComplete`: 无 value
    * `onError` ： 异常



> * [ReactiveX - backpressure](https://reactivex.io/documentation/operators/backpressure.html)
> * [Android Rxjava ：最简单&全面背压讲解 (Flowable) - 简书 (jianshu.com)](https://www.jianshu.com/p/d814e04673ea)

##  Observable 详解

- `onNext`:
  - Observable 发出 项目时调用
- `onError`
  - Observable 无法生成期望的数据/发生了错误
  - 后续不会再调用 `onNext` 或 `onCompleted`
- `onCompleted`：
  - 最后一次调用 `onNext` 之后调用，并且没有产生任何错误
- 发射： `onNext`
- 通知： `onError` ｜ `onCompleted`

## 操作符

