# gitlab配置纯issues+wiki项目

某些场景下，我们希望某些外部人员能够给我们的项目提issues，但是我们不希望他们看到代码，这中场景下，可以使用如下两种方式进行设置

## 方法一、使用原仓库

1. 给对应的成员Guest角色权限，可以实现对Guest成员隐藏仓库代码；不过从下图中可以看到，用户仍然可以看到流水线；

   ![访客可以看到的菜单](/Users/hanlyjiang/Library/Mobile Documents/com~apple~CloudDocs/Sync/Typora/Images/Gitlab-访客视图.png)

2. 此时我们可以到项目的CI/CD设置中取消公开流水线

   ![image-20210224141331199](/Users/hanlyjiang/Library/Mobile Documents/com~apple~CloudDocs/Sync/Typora/Images/gitab-setting-关闭公开流水线.png)

   设置完成后，访客用户将无法查看流水线

   ![关闭公开流水线后的访客视图](/Users/hanlyjiang/Library/Mobile Documents/com~apple~CloudDocs/Sync/Typora/Images/关闭公开流水线后的访客视图.png)

   

   ## 方式二、新建仓库-关闭仓库可见性

   建立一个新的仓库，关闭仓库的可见性勾选；

   ![image-20210224141706264](/Users/hanlyjiang/Library/Mobile Documents/com~apple~CloudDocs/Sync/Typora/Images/取消仓库的可见性勾选.png)

   关闭仓库可见性后的Guest访客视图，可以看到项目概览中的`发布`菜单入口也没有了；

   ![image-20210224141940008](/Users/hanlyjiang/Library/Mobile Documents/com~apple~CloudDocs/Sync/Typora/Images/关闭仓库后的菜单.png)

