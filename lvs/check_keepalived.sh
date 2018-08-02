#!/bin/bash
vip=192.168.0.38

while true
do
if [ `ip a show eth0 |grep $vip|wc -l` -ne 0 ]
then
    echo "keepalived is error!"
else
    echo "keepalived is OK !"
fi
done