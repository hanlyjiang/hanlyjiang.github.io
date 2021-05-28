# [Linux下使用fdisk扩展分区容量](https://www.linuxprobe.com/linux-fdisk-size.html)



| 导读 | **我们管理的服务器可能会随着业务量的不断增长造成磁盘空间不足的情况，比如：共享文件服务器硬盘空间不足，在这个时候我们就需要增加磁盘空间，来满足线上的业务；又或者我们在使用[linux](https://www.linuxprobe.com/)的过程中, 有时会因为安装系统时分区不当导致有的分区空间不足,而有的分区空间过剩的情况，都可以是使用fdisk分区工具来动态调整分区的大小；** |
| ---- | ------------------------------------------------------------ |

## **扩展磁盘空间**

**硬盘空间为20G，使用vSphere Client增加磁盘大小，需要再增加10G空间;**
![Linux下使用fdisk扩展分区容量Linux下使用fdisk扩展分区容量](https://www.linuxprobe.com/wp-content/uploads/2016/05/fdisk_l-20G.png)![Linux下使用fdisk扩展分区容量Linux下使用fdisk扩展分区容量](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524100228.png)

**扩展完后，重启系统，再次使用fdisk -l查看，会发现硬盘空间变大了；**

```shell
[root@linuxprobe ~]# fdisk -l
Disk /dev/sda: 32.2 GB, 32212254720 bytes
255 heads, 63 sectors/track, 3916 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0005210c

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          26      204800   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/sda2              26        1301    10240000   83  Linux
/dev/sda3            1301        1497     1572864   82  Linux swap / Solaris
/dev/sda4            1497        2611     8952832   83  Linux
[root@linuxprobe ~]# df -hT
Filesystem     Type   Size  Used Avail Use% Mounted on
/dev/sda2      ext4   9.7G  1.5G  7.7G  16% /
tmpfs          tmpfs  939M     0  939M   0% /dev/shm
/dev/sda1      ext4   194M   34M  151M  19% /boot
/dev/sda4      ext4   8.5G  148M  7.9G   2% /data
```

![Linux下使用fdisk扩展分区容量Linux下使用fdisk扩展分区容量](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524100237.png)

## **重新创建分区，调整分区信息**

**本次实验主要对/dev/sda4这个分区扩展，如果是生产环境，请提前做好备份保存到其他分区，虽然扩展分区大小不会导致数据丢失，安全起见，请提前做好备份；
首先模拟出一些数据：**

```shell
[root@linuxprobe data]# mkdir test
[root@linuxprobe data]# echo "we are Linuxer" > linuxprobe
[root@linuxprobe data]# ll
total 24
-rw-r--r--. 1 root root    15 May 23 21:59 linuxprobe
drwx------. 2 root root 16384 May 23 15:07 lost+found
drwxr-xr-x. 2 root root  4096 May 23 21:51 test
[root@linuxprobe ~]# umount /dev/sda4          #卸载磁盘分区
```

若提示磁盘忙，使用fuser找出将正在使用磁盘的程序并结束掉；

```shell
fuser -m -v /data
fuser -m -v -i -k /data
```

**使用fdisk工具先删除/dev/sda4分区，然后创建新分区，注意开始的磁柱号要和原来的一致（是保证数据不丢失的关键步骤），结束的磁柱号默认回车使用全部磁盘。**

```shell
[root@linuxprobe ~]# fdisk /dev/sda

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help): p        #查看分区表信息

Disk /dev/sda: 32.2 GB, 32212254720 bytes
255 heads, 63 sectors/track, 3916 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0005210c

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          26      204800   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/sda2              26        1301    10240000   83  Linux
/dev/sda3            1301        1497     1572864   82  Linux swap / Solaris
/dev/sda4            1497        2611     8952832   83  Linux

Command (m for help): d           #删除分区
Partition number (1-4): 4         #删除第四个

Command (m for help): p       #再次查看分区信息，/dev/sda4已被删除

Disk /dev/sda: 32.2 GB, 32212254720 bytes
255 heads, 63 sectors/track, 3916 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0005210c

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          26      204800   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/sda2              26        1301    10240000   83  Linux
/dev/sda3            1301        1497     1572864   82  Linux swap / Solaris

Command (m for help): n      #创建新的分区
Command action
   e   extended
   p   primary partition (1-4)
p             #创建为主分区
Selected partition 4
First cylinder (1497-3916, default 1497):          #经对比，正好和上一个磁盘柱一致，默认即可
Using default value 1497
Last cylinder, +cylinders or +size{K,M,G} (1497-3916, default 3916): 
Using default value 3916              #直接默认就可以

Command (m for help): p               #查看分区表信息

Disk /dev/sda: 32.2 GB, 32212254720 bytes
255 heads, 63 sectors/track, 3916 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0005210c

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          26      204800   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/sda2              26        1301    10240000   83  Linux
/dev/sda3            1301        1497     1572864   82  Linux swap / Solaris
/dev/sda4            1497        3916    19436582   83  Linux

Command (m for help): wp       #保存并退出，如果创建有误，直接退出不要保存即可
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.
```

![Linux下使用fdisk扩展分区容量Linux下使用fdisk扩展分区容量](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524100242.png)![Linux下使用fdisk扩展分区容量Linux下使用fdisk扩展分区容量](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524100247.png)
**重新创建分区后，需要重启一下；**

```shell
[root@linuxprobe ~]# init 6
[root@linuxprobe ~]# e2fsck -f /dev/sda4                #检查分区信息
[root@linuxprobe ~]# resize2fs -p /dev/sda4             #调整分区大小
```

**重新挂载、查看分区大小、数据**

```shell
[root@linuxprobe ~]# mount /dev/sda4 /data
[root@linuxprobe ~]# df -hT
[root@linuxprobe ~]# cat /data/linuxprobe
we are  Linuxer
```

![Linux下使用fdisk扩展分区容量Linux下使用fdisk扩展分区容量](https://gitee.com/hanlyjiang/image-repo/raw/master/imgs/20210524100251.png)

> 本文原创地址：https://www.linuxprobe.com/linux-fdisk-size.html 作者：岳永，审核员：逄增宝

