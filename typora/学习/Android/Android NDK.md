# Android NDK 

## 参考&资料

* https://github.com/android/ndk-samples



## Android NDK 编译

使用NDK编译有以下几种方式：

1. **ndk-build**
2. **cmake**
3. **将 NDK 与其他构建系统配合使用：使用NDK构建使用其他构建系统构建的代码。**
4. **将NDK作为独立的工具链进行构建**

> 详细可参考官方文档：
>
> * [构建您的项目  | Android NDK  | Android Developers (google.cn)](https://developer.android.google.cn/ndk/guides/build?hl=zh-cn)
>
> * [将 NDK 与其他构建系统配合使用  | Android NDK  | Android Developers (google.cn)](https://developer.android.google.cn/ndk/guides/other_build_systems?hl=zh-cn)）



其中：

* ndk-build使用ndk内部提供的一个ndk-build的脚本进行构建，需要编写Android.mk及Application.mk等配置进行构建；
* cmake方式需要编写CMakeLists 配置，然后使用cmake 或者使用gradle执行cmake任务；
* 与其他构建系统配合使用时则需要结合具体的情况进行一些构建选项及变量的配置。
* 独立工具链的方式已经弃用。

### 与其他构建系统配合使用

#### ndk clang手动构建android可用的so库

以下介绍最简单的情况下如何构建一个android可用的so库。

* `get.h`

  ```c
  #include<stdio.h>
  int get();
  ```

* `get.c`

  ```c
  #include "get.h"

  int get(){
      return 888;
  }
  ```

* 编译

  ```shell
  export ANDROID_SDK=/Users/hanlyjiang/Library/Android/sdk
  export NDK_VERSION=21.1.6352462
  export NDK=$ANDROID_SDK/ndk/$NDK_VERSION
  
  # 设置主机标识
  HOST_TAG=darwin-x86_64
  # 配置编译的so 对应的 ABI
  ABI=aarch64-linux-android
  # 配置最小支持的SDK版本
  minSdkVersion=24
  #  
  CC=$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/clang
  READELF=$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$ABI-readelf
  
  $CC -target $ABI$minSdkVersion -Wl,-soname,libget.so -fPIC -shared get.c -o libget.so
  ```
  
  * **`-Wl,-soname,libget.so`的说明：**
  
    `-Wl,-soname,libget.so `必须添加，用于传递选项给链接器。如果链接时没有添加soname，则在android cpp代码中，引用此so库文件时，在API 23及以上版本上可能会出现找不到so库的问题，具体可参考：https://android-developers.googleblog.com/2016/06/android-changes-for-ndk-developers.html 中 ”*Invalid DT_NEEDED Entries (Enforced since API 23)*“ 及 “*Missing SONAME (Used since API 23)*” 两小节。
  
  可通过 `readelf` 命令来确认so 中是否有对应的SONAME信息：
  
    ```shell
    # 查看soname是否存在
    $READELF -d libget.so | grep SONAME
    ```
* 主机标记

	| NDK 操作系统变体 | 主机标记         |
  | :--------------- | :--------------- |
  | macOS            | `darwin-x86_64`  |
  | Linux            | `linux-x86_64`   |
  | 32 位 Windows    | `windows`        |
  | 64 位 Windows    | `windows-x86_64` |

* ABI

  | ABI         | 三元组                     |
  | :---------- | :------------------------- |
  | armeabi-v7a | `armv7a-linux-androideabi` |
  | arm64-v8a   | `aarch64-linux-android`    |
  | x86         | `i686-linux-android`       |
  | x86-64      | `x86_64-linux-android`     |

### CMake 构建

#### 文件结构

```shell
- get.c
- get.h
- CMakeLists.txt
- build
```



* CMakeLists.txt
  ```cmake
  cmake_minimum_required(VERSION 3.10)
  
  project(get C)
  
  add_library(get MODULE get.c)
  ```
  
* get.h

  ```c
  #include<stdio.h>
  int get();
  ```

* get.c

  ```c
  #include "get.h"
  
  int get(){
      return 888;
  }
  ```

#### CMake 初始化

```shell
export ANDROID_SDK=$USER_HOME/Library/Android/sdk
export NDK_VERSION=21.1.6352462
export NDK=$ANDROID_SDK/ndk/$NDK_VERSION

export CMAKE_HOME=/Users/hanlyjiang/Library/Android/sdk/cmake/3.10.2.4988404
export PATH=$CMAKE_HOME/bin:$PATH

# 设置主机标识whi
HOST_TAG=darwin-x86_64
# 配置编译的so 对应的 ABI
ABI=arm64-v8a
ANDROID_ABI=aarch64-linux-android
# 配置最小支持的SDK版本
minSdkVersion=24

# 初始化
mkdir build;cd build;
cmake .. -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
    -GNinja \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_NATIVE_API_LEVEL=$minSdkVersion \
    -DANDROID_NDK=$NDK \
    -DCMAKE_MAKE_PROGRAM=$CMAKE_HOME/bin/ninja \
    -DCMAKE_LINKER=$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin/$ANDROID_ABI-ld \
    -DCMAKE_MODULE_LINKER_FLAGS=-Wl,-soname,libget.so \
    -DANDROID_NATIVE_API_LEVEL=24 \
    -DANDROID_TOOLCHAIN=clang
```

> **注意：**
>
> 在官方文档（[CMake  | Android NDK  | Android Developers (google.cn)](https://developer.android.google.cn/ndk/guides/cmake?hl=zh-cn#command-line)）中，指定给[cmake的Generator](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html#ninja-generators)是`Android Gradle - Ninja`,而我们通过cmake help 查看可以使用的Generator的列表中并没有这个选项。所以我们选择 Ninja。

#### 构建

```shell
# 进入源码目录
cd ../
# 构建
cmake --build ./build 
```

生成的so文件位于build目录

# 错误解决

## 引入预构建so库：`java.lang.UnsatisfiedLinkError: dlopen failed` 主机路径

* [配置 CMake  | Android 开发者  | Android Developers (google.cn)](https://developer.android.google.cn/studio/projects/configure-cmake?hl=zh-cn#add-other-library)
* [Android Studio带C++项目提示More than one file was found with OS independent path问题修正 – K-Res的Blog](https://blog.k-res.net/archives/2592.html)
* [Android Developers Blog: Android changes for NDK developers (googleblog.com)](https://android-developers.googleblog.com/2016/06/android-changes-for-ndk-developers.html) ：`Invalid DT_NEEDED Entries (Enforced since API 23)`
* [dlopen failed, tries to open PC file, not Android file · Issue #669 · android/ndk-samples (github.com)](https://github.com/android/ndk-samples/issues/669)
* [hello-libs dlopen error · Issue #364 · android/ndk-samples (github.com)](https://github.com/android/ndk-samples/issues/364)

### 错误信息

```shell
java.lang.UnsatisfiedLinkError: dlopen failed: library "/Users/hanlyjiang/Downloads/example/app/src/main/cpp/../../../../libs/x86_64/libget.so" not found
```

### 原因：缺少SONAME

so库DT_NEEDED字段是可以指向绝对路径的， API 23 之前会忽略绝对路径，只使用basename-也就是文件名。但是23之后必须要匹配SONAME。

```shell
$ANDROID_SDK_ROOT/ndk/21.1.6352462/toolchains/llvm/prebuilt/darwin-x86_64/x86_64-linux-android/bin/readelf -d ./app/build/intermediates/merged_native_libs/debug/out/lib/x86_64/libnative-lib.so

Dynamic section at offset 0x2d18 contains 30 entries:
  Tag        Type                         Name/Value
 0x0000000000000003 (PLTGOT)             0x3f48
 0x0000000000000002 (PLTRELSZ)           480 (bytes)
 0x0000000000000017 (JMPREL)             0xc00
 0x0000000000000014 (PLTREL)             RELA
 0x0000000000000007 (RELA)               0xbb8
 0x0000000000000008 (RELASZ)             72 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000006ffffff9 (RELACOUNT)          3
 0x0000000000000006 (SYMTAB)             0x2c0
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000005 (STRTAB)             0x560
 0x000000000000000a (STRSZ)              1126 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x9c8
 0x0000000000000004 (HASH)               0xa88
 0x0000000000000001 (NEEDED)             Shared library: [liblog.so]
 0x0000000000000001 (NEEDED)             Shared library: [/Users/hanlyjiang/Downloads/example/app/src/main/cpp/../../../../libs/x86_64/libget.so]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so]
 0x0000000000000001 (NEEDED)             Shared library: [libdl.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so]
 0x000000000000000e (SONAME)             Library soname: [libnative-lib.so]
 0x000000000000001a (FINI_ARRAY)         0x3d08
 0x000000000000001c (FINI_ARRAYSZ)       16 (bytes)
 0x000000000000001e (FLAGS)              BIND_NOW
 0x000000006ffffffb (FLAGS_1)            Flags: NOW
 0x000000006ffffff0 (VERSYM)             0xb44
 0x000000006ffffffc (VERDEF)             0xb7c
 0x000000006ffffffd (VERDEFNUM)          1
 0x000000006ffffffe (VERNEED)            0xb98
 0x000000006fffffff (VERNEEDNUM)         1
 0x0000000000000000 (NULL)               0x0
```

查看依赖的so库，发现其中缺失 SO_NAME 字段：（使用ndkr17 构建）

```shell
ndk//21.1.6352462/toolchains/llvm/prebuilt/darwin-x86_64/x86_64-linux-android/bin/readelf -d ./app/build/intermediates/merged_native_libs/debug/out/lib/x86_64/libget.so

Dynamic section at offset 0x2e90 contains 17 entries:
  Tag        Type                         Name/Value
 0x000000000000000c (INIT)               0x1000
 0x000000000000000d (FINI)               0x1108
 0x0000000000000019 (INIT_ARRAY)         0x3e80
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x3e88
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x2f0
 0x0000000000000005 (STRTAB)             0x3a8
 0x0000000000000006 (SYMTAB)             0x318
 0x000000000000000a (STRSZ)              89 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000003 (PLTGOT)             0x4000
 0x0000000000000007 (RELA)               0x408
 0x0000000000000008 (RELASZ)             168 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000006ffffff9 (RELACOUNT)          3
 0x0000000000000000 (NULL)               0x0
```

### 解决

1. 重新使用最新的NDK并使用ndk-build/cmake方式编译SO库

2. 如果是手动编译，需要在gcc/clang编译时加上 `-Wl,-soname,libget.so` 选项

### 官方文档摘录

引用自 https://android-developers.googleblog.com/2016/06/android-changes-for-ndk-developers.html ，需要代理访问。

> #### Invalid DT_NEEDED Entries (Enforced since API 23)
>
> While library dependencies (DT_NEEDED entries in the ELF headers) can be absolute paths, that doesn’t make sense on Android because you have no control over where your library will be installed by the system. A DT_NEEDED entry should be the same as the needed library’s SONAME, leaving the business of finding the library at runtime to the dynamic linker.
>
> Before API 23, Android’s dynamic linker ignored the full path, and used only the basename (the part after the last ‘/’) when looking up the required libraries. Since API 23 the runtime linker will honor the DT_NEEDED exactly and so it won’t be able to load the library if it is not present in that exact location on the device.
>
> Even worse, some build systems have bugs that cause them to insert DT_NEEDED entries that point to a file on the **build** host, something that cannot be found on the device.
>
> ```
> $ readelf --dynamic libSample.so | grep NEEDED
>  0x00000001 (NEEDED)                     Shared library: [libm.so]
>  0x00000001 (NEEDED)                     Shared library: [libc.so]
>  0x00000001 (NEEDED)                     Shared library: [libdl.so]
>  0x00000001 (NEEDED)                     Shared library:
> [C:\Users\build\Android\ci\jni\libBroken.so]
> $
> ```
>
> Potential problems: before API 23 the DT_NEEDED entry’s basename was used, but starting from API 23 the Android runtime will try to load the library using the path specified, and that path won’t exist on the device. There are broken third-party toolchains/build systems that use a path on a build host instead of the SONAME.
>
> Resolution: make sure all required libraries are referenced by SONAME only. It is better to let the runtime linker to find and load those libraries as the location may change from device to device.
>
> #### Missing SONAME (Used since API 23)
>
> Each ELF shared object (“native library”) must have a SONAME (Shared Object Name) attribute. The NDK toolchain adds this attribute by default, so its absence indicates either a misconfigured alternative toolchain or a misconfiguration in your build system. A missing SONAME may lead to runtime issues such as the wrong library being loaded: the filename is used instead when this attribute is missing.
>
> ```
> $ readelf --dynamic libWithSoName.so | grep SONAME
>  0x0000000e (SONAME)                     Library soname: [libWithSoName.so]
> $
> ```
>
> Potential problems: namespace conflicts may lead to the wrong library being loaded at runtime, which leads to crashes when required symbols are not found, or you try to use an ABI-incompatible library that isn’t the library you were expecting.
>
> Resolution: the current NDK generates the correct SONAME by default. Ensure you’re using the current NDK and that you haven’t configured your build system to generate incorrect SONAME entries (using the `-soname` linker option).
>
> Please remember, clean, cross-platform code built with a current NDK should have no issues on Android N. We encourage you to revise your native code build so that it produces correct binaries.
>

### 原因追究

#### 为什么AndroidStudio中编译的CPP动态链接库是可以正确的设置SONAME字段到so库文件中的？

