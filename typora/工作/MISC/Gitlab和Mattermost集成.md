# Gitlab关联Mattermost操作指南

本文介绍如何将Gitlab集成到mattermost，集成完毕后，mattermost中会接收到Gitlab中活动的消息推送。

## 登录Mattermost

登录地址：http://172.17.0.206:8000

登录方式：使用Gitlab账号进行第三方登录

## 创建团队

- Mattermost登录成功后，即系统会引导您加入现有团队或创建一个新的团队。

  <img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101227.png" alt="image-20210302101227242" style="zoom:67%;" />

点击【创建一个新的团队】。

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101240.png" alt="image-20210302101240101" style="zoom:67%;" />

- 输入团队名称，点击【下一步】

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101246.png" alt="image-20210302101246518" style="zoom:67%;" />

- 输入团队的URL，点击【完成】。

![image-20210302101253267](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101253.png)

这样就完成了团队创建。点击左侧菜单的三个横杠，可以弹出主菜单，进行相关操作。

## 集成Gitlab项目

通过本节的设置，Gitlab项目的各种事件（Push、Issue、Merge request等）都会推送到Mattermost团队的指定频道。

说明：本节设置需要Mattermost的system_admin权限，以及Gitlab项目的Owner权限。

### 配置Mattermost传入WebHook

- 点击团队主菜单按钮，点击【集成 Integration】

![image-20210302101258518](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101258.png)

- 点击【传入WebHook】

![image-20210302101302570](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101302.png)

- 点击【添加引入勾子】

![image-20210302101307123](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101307.png)

- 填写传入WebHook标题、描述以及推送的频道，这里选择“公共频道”。频道可以是默认的“公共频道”、“闲聊”频道，也可以是自己创建的频道，填写完成后点击【保存】按钮。

![image-20210302101311615](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101311.png)

- 保存成功后会在页面显示传入WebHook的URL地址，复制该地址，在后面的Gitlab配置中会使用到。复制的值为：http://172.17.0.206:8000/hooks/hq99qmcq5inhienok8ojdowc6y

![image-20210302101318252](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101318.png)

### 配置Gitlab项目 



- 在Gitlab项目的首页，点击【设置】-【集成】

![image-20210302101324061](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101324.png)

- 在集成页面里，一直往下拉，找到【Project Services】部分，再往下拉找到【Mattermost notifications】

![image-20210302101329252](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101329.png)

- 点击【Mattermost notifications】进入配置页面。选中【Active】选项，并在下面的【WebHook】输入框中输入Mattermost配置中获取的WebHook地址：http://172.17.0.206:8000/hooks/hq99qmcq5inhienok8ojdowc6y

![image-20210302101333903](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101333.png)







![image-20210302103554732](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302103554.png)





- 点击【保存】，即完成Mattermost与Gitlab项目的集成。Gitlab项目中事件都会推送到团队的“公共频道”中。

### 验证测试

这里提交一个Issue来进行测试，验证Mattermost是否能够收到推送。

- 在Gitlab项目页面点击【议题 Issue】，点击【新建议题 New Issue】，输入标题和描述后，点击【提交议题 Submit Issue】

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101339.png" alt="image-20210302101339039" style="zoom: 80%;" />

- 提交Issue后，可以在Mattermost团队的公共频道查看到提交的Issue通知。

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302101343.png" alt="image-20210302101343116" style="zoom:80%;" />

- 可以看到Issue提交通知，说明Mattermost和Issue集成成功。

