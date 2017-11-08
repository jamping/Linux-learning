#!/bin/bash
#auto drop ssh failed IP address
#added by jjp 2017.11.08
#定义变量
SEC_FILE=/var/log/secure
#如下为截取 secure 文件恶意 ip 远程登录 22 端口,大于等于 4次就写入防火墙,禁止以后再登录服务器的 22 端口
IP_ADDR=`tail -n 1000 /var/log/secure | grep "Failed password" | egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort -nr | uniq -c | awk ' $1>=4 {print $2}'`
IPTABLE_CONF=/etc/sysconfig/iptables

echo 
cat <<EOF
++++++++++++++welcome to use ssh login drop failed ip+++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+++++++++++++++++------------------------------------+++++++++++++++++++++++++++++
EOF

echo -n "请等待 5 秒后开始执行 "
for ((j=0;j<=4;j++)) ;do echo -n "----------";sleep 1 ;done
echo
for i in $IP_ADDR
do
#查看 iptables 配置文件是否含有提取的 IP 信息
cat $IPTABLE_CONF | grep $i >/dev/null
if [ $? -ne 0 ];then
#判断 iptables 配置文件里面是否存在已拒绝的 ip,如何不存在就再添加相应条目
sed -i "/lo/a -A INPUT -s $i -m state --state NEW -m tcp -p tcp --dport 22 -j DROP" $IPTABLE_CONF
else
#如何存在的话,就打印提示信息即可
echo "This is $i is exist in iptables,please exit ......"
fi
done
#最后重启 iptables 生效
/etc/init.d/iptables restart
