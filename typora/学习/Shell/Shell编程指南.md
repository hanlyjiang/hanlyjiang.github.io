# Shell编程指南

## for循环

### 语法说明

有两种风格的：

* for in

  ```shell
  for var in list do
  	commands
  done
  ```

  

* c风格：

  ```shell
  for (i = 0; i < 10; i++)
  {
  	printf("The next number is %d\n", i);
  }
  ```

  

### 数组循环

```shell
module_list=(1 2 3 "string")
for module in ${module_list[@]};do
	echo Module:$module
done
```

输出：

```shell
Module:1
Module:2
Module:3
Module:string
```

### 从命令中读取值

遍历当前目录下的文件

```shell
# 换行
for module in $(ls -1);do
	echo Module:$module
done

# 不换行
for module in $(ls);do
	echo Module:$module
done
```

### 遍历文件列表

需要使用通配符，如下所示：

```shell
# 当前目录
for file in $PWD/* ; do 
	echo "file is : $file" 
done

# 二级目录
for file in $PWD/* ; do 
	echo "file is : $file" 
done

# 指定文件类型(通过**匹配所有层级的目录)
for file in $PWD/**/*.java ; do 
	echo "file is : $file" 
done
```





## 重定向

Linux的标准文件描述符

| 文件描述符 | 缩写   | 描述     |
| ---------- | ------ | -------- |
| 0          | STDIN  | 标准输入 |
| 1          | STDOUT | 标准输出 |
| 2          | STDERR | 标准错误 |

### 重定向错误

```shell
ls -al badfile 2> test4
```

### 重定向错误和输出

重定向到不同的文件

```shell
ls -al test test2 test3 badtest 2> test6 1> test7
```

重定向到一个文件：可以将STDERR和STDOUT的输出重定向到同一个输出文件。为此bash shell 提供了特殊的重定向符号 `&>`。

```shell
$ ls -al test test2 test3 badtest &> test7
```

> 当使用&>符时，命令生成的所有输出都会发送到同一位置，包括数据和错误。你会注意到其 中一条错误消息出现的位置和预想中的不一样。badtest文件(列出的最后一个文件)的这条错误 消息出现在输出文件中的第二行。为了避免错误信息散落在输出文件中，相较于标准输出，**bash在脚本中重定向输出 shell自动赋予了错误消息更高的优先级。这样你能够集中浏览错误信息了**。



### 脚本中重定向

分为两种：

1. 临时重定向，使用上面的命令即可；
2. 永久重定向，适合大量内容需要重定向时；

#### 永久重定向

`exec 1>testout` ： exec命令会启动一个新shell并将STDOUT文件描述符重定向到文件。脚本中发给STDOUT的所 有输出会被重定向到文件

* 重定向输入：	`exec 0< testfile`
* 重定向输出：    `exec 1>testout`
* 重定错误：      `exec 2>testerror`

```shell
$ cat test10

#!/bin/bash
# redirecting all output to a file
exec 1>testout
echo "This is a test of redirecting all output"
echo "from a script to another file."
echo "without having to redirect every individual line"
$ ./test10
$ cat testout
This is a test of redirecting all output
from a script to another file.
without having to redirect every individual line
```

> 一旦重定向了STDOUT或STDERR，就很难再将它们重定向回原来的位置。如果你需要在重定 向中来回切换的话，就比较麻烦；





## 常用变量

### 参数

* 参数个数： `$#`

* 所有参数 `$*`/ `$@`： 

  ```
  function log() {
      echo "OOO -->参数个数：$# ,参数：$*"
  }
  
  log 11 22 33 
  
  function log() {
     echo "OOO -->参数个数：$# ,参数： $@" 
  }
  log 11 22 33 
  ```

### 函数中的变量/参数

* 局部变量 ： `local temp`

  ```shell
  local temp=$[ $value + 5 ]
  ```

* 数组作为函数参数：通过 `newarray=($(echo "$@"))` 来取出参数中的数组并保存到变量

  ```shell
  function testit {
         local newarray
         newarray=(;'echo "$@"')
         echo "The new array value is: ${newarray[*]}"
  }
  ```

  



## 算数运算

```shell
echo $[ 2 + 4 ]
6
echo $[ 2 * 4 ]
8
echo $[ 2 / 4 ]
0
echo $[ 2 - 4 ]
-2 
```





## 数组

[Unix / Linux - Using Shell Arrays - Tutorialspoint](https://www.tutorialspoint.com/unix/unix-using-arrays.htm)

### 定义数组

#### 索引赋值

```shell
NAME[0]="Zara"
NAME[1]="Qadir"
NAME[2]="Mahnaz"
NAME[3]="Ayan"
NAME[4]="Daisy"
echo $NAME
```

> 注意：zsh的下标从1开始

#### 初始化赋值

```shell
$ array=(1 2 3 "test")
$ echo ${array[@]}
1 2 3 test
```

### 访问数组

通过如下语法来访问

```shell
${array_name[index]}
```

示例如下：

```shell
#!/bin/sh

NAME[0]="Zara"
NAME[1]="Qadir"
NAME[2]="Mahnaz"
NAME[3]="Ayan"
NAME[4]="Daisy"
echo "First Index: ${NAME[1]}"
echo "Second Index: ${NAME[2]}"

# 输出如下：
First Index: Qadir
Second Index: Mahnaz
```

> 在zsh中，可以直接使用数组变量名称来访问数组所有元素，但是bash中不行，bash中数组变量名访问的是第一个元素

### 遍历数组

以下在zsh中可以使用，但是在bash中只能显示出第一个元素：

```shell
for n in $NAME; do
echo $n
done
# 输出如下
Qadir
Mahnaz
Ayan
Daisy
```

想要通用，需要按如下写法：(`${NAME[*]}`可以换成`${NAME[@]}`)

```shell
for n in ${NAME[*]}; do
echo $n
done
# 输出如下
Qadir
Mahnaz
Ayan
Daisy
```

### 其他命令的输出作为数组

```shell
$ file_list=( $(ls -1) )
$ echo ${file_list[*]}
GeoArk flink-1.11.3 flink-1.11.3-bin-scala_2.11.tgz flink-conf.yaml flinkx-test git-2.27.0 ios-sdk-examples moa-initial-helper mobile-center-deploy test.sh 
```

> 上述写法有时候会有问题，可参考： [SC2207 · koalaman/shellcheck Wiki (github.com)](https://github.com/koalaman/shellcheck/wiki/SC2207)

### 通用建议

* 索引赋值时，从1开始，以兼容zsh
* 遍历时使用 for in `${NAME[*]}`或`${NAME[@]}`



# 调试shell脚本

[How to Debug Bash Scripts - LinuxConfig.org](https://linuxconfig.org/how-to-debug-bash-scripts)

1. 传统技术；
2. xtrace选项；
3. 其他Bash选项；
4. trap



> The most effective debugging tool is still careful thought, coupled with judiciously placed print statements. - **Brian Kernighan, "Unix for Beginners" (1979)**



## 使用传统技术

* 语法高亮
* 调试器

## 使用Bash xtrace选项

通过 bash -x 来 启用xtrace：

* 显示解释后的待执行语句；

* `-v` : 显示评估（evaluate）之前的语句内容；(几乎就是把脚本输出)
* `-x` : 解释之后实际执行的脚本内容
* `-n`: 解释脚本，但是不执行，可用于检查语法错误
* `-e`: 出错时结束程序

* -v 和 -x 可以结合使用，用于对比

有如下脚本：

```shell
#!/bin/bash

name="TTTT"
echo "Name is $name"
```

使用 bash 直接执行：

```shell
$ bash test.sh
Name is TTTT
```

`bash -x test.sh`: （输出脚本解释后的实际语句，同时也执行了脚本）

```shell
$ bash -x test.sh
+ name=TTTT
+ echo 'Name is TTTT'
Name is TTTT
```

`bash -v test.sh`: (输出脚本内容，同时也执行了脚本)

```shell
$ bash -v test.sh
#!/bin/bash

name="TTTT"
echo "Name is $name"
Name is TTTT
```

`bash -xv test.sh `:  （结合两者）

```shell
bash -xv test.sh
#!/bin/bash

name="TTTT"
+ name=TTTT
echo "Name is $name"
+ echo 'Name is TTTT'
Name is TTTT
```

## 如何使用其他选项

### 查看debug开关状态

debug的设置，通过set命令开启之后，就默认时开启状态，可以通过 `$-`来查看



### 脚本中设置开关

```shell
#!/bin/bash

read -p "Path to be added: " $path

set -xv
if [ "$path" = "/home/mike/bin" ]; then
	echo $path >> $PATH
	echo "new path: $PATH"
else
	echo "did not modify PATH"
fi
set +xv
```



## set命令说明

参数    说明
-a    标示已修改的变量，以供输出至环境变量
-b    使被中止的后台程序立刻回报执行状态
-d    Shell预设会用杂凑表记忆使用过的指令，以加速指令的执行。使用-d参数可取消
-e    若指令传回值不等于0，则立即退出shell
-f    取消使用通配符
-h    自动记录函数的所在位置
-k    指令所给的参数都会被视为此指令的环境变量
-l    记录for循环的变量名称
-m    使用监视模式
-n    测试模式，只读取指令，而不实际执行
-p    启动优先顺序模式
-P    启动-P参数后，执行指令时，会以实际的文件或目录来取代符号连接
-t    执行完随后的指令，即退出shell
-u    当执行时使用到未定义过的变量，则显示错误信息
-v    显示shell所读取的输入值
-H shell    可利用”!”加<指令编号>的方式来执行 history 中记录的指令
-x    执行指令后，会先显示该指令及所下的参数
+<参数>    取消某个set曾启动的参数。与-<参数>相反
-o option    特殊属性有很多，大部分与上面的可选参数功能相同，这里就不列了


> 版权声明：本文为CSDN博主「zhang-la--la」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
> 原文链接：https://blog.csdn.net/zhangna20151015/article/details/103713822







