# LinkSysWRT32X安装OpenWRT

## 安装

* 参考 官方页面： [OpenWrt Wiki\] Linksys WRT32X](https://openwrt.org/toh/linksys/wrt32x)

1. 下载镜像： http://downloads.openwrt.org/releases/21.02.0/targets/mvebu/cortexa9/openwrt-21.02.0-mvebu-cortexa9-linksys_wrt32x-squashfs-factory.img 
2. 登录到LinkSys32X的管理界面，使用系统的升级界面，上传img，然后安装，等待完成即可；



## OpenWRT配置

### 登录

OpenWRT默认管理页面是在 192.168.1.1 ，直接打开 http://192.168.1.1 进入页面，会提示设置一个管理密码，设置后进入；



### 安装中文语言包

默认情况下系统界面是英文的，我们可以安装中文语言包以方便使用。

* System-Sofeware 界面点击 UPDATE LISTS

  ![image-20210920083759370](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210920083800.png)

* 等待列表更新完成后，在 Filter 中输入`luci-i18n-base-zh-cn` ，然后在下方结果中点击最后面的安装按钮

  ![image-20210920083947985](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210920083949.png)

* 等待安装完成之后，刷新页面。

### 配置路由器名称

进入系统-系统属性-常规设置，然后修改主机名，完成之后点击“保存并应用”，等待生效即可；

![image-20210920083038641](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210920083042.png)



### 修改默认的管理地址

LinkSysWRT32 官方固件出厂时的管理地址为 10.46.202.1 ，为了保持地址统一，这里将OpenWRT的也修改为一致的地址。

* 打开 “网络-接口” 

  ![image-20210920083331895](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210920083333.png)

* 点击编辑按钮，修改IPv4地址为 10.46.202.1 

  ![image-20210920083424971](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210920083426.png)

* 点击“保存” 关闭弹出框

* 然后点击“保存并应用”，⌛️等待生效即可。



### 设置160MHZ

>  参考 :
>
> 1. https://github.com/patrikx3/openwrt-insomnia/blob/master/docs/linksys-wrt-3200acm-160mhz.md 
> 2. 官方文档 ： https://www.linksys.com/us/support-article?articleNum=270545 搜索 `160 MHz`

主要操作步骤：

1. 无线安全-算法 设置为 `强制CMP (AES)`
2. 选择带宽为 160MHZ

![image-20210920090906949](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210920090908.png)

连接之后显示如下：

![image-20210920090940501](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210920090942.png)





## VPN配置

参考 ： 

* [OpenWRT CI setup with NordVPN | NordVPN Support](https://support.nordvpn.com/Connectivity/Router/1047411192/OpenWRT-CI-setup-with-NordVPN.htm)

* [[OpenWrt Wiki\] OpenVPN client using LuCI](https://openwrt.org/docs/guide-user/services/vpn/openvpn/client-luci)
* [Get the Best VPN Router 2021 l ExpressVPN](https://www.expressvpn.com/vpn-software/vpn-router)
* [针对OpenWRT的VyprVPN OpenVPN设置 – VyprVPN Support](https://support.vyprvpn.com/hc/zh-cn/articles/360037716552-针对OpenWRT的VyprVPN-OpenVPN设置)



安装如下软件包：

```shell
openvpn-openssl
luci-app-openvpn
luci-i18n-openvpn-zh-cn

collectd-mod-openvpn
vpn-policy-routing
```

通过ssh安装：

```shell
opkg install --force-overwrite openvpn-openssl luci-app-openvpn luci-i18n-openvpn-zh-cn
```

创建网络接口：

```shell
uci set network.nordvpntun=interface
uci set network.nordvpntun.proto='none'
uci set network.nordvpntun.ifname='tun0'
uci commit network
```





```shell
uci set openvpn.nordvpn=openvpn
uci set openvpn.nordvpn.enabled='1'
uci set openvpn.nordvpn.config='/etc/openvpn/jp536.ovpn'
uci commit openvpn
```



```shell
uci set network.nordvpntun=interface
uci set network.nordvpntun.proto='none'
uci set network.nordvpntun.ifname='tun0'
uci commit network
```



```shell
uci add firewall zone
uci set firewall.@zone[-1].name='vpnfirewall'
uci set firewall.@zone[-1].input='REJECT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].masq='1'
uci set firewall.@zone[-1].mtu_fix='1'
uci add_list firewall.@zone[-1].network='nordvpntun'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='vpnfirewall'
uci commit firewall
```

配置DNS：

```shell
uci set network.wan.peerdns='0'
uci del network.wan.dns
uci add_list network.wan.dns='103.86.96.100'
uci add_list network.wan.dns='103.86.99.100'
uci commit
```

## 主题安装

**用不了：**

[能不能适配一下openwrt v21.02呢？ · Issue #214 · jerrykuku/luci-theme-argon (github.com)](https://github.com/jerrykuku/luci-theme-argon/issues/214)

```shell
opkg install luci-lib-ipkg
opkg install luci-compat

scp ~/Downloads/luci-app-argon-config_0.9-20210309_all.ipk  root@10.46.202.1:/tmp/
scp ~/Downloads/luci-theme-argon_1.7.2-20210309_all.ipk root@10.46.202.1:/tmp/

opkg install luci-theme-argon_1.7.2-20210309_all.ipk
opkg install luci-app-argon-config_0.9-20210309_all.ipk
```

