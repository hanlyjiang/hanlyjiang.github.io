# UniApp-iOS插件开发

本文仅简要介绍iOS插件开发的大体步骤，部分详细操作可参考[官方文档](https://nativesupport.dcloud.net.cn/NativePlugin/course/ios)。

**文档资源**

* [原生插件开发 (dcloud.net.cn)](https://nativesupport.dcloud.net.cn/NativePlugin/README)
* [iOS原生插件开发 (dcloud.net.cn)](https://nativesupport.dcloud.net.cn/NativePlugin/course/ios)
* [App离线打包SDK -下载(dcloud.net.cn)](https://nativesupport.dcloud.net.cn/AppDocs/download/ios)
* [App离线打包SDK -简介(dcloud.net.cn)](https://nativesupport.dcloud.net.cn/AppDocs/README)

## 概述

实际上UniApp-iOS的插件开发包括三部分内容：

1. 插件开发：包括获取SDK，及开发环境及工程的配置，及插件的编写方式，UniApp提供的API等；（可参考：[原生插件开发 (dcloud.net.cn)](https://nativesupport.dcloud.net.cn/NativePlugin/course/ios)）
2. iOS离线打包运行：插件工程配置好之后，编写了插件代码，需要运行起来测试，此时需要配置好离线打包的环境配置，并且将离线App打包运行起来进行测试；（可参考：[App离线打包SDK (dcloud.net.cn)](https://nativesupport.dcloud.net.cn/AppDocs/usesdk/ios)）
3. 插件打包：插件调试完毕之后，需要将其上传到DCloud的插件市场，此时需要了解UniApp的原生插件包的格式，并按其要求将成果组织。（可参考：[原生插件开发-packagejson格式 (dcloud.net.cn)](https://nativesupport.dcloud.net.cn/NativePlugin/course/package?id=packagejson) 及 [原生插件开发 - 生成插件包 (dcloud.net.cn)](https://nativesupport.dcloud.net.cn/NativePlugin/course/ios?id=生成插件包)）

## 获取SDK

从官方下载最新的IOS SDK。

## 创建插件工程

>  按官方文档的 [原生插件开发-创建插件工程 (dcloud.net.cn)](https://nativesupport.dcloud.net.cn/NativePlugin/course/ios?id=创建插件工程) 的步骤操作即可。

主要过程描述如下：

1. 创建一个  `Framework` 或 `Static Library`的项目，存放于UniApp插件开发主工程中（`HBuilder-uniPluginDemo `目录）
2. `TARGETS->Build Settings`中，将 `Mach-O Type` 设置为 `Static Library`；
3. 关闭工程

## 导入插件工程

> 官方文档：[原生插件开发-导入插件工程 (dcloud.net.cn)](https://nativesupport.dcloud.net.cn/NativePlugin/course/ios?id=导入插件工程)

主要过程描述如下：

1. 打开插件开发主工程（ `iOSSDK/HBuilder-uniPluginDemo`工程目录，双击目录中的`HBuilder-uniPlugin.xcodeproj`）
2. 将我们上一步创建的只工程添加到主工程中：
   1. 在 Xcode 项目左侧目录选中**主工程名**，然后点击右键选择`Add Files to “HBuilder-uniPlugin” ...`
   2. 然后选择您刚刚创建的插件工程路径中，选中插件工程文件，勾选 `Create folder references` 和 `Add to targets` 两项，然后点击`Add`

## 工程配置

> 官方文档：[原生插件开发-工程配置 (dcloud.net.cn)](https://nativesupport.dcloud.net.cn/NativePlugin/course/ios?id=工程配置)

### 添加插件工程到主工程的 `Dependencies` 及 `Link Binary With Libraries`中

1. 然后在 Xcode 项目左侧目录选中**主工程名**，在`TARGETS->Build Phases->Dependencies`中点击`+`
2. 在弹窗中选中插件工程，然后点击`Add`，将插件工程添加到`Dependencies`中
3. 然后在`Link Binary With Libraries`中点击`+`，同样在弹窗中选中插件工程，点击`Add`

### 将主工程的头文件`HBuilder-Hello/inc`引入到插件工程

选中**插件工程名**，找到`TARGETS->Build Settings->Header Search Paths`双击右侧区域打开添加窗口，然后将`inc`目录拖入会自动填充相对路径，然后将模式改成`recursive`

## 打包



## 遇到的问题

### Signing for "HBuilder" requires a development team.



### Appkey is not configured or configured incorrectly

**原因：**

需要配置APP KEY

**解决：**

1. [Dcloud开发者后台](https://dev.dcloud.net.cn/app/index?type=0?appid=&type=0)中查看“我创建的应用”
2.  点击当前使用的应用的名称，进入应用的详细页面；
3. 点击左侧菜单栏中最底部的理想打包Key管理，填写对应的信息（注意记录BundlerId），然后保存；
4. 保存之后即之后生成了Android和iOS对应的App Key；
5. 在XCode中更改BundlerId为刚才设置的；
6. 在XCode中编辑 `HBuilder-uniPlugin-Info.plist` 文件中的 `dcloud_appkey` 的配置为Dcloud后台生成的对应的iOS的AppKey的值；



### Uni-App中调用方法时，提示undefined

**原因：**

配置 `HBuilder-uniPlugin-Info.plist` 时模块名称设置和在Uni-App中`uni.requireNativePlugin`引入时设置的不一致

**解决：**

改成一致即可，注意，下方的`<key>name</key>`之后的`<string>HJSangForVPN-SangforVPNModule</string>` 中的值即是插件的名称，也就是`uni.requireNativePlugin`的参数；

```xml
<key>dcloud_uniplugins</key>
<array>
		<dict>
			<key>hooksClass</key>
			<string>SangforVPNModule</string>
			<key>plugins</key>
			<array>
				<dict>
					<key>class</key>
					<string>SangforVPNModule</string>
					<key>name</key>
					<string>HJSangForVPN-SangforVPNModule</string>
					<key>type</key>
					<string>module</string>
				</dict>
			</array>
		</dict>
</array>
```



### Undefined symbol: _OBJC_CLASS_$_SFMobileSecuritySDK