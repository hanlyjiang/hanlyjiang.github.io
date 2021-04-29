## FFmpeg简介

用于处理音频，视频，字幕及相关元数据的一个库和工具的集合；

包含内容：

### 库

* `libavcodec`: 音视频编码解码的实现
* `libavformat`: 实现了流协议，容器格式及基础的I/O访问（音视频容器格式的封装和解析）
* `libavutil`: 提供hasher，decompressors和杂项工具函数
* `libavfilter`:  （提供通过滤镜链条修改解码音频和视频的方法）音视频滤镜库 如视频加水印、音频变声
* `libavdevice`: 捕获和播放设备的抽象访问接口（输入输出设备库，提供设备数据的输入与输出）
* `libswresample`: 音频混音和重新取样的实现
* `libswscale`:  颜色转换和缩放的接口

### 工具

* [ffmpeg](https://ffmpeg.org/ffmpeg.html)：一个用于操作，转换，流化多媒体内容的命令行工具 
* [ffplay](https://ffmpeg.org/ffplay.html)：极简的多媒体播放器
* [ffprobe](https://ffmpeg.org/ffplay.html)： 用来检视多媒体内容的简单的分析工具
* 其他工具： aviocat，ismindex，qt-faststart



## ffmpeg-android-maker介绍

### 介绍

仓库提供了下载FFmpeg源码并将其编译为Android可用的库的脚本。

编译后会生成：

1. so库
2. 头文件
3. ffmpeg 和 ffprobe 的可执行文件，可以直接在android的终端中使用。

### 编译

获取编译脚本

```shell
 git clone git@github.com:Javernaut/ffmpeg-android-maker.git
```

编译镜像：

```shell
cd ffmpeg-android-maker
docker build -t hanlyjiang/ffmpeg-builder -f tools/docker/Dockerfile ./
```

