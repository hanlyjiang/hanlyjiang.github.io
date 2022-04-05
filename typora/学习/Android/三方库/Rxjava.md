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

- observeOn 会将其包装的 Observable 的的订阅 Observer 的通知方法（next, complete,error）运行到指定的线程之中。 影响的是其后续的通知，因为只有订阅它的时候才会触发对应的通知回调。
- 一般的变换操作都需要在其实现中调用 source.subscribe 来触发事件流。所以此时就会调用对应的通知方法。

### subscribeOn 分析

实际上就是把 `source.subscribe(parent); ` 放到另外一个线程中

如何保证其他的部分在原来的线程中？没有保证。所以如果默认情况下没有通过 observeOn 切换线程的话，那么通知也会在 subscribeOn 所指定的线程中进行操作。

```java
 public final Observable<T> subscribeOn(@NonNull Scheduler scheduler) {
        Objects.requireNonNull(scheduler, "scheduler is null");
   // 包装到 ObservableSubscribeOn 中
        return RxJavaPlugins.onAssembly(new ObservableSubscribeOn<>(this, scheduler));
    }

public final class ObservableSubscribeOn<T> extends AbstractObservableWithUpstream<T, T> {
    final Scheduler scheduler;

    public ObservableSubscribeOn(ObservableSource<T> source, Scheduler scheduler) {
        super(source);
        this.scheduler = scheduler;
    }

    @Override
    public void subscribeActual(final Observer<? super T> observer) {
        final SubscribeOnObserver<T> parent = new SubscribeOnObserver<>(observer);
				// observer = LambdaObserver（被包装的Observable的订阅者）
      	// 原始的 Observer 的 onSubscribe还没有切换线程
        observer.onSubscribe(parent);
				// 自己的切换了线程，run =  source.subscribe(parent)
      	// source = ObservableJust （被包装的Observable）
        parent.setDisposable(scheduler.scheduleDirect(new SubscribeTask(parent)));
    }
  static final class SubscribeOnObserver<T> extends AtomicReference<Disposable> implements Observer<T>, Disposable {

        private static final long serialVersionUID = 8094547886072529208L;
        final Observer<? super T> downstream;

        final AtomicReference<Disposable> upstream;

        SubscribeOnObserver(Observer<? super T> downstream) {
            this.downstream = downstream;
            this.upstream = new AtomicReference<>();
        }

        @Override
        public void onSubscribe(Disposable d) {
            DisposableHelper.setOnce(this.upstream, d);
        }

        @Override
        public void onNext(T t) {
            downstream.onNext(t);
        }

        @Override
        public void onError(Throwable t) {
            downstream.onError(t);
        }

        @Override
        public void onComplete() {
            downstream.onComplete();
        }

        @Override
        public void dispose() {
            DisposableHelper.dispose(upstream);
            DisposableHelper.dispose(this);
        }

        @Override
        public boolean isDisposed() {
            return DisposableHelper.isDisposed(get());
        }

        void setDisposable(Disposable d) {
            DisposableHelper.setOnce(this, d);
        }
    }
   final class SubscribeTask implements Runnable {
        private final SubscribeOnObserver<T> parent;

        SubscribeTask(SubscribeOnObserver<T> parent) {
            this.parent = parent;
        }

        @Override
        public void run() {
            source.subscribe(parent);
        }
    }
}
```



### doOnTerminate，doOnComplete 在何处执行？

#### 分析

通过 doOnTerminate， doOnComplete 等我们可以在对应的事件阶段添加其他的Action。那么这些Action怎么切换线程了？

所有的 doOnXXX 的动作都是通过 ObservableDoOnEach 包装完成的。

下面仅以 onNext 为例进行说明，其他的都类似。

- 可以看到，只是简单包装了一下，让doOnNext 的 action 在包装的对象的OnNext中先执行，然后在调用downstream.onNext(t)
- 所以，得到如下结论：
  - doOnNext 的Action实际上也是在我们subscribe的 onNext 之前执行的；

那么，我们有一个问题，doOnNext （onNext.accept(t)）和 onNext（downstream.onNext(t)） 一定是在一个线程中执行吗？

- 答案是不一定，doOnNext 执行的时机决定于当前 Observer，而 onNext 执行的线程则决定与 downstream 在哪个线程执行。

```java
public final class ObservableDoOnEach<T> extends AbstractObservableWithUpstream<T, T> {
    final Consumer<? super T> onNext;

    public ObservableDoOnEach(ObservableSource<T> source, Consumer<? super T> onNext,
                              Consumer<? super Throwable> onError,
                              Action onComplete,
                              Action onAfterTerminate) {
        super(source);
        this.onNext = onNext;
    }

    @Override
    public void subscribeActual(Observer<? super T> t) {
       // source 就是我们被包装的 Observable ，让其订阅 DoOnEachObserver
        source.subscribe(new DoOnEachObserver<>(t, onNext, onError, onComplete, onAfterTerminate));
    }

    static final class DoOnEachObserver<T> implements Observer<T>, Disposable {
        final Observer<? super T> downstream;
        final Consumer<? super T> onNext;
        Disposable upstream;
        boolean done;
        DoOnEachObserver(
                Observer<? super T> actual,
                Consumer<? super T> onNext,
                Consumer<? super Throwable> onError,
                Action onComplete,
                Action onAfterTerminate) {
            this.downstream = actual;
            this.onNext = onNext;
        }
      
        @Override
        public void onNext(T t) {
            if (done) {
                return;
            }
            try {
              	// doOnNext 的 Action
                onNext.accept(t);
            } catch (Throwable e) {
                Exceptions.throwIfFatal(e);
                upstream.dispose();
                onError(e);
                return;
            }
						// 实际的 Observer
            downstream.onNext(t);
        }
}

```

#### 如何切换doOnSubscribe 执行的线程？

而 subscribeOn 则是要把 Observer的 subscribe 方法放到指定的线程中去执行，而subscribe 动作是还没有发生的，只有我们调用subscribe时才会发生， 所以我们需要通过  .subscribeOn(Schedulers.io()) 去触发，所以subscribeOn需要放在后面调用。

```java
// 将 subscribeOn 放在 doOnSubscribe后面即可                
.doOnSubscribe(disposable -> log("doOnSubscribe"))
                .subscribeOn(Schedulers.io())
```

#### 如何切换 doOnNext/doOnComplete/doOnError/doOnTerminate 执行的线程？

因为 observeOn 相当于把下游的 Observer 的通知函数抛到指定的线程中去执行，而这个执行只有在 subscribe（包括我们主动subscribe及变换操作时触发的subscribe）才会触发通知事件流，所以我们需要预先切换；

每个转换动作都需要触发事件流，就是每个都需要调用 subscribe

```java
// 将 observeOn 放在doOnXXX 之后即可
Observable.create((ObservableOnSubscribe<Integer>) emitter -> {
                    log("subscribe");
                    emitter.onNext(1);
                    emitter.onComplete();
                })
                .observeOn(Schedulers.newThread())
                .doOnNext(b -> log("doOnNext"))
                .observeOn(Schedulers.computation())
                .doOnSubscribe(disposable -> log("doOnSubscribe"))
                .subscribeOn(Schedulers.io())
                .doOnError(throwable -> log("doOnError"))
                .observeOn(Schedulers.newThread())
                .doOnComplete(() -> log("doOnComplete"))
                .observeOn(Schedulers.newThread())
                .doOnTerminate(countDownLatch::countDown)
                .observeOn(Schedulers.newThread())
                .subscribe(integer -> log("onNext"),
                        throwable -> log("onError"),
                        () -> log("onComplete"));

// 输出
RxCachedThreadScheduler-1|doOnSubscribe
RxCachedThreadScheduler-1|subscribe
RxNewThreadScheduler-1|doOnNext
RxNewThreadScheduler-2|doOnComplete
RxNewThreadScheduler-4|onNext
RxNewThreadScheduler-4|onComplete
```

再看下面的例子：

```java
       Observable.create((ObservableOnSubscribe<Integer>) emitter -> {
                    log("subscribe");
                    emitter.onNext(1);
                    emitter.onComplete();
                })
                .doOnSubscribe(disposable -> log("doOnSubscribe"))
                .subscribeOn(Schedulers.io())

                .observeOn(Schedulers.newThread())
                .doOnNext(b -> log("doOnNext-" + (count.incrementAndGet()))) // RxNewThreadScheduler-1|doOnNext-1
//                .observeOn(Schedulers.newThread())
                .doOnNext(b -> log("doOnNext-" + (count.incrementAndGet()))) // RxNewThreadScheduler-1|doOnNext-2

                .observeOn(Schedulers.newThread())
                .doOnNext(b -> log("doOnNext-" + (count.incrementAndGet()))) // RxNewThreadScheduler-2|doOnNext-3

                .observeOn(Schedulers.newThread())
                .doOnNext(b -> log("doOnNext-" + (count.incrementAndGet()))) // RxNewThreadScheduler-3|doOnNext-4


                .observeOn(Schedulers.newThread())
                .doOnTerminate(countDownLatch::countDown)

                .observeOn(Schedulers.newThread())
                .subscribe(integer -> log("onNext"),
                        throwable -> log("onError"),
                        () -> log("onComplete"));

// 输出
RxCachedThreadScheduler-1|doOnSubscribe
RxCachedThreadScheduler-1|subscribe
  // 一个管下面两条
RxNewThreadScheduler-1|doOnNext-1
RxNewThreadScheduler-1|doOnNext-2
  
RxNewThreadScheduler-2|doOnNext-3
RxNewThreadScheduler-3|doOnNext-4
RxNewThreadScheduler-5|onNext
RxNewThreadScheduler-5|onComplete
```



### 线程切换实例总结

有如下测试代码：

```java
    public static void main(String[] args) {
        RxJavaTest rxJavaTest = new RxJavaTest();
        CountDownLatch countDownLatch = new CountDownLatch(1);
        Disposable subscribe = Observable.create((ObservableOnSubscribe<Integer>) emitter -> {
                    log("subscribe");
                    emitter.onNext(1);
                    emitter.onComplete();
                })
//                .observeOn(Schedulers.io())
//                .subscribeOn(Schedulers.computation())
                .doOnTerminate(countDownLatch::countDown)
                .subscribe(integer -> log("onNext"),
                        throwable -> log("onError"),
                        () -> log("onComplete"));
        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
```

#### 单一Observable切换

按不同的订阅方式，分别有如下线程切换表现：

1. 不调用 observeOn subscribeOn
    ```java
      // 不调用 observeOn subscribeOn
    // .observeOn(Schedulers.io())
    // .subscribeOn(Schedulers.computation())
    // 输出
      main|subscribe
      main|onNext
      main|onComplete
    ```

2. 仅调用 observeOn

   只会切换通知方法的调用线程，如下：

   ```java
   // 仅调用 observeOn
      .observeOn(Schedulers.io())
   // .subscribeOn(Schedulers.computation())
   // 输出
   	main|subscribe
     RxCachedThreadScheduler-1|onNext
     RxCachedThreadScheduler-1|onComplete
   ```

3. 仅调用  subscribeOn

    可以看到，subscribe 及 通知方法都在 computation 线程中调用了。

    ```java 
    // 仅调用 subscribeOn
    //  .observeOn(Schedulers.io())
        .subscribeOn(Schedulers.computation())
    // 输出
    RxComputationThreadPool-1|subscribe
    RxComputationThreadPool-1|onNext
    RxComputationThreadPool-1|onComplete
    ```

4. 两者都调用

    subscribe 在 computation ，通知在 io

    ```java
      .observeOn(Schedulers.io())
      .subscribeOn(Schedulers.computation())
    // 输出
    RxComputationThreadPool-1|subscribe
    RxCachedThreadScheduler-1|onNext
    RxCachedThreadScheduler-1|onComplete
    ```

5. 多次调用subscribeOn

    **前面**的生效

    ```java
    .subscribeOn(Schedulers.computation())
      .observeOn(Schedulers.io())
      .subscribeOn(Schedulers.newThread())
    // 输出
    RxComputationThreadPool-1|subscribe
    RxCachedThreadScheduler-1|onNext
    RxCachedThreadScheduler-1|onComplete
                      
    ```

6. 多次 observeOn

    **后面**的生效

    ```java
    .subscribeOn(Schedulers.computation())
    .observeOn(Schedulers.io())
    .observeOn(Schedulers.newThread())
    // 输出 
    RxComputationThreadPool-1|subscribe
    RxNewThreadScheduler-1|onNext
    RxNewThreadScheduler-1|onComplete
    ```

#### 变换操作切换

对于变换的操作的线程切换，需要看变换是发生在 subscribe 还是通知上面。

如 map 操作源代码如下：

```java
static final class MapObserver<T, U> extends BasicFuseableObserver<T, U> {
        final Function<? super T, ? extends U> mapper;
        MapObserver(Observer<? super U> actual, Function<? super T, ? extends U> mapper) {
            super(actual);
            this.mapper = mapper;
        }
        @Override
        public void onNext(T t) {
            if (done) {
                return;
            }

            if (sourceMode != NONE) {
                downstream.onNext(null);
                return;
            }

            U v;

            try {
                // map 的转换操作是在onNext中，所以我们需要使用 observerOn 进行切换
                v = Objects.requireNonNull(mapper.apply(t), "The mapper function returned a null value.");
            } catch (Throwable ex) {
                fail(ex);
                return;
            }
            downstream.onNext(v);
        }
}
```

操作在 onNext 中，故如果需要切换，需要使用 observerOn 进行切换，如下测试代码

```java
public static void main(String[] args) {
        RxJavaTest rxJavaTest = new RxJavaTest();
        CountDownLatch countDownLatch = new CountDownLatch(1);
        Disposable subscribe = Observable.create((ObservableOnSubscribe<Integer>) emitter -> {
                    log("subscribe");
                    emitter.onNext(1);
                    emitter.onComplete();
                })
          // 注意顺序 observeOn在map操作前面，类似于map中的onNext等同于 subscribe 后的 next
                .observeOn(Schedulers.newThread())
                .map(integer -> {
                    log("map");
                    return true;
                })
                .doOnTerminate(countDownLatch::countDown)
                .subscribe(integer -> log("onNext"),
                        throwable -> log("onError"),
                        () -> log("onComplete"));
        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
```



