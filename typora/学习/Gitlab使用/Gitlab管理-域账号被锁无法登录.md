# Gitlab域账号被锁无法Unblock问题解决方案



## 问题描述

- 实习期员工转试用期，域账号信息发生变化
- Gitlab上登录时提示用户无法登录，需联系管理员

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171204.png" alt="image-20210302171204808" style="zoom:67%;" />





- 管理员账号登录，unblock用户失败，提示： `无法从gitlab手动解禁此用户`

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171236.png" alt="image-20210302171236466" style="zoom:80%;" />

## 解决方法

1. 获取域账号的新的 identify，如何获取请参考下方**补充说明**
2. 使用管理员账号，打开用户的详情页面，http://172.17.0.205/admin/users/huangpengfei/ ，进入用户的identify标签页，删除identify

<img src="https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171256.png" alt="image-20210302171256396"  />



1. 重新解锁用户，提示解锁成功
2. 再次进入identify页面，手动添加**域账号的identify**

![image-20210302171323908](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171323.png)

## 补充说明：获取域账号的identify

1. 下载ApacheDirectoryStudio或者LDAPBrowser，这里使用ApacheDirectoryStudio
2. 在ADS中新建公司域账号的连接，使用个人域账号登录

![image-20210302171454200](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171454.png)

![image-20210302171450044](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171450.png)



3. 搜索对应用户

* 选择 DC=geostar,DC=com,DC=cn

* 选中 “Search Whole Subtree” 按钮
* 在上方搜索中输入 CN = 用户名
* 点击“Search Whole Subtree” 旁边的 “Run Quick Search” 按钮，即可在右侧看到搜索结果，CN，xxxxx , DN=cn 这一串即为用户的LDAP identify

![image-20210302171412940](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171412.png)

![image-20210302171421721](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171421.png)

![image-20210302171427184](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210302171427.png)