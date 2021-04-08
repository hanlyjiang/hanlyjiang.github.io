# TB&Gitlab&Mattermost项目关联设置



## Teambition关联Gitlab

### Teambition开启【集成代码仓库】插件

TB项目需开启【集成代码仓库插件】获取Webhook地址及Secert

* 项目菜单中点击项目应用

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101806.png" alt="image-20210302101806253" style="zoom:50%;" />

* 搜索“集成代码仓库”插件，并安装

  <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101903.png" alt="image-20210302101903645" style="zoom:50%;" />

* 再次进入项目菜单，点击“集成代码仓库”，获取URL及Secret；

  <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101954.png" alt="image-20210302101954459" style="zoom:50%;" />

  <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302102027.png" alt="image-20210302102027833" style="zoom:50%;" />

### Gitlab集成Teambition Webhooks

项目设置中添加TB项目的Webhook

* 在需要关联Teambition的gitlab项目中打开Webhooks设置，填入上一步获取到的URL及Secret，并勾选`Merge request events`，并保存webhooks

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302102232.png" alt="image-20210302102232159" style="zoom:50%;" />

* 新建合并请求，并在Gitlab合并请求的标题中包含对应Teambition项目中某一任务的任务ID，如 #IMC-41，提交合并请求

![image-20210225141504404](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302102454.png)

* 提交合并请求后查看对应的Teambition任务中是否关联了对应的合并请求

  <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210225144541.png" alt="image-20210225144541305"  />

## Gitlab关联Mattermost

请阅读：[Gitlab和Mattermost集成](Gitlab和Mattermost集成.md)



## 参考

* [TB-项目内支持集成 Git 类代码库](https://blog.teambition.com/web-9-15-0) 