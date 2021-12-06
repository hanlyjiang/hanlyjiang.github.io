# Cmake使用指南

## 基本用法

> * [User Interaction Guide — CMake 3.22.0 Documentation](https://cmake.org/cmake/help/latest/guide/user-interaction/index.html#guide:User Interaction Guide)
> * [构建环境变量设置-User Interaction Guide — CMake 3.22.0 Documentation](https://cmake.org/cmake/help/latest/guide/user-interaction/index.html#setting-build-variables)

CMake是一个管理源代码构建的工具。最初，CMake被设计为`Makefile`的各种方言的生成器，今天CMake生成现代构建系统，如`Ninja`，以及IDE的项目文件，如Visual Studio和Xcode。



### 构建

#### 一般流程

```shell
$ cd some_software-1.4.2
$ mkdir build
$ cd build
# 初始化，生成对应文件
$ cmake .. -DCMAKE_INSTALL_PREFIX=/opt/the/prefix
# -G Ninja
# 构建
$ cmake --build . --verbose
# 指定目标构建
$ cmake --build . --target install

$ cmake --build . --target myexe --config Release
```

> 执行这些的基础是源码目录下面有一个 CMakeLists.txt 的文件
>
> 示例配置如下：
>
> ```cmake
> cmake_minimum_required(VERSION 3.20)
> project(C_001 C)
> 
> set(CMAKE_C_STANDARD 11)
> 
> # 可执行文件
> add_executable(C_001 main.c test/test.c)
> # static
> add_library(test_a test/test.c)
> 
> # dylib
> add_library(test SHARED test/test.c)
> # so
> add_library(test_so MODULE test/test.c)
> 
> # 安装配置
> install(TARGETS test_a test_so C_001 DESTINATION lib)
> install(FILES test/test.h DESTINATION include)
> ```
>
> 

#### 查看帮助

```shell
cmake --build ./cmake-build-debug --target help
```

* 使用 `--build` 指定cmake使用的构建目录
* 使用 `--target` 指定目标



## CMakeLists.txt 文件写法

> [Step 1: A Basic Starting Point — CMake 3.22.0 Documentation](https://cmake.org/cmake/help/latest/guide/tutorial/A Basic Starting Point.html)

示例配置：

```cmake
cmake_minimum_required(VERSION 3.20)
project(C_001 C)

set(CMAKE_C_STANDARD 11)

# 可执行文件
add_executable(C_001 main.c test/test.c)
# static
add_library(test_a test/test.c)

target_include_directories(test_a PUBLIC
        "${PROJECT_BINARY_DIR}"
        )
# dylib
add_library(test SHARED test/test.c)
# so
add_library(test_so MODULE test/test.c)

# cmake --build bulid/ --target install 
install(TARGETS test_a test_so C_001 DESTINATION lib)
install(FILES test/test.h DESTINATION include)

# 打包：cpack -G ZIP -C Debug
include(InstallRequiredSystemLibraries)
#set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/License.txt")
set(CPACK_PACKAGE_VERSION_MAJOR "1")
set(CPACK_PACKAGE_VERSION_MINOR "0")
include(CPack)
```



## 重要文件说明

### CMakeCache.txt

‎当CMake执行时，它需要找到编译器，工具和依赖项的位置。它还需要能够始终如一地重新生成构建系统，以使用相同的编译/链接标志和依赖项路径。这些参数还需要由用户配置，因为它们是特定于用户系统的路径和选项。‎

首次执行时，CMake 会在生成目录中生成一个`CMakeCache.txt`文件，其中包含此类项目的键值对。‎



### CMakePresets.json & CMakeUserPresets.json

用于保存常用配置设置的预设。这些预设可以设置生成目录、生成器、缓存变量、环境变量和其他命令行选项。所有这些选项都可以被用户覆盖。

示例：

```json
{
  "version": 1,
  "configurePresets": [
    {
      "name": "ninja-release",
      "binaryDir": "${sourceDir}/build/${presetName}",
      "generator": "Ninja",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release"
      }
    }
  ]
}
```

使用：

```shell
cmake -S /path/to/source --preset=ninja-release
```





# 问题解决记录

## 
