+++

date = '2025-11-16T09:32:13+08:00'
draft = false
title = 'GLiNet-MT3000配置'
categories = ["蜻蜓点水"]
tags = ["OpenWRT", "教程","MT3000"]
series = ["WRT系列"]

+++

# 前言

最近入手了 MT3000，使用过后发现是当前最省心的🧙‍♀️路由器了；故此记录下相关的配置过程；

主要分为两个部分：

1. 基础配置部分，包括改区，中继上网配置等操作；
2. 🧙‍♀️上网配置部分；

# 基础配置

## 系统升级



到手后内置系统是 4.7.13 版本，可先升级到最新版本 4.8.1 ：



<img src="./pics/image-20251116104528933.png" alt="image-20251116104528933" style="zoom:50%;" />

升级系统后：

<img src="./pics/image-20251116103205645.png" alt="image-20251116103205645" style="zoom:50%;" />





## 换区

国内买的默认是国区，部分功能用不了，所以需要换区成US，按如下方式进行换区处理：

先通过命令查看 /dev/mtdblock3 ，可以看到其中有 CN 的字符：



```SHELL
root@GL-MT3000:~# cat /dev/mtdblock3
□y□□□z □□□□z □zra209c0fe807b2d847b4cfe306bf2c496d32a8MCZQDR99YWfirsttestsecondtestGL-250725902794□CN[HL(□□□□□□□□□□□
                                                                                                                   □""""3333333333333333333333333333%%))%%%%%%%%%%%%%%%((((($$$$""""$$$$""""$$$$""""$$$$""""□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□          □□□□□□□□□□              □□□□□□□□□□              □□□□□□□□□□              □□7777777777777777777777777777"□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□ŇIRVUUUUJRQQQQQJSUVVVVIPNQQQQIQPTTTTIPQQQQQIRQPPPPIRQQQQQIRQTTTTIQPTTTTISRQQQQISSRRRRIQPPPPPIQRTTTTIRQSSSS□□□□□□□□□□□□□□Â□□□□□□□□□□□ā□□□□□□□□□□□□@□□□□□□□@□@□@□□□@□□□□□□□@□@□□□□□□□@□@□□□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□@□root@GL-MT3000:~#

```



替换区域字段：

```SHELL
echo "US" | dd of=/dev/mtdblock3 bs=1 seek=136
sync


输入如下：
root@GL-MT3000:~# echo "US" | dd of=/dev/mtdblock3 bs=1 seek=136
3+0 records in
3+0 records out
root@GL-MT3000:~# sync

```



重启后就不是CN 了。

## 改语言

换区之后，改成英文就可以出现ADGuardHome 插件了，但是切换成就又没有了。

所以通过如下方式将繁体中文的语言改成简体中文的，然后再将语言替换成繁体中文就可以了；



```SHELL
cd /www/i18n && \
for f in *zh-tw*; do mv "$f" "${f//zh-tw/zh-bak}"; done && \
for f in *zh-cn*; do cp "$f" "${f//zh-cn/zh-tw}"; done

```





# 网络配置

网络配置包含两个部分：

1. 带 Scramble 的插件安装
2. 连接末法网络
3. 配置策略规则

## Scramble 插件安装

自带的open 虚拟专用网络插件是不带 Scramble 的，所以需要安装成带 Scrameble 的版本，可通过 LuCI 软件包管理界面进行覆盖安装即可；

> 注意：此版本需要自行编译 ipk 插件

<img src="./pics/image-20251116203929147.png" alt="image-20251116203929147" style="zoom:50%;" />

通过 `系统-高级设置` 即可进入 luCI 中手动安装 ipk 软件包，安装过程不再赘述；编译插件的过程此处也略去；

## 连接魔法网络



GLiNet 的魔法网络配置还是挺方便的，将相关配置及证书文件等打包成一个 压缩包上传即可添加，具体配置过程不再赘述；

添加成功之后就可以连接了；

## 配置策略规则



连接魔法网络之后，需要能根据国内和国外域名来区分走的路径，GLiNet 也有相关配置支持，直接导入对应的地址列表即可；



<img src="./pics/image-20251116204446425-1763297089063-7.png" alt="image-20251116204446425" style="zoom:50%;" />

地址来源于：[chnroute/CN.rsc at master · ruijzhan/chnroute · GitHub](https://github.com/ruijzhan/chnroute/blob/master/CN.rsc)

通过文本替换提取的方式，提取出符合格式的IP列表即可；



## DNS 配置

配置完之后，域名解析还是有问题，需要切换DNS服务器，直接在 GLiNet 的配置中选择 google 的DNS 即可：

![image-20251116205826086](./pics/image-20251116205826086-1763297907980-10.png)

# 更多参考：

-  https://raw.githubusercontent.com/ruijzhan/chnroute/refs/heads/master/gfwlist.txt
-  https://github.com/ruijzhan/chnroute?tab=readme-ov-file



