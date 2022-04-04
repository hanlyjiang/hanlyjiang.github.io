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

## 线程切换

### 概览

线程切换的操作符解析。

有如下几种类型的线程切换方式。

1. 单独的线程切换操作符，有如下三种：

   ```
   observeOn()
   subscribeOn()
   unsubscribeOn()
   ```

2. 部分其他操作符自带的 Scheduler 参数的重载函数，有如下：（仅统计Observable）

   - interval
   - timer
   - buffer
   - concatMap/concatMapDelayError
   - debounce
   - delay
   - replay
   - sample
   - skip/skipLast
   - take/taskLast
   - throttleFist/throtleLast/throttleLatest/throttleWithTimeout
   - timeInterval
   - timeout
   - timestamp
   - window

### observeOn 分析

#### 示例介绍

示例代码如下，在 subscribe 调用前，每次调用都是对之前的Observable的包装，下面在注释中写出了每行调用之后返回的包装对象，或者 subscribe 最终的调用对象。

```java
Observable.just(1) 										 // 1. ObservableJust 
          .observeOn(Schedulers.io()) // 2. ObservableObserveOn
  				.subscribe();								 // 3. ObservableObserveOn#subscribe
```

- `observeOn` 的包装过程可参看下方源码：

  ```java
  public final Observable<T> observeOn(@NonNull Scheduler scheduler) {
    return observeOn(scheduler, false, bufferSize());
  }
  
  public final Observable<T> observeOn(@NonNull Scheduler scheduler, boolean delayError, int bufferSize) {
    Objects.requireNonNull(scheduler, "scheduler is null");
    ObjectHelper.verifyPositive(bufferSize, "bufferSize");
    // 将 ObservableJust 传递给 ObservableObserveOn 
    return RxJavaPlugins.onAssembly(new ObservableObserveOn<>(this, scheduler, delayError, bufferSize));
  }
  ```

#### `ObservableJust` 

实现非常简单，我们就直接先看了：

```java
public final class ObservableJust<T> extends Observable<T> implements ScalarSupplier<T> {

    private final T value;
    public ObservableJust(final T value) {
        this.value = value;
    }

    @Override
    protected void subscribeActual(Observer<? super T> observer) {
        ScalarDisposable<T> sd = new ScalarDisposable<>(observer, value);
      	// 做的事情很简单
        observer.onSubscribe(sd);
        sd.run();
    }

    @Override
    public T get() {
        return value;
    }
}

public static final class ScalarDisposable<T>
    extends AtomicInteger
    implements QueueDisposable<T>, Runnable {

        private static final long serialVersionUID = 3880992722410194083L;

        final Observer<? super T> observer;

        final T value;

        static final int START = 0;
        static final int FUSED = 1;
        static final int ON_NEXT = 2;
        static final int ON_COMPLETE = 3;

        public ScalarDisposable(Observer<? super T> observer, T value) {
            this.observer = observer;
            this.value = value;
        }

        @Override
        public void run() {
            if (get() == START && compareAndSet(START, ON_NEXT)) {
                observer.onNext(value);
                if (get() == ON_NEXT) {
                    lazySet(ON_COMPLETE);
                    observer.onComplete();
                }
            }
        }
    }
```

我们铺开一下 just 的 `subscribeActual` 调用，实际上就是如下三个方法：

```java
observer.onSubscribe(ScalarDisposable);
	ScalarDisposable.run
		observer.onNext(value);
		observer.onComplete();
```

####  入口：`ObservableObserveOn.subscribe`	

```java
// subscribe 方法为 Observable 的 final 方法，各种变体最终都调用到这个方法中来    
public final Disposable subscribe(@NonNull Consumer<? super T> onNext, @NonNull Consumer<? super Throwable> onError,
            @NonNull Action onComplete) {
  			// 所有的通知函数都被包装成一个 LambdaObserver
        LambdaObserver<T> ls = new LambdaObserver<>(onNext, onError, onComplete, Functions.emptyConsumer());
        subscribe(ls);
        return ls;
}

public final void subscribe(@NonNull Observer<? super T> observer) {
        Objects.requireNonNull(observer, "observer is null");
        try {
          	// 正常情况下（没有设置hook），直接返回传入的 observer
            observer = RxJavaPlugins.onSubscribe(this, observer);
            // 最终调用的是 subscribeActual(LambdaObserver)
            subscribeActual(observer);
        } catch (NullPointerException e) { // NOPMD
            throw e;
        } catch (Throwable e) {
            throw npe;
        }
}
```

所以调用序列如下：

```java
Observable.just(1).observeOn(Schedulers.io()).subscribe();
	ObservableObserveOn.subscribe(LambdaObserver)
  	ObservableObserveOn.subscribeActual(LambdaObserver)
```

其中 LambdaObserver 也就是最终用户关注的那些个通知函数（onNext，onError等）。

#### `ObservableObserveOn.subscribeActual`

```java
		// observer 即为 LambdaObserver
		// 这里的 source 为我们的 ObservableJust
		@Override
    protected void subscribeActual(Observer<? super T> observer) {
        if (scheduler instanceof TrampolineScheduler) {
            // 当前线程队列执行
            source.subscribe(observer);
        } else {
          	// 一般情况获取 Scheduler 的worker，我们切换线程的，就走这个分支
            Scheduler.Worker w = scheduler.createWorker();
						// 然后又包装了一下 🧄
            source.subscribe(new ObserveOnObserver<>(observer, w, delayError, bufferSize));
        }
    }
```

目前为止，调用序列如下：

```java
Observable.just(1).observeOn(Schedulers.io()).subscribe();
	ObservableObserveOn.subscribe(LambdaObserver)
  	ObservableObserveOn.subscribeActual(LambdaObserver)
    	ObservableJust.subscribe(ObserveOnObserver(LambdaObserver,scheduler.createWorker()))
```

接下来就到了 `ObservableJust.subscribe` 了，根据我们之前的分析，实际上就是如下调用序列：

```java
observer.onSubscribe(ScalarDisposable);
	ScalarDisposable.run
		observer.onNext(value);
		observer.onComplete();
```

也就是说重点来到了 `ObserveOnObserver` (ObserveOnObserver(LambdaObserver,scheduler.createWorker()))

即：

```java
ObserveOnObserver.onSubscribe(ScalarDisposable);
	ScalarDisposable.run
		ObserveOnObserver.onNext(value);
		ObserveOnObserver.onComplete();
```



####  ObserveOnObserver

```java
ObserveOnObserver(Observer<? super T> actual, Scheduler.Worker worker, boolean delayError, int bufferSize) {
    this.downstream = actual;
    this.worker = worker;
    this.delayError = delayError;
    this.bufferSize = bufferSize;
}
```

首先，通过查看其构造函数，我们可以看到 ：

- `downstream` 指向原始的 Observer（LambdaObserver，也就是用户关心的那些个通知毁掉）
- `worker` 指向 Scheduler 创建的 Worker

接下来，我们按调用序列依次查看其实现：

```java
ObserveOnObserver.onSubscribe(ScalarDisposable);
	ScalarDisposable.run
		ObserveOnObserver.onNext(value);
		ObserveOnObserver.onComplete();
```

##### 1. ObserveOnObserver.onSubscribe(ScalarDisposable);

```java
				@Override
        public void onSubscribe(Disposable d) {
            if (DisposableHelper.validate(this.upstream, d)) {
                this.upstream = d;
              // 很明显，我们的 ScalarDisposable 是一个 QueueDisposable
                if (d instanceof QueueDisposable) {
                    @SuppressWarnings("unchecked")
                    QueueDisposable<T> qd = (QueueDisposable<T>) d;

                    int m = qd.requestFusion(QueueDisposable.ANY | QueueDisposable.BOUNDARY);
										 // sd 返回 SYNC，走以下同步分支
                    if (m == QueueDisposable.SYNC) {
                        sourceMode = m;
                      	// 设置队列为 ScalarDisposable
                        queue = qd;
                        done = true;
                       	// downstream 即为 LambdaObserver，这里就调用了目标通知Observable的 onSubscribe
                        downstream.onSubscribe(this);
                        schedule();
                      	// 到这里就直接return了
                        return;
                    }
                    if (m == QueueDisposable.ASYNC) {
                        sourceMode = m;
                        queue = qd;
                        downstream.onSubscribe(this);
                        return;
                    }
                }

                queue = new SpscLinkedArrayQueue<>(bufferSize);

                downstream.onSubscribe(this);
            }
        }

        void schedule() {
            if (getAndIncrement() == 0) {
                worker.schedule(this);
            }
        }


```

通过 worker.schedule(ObserveOnObserver) 就会直接运行 ObserveOnObserver.run ，只不过这时**切换了线程**。

```java
        @Override
        public void run() {
          // requestFusion 时，如果传入的是 ASYNC 则 outFused 为true，所以我们走 drainNormal 逻辑
            if (outputFused) {
                drainFused();
            } else {
                drainNormal();
            }
        }

				void drainNormal() {
            int missed = 1;
						// onSubscribe 时设置了 queue 为我们的 ScalarDisposable ，就是 ObservableJust 的 subscribeActual 中创建的的那个 Disposable
            final SimpleQueue<T> q = queue;
            // a 就是我们的下游Observer ，即 LambdaObserver
            final Observer<? super T> a = downstream;

            for (;;) {
                if (checkTerminated(done, q.isEmpty(), a)) {
                    return;
                }

                for (;;) {
                    boolean d = done;
                    T v;

                    try {
                       // 取值,实际上就是 just(T) 中的 T value
                        v = q.poll();
                    } catch (Throwable ex) {
                        Exceptions.throwIfFatal(ex);
                        disposed = true;
                        upstream.dispose();
                        q.clear();
                        a.onError(ex);
                        worker.dispose();
                        return;
                    }
                    boolean empty = v == null;

                    if (checkTerminated(d, empty, a)) {
                        return;
                    }

                    if (empty) {
                        break;
                    }
										 // 然后调用了
                    a.onNext(v);
                }

                missed = addAndGet(-missed);
                if (missed == 0) {
                    break;
                }
            }
        }
```

总结在其他线程的调用序列：

```java
LambdaObserver.onNext(value)
```

##### onComplete

```java
@Override
public void onComplete() {
    if (done) {
        return;
    }
    done = true;
    schedule();
}
```

这里设置了 done 标记，然后又通过schedule，在线程池中执行 drainNormal ，drainNormal中有一个checkTerminated方法使用到了done这个标记：



```java
         if (checkTerminated(done, q.isEmpty(), a)) {
                    return;
                }

boolean checkTerminated(boolean d, boolean empty, Observer<? super T> a) {
            if (disposed) {
                queue.clear();
                return true;
            }
            if (d) {
                Throwable e = error;
                if (delayError) {
                    if (empty) {
                        disposed = true;
                        if (e != null) {
                            a.onError(e);
                        } else {
                            a.onComplete();
                        }
                        worker.dispose();
                        return true;
                    }
                } else {
                    if (e != null) {
                        disposed = true;
                        queue.clear();
                        a.onError(e);
                        worker.dispose();
                        return true;
                    } else
                    if (empty) {
                        disposed = true;
                        a.onComplete();
                        worker.dispose();
                        return true;
                    }
                }
            }
            return false;
        }
```

然后在这个方法中，如果 done = true，则会执行 `LambdaObserver.onComplete` 或 `LambdaObserver.onError` ，而且此时动作执行在Scheduler对应的线程池之中。

#### 总结

observeOn会将其包装的 Observable 的的订阅 Observer 的通知方法（next, complete,error）运行到指定的线程之中。
