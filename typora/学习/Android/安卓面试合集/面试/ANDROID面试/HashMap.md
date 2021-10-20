# 面试官爆锤HashMap：HashMap实现原理？HashMap是线程安全的吗？

**面试题1：说一下 HashMap 的实现原理？**

- 追问1：如何实现HashMap的有序？
- 追问2：那TreeMap怎么实现有序的？
- 追问3：put方法原理是怎么实现的？
- 追问4：HashMap扩容机制原理
- 追问5：HashMap在JDK1.8都做了哪些优化？
- 追问6：链表红黑树如何互相转换？阈值多少？

**面试题2：HashMap是线程安全的吗？**

- 追问1：你是如何解决这个线程不安全问题的？
- 追问2：说一下大家为什么要选择ConcurrentHashMap？
- 追问3：ConcurrentHashMap在JDK1.7、1.8中都有哪些优化？

# 面试题1：说一下 HashMap 的实现原理？

**正经回答：**

众所周知，HashMap是一个用于存储Key-Value键值对的集合，每一个键值对也叫做Entry（包括Key-Value），其中Key 和 Value 允许为null。这些个键值对（Entry）分散存储在一个数组当中，这个数组就是HashMap的主干。另外，HashMap数组每一个元素的初始值都是Null。

![img](https://upload-images.jianshu.io/upload_images/26522304-85503ac7070d1246.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/804/format/webp)



值得注意的是：HashMap不能保证映射的顺序，插入后的数据顺序也不能保证一直不变（如扩容后rehash）。

要说HashMap的原理，首先要先了解它的数据结构

![img](https://upload-images.jianshu.io/upload_images/26522304-dceaec636b23e893.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/807/format/webp)

如上图为JDK1.8版本的数据结构，其实HashMap在JDK1.7及以前是一个“链表散列”的数据结构，即数组 + 链表的结合体。JDK8优化为：数组+链表+红黑树。

我们常把数组中的每一个节点称为一个桶。当向桶中添加一个键值对时，首先计算键值对中key的hash值（hash(key)），以此确定插入数组中的位置（即哪个桶），但是可能存在同一hash值的元素已经被放在数组同一位置了，这种现象称为碰撞，这时按照尾插法(jdk1.7及以前为头插法)的方式添加key-value到同一hash值的元素的最后面，链表就这样形成了。

当链表长度超过8(TREEIFY_THRESHOLD - 阈值)时，链表就自行转为红黑树。

> 注意：同一hash值的元素指的是key内容一样么？不是。根据hash算法的计算方式，是将key值转为一个32位的int值（近似取值），key值不同但key值相近的很可能hash值相同，如key=“a”和key=“aa”等

通过上述回答的内容，我们明显给了面试官往深入问的多个诱饵，根据我们的回答，下一步他多可能会追问这些问题：

> 1、如何实现HashMap的有序？
>
> 4、put方法原理是怎么实现的？
>
> 6、扩容机制原理 → 初始容量、加载因子 → 扩容后的rehash（元素迁移）
>
> 2、插入后的数据顺序会变的原因是什么？
>
> 3、HashMap在JDK1.7-JDK1.8都做了哪些优化？
>
> 5、链表红黑树如何互相转换？阈值多少？
>
> 7、头插法改成尾插法为了解决什么问题？

而我们，当然是提前准备好如何回答好这些问题！当你的回答超过面试同学的认知范围时，主动权就到我们手里了。



# 追问1：如何实现HashMap的有序？

**使用LinkedHashMap 或 TreeMap。**

LinkedHashMap内部维护了一个单链表，有头尾节点，同时LinkedHashMap节点Entry内部除了继承HashMap的Node属性，还有before 和 after用于标识前置节点和后置节点。可以实现按插入的顺序或访问顺序排序。



```java
/**
 * The head (eldest) of the doubly linked list.
*/
transient LinkedHashMap.Entry<K,V> head;

/**
  * The tail (youngest) of the doubly linked list.
*/
transient LinkedHashMap.Entry<K,V> tail;
//将加入的p节点添加到链表末尾
private void linkNodeLast(LinkedHashMap.Entry<K,V> p) {
  LinkedHashMap.Entry<K,V> last = tail;
  tail = p;
  if (last == null)
    head = p;
  else {
    p.before = last;
    last.after = p;
  }
}
//LinkedHashMap的节点类
static class Entry<K,V> extends HashMap.Node<K,V> {
  Entry<K,V> before, after;
  Entry(int hash, K key, V value, Node<K,V> next) {
    super(hash, key, value, next);
  }
}
```

示例代码：



```dart
public static void main(String[] args) {
  Map<String, String> linkedMap = new LinkedHashMap<String, String>();
  linkedMap.put("1", "占便宜");
  linkedMap.put("2", "没够儿");
  linkedMap.put("3", "吃亏");
  linkedMap.put("4", "难受");

  for(linkedMap.Entry<String,String> item: linkedMap.entrySet()){
    System.out.println(item.getKey() + ":" + item.getValue());
  }
}
```

输出结果：



```undefined
1:占便宜
2:没够儿
3:吃亏
4:难受
```

# 追问2：那TreeMap怎么实现有序的？

TreeMap是按照Key的自然顺序或者Comprator的顺序进行排序，内部是通过红黑树来实现。

- TreeMap实现了SortedMap接口，它是一个key有序的Map类。
- 要么key所属的类实现Comparable接口，或者自定义一个实现了Comparator接口的比较器，传给TreeMap用于key的比较。



```dart
TreeMap<String, String> map = new TreeMap<String, String>(new Comparator<String>() {

    @Override
    public int compare(String o1, String o2) {
            return o2.compareTo(o1);
    }

});
```

# 追问3：put方法原理是怎么实现的？

![img](https://upload-images.jianshu.io/upload_images/26522304-d3e64d1c6021aed8.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1107/format/webp)

因此，在扩容时，不需要重新计算元素的hash了，只需要判断最高位是1还是0就好了。

下面我们看看源码中的内容：



```csharp
/**
 * 将指定参数key和指定参数value插入map中，如果key已经存在，那就替换key对应的value
 * 
 * @param key 指定key
 * @param value 指定value
 * @return 如果value被替换，则返回旧的value，否则返回null。当然，可能key对应的value就是null。
 */
public V put(K key, V value) {
    //putVal方法的实现就在下面
    return putVal(hash(key), key, value, false, true);
}
```

从源码中可以看到，put(K key, V value)可以分为三个步骤：

- 通过hash(Object key)方法计算key的哈希值。
- 通过putVal(hash(key), key, value, false, true)方法实现功能。
- 返回putVal方法返回的结果。

那么看看putVal方法的源码是如何实现的？

```csharp
/**
 * Map.put和其他相关方法的实现需要的方法
 * 
 * @param hash 指定参数key的哈希值
 * @param key 指定参数key
 * @param value 指定参数value
 * @param onlyIfAbsent 如果为true，即使指定参数key在map中已经存在，也不会替换value
 * @param evict 如果为false，数组table在创建模式中
 * @return 如果value被替换，则返回旧的value，否则返回null。当然，可能key对应的value就是null。
 */
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    //如果哈希表为空，调用resize()创建一个哈希表，并用变量n记录哈希表长度
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    //如果指定参数hash在表中没有对应的桶，即为没有碰撞
    if ((p = tab[i = (n - 1) & hash]) == null)
        //直接将键值对插入到map中即可
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        //如果碰撞了，且桶中的第一个节点就匹配了
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            //将桶中的第一个节点记录起来
            e = p;
        //如果桶中的第一个节点没有匹配上，且桶内为红黑树结构，则调用红黑树对应的方法插入键值对
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        //不是红黑树结构，那么就肯定是链式结构
        else {
            //遍历链式结构
            for (int binCount = 0; ; ++binCount) {
                //如果到了链表尾部
                if ((e = p.next) == null) {
                    //在链表尾部插入键值对
                    p.next = newNode(hash, key, value, null);
                    //如果链的长度大于TREEIFY_THRESHOLD这个临界值，则把链变为红黑树
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    //跳出循环
                    break;
                }
                //如果找到了重复的key，判断链表中结点的key值与插入的元素的key值是否相等，如果相等，跳出循环
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                //用于遍历桶中的链表，与前面的e = p.next组合，可以遍历链表
                p = e;
            }
        }
        //如果key映射的节点不为null
        if (e != null) { // existing mapping for key
            //记录节点的vlaue
            V oldValue = e.value;
            //如果onlyIfAbsent为false，或者oldValue为null
            if (!onlyIfAbsent || oldValue == null)
                //替换value
                e.value = value;
            //访问后回调
            afterNodeAccess(e);
            //返回节点的旧值
            return oldValue;
        }
    }
    //结构型修改次数+1
    ++modCount;
    //判断是否需要扩容
    if (++size > threshold)
        resize();
    //插入后回调
    afterNodeInsertion(evict);
    return null;
}
```

# 追问4：HashMap扩容机制原理

> capacity 即容量，默认16。
>
> loadFactor 加载因子，默认是0.75threshold 阈值。阈值=容量*加载因子。默认12。当元素数量超过阈值时便会触发扩容。

- 一般情况下，当元素数量超过阈值时便会触发扩容（调用resize()方法）。
- 每次扩容的容量都是之前容量的2倍。
- 扩展后Node对象的位置要么在原位置，要么移动到原偏移量两倍的位置。

这里我们以JDK1.8的扩容为例：

HashMap的容量变化通常存在以下几种情况：

- 空参数的构造函数：实例化的HashMap默认内部数组是null，即没有实例化。第一次调用put方法时，则会开始第一次初始化扩容，长度为16。
- 有参构造函数：用于指定容量。会根据指定的正整数找到不小于指定容量的2的幂数，将这个数设置赋值给阈值（threshold）。第一次调用put方法时，会将阈值赋值给容量，然后让 阈值 = 容量 x 加载因子 。（因此并不是我们手动指定了容量就一定不会触发扩容，超过阈值后一样会扩容！！）
- 如果不是第一次扩容，则容量变为原来的2倍，阈值也变为原来的2倍。（容量和阈值都变为原来的2倍时，加载因子0.75不变）

此外还有几个点需要注意：

- 首次put时，先会触发扩容（算是初始化），然后存入数据，然后判断是否需要扩容；可见首次扩容可能会调用两次resize()方法。
- 不是首次put，则不再初始化，直接存入数据，然后判断是否需要扩容；

> 扩容时，要扩大空间，为了使hash散列均匀分布，原有部分元素的位置会发生移位。

**JDK7的元素迁移**

JDK7中，HashMap的内部数据保存的都是链表。因此逻辑相对简单：在准备好新的数组后，map会遍历数组的每个“桶”，然后遍历桶中的每个Entity，重新计算其hash值（也有可能不计算），找到新数组中的对应位置，以头插法插入新的链表。

**这里有几个注意点：**

- 是否要重新计算hash值的条件这里不深入讨论，读者可自行查阅源码。
- 因为是头插法，因此新旧链表的元素位置会发生转置现象。
- 元素迁移的过程中在多线程情境下有可能会触发死循环（无限进行链表反转）。

**JDK1.8的元素迁移**

JDK1.8则因为巧妙的设计，性能有了大大的提升：由于数组的容量是以2的幂次方扩容的，那么一个Entity在扩容时，新的位置要么在原位置，要么在原长度+原位置的位置。原因如下图：

![img](https://upload-images.jianshu.io/upload_images/26522304-c749a4f09fb45d89.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/727/format/webp)

image

数组长度变为原来的2倍，表现在二进制上就是多了一个高位参与数组下标确定。此时，一个元素通过hash转换坐标的方法计算后，恰好出现一个现象：最高位是0则坐标不变，最高位是1则坐标变为“10000+原坐标”，即“原长度+原坐标”。如下图：

![img](https://upload-images.jianshu.io/upload_images/26522304-c78a4978f74e6e84.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/520/format/webp)

image

因此，在扩容时，不需要重新计算元素的hash了，只需要判断最高位是1还是0就好了。

JDK8的HashMap还有以下细节需要注意：

- JDK8在迁移元素时是正序的，不会出现链表转置的发生。
- 如果某个桶内的元素超过8个，则会将链表转化成红黑树，加快数据查询效率。

# 追问5：HashMap在JDK1.8都做了哪些优化？

![img](https://upload-images.jianshu.io/upload_images/26522304-62e595b30b10c19b.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/876/format/webp)

image

- 数组+链表改成了数组+链表或红黑树

防止发生hash冲突，链表长度过长，将时间复杂度由O(n)降为O(logn);

- 链表的插入方式从头插法改成了尾插法，简单说就是插入时，如果数组位置上已经有元素，1.7将新元素放到数组中，新节点插入到链表头部，原始节点后移；而JDK1.8会遍历链表，将元素放置到链表的最后；

因为1.7头插法扩容时，头插法可能会导致链表发生反转，多线程环境下会产生环（死循环）；

![img](https://upload-images.jianshu.io/upload_images/26522304-e09d5bc519e7cc8d.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/671/format/webp)

image

这个过程为，先将A复制到新的hash表中，然后接着复制B到链头（A的前边：B.next=A），本来B.next=null，到此也就结束了（跟线程二一样的过程），但是，由于线程二扩容的原因，将B.next=A，所以，这里继续复制A，让A.next=B，由此，环形链表出现：B.next=A; A.next=B

使用头插会改变链表的上的顺序，但是如果使用尾插，在扩容时会保持链表元素原本的顺序，就不会出现链表成环的问题了。

就是说原本是A->B，在扩容后那个链表还是A->B。

- 扩容的时候1.7需要对原数组中的元素进行重新hash定位在新数组的位置，1.8采用更简单的判断逻辑，位置不变或索引+旧容量大小；
- 在插入时，1.7先判断是否需要扩容，再插入，1.8先进行插入，插入完成再判断是否需要扩容；

# 追问6：链表红黑树如何互相转换？阈值多少？

- 链表转红黑树的阈值为：8
- 红黑树转链表的阈值为：6

经过计算，在hash函数设计合理的情况下，发生hash碰撞8次的几率为百万分之6，从概率上讲，阈值为8足够用；至于为什么红黑树转回来链表的条件阈值是6而不是7或9？因为如果hash碰撞次数在8附近徘徊，可能会频繁发生链表和红黑树的互相转化操作，为了预防这种情况的发生。

# 面试题2：HashMap是线程安全的吗？

不是线程安全的，在多线程环境下，

- JDK1.7：会产生死循环、数据丢失、数据覆盖的问题；
- JDK1.8：中会有数据覆盖的问题。

以1.8为例，当A线程判断index位置为空后正好挂起，B线程开始往index位置写入数据时，这时A线程恢复，执行写入操作，这样A或B数据就被覆盖了。

# 追问1：你是如何解决这个线程不安全问题的？

在Java中有HashTable、SynchronizedMap、ConcurrentHashMap这三种是实现线程安全的Map。

- HashTable：是直接在操作方法上加synchronized关键字，锁住整个数组，粒度比较大；
- SynchronizedMap：是使用Collections集合工具的内部类，通过传入Map封装出一个SynchronizedMap对象，内部定义了一个对象锁，方法内通过对象锁实现；
- ConcurrentHashMap：使用分段锁（CAS + synchronized相结合），降低了锁粒度，大大提高并发度

# 追问2：说一下大家为什么要选择ConcurrentHashMap？

在并发编程中使用HashMap可能导致程序死循环。而使用线程安全的HashTable效率又非常低下，基于以上两个原因，便有了ConcurrentHashMap的登场机会

**1）线程不安全的HashMap**

在多线程环境下，使用HashMap进行put操作会引起死循环，导致CPU利用率接近100%，所以在并发情况下不能使用HashMap。HashMap在并发执行put操作时会引起死循环，是因为多线程环境下会导致HashMap的Entry链表形成环形数据结构，一旦形成环形数据结构，Entry的next节点永远不为空，调用.next()时就会产生死循环获取Entry。

**2）效率低下的HashTable**

HashTable容器使用synchronized来保证线程安全，但在线程竞争激烈的情况下HashTable的效率非常低下（类似于数据库中的串行化隔离级别）。因为当一个线程访问HashTable的同步方法，其他线程也访问HashTable的同步方法时，会进入阻塞或轮询状态。如线程1使用put进行元素添加，线程2不但不能使用put方法添加元素，也不能使用get方法来获取元素，读写操作均需要获取锁，竞争越激烈效率越低。

因此，若未明确严格要求业务遵循串行化时（如转账、支付类业务），建议不启用HashTable。

![img](https://upload-images.jianshu.io/upload_images/26522304-85ac296abf660118.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/509/format/webp)

image

**3）ConcurrentHashMap的分段锁技术可有效提升并发访问率**

HashTable容器在竞争激烈的并发环境下表现出效率低下的原因是所有访问HashTable的线程都必须竞争同一把锁，假如容器里有多把锁，每一把锁用于锁容器其中一部分数据，那么当多线程访问容器里不同数据段的数据时，线程间就不会存在严重锁竞争，从而可以有效提高并发访问效率，这就是ConcurrentHashMap所使用的分段锁技术。首先将数据分成一段一段地存储（一堆Segment），然后给每一段数据配一把锁，当一个线程占用锁访问其中一个段数据的时候，其他段的数据也能被其他线程访问。

对于 ConcurrentHashMap 你至少要知道的几个点：

- 默认数组大小为16
- 扩容因子为0.75，扩容后数组大小翻倍
- 当存储的node总数量 >= 数组长度*扩容因子时，会进行扩容（数组中的元素、链表元素、红黑树元素都是内部类Node的实例或子类实例，这里的node总数量是指所有put进map的node数量）
- 当链表长度>=8且数组长度<64时会进行扩容
- 当数组下是链表时，在扩容的时候会从链表的尾部开始rehash
- 当链表长度>=8且数组长度>=64时链表会变成红黑树
- 树节点减少直至为空时会将对应的数组下标置空，下次存储操作再定位在这个下标t时会按照链表存储
- 扩容时树节点数量<=6时会变成链表
- 当一个事 物 操作发现map正在扩容时，会帮助扩容
- map正在扩容时获取（get等类似操作）操作还没进行扩容的下标会从原来的table获取，扩容完毕的下标会从新的table中获取

# 追问3：ConcurrentHashMap在JDK1.7、1.8中都有哪些优化？

其实，JDK1.8版本的ConcurrentHashMap的数据结构已经接近HashMap，相对而言，ConcurrentHashMap只是增加了同步的操作来控制并发。

- JDK1.7：ReentrantLock+Segment+HashEntry
- JDK1.8：Synchronized+CAS+Node（HashEntry）+红黑树

从JDK1.7版本的ReentrantLock+Segment+HashEntry，到JDK1.8版本中synchronized+CAS+HashEntry+红黑树。其中抛弃了原有的 Segment 分段锁，而采用了 CAS + synchronized 来保证并发安全性。

![img](https://upload-images.jianshu.io/upload_images/26522304-aa88284cb56ea881.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

image

数据结构上跟HashMap很像，从1.7到1.8版本，由于HashEntry从链表 → 红黑树所以 concurrentHashMap的时间复杂度从O(n)到O(log(n)) ↓↓↓；

![img](https://upload-images.jianshu.io/upload_images/26522304-a8514a0b133c35b4.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1140/format/webp)

image

同时，也把之前的HashEntry改成了Node，作用不变，当Node链表的节点数大于8时Node会自动转化为TreeNode,会转换成红黑树的结构。把值和next采用了volatile去修饰，保证了可见性，并且也引入了红黑树，在链表大于一定值的时候会转换（默认是8）。

归纳一下：

- JDK1.8的实现降低锁的粒度，JDK1.7版本锁的粒度是基于Segment的，包含多个HashEntry，而JDK1.8锁的粒度就是HashEntry（首节点）
- JDK1.8版本的数据结构变得更加简单，使得操作也更加清晰流畅，因为已经使用synchronized来进行同步，所以不需要分段锁的概念（jdk1.8），也就不需要Segment这种数据结构了，由于粒度的降低，实现的复杂度也增加了
- JDK1.8使用红黑树来优化链表，基于长度很长的链表的遍历是一个很漫长的过程，而红黑树的遍历效率是很快的，成功代替了一定阈值的链表。

> 作者：_陈哈哈
> 原文链接：[https://blog.csdn.net/qq_39390545/article/details/118077143](https://links.jianshu.com/go?to=https%3A%2F%2Fblog.csdn.net%2Fqq_39390545%2Farticle%2Fdetails%2F118077143)