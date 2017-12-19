#!/bin/bash

#epel
[ -d /data/www/epel/ ] || mkdir -p /data/www/epel/
rsync -avz  rsync://mirrors.tuna.tsinghua.edu.cn/epel/ /data/www/epel/
createrepo  /data/www/epel/

#centos
[ -d /data/www/centos/ ] || mkdir -p /data/www/centos/
rsync -avz  rsync://mirrors.tuna.tsinghua.edu.cn/centos/ /data/www/centos/
createrepo /data/www/centos/