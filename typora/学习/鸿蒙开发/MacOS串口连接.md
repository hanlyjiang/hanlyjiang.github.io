# MAC OS X 如何使用USB串口设备



## 本机连接

1. 打开terminal

2. 查找usb serial 设备

    ```shell
    $ ls /dev/cu.usbserial-*
    /dev/cu.usbserial-144420
    ```
    
3. 使用screen 连接 usb serial

    ```undeshellfined
    screen -L /dev/cu.usbserial-144420 115200 –L
    ```
    
4. 进入 screen 后按两次enter 。

5. 退出：先按 ==Ctrl + A== ，然后 ==Ctrl + K==。

![image-20211111103552012](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20211111103554.png)



## 虚拟机连接

![image-20211111103421077](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20211111103425.png)