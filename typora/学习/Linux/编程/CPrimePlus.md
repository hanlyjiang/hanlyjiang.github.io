# C

## misc

### printf

查看用法可以直接使用 `man printf` 即可。



### sizeof

返回 bytes 大小



## 数据类型大小

![image-20211125220826595](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111252208628.png)





## 指针

* 指针表示法更加接近机器语言，因此一些编译器在编译时能生成效率更高的代码。

### & 运算符 和 * 运算符

* `&`: 取址运算符，找出变量的指针地址
* `*`: *indirection operator - 间接运算符*，找出指针指向的值

> * `ptr=&bah; val=*ptr;` 等于 `val = bah`,所以称`*` 为间接运算符
> * 普通变量的直接值为值，派生值为指针
> * 指针变量的直接值为地址，派生值为对应的值

### 交换值

```c
#include <stdio.h>

void swap(int *a, int *b);

int main() {
    int x = 1, y = 2;
    printf("x=%d,y=%d addr: &x=%p,&y=%p \n", x, y, &x, &y);
    swap(&x, &y);
    printf("x=%d,y=%d addr: &x=%p,&y=%p \n\n", x, y, &x, &y);
    return 0;
}

void swap(int *a, int *b) {
    printf("swap a=%d,b=%d,addr: &a=%p,&b=%p \n", *a, *b, a, b);
    int temp;
    temp = *a;
    *a = *b;
    *b = temp;
    printf("swap a=%d,b=%d,addr: &a=%p,&b=%p \n", *a, *b, a, b);
}

// output
x=1,y=2 addr: &x=0x7ff7bc096f28,&y=0x7ff7bc096f24 
swap a=1,b=2,addr: &a=0x7ff7bc096f28,&b=0x7ff7bc096f24 
swap a=2,b=1,addr: &a=0x7ff7bc096f28,&b=0x7ff7bc096f24 
x=2,y=1 addr: &x=0x7ff7bc096f28,&y=0x7ff7bc096f24 
```



**⚠️注意：**

* C中没有引用变量（虽然C++有）
* **地址，指针，值**



### 指针&数组

> 指针提供一种以符合形式使用地址的方法。因为计算机的硬件指令非常依赖地址，指针在某种程度上把程序员想要传达的指令以更接近机器的方式表达。因此，使用指针的程序更有效率。

数组表示法实际上是在变相的使用指针。

* 数组名是该数组首元素的地址

  ```c
      int array[COL] = {1, 3, 4, 5};
      printf("\narray name is ptr: %p", array);
      printf("\n&array[0] is  ptr: %p", &array[0]);
  // output
  array name is ptr: 0x7ff7bc07aef0
  &array[0] is  ptr: 0x7ff7bc07aef0
  ```

#### 指针加数

##### 数组指针地址+1

```c
    short dates[ROW];
    short *pti;
    short index;
    double bills[ROW];
    double *ptf;
    pti = dates;
    ptf = bills;
    printf("\n%23s %15s", "short", "double");
    for (index = 0; index < ROW; ++index) {
        printf("\npointers+ %d: %10p %10p", index, pti + index, ptf + index);
    }

// output
                  short          double
pointers+ 0: 0x7ff7ba526ee8 0x7ff7ba526ec0
pointers+ 1: 0x7ff7ba526eea 0x7ff7ba526ec8
pointers+ 2: 0x7ff7ba526eec 0x7ff7ba526ed0
pointers+ 3: 0x7ff7ba526eee 0x7ff7ba526ed8
 
```

* short 2个字节
* double 8个字节
* **+1 指该类型的指针+1（自动移动对应的byte大小）**



##### 取值

```c
    short dates[ROW] = {1, 2, 3, 4};
    short *pti;
    short index;
    double bills[ROW] = {1.0, 2.0, 3.0, 4.0};
    double *ptf;
    pti = dates;
    ptf = bills;
    printf("\n%30s %10s", "short", "double");
    for (index = 0; index < ROW; ++index) {
        printf("\npointers+ %d value: %10d %12f", index, *(pti + index), *(ptf + index));
    }

// output 
                         short     double
pointers+ 0 value:          1     1.000000
pointers+ 1 value:          2     2.000000
pointers+ 2 value:          3     3.000000
pointers+ 3 value:          4     4.000000
```



##### 总结

`*(date + 2) == date[2]`

**遍历二维数组的新方式：**

```c
    int matrix[ROW][COL] = {
            {1, 1, 1, 1, 0},
            {1, 2, 1, 1, 0},
            {1, 1, 3, 1, 0},
            {1, 1, 1, 4, 0},
    };
    for (int i = 0; i < ROW * COL; i++) {
        if (i % (COL-1) == 0) {
            printf("\n");
        }
        printf("value= %d\t", *(matrix[0] + i));
    }
// output
value= 1	value= 1	value= 1	value= 1	
value= 0	value= 1	value= 2	value= 1	
value= 1	value= 0	value= 1	value= 1	
value= 3	value= 1	value= 0	value= 1	
value= 1	value= 1	value= 4	value= 0	
```

### 指针操作

* **指针求差**：返回相隔多少个对应类型的元素，返回的是整数

* **指针和数+/-**： 返回另外一个指针

* **解引用**：

  * 千万不要解引用未初始化的指针；因为指针指向的地址不确定，操作可能导致指针指向地址的数据被修改；

* **取址**：指针变量也有自己的地址和值；对指针而言， & 运算符给出指针本身的地址；

  * ```c
    int *ptr = array;
        printf("指针本身地址：    %p\n", &ptr);
        printf("指针指向地址：    %p\n", ptr);
        printf("数组地址：       %p\n", ptr);
        printf("指针指向地址的值：%d\n", *ptr);
    
    // output
    指针本身地址：    0x7ff7babb0e80
    指针指向地址：    0x7ff7babb0ea0
    数组地址：       0x7ff7babb0ea0
    指针指向地址的值：1
    ```

  * 可以看到，指针本身存储在内存地址编号为`0x7ff7babb0e80`的地方，其中存储的内容为 `0x7ff7babb0ea0` ，即 array 的地址。因此 `&ptr` 是指向`ptr`的指针，`ptr`是指向`array[0]` 的指针；

### 指针和多维数组



* 指针和数组名区别：指针只是指向一个地址，但是数组名称可以代表对应的类型

* ```c
  # define ROW  4
  # define COL  5
  const int m_array[ROW][COL] = {
          {1,  2,  3,  4,  5},
          {6,  7,  8,  9,  10},
          {11, 12, 13, 14, 15},
          {16, 17, 18, 19, 20},
  };
  
  void array_point();
  
  int main() {
      array_point();
      return 0;
  }
  
  void array_point() {
      int *ptr1 = m_array;
      int *ptr2 = m_array[0];
  }
  ```

* m_array 代表的是一个二维数组，相当于其元素类型为两个int类型

  <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111231110410.png" alt="image-20211123111029272" style="zoom: 50%;" />

* m_array[0] 代表的是一维数组，其元素类型为一个int

* <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111231110020.png" alt="image-20211123111056942" style="zoom:50%;" />

* 但是如果使用指针，则ptr1和ptr2都只是表示指向同一个地址的指针
* ‼️ `m_array[2][1]` 等价于 `*(*(m_array+2)+1))` 
* 二维数组需要使用两次间接操作符来取值。

#### 指向多维数组的指针

```c
int (* ptr1)[5]  = m_array;
```

注意：

1. 写法注意；
2. 维度写成和 m_array 声明的时候不一致也可以；

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111231128882.png" alt="image-20211123112845853" style="zoom:50%;" />

3. 考虑内存布局：声明指针的时候实际上是声明指向一个几维数组的指针

   ![image-20211123113420056](https://gitee.com/hanlyjiang/image-repo/raw/master/image/202111231134090.png)

   #### 多维数组函数形式参数声明

   ```c
   void array_iter(int array[][5], int length);
   
   void array_iter(int array[][5], int length) {
     
   // void array_iter(int (*array)[5], int length) {
       for (int i = 0; i < length; i++) {
           printf("\n");
           for (int j = 0; j < 5; j++) {
               printf("%10d", array[i][j]);
           }
       }
   }
   ```

   * 只能在形式参数声明时使用 `int array[][5]` 形式的声明，正常语句中无法使用；
   * 等价于 `int (*array)[5]`,不过这种写法可以用于普通表达式；
   * 第一个括号表示是指针，后面的括号表示指针指向的数据类型；
     * 如：`int (*array)[2][3] = int array[][2][3]`

   

##  数组

### 声明 & 赋值

#### 声明后索引访问赋值

```c
float candy[2];
candy[1] = 1;
```
> 不初始化则使用内存地址上现有的值

#### 声明时赋值

```c
float road[3] = {1,3};
// 计算数组长度：sizeof candy/sizeof *candy
printf("sizeof road is : %lu\n",sizeof road/sizeof *road);
printf("road[0] = %.5f \n", road[0]); // 1.00000
printf("road[1] = %.5f \n", road[1]); // 3.00000
printf("road[2] = %.5f \n", road[2]); // 0.00000
```

> 初始化时，如果项数不够，则会初始化为类型的默认值

#### 只读数组 - const

```c
const int week[7] = {1, 2, 3, 4, 5, 6, 7};
```

#### 指定初始化器（C99）

可以解决之前必须按顺序初始化的问题

```c
    // 指定初始化器
    int arr[6] = {[2] = 22};
    for (int i = 0; i < (sizeof arr / sizeof arr[0]);i++) {
        printf("arr[%d]=%d \n" , i, arr[i]);
    }

    // 指定初始化器
    int arr[6] = {[2] = 22,23,34};
    for (int i = 0; i < (sizeof arr / sizeof arr[0]);i++) {
        printf("arr[%d]=%d \n" , i, arr[i]);
    }
```

> 数组下标越界之后，编译器只会给出警告，但是不会报错。



#### 变长数组（VLA）

variable-length-array

C99 引入，C11 放弃，作为可选功能；

```c
int m = 9;
float sa[m];
```



### 多维数组

* 声明

```c
// 二维数组
    int matrix[4][4] = {
            {1, 1, 1, 1},
            {1, 2, 1, 1},
            {1, 1, 3, 1},
            {1, 1, 1, 4},
    };
    for (int i = 0; i < 4; i++) {
        printf("\n");
        for (int j = 0; j < 4; j++) {
            printf("matrix[%d][%d] = %d \t", i, j, matrix[i][j]);
        }
    }

输出：
matrix[0][0] = 1 	matrix[0][1] = 1 	matrix[0][2] = 1 	matrix[0][3] = 1 	
matrix[1][0] = 1 	matrix[1][1] = 2 	matrix[1][2] = 1 	matrix[1][3] = 1 	
matrix[2][0] = 1 	matrix[2][1] = 1 	matrix[2][2] = 3 	matrix[2][3] = 1 	
matrix[3][0] = 1 	matrix[3][1] = 1 	matrix[3][2] = 1 	matrix[3][3] = 4 
```

* 长度计算

  ```c
  # define ROW  4
  # define COL  5
  
  // 二维数组
      int matrix[ROW][COL] = {
              {1, 1, 1, 1, 0},
              {1, 2, 1, 1, 0},
              {1, 1, 3, 1, 0},
              {1, 1, 1, 4, 0},
      };
      for (int i = 0; i < ROW; i++) {
          printf("\n");
          for (int j = 0; j < COL; j++) {
              printf("matrix[%d][%d] = %d \t", i, j, matrix[i][j]);
          }
      }
      for (int i = 0; i < 4; i++) {
          printf("\n");
          for (int j = 0; j < 4; j++) {
              printf("matrix[%d][%d] = %p \t", i, j, &matrix[i][j]);
          }
      }
      printf("\nsize of matrix = %lu", sizeof matrix);
      printf("\nsize of matrix col = %lu", sizeof matrix[0] / sizeof matrix[0][0]);
      printf("\nsize of matrix row = %lu", sizeof matrix / sizeof matrix[0]);
  
  // 输出
  matrix[0][0] = 1 	matrix[0][1] = 1 	matrix[0][2] = 1 	matrix[0][3] = 1 	matrix[0][4] = 0 	
  matrix[1][0] = 1 	matrix[1][1] = 2 	matrix[1][2] = 1 	matrix[1][3] = 1 	matrix[1][4] = 0 	
  matrix[2][0] = 1 	matrix[2][1] = 1 	matrix[2][2] = 3 	matrix[2][3] = 1 	matrix[2][4] = 0 	
  matrix[3][0] = 1 	matrix[3][1] = 1 	matrix[3][2] = 1 	matrix[3][3] = 4 	matrix[3][4] = 0 	
  matrix[0][0] = 0x7ff7be565e70 	matrix[0][1] = 0x7ff7be565e74 	matrix[0][2] = 0x7ff7be565e78 	matrix[0][3] = 0x7ff7be565e7c 	
  matrix[1][0] = 0x7ff7be565e84 	matrix[1][1] = 0x7ff7be565e88 	matrix[1][2] = 0x7ff7be565e8c 	matrix[1][3] = 0x7ff7be565e90 	
  matrix[2][0] = 0x7ff7be565e98 	matrix[2][1] = 0x7ff7be565e9c 	matrix[2][2] = 0x7ff7be565ea0 	matrix[2][3] = 0x7ff7be565ea4 	
  matrix[3][0] = 0x7ff7be565eac 	matrix[3][1] = 0x7ff7be565eb0 	matrix[3][2] = 0x7ff7be565eb4 	matrix[3][3] = 0x7ff7be565eb8 	
  size of matrix = 80 （bytes）
  size of matrix col = 5
  size of matrix row = 4
  ```

  

### 数组长度计算

1. 声明的一个范围内可以直接计算（`sizeof array / sizeof *array`）
2. 作为参数传递之后无法这样计算，需要将数组长度作为参数进行传递；因为传递给函数的数组只是一个指向数组的指针。

```c
int sum_of_array(const int array[], int length);
//int sum_of_array(const int * array, int length);

int main() {
    printf("array demo - 函数，数组和指针\n");
    int array[5] = {1, 2, 3, 4, 5};
    int size = (sizeof array / sizeof *array);
    printf("array size is : %10d\n", size);
    printf("sum of array = %10d", sum_of_array(array, size));
    return 0;
}

int sum_of_array(const int *array, int length) {
    int sum = 0;
    // 🙅 错误，无法计算长度，需要通过参数传递，编译时也会发出警告⚠️
    int size = (sizeof array / sizeof *array);
    printf("array size is : %10d\n", size);// 输出错误的长度
    for (int i = 0; i < length; ++i) {
        sum += array[i];
    }
    return sum;
}
```

### 函数中遍历数组

将数组作为参数传递给函数进行遍历：

1. 传递开始指针和长度；
2. 传递开始指针和结束指针；

```c
int sum_of_array( int *start, int * end);
int sum_of_array( int *start, int length);
```



### 使用const保护数组中的数据

* 传递给函数作为参数时，可以使用const来声明数组，保护数组中的数据不被修改；（表示该函数不会使用指针改变数据）

* 把const数据或非const数据的地址初始化为指向const的指针或为其赋值是合法的；

* 只能把非const数据的地址赋给普通指针；

  ```c
  int *bptr = array;
  printf("指针bptr指向地址：    %p\n", bptr);
  int array2[2] = {1, 2};
  bptr = array2;
  printf("指针bptr指向地址：    %p\n", bptr);
  *bptr = 6;
  printf("bptr[0]：    %d\n", bptr[0]);
  
  const int *bptr = array;
  // 编译器报错
  // *bptr = 6;
  即不能用该指针来修改值
  ```

* 初始化指针时，**可以有两个const**

  ```c
      const int* const bptr = array;
      printf("指针bptr指向地址：    %p\n", bptr);
      int array2[2] = {1, 2};
  	 // 下面的编译是报错的
      bptr = array2;
  ```

  * 第一个const表示指针不能修改其所指向地址的变量的内容
  * 第二个const表示，指针不能指向别的地址，只能指向初始化时指定的地址；
  * 注意：`const` 在 `int*` 后面





## 存储类别、链接和内存管理

### 主要内容

* **关键字：`auto`，`extern`，`static`，`register`，`const`，`volatile`，`restricted`**
* **函数：`rand`,`srand`,`time`,`malloc`,`calloc`,`free`**
* **如何确定变量的作用域-可见范围 和 生命期-存在多久；**
* **设计更复杂的程序；**





在内存中存储数据的类别；

* 对象：被存储的每个值都占用一块内存，这样的一块内存称为对象；
* 标识符：程序需要通过一种方法访对象，可以通过声明变量来完成。标识符是C语言指定硬件内存中对象的方式；
  * 变量名
  * (表达式)指针声明
* 左值：指定对象的表达式
  * 可修改的左值：可以使用左值改变对象中的值
* 作用域
* 链接
* 存储期

作用域和链接描述标识符的可见性，存储期描述对象的生存期；

### 作用域

* **描述程序中可访问标识符的区域**；
  * **块作用域**；`{}`,也包括 for if 等语句
  * **函数作用域**: 用于goto语句的标签；一个标签首次出现在函数的内层块中，他的作用域也延伸至整个函数。
  * **函数原型作用域**；用于函数原型中的形参名，范围是形式参数定义到原型声明结束；
  * **文件作用域**；范围：定义处到文件末尾。

### 链接

三种类型：

* **内部链接**：只能在一个翻译单元中使用（一个源代码文件及其所包含的头文件）
* **外部链接**：可以在多文件程序中使用
* **无链接**: 块作用域，函数作用域，函数原型作用域的变量都是无链接变量。

```c
int gat = 5; // 文件作用域，外部链接
static int dog = 3; // 文件作用域，内部链接 static为存储类别说明符

该文件同一程序的其他文件都可以使用gat变量，变量dog属于文件私有，该文件中的任意函数都可以使用它。
```

**示例：**

```c
// a.c
int gog = 1234;
static int dog = 3;

int print_gog();

int main() {
    print_gog();
    return 0;
}

// b.c
#include <stdio.h>
// extern int gog; 需要使用 extern 声明在其他源文件中声明的外部变量，不过测试不使用也可以读取到
int gog;
int dog;

int print_gog() {
    printf("\n gog= %d,dog=%d", gog, dog);
    return 0;
}

// output
gog= 1234,dog=0
```



### 存储期

四种存储期：

1. 静态存储期： 程序执行期间一直都存在
   * 所有的文件作用域变量具有静态存储期
2. 线程存储期：并发编程，从被声明到线程结束以关键字`_Thread_local`声明一个对象时，每个 线程都获得该变量的私有备份。
3. 自动存储期：程序**进入定义这些变量的块（不是从声明开始哦）**时，为这些变量自动分配内存；当退出这个块时，释放刚才为变量分配的内存。
   * 块作用域变量一般都有自动存储期，不过使用static可以使块作用域变量具有静态存储期
4. 动态分配存储期；



### 存储类别

* 自动
* 寄存器
* 静态作用域
* 静态外部链接
* 静态内部链接

| 存储类别     | 存储期 | 作用域 | 链接 | 声明方式                     |
| ------------ | ------ | ------ | ---- | ---------------------------- |
| 自动         | 自动   | 块     | 无   | 块内                         |
| 寄存器       | 自动   | 块     | 无   | 块内，使用关键字register     |
| 静态外部链接 | 静态   | 文件   | 外部 | 所有函数外                   |
| 静态内部链接 | 静态   | 文件   | 内部 | 所有函数外，使用关键字static |
| 静态无链接   | 静态   | 块     | 无   | 块内，使用关键字static       |



### 自动变量

* C中可使用 auto 修饰
* 自动变量不会自动初始化，除非显式初始化；

### 寄存器变量

* 变量通常存储在计算机内存中，寄存器变量存储在CPU的寄存器中（最快的可用内存中）
* 无法获得寄存器变量的地址；
* 其他地方与自动变量一致
* register 的声明只是一种请求，不一定能被响应。
* 类型会收到限制，如寄存器没有足够大的空间来存储double类型。



### 块作用域的静态变量

* <span style="color:red;">静态变量指的是该变量在内存中原地不动，但是其值时可以变化的</span>

* 程序离开块之后，这些变量不会消失。**多次函数调用之间会记录他们的值**。
* 不能在函数的形参中使用 static 

```c
#include <stdio.h>

void static_var();

int main() {
    for (int i = 0; i < 2; i++) {
        static_var();
    }
    return 0;
}

void static_var() {
   // 第二次调用时不会再初始化赋值，而是使用了之前的 
    static int count = 1;
    int cc = 1;
    count++;
    cc++;
    printf("call me %d times, cc=%d\n", count, cc);
}


// output
call me 2 times, cc=2
call me 3 times, cc=2
```



### 外部链接的静态变量

* 创建：把变量的定义性声明放在所有函数的外面
* 使用：
  * 外部文件的所有函数外面：直接再次声明，或者加上extern 进行声明
  * 函数中，必须使用extern进行声明
* 初始化：
  * 如果不初始化，会被自动初始化为0；

```c
#include <stdio.h>
// int gog;
int dog;

int print_gog() {
  // 函数中必须使用 extern 声明，否则会创建自动变量
    extern int gog;
    printf("\ngog= %d,dog=%d", gog, dog);
    return 0;
}
```



### 变量声明与定义

* 定义式声明
* 引用式声明：指示编译器







## 字符串

### 初始化

#### 指针形式和数组形式

* 指针形式使得编译器为字符串在静态存储区预留指定大小的元素空间，一旦开始执行程序，他会为指针变量留出一个存储位置，并把字符串的地址存储在指针变量中。
* 初始化数组把静态存储区的字符串拷贝到数组中，而初始化指针只把字符串的地址拷贝给指针。
