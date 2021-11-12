# OpenHarmony 编译USB子系统



本文档用于记录如何在OpenHarmony 3.0LTS中加入USB管理器模块的源码，并添加编译配置，最终编译出可供开发板使用的包括usb mgr服务的可刷写镜像。

## 相关知识

- openHarmony 构建系统

## 配置

参考 [标准系统编译构建指导 | OpenHarmony](https://www.openharmony.cn/pages/00040001/#编译命令) 及 [docs/标准系统如何添加一个模块.md · OpenHarmony/build - 码云 - 开源中国 (gitee.com)](https://gitee.com/openharmony/build/blob/master/docs/标准系统如何添加一个模块.md) 可知，在OpenHarmony构建系统中主要涉及如下四种配置：

1. 产品配置（一般位于 productdefine/common/products/xx.json ,定义产品中应该包含子系统的那些模块 ）
2. 子系统总体配置（build目录下的subsystem_config.json文件，定义子系统的路径，让构建系统可以找到子系统目录）
3. 子系统自身定义(ohos.build)
4. （子系统）模块配置（BUILD.gn）

由于子系统自身定义及模块配置 usb 子系统代码中均已提供，我们只需要修改产品配置及 subsystem_config 即可。

在系统对应的配置文件中添加usb子系统的配置，具体修改配置如下：

### `build/subsystem_config.json` 

在此文件中添加子系统配置信息：

```json
  "kernel": {
    "project":"hmf/kernel",
    "path": "kernel/linux/build",
    "name": "kernel",
    "dir": "kernel/linux"
  },

  // 以下为我们新增加的配置
  "usb": {
    "project":"hmf/usb",
    "path": "base/usb",
    "name": "usb",
    "dir": "base"
  }
```

### `productdefine/common/products/Hi3516DV300.json`

在此文件中注册

```json
 {   
    "ark:ark_ts2abc":{},
    // 新增如下配置
    "usb:usb_manager_native":{}
  }
```



## 构建

> 构建过程中会遇到问题，可参考 **错误解决** 部分预先调整

配置修改完毕后，可执行如下命令单独构建模块：

```
./build.sh --product-name Hi3516DV300 --build-target usb
```

执行如下命令进行全量构建

```
./build.sh --product-name Hi3516DV300  --ccache
```

构建成功输出：

```shell
[2086/2132] SOLINK utils/utils_base/libutilsecurec_shared.z.so
[2087/2132] SOLINK hiviewdfx/hilog_native/libhilog_os_adapter.z.so
[2088/2132] SOLINK communication/dsoftbus_standard/libnstackx_util.open.z.so
[2089/2132] SOLINK communication/dsoftbus_standard/libnstackx_congestion.open.z.so
[2090/2132] SOLINK hiviewdfx/hilog_native/libhilogutil.so
[2091/2132] STAMP obj/base/hiviewdfx/hilog/frameworks/native/libhilog_source.stamp
[2092/2132] SOLINK communication/dsoftbus_standard/libnstackx_dfile.open.z.so
[2093/2132] SOLINK hiviewdfx/hilog_native/libhilog.so
[2094/2132] SOLINK ace/napi/libace_napi.z.so
[2095/2132] SOLINK appexecfwk/appexecfwk_standard/libeventhandler.z.so
[2096/2132] SOLINK utils/utils_base/libutils.z.so
[2097/2132] SOLINK hdf/hdf/libhdf_utils.z.so
[2098/2132] SOLINK startup/startup_l2/libsysparam_hal.z.so
[2099/2132] SOLINK communication/ipc/libipc_single.z.so
[2100/2132] SOLINK hdf/hdf/libhdf_hcs.z.so
[2101/2132] STAMP obj/drivers/adapter/uhdf2/config/uhdf_hcs_pkg.stamp
[2102/2132] SOLINK startup/startup_l2/libsyspara.z.so
[2103/2132] SOLINK communication/dsoftbus_standard/libsoftbus_adapter.z.so
[2104/2132] SOLINK communication/dsoftbus_standard/libsoftbus_property.z.so
[2105/2132] SOLINK communication/dsoftbus_standard/libsoftbus_log.z.so
[2106/2132] SOLINK communication/dsoftbus_standard/libsoftbus_seq_verification.z.so
[2107/2132] SOLINK communication/dsoftbus_standard/libsoftbus_utils.z.so
[2108/2132] SOLINK communication/dsoftbus_standard/libjson_utils.z.so
[2109/2132] SOLINK communication/dsoftbus_standard/libconn_common.z.so
[2110/2132] SOLINK communication/dsoftbus_standard/libsoftbus_trans_pending.z.so
[2111/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_disc_manager_sdk.z.so
[2112/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_trans_ipc_proxy_sdk.z.so
[2113/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_bus_center_manager_sdk.z.so
[2114/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_trans_direct_channel_sdk.z.so
[2115/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_trans_auth_channel_sdk.z.so
[2116/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_trans_proxy_channel_sdk.z.so
[2117/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_trans_udp_channel_sdk.z.so
[2118/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_trans_session_manager_sdk.z.so
[2119/2132] SOLINK communication/dsoftbus_standard/libsoftbus_client_frame.z.so
[2120/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_disc_service_sdk.z.so
[2121/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_bus_center_service_sdk.z.so
[2122/2132] SOLINK communication/dsoftbus_standard/libdsoftbus_trans_session_sdk.z.so
[2123/2132] SOLINK communication/dsoftbus_standard/libsoftbus_client.z.so
[2124/2132] SOLINK communication/ipc/libipc_core.z.so
[2125/2132] SOLINK distributedschedule/samgr_L2/libsamgr_proxy.z.so
[2126/2132] SOLINK hdf/hdf/libhdf_ipc_adapter.z.so
[2127/2132] SOLINK distributedschedule/safwk/libsystem_ability_fwk.z.so
[2128/2132] SOLINK hdf/hdf/libhdi.z.so
[2129/2132] SOLINK hdf/hdf/libhdf_host.z.so
[2130/2132] SOLINK usb/usb_manager_native/libusbd_client.z.so
[2131/2132] SOLINK usb/usb_manager_native/libusbsrv_client.z.so
[2132/2132] SOLINK usb/usb_manager_native/libusb.z.so
used: 144 seconds
pycache statistics
manage pycache contents
pycache daemon exit
c targets overlap rate statistics
subsystem       	files NO.	percentage	builds NO.	percentage	overlap rate
ark             	     421	3.1%	     755	5.2%	1.79
utils           	     205	1.5%	     245	1.7%	1.20
third_party     	    6960	51.2%	    7553	51.9%	1.09
aafwk           	     203	1.5%	     203	1.4%	1.00
account         	      14	0.1%	      14	0.1%	1.00
ace             	    1257	9.3%	    1257	8.6%	1.00
appexecfwk      	     370	2.7%	     370	2.5%	1.00
ccruntime       	      29	0.2%	      29	0.2%	1.00
communication   	     462	3.4%	     462	3.2%	1.00
developtools    	      77	0.6%	      77	0.5%	1.00
distributeddatamgr	     331	2.4%	     331	2.3%	1.00
distributedhardware	      33	0.2%	      33	0.2%	1.00
distributedschedule	      40	0.3%	      40	0.3%	1.00
global          	      19	0.1%	      19	0.1%	1.00
graphic         	     133	1.0%	     133	0.9%	1.00
hdf             	      44	0.3%	      44	0.3%	1.00
hiviewdfx       	     135	1.0%	     135	0.9%	1.00
miscservices    	      62	0.5%	      62	0.4%	1.00
multimedia      	     272	2.0%	     272	1.9%	1.00
multimodalinput 	      29	0.2%	      29	0.2%	1.00
notification    	     127	0.9%	     127	0.9%	1.00
powermgr        	      50	0.4%	      50	0.3%	1.00
security        	     269	2.0%	     269	1.8%	1.00
startup         	      57	0.4%	      57	0.4%	1.00
telephony       	     225	1.7%	     225	1.5%	1.00
updater         	      81	0.6%	      81	0.6%	1.00
usb             	      10	0.1%	      10	0.1%	1.00
wpa_supplicant-2.9	     149	1.1%	     149	1.0%	1.00

c overall build overlap rate: 1.07


post_process
=====build Hi3516DV300 successful.
2021-11-12 15:30:32
```



## 错误解决

### param_client 依赖找不到

报错如下：

```
ERROR Unresolved dependencies.

//base/usb/usb_manager/hdi/service:usbd(//build/toolchain/ohos:ohos_clang_arm)
needs //base/startup/init_lite/services/param:param_client(//build/toolchain/ohos:ohos_clang_arm)
```

修改：`base/usb/usb_manager/hdi/service/BUILD.gn` 文件，将 param_client 修改为 paramclient

```shell
-    "//base/startup/init_lite/services/param:param_client",
+    "//base/startup/init_lite/services/param:paramclient",
```

### `USB_MANAGER_USB_SERVICE_ID` 定义找不到

报错如下：

```
../../base/usb/usb_manager/interfaces/innerkits/native/src/usb_srv_client.cpp:63:64: error: use of undeclared identifier 'USB_MANAGER_USB_SERVICE_ID'
    sptr<IRemoteObject> remoteObject_ = sm->CheckSystemAbility(USB_MANAGER_USB_SERVICE_ID);
                                                               ^
1 error generated.
```

修改：`utils/system/safwk/native/include/system_ability_definition.h` 

增加 `USB_MANAGER_USB_SERVICE_ID` 的定义：

```c++
diff --git a/system/safwk/native/include/system_ability_definition.h b/system/safwk/native/include/system_ability_definition.h
index 2560d95..c3ec3d5 100644
--- a/system/safwk/native/include/system_ability_definition.h
+++ b/system/safwk/native/include/system_ability_definition.h

@@ -183,6 +183,7 @@ enum {
     DISTRIBUTED_HARDWARE_DEVICEMANAGER_SA_ID         = 4802,
     DEVICE_STORAGE_MANAGER_SERVICE_ID                = 5000,
     STORAGE_SERVICE_ID                               = 5001,
+    USB_MANAGER_USB_SERVICE_ID                       = 6001,
     LAST_SYS_ABILITY_ID                              = 0x00ffffff,  // 16777215
 };

@@ -224,6 +225,7 @@ static const std::map<int, std::string> saNameMap_ = {
     { TELEPHONY_SYS_ABILITY_ID, "Telephony" },
     { DCALL_SYS_ABILITY_ID, "DistributedCallMgr" },
     { DISTRIBUTED_HARDWARE_DEVICEMANAGER_SA_ID, "DeviceManagerService" },
+    { USB_MANAGER_USB_SERVICE_ID, "UsbManagerService" },
 };

 } // namespace OHOS
```

## 相关资料

**NAPI：**

* [通过N-API使用C/C++开发Node.js Native模块_Ghosind-CSDN博客](https://blog.csdn.net/ghosind/article/details/105152252)
* [Node-API | Node.js v17.1.0 Documentation (nodejs.org)](https://nodejs.org/api/n-api.html#node-api)
* [拥抱Node.js 8.0，N-API入门极简例子 - 程序猿小卡 - 博客园 (cnblogs.com)](https://www.cnblogs.com/chyingp/p/nodejs-learning-napi.html)

**编译系统：**

* [跨平台：GN实践详解（ninja, 编译, windows/mac/android实战）强烈推荐 - Bigben - 博客园 (cnblogs.com)](https://www.cnblogs.com/bigben0123/p/12643839.html)
* [GN Language and Operation (googlesource.com)](https://chromium.googlesource.com/chromium/src/tools/gn/+/48062805e19b4697c5fbd926dc649c78b6aaa138/docs/language.md#GN-Language-and-Operation)

* [标准系统编译构建指导 | OpenHarmony](https://www.openharmony.cn/pages/00040001/#编译命令)
* [docs/标准系统如何添加一个模块.md · OpenHarmony/build - 码云 - 开源中国 (gitee.com)](https://gitee.com/openharmony/build/blob/master/docs/标准系统如何添加一个模块.md) 