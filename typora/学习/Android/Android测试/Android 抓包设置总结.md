# Android 抓包测试总结

## Https 抓包

我们可以使用 Charles 及 Fiddler 来进行抓包及代理拦截的相关测试。

### 安装包配置

7.0以后，https的抓包需要特殊配置，可在debug变体中添加如下配置文件 `debug/res/xml/network-security-config.xml`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="user" />
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

`debug/AndroidManifest.xml` 中配置

```xml
<application
        android:networkSecurityConfig="@xml/network_security_config">
  
</application>
```

重新打包安装到手机。

### 手机端安装抓包软件证书

下面以 Charles 举例。

<img src="/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20220410233315380.png" alt="image-20220410233315380" style="zoom:50%;" />

通过 help 菜单可以看到操作步骤。

1. 手机 Wifi 连接配置代理；
2. 访问 chls.pro/ssl ，会自动下载证书，然后去下载列表中点击证书文件，选择**证书安装程序**，这里可能会提示要去设置中进行安装，可以在设置中搜索“证书”然后安装证书。

<img src="/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20220410233551869.png" alt="image-20220410233551869" style="zoom:33%;" />

### Charles 配置 SSL 代理

<img src="/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20220410235955746.png" alt="image-20220410235955746" style="zoom:50%;" />

### 验证

由于Edge浏览器配置了此network配置，所以这里我们直接以 Edge 浏览器进行测试，看看我们的证书是否导入成功，打开HTTPS的页面，查看能否抓包。

<img src="/Users/hanlyjiang/Library/Application Support/typora-user-images/image-20220411000850284.png" alt="image-20220411000850284" style="zoom: 40%;" />

> - [在Android手机上对https请求进行抓包_安卓手机抓包](https://blog.csdn.net/guolin_blog/article/details/117192301)