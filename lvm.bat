CentOS 7 LVM扩容

实验环境：Oracle VM VirtualBox
系统平台：CentOS 7
mdadm 版本：mdadm - v4.0-5.el7.x86_64
LVM 版本：lvm2-2.02.166-1.el7.x86_64

1、磁盘准备：创建5个2G的虚拟磁盘
2、安装LVM和Raid管理工具
rpm -qa|grep lvm || yum install -y lvm*
rpm -qa|grep mdadm || yum install -y mdadm
3、5个新建磁盘做raid5
fdisk -l
使用/dev/sdb, /dev/sdc, /dev/sdd, /dev/sde 做Raid 5,/dev/sdf做热备。
mdadm -C /dev/md5 -ayes -l5 -n4 -x1 /dev/sd[b,c,d,e,f]
写入RAID配置文件/etc/mdadm.conf保存信息
echo DEVICE /dev/sd{b,c,d,e,f} >> /etc/mdadm.conf
mdadm –Ds >> /etc/mdadm.conf
4、格式化
fdisk /dev/md5 (文件类型选8e lvm格式)
partprobe    (这一步很重要！强制让核心重新捉一次 partition table)
fdisk -l
5、创建PV
pvcreate /dev/md5 
pvdisplay 查看PV
6、VG扩容
vgextend cl /dev/md5 （cl为原来VG）
vgdisplay
7、LV扩容
lvdisplay
lvextend -l +1534 /dev/cl/root (1534为Free PE值,/dev/cl/root为需要扩容的LV卷)
查看磁盘 df -Th，这时没有变化，需要对文件系统扩容
resize2fs /dev/cl/root (ext文件系统)
xfs_growfs /dev/cl/root (xfs文件系统)



