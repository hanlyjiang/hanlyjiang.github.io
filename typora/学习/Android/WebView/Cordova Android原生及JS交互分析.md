|**时间**|**更新内容**|**作者**|
|:----|:----|:----|
|2018/11/xx|新建文档|hanlyjiang@yeah.net|
|2019/06/29|整理完善|hanlyjiang@yeah.net|

# Cordova 简要介绍

一个开源的移动开发框架，允许你使用标准的web开发技术-HTML5,CSS3和JavaScript 开进行跨平台的开发。开发的应用会执行在目标平台的包装器之内。并依赖符合标准的API绑定来访问每个设备的功能，如传感器，数据，网络状态等。

## 架构图

![图片](https://uploader.shimo.im/f/aJHqHpzhoyoc5FyC.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

简单来讲，就是Cordova提供了一个完善的WebView壳，你可以很方便的将 webApp放到里面运行。提供了很多插件来供WebApp调用原生的功能；同时提供了一套API，你可以自己扩展插件来提供原生能力给 JavaScript。

>了解更多：
>-[Cororva 官方文档站点](https://cordova.apache.org/docs/en/latest/guide/overview/index.html?fileGuid=kytoN21EHh88ps3y)
# 环境准备

## Cordova 安装、建立示例工程

>示例工程github地址：[hanlyjiang/cordova-android-analysis](https://github.com/hanlyjiang/cordova-android-analysis?fileGuid=kytoN21EHh88ps3y)

以下命令安装cordova并使用 cordova-cli 来建立 Cordova 项目

```
# 安装 (首先需要安装nodejs)
npm install -g cordova
# 创建APP
cordova create CordovaAndroidAnalysis
cdCordovaAndroidAnalysis
# 添加 ignore 文件
wget https://raw.githubusercontent.com/apache/cordova-android/master/.gitignore # 初始化为git库
git init
# 初始化提交
git add . ; git commit -m "initial"
# 添加平台
cordova platform add android
# cordova platform add browser
# 运行
cordova run android
# cordova run browser
```
添加一个状态栏插件用于分析：
```
# 添加插件 状态栏
# 状态栏插件： https://cordova.apache.org/docs/en/latest/reference/cordova-plugin-statusbar/index.html
cordova plugin add cordova-plugin-statusbar
```
>**注意:**在你使用CLI创建应用的时候， 不要 修改/platforms/目录中的任何文件。当准备构建应用或者重新安装插件时这个目录通常会被重写。

建立完成后目录结构

![图片](https://images-cdn.shimo.im/v4yDgtAlWS8Cvz29/image.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

>**提示：**可以使用 IDEA 直接打开项目根目录，使用 AndroidStudio 打开 platforms/android 目录来查看及调试 Android 代码。

使用Chrome调试时可以看见实际加载的目录是这样的：

![图片](https://uploader.shimo.im/f/pjlibb1uZj4PlPZ9.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

## Android调试 Cordova WebApp 调试方法

1. Android原生调试

请阅读： Google官方android文档-[调试您的应用](https://developer.android.google.cn/studio/debug/?fileGuid=kytoN21EHh88ps3y)

2. Android WebView 远程调试

请阅读：[远程调试 Android 设备使用入门](https://developers.google.com/web/tools/chrome-devtools/remote-debugging/?hl=zh-cn&fileGuid=kytoN21EHh88ps3y)

[AndroidWebView远程调试-Get Started with Remote Debugging Android Devices  |  Tools for Web Developers  |  Google Developers.pdf](https://attachments-cdn.shimo.im/zVsMkCdV89gEKRDA/AndroidWebView远程调试_Get_Started_with_Remote_Debugging_Android_Devices_Tools_for_Web_Developers_Google_Developers.pdf?fileGuid=kytoN21EHh88ps3y)**简要介绍：**

* **使用 console.log 在 logcat 中输出日志**
```
console.log("Hello World");
```
* **Chrome远程调试**

主要步骤： 连接设备 - 打开USB调试 - Chrome DevTools 中- More Tools - Remote Devices

![图片](https://images-cdn.shimo.im/CWGVI0Rt8VorCEpj/image.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

![图片](https://images-cdn.shimo.im/AfDfcQFejswRRjpE/image.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

为了debug js 侧代码，我们需要使用Chrome远程调试。

>**提示：**如果点击 inspect 时Chrome中显示空白 或出现 404 ，可以试着挂到google的代理，然后重试。

# 知识准备



# 分析主要关注点

主要专注于js及原生交互的实现过程，按照以下思路：

1. 梳理Android提供的JS原生交互API 及 Cordova 如何使用这些API作为底层支持；
2. 分析 JS 如何调用 到 Java 代码；
3. JS 调用到原生后，Cordova 实现中 Java代码的处理流程。
# 初始化入口

```
public class MainActivity extends CordovaActivity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        // enable Cordova apps to be started in the background
        Bundle extras = getIntent().getExtras();
        if (extras != null && extras.getBoolean("cdvStartInBackground", false)) {
            moveTaskToBack(true);
        }
        // Set by <content src="index.html" /> in config.xml
        loadUrl(launchUrl);
    }
}
```
整个流程入口有两个方法：1. onCreate ；2. loadUrl，大体调用流程如下图所示：
![图片](https://uploader.shimo.im/f/ZpRRK0c4vUIu6xZS.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

# 交互通道封装

## Cordova***addJavascriptInterface***注册代码

默认实现在***SystemWebViewEngine***中， 将********SystemExposedJsApi**类的对象以***_cordovaNative***名称注入到了WebView中。如下：

***SystemWebViewEngine.java  line: 233***

```
@SuppressLint("AddJavascriptInterface")
private static void exposeJsInterface(WebView webView, CordovaBridge bridge) {
SystemExposedJsApi exposedJsApi = new SystemExposedJsApi(bridge);
webView.addJavascriptInterface(exposedJsApi, "_cordovaNative");
}
```
>即： js 侧会以 _cordovaNative 对象来调用对应的远程方法

***SystemExposedJsApi.java***有三个方法，并且持有一个 CordovaBridge 对象的引用，实际动作都交由 CordovaBridge 对象实例去完成，每个方法的用途看注释说明。

```
/**
 * Contains APIs that the JS can call. All functions in here should also have
 * an equivalent entry in CordovaChromeClient.java, and be added to
 * cordova-js/lib/android/plugin/android/promptbasednativeapi.js
 */
class SystemExposedJsApi implements ExposedJsApi {
private final CordovaBridge bridge;
SystemExposedJsApi(CordovaBridge bridge) {
this.bridge = bridge;
}
/**
* 用于 js 端调用原生方法
*/
@JavascriptInterface
public String exec(int bridgeSecret, String service, String action, String callbackId, String arguments) throws JSONException, IllegalAccessException {
return bridge.jsExec(bridgeSecret, service, action, callbackId, arguments);
}
/**
* 用于在js代码中切换 js 原生通讯模式，有两个值： PROMPT - onJsPrompt() 原生回调中执行原生代码， JS_OBJECT - 通过注入的对象(SystemExposedJsApi对象)来执行原生代码
*/
@JavascriptInterface
public void setNativeToJsBridgeMode(int bridgeSecret, int value) throws IllegalAccessException {
bridge.jsSetNativeToJsBridgeMode(bridgeSecret, value);
}
/**
* 用于在 js 代码中获取 exec 调用产出的结果。
*/
@JavascriptInterface
public String retrieveJsMessages(int bridgeSecret, boolean fromOnlineEvent) throws IllegalAccessException {
return bridge.jsRetrieveJsMessages(bridgeSecret, fromOnlineEvent);
}
}
```
# 状态栏插件使用-改变状态栏

## 状态栏插件结构介绍：

![图片](https://uploader.shimo.im/f/U7o8e5jQNo0sdml3.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

## 添加状态栏插件使用代码

在 index.js 文件中添加改变状态栏的方法：

```
// Update DOM on a Received Event
receivedEvent: function(id) {
    var parentElement = document.getElementById(id);
    var listeningElement = parentElement.querySelector('.listening');
    var receivedElement = parentElement.querySelector('.received');    listeningElement.setAttribute('style', 'display:none;');
    receivedElement.setAttribute('style', 'display:block;');    console.log('Received Event: ' + id);
    // 添加：设置浅色状态栏
    window.StatusBar.styleDefault();
    window.StatusBar.backgroundColorByName('white');
}
```
运行效果对比：
![图片](https://uploader.shimo.im/f/BiLNynlQzUsjDm7N.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

# JS原生交互分析

使用IDEA 打开 platforms/android/app/src/main/assets 目录进行源码分析。

## JS调用原生代码 - JS侧调用栈

以 Camera 插件为例，Camera js侧插件提供 getPicture 方法，以下为调用方式：

```
function openCamera() {
navigator.camera.getPicture(successCallback, errorCallback, {"quality":50})
}
```
![图片](https://images-cdn.shimo.im/rqv6Ara6wTMqXM7f/image.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

如以上方法调用可见，最后调用的是

## JS调用原生代码 - 原生代码调用流程

我们先看原生部分的调用，如果按正常**JS_OBJECT**模式（此处后面再说），当在 js 代码中调用**exec**方法就会执行到**SystemExposedJsApi.exec**方法，实际调用顺序如下：

![图片](https://images-cdn.shimo.im/1QwVeR91vpktsrfC/image.png!thumbnail?fileGuid=kytoN21EHh88ps3y)

也就是说最后实际是使用**PluginManager**纷发到具体的插件来处理**js**代码的调用。




## Cordova JS侧初始化流程分析

由于通过addJavaScript注入的Java对象名称为**_cordovaNative ，**所以在js应该有通过此对象调用原生方法。

cordova.js 中实现了一个类似[AMD (中文版)](https://github.com/amdjs/amdjs-api/wiki/AMD-(中文版)?fileGuid=kytoN21EHh88ps3y)的定义和加载包的机制。

***cordova.js***

```
//
window.cordova = require('cordova');
// file: src/scripts/bootstrap.js
require('cordova/init');
```
***cordova.js***

```
// file: /Users/brodybits/Documents/cordova/cordova-android/cordova-js-src/android/nativeapiprovider.js
define("cordova/android/nativeapiprovider", function(require, exports, module) {
/**
* Exports the ExposedJsApi.java object if available, otherwise exports the PromptBasedNativeApi.
*/
// 这里的this是 Window 对象
var nativeApi = this._cordovaNative || require('cordova/android/promptbasednativeapi');
var currentApi = nativeApi;
module.exports = {
get: function() { return currentApi; },
setPreferPrompt: function(value) {
currentApi = value ? require('cordova/android/promptbasednativeapi') : nativeApi;
},
// Used only by tests.
set: function(value) {
currentApi = value;
}
};
});
```
解释： 如果存在***_cordovaNative***则使用***_cordovaNative***否者使用 prompt 方式



# 参考：

* [AMD-JS](https://github.com/amdjs/amdjs-api/wiki/AMD?fileGuid=kytoN21EHh88ps3y)/[AMD-中文版](https://github.com/amdjs/amdjs-api/wiki/AMD-(中文版)?fileGuid=kytoN21EHh88ps3y)
* [What is define([ , function ]) in JavaScript? [duplicate]](https://stackoverflow.com/questions/16950560/what-is-define-function-in-javascript?fileGuid=kytoN21EHh88ps3y)
* [https://geeklearning.io/apache-cordova-and-remote-debugging-on-android/](https://geeklearning.io/apache-cordova-and-remote-debugging-on-android/?fileGuid=kytoN21EHh88ps3y)
* [https://developer.mozilla.org/en-US/docs/Tools/Remote_Debugging](https://developer.mozilla.org/en-US/docs/Tools/Remote_Debugging?fileGuid=kytoN21EHh88ps3y)


