# shell 通配符，`或$(),$(()),转义字符\,单双引号

# 

[舌耳](https://blog.csdn.net/weixin_38280090/article/details/81807875) 

## 通配符 *  ?  []

*                      用来匹配0个或多个任意字符

?                     用来匹配一个任意字符

[数个字符]      匹配方括号中的任意一个字符出现一次

[root@localhost ~]# ls /dev/ttyS*
/dev/ttyS0  /dev/ttyS1  /dev/ttyS2  /dev/ttyS3

[root@localhost ~]# ls 0?.doc
01.doc

[root@localhost ~]# ls 0[123].doc
01.doc

[root@localhost ~]# ls [0-9][0-9].doc
01.doc  

 

 


注意，Globbing所匹配的文件名是由Shell展开的，也就是说在参数还没传给程序之前已经展开了，比如上述ls ch0[012].doc命令，如果当前目录下有ch00.doc和ch02.doc，则传给ls命令的参数实际上是这两个文件名，而不是一个匹配字符串。 

## 命令代换：`或$()

由'`'反引号括起来的也是一条命令，Shell先执行该命令，然后将输出结果立刻代换到当前命令行中。例如定义一个变量存放date命令的输出：

[root@localhost ~]# DATE=`date`
[root@localhost ~]# echo $DATE
Fri Aug 17 22:56:11 PDT 2018

[root@localhost ~]# DATE=$(date)
[root@localhost ~]# echo $DATE
Fri Aug 17 22:57:03 PDT 2018

## 算数代换：`$(())与$[]`

用于算术计算，$(())中的Shell变量取值将转换成整数，同样含义的$[]等价例如：

[root@localhost ~]# var=45
[root@localhost ~]# echo $(($var+2))
47

$(())中只能用+-*/和()运算符，并且只能做整数运算。$[]一样。
[base#n],其中base表示进制,n按照base进制解释，后面再有运算数，按十进制解释。
[root@localhost ~]# echo $[2#10+11]
13

[root@localhost ~]# echo $[$var#10+11]
56

## 转义字符\

和C语言类似，\在Shell中被用作转义字符，用于去除紧跟其后的单个字符的特殊意义（回车除外），换句话说，紧跟其后的字符取字面值。例如：

[root@localhost ~]# echo $SHELL
/bin/bash
[root@localhost ~]# echo \$SHELL
$SHELL
[root@localhost ~]# echo \\
\

[root@localhost ~]# touch $\ $                #创建一个$ $为文件名的

## 单引号

和C语言不一样，Shell脚本中的单引号和双引号一样都是字符串的界定符（双引号下一节介绍），而不是字符的界定符。单引号用于保持引号内所有字符的字面值，即使引号内的\和回车也不例外，但是字符串中不能出现单引号。如果引号没有配对就输入回车，Shell会给出续行提示符，要求用户把引号配上对。例如：

[root@localhost ~]# echo 'ABC
> '
> ABC

## 双引号

被双引号用括住的内容，将被视为单一字串。它防止通配符扩展，但允许变量扩展。这点与单引号的处理方式不同

[root@localhost ~]# DATE=$(date)
[root@localhost ~]# echo "$DATE"
Fri Aug 17 22:57:03 PDT 2018
[root@localhost ~]# echo '$DATE'
$DATE

————————————————
版权声明：本文为CSDN博主「舌耳」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/weixin_38280090/article/details/81807875