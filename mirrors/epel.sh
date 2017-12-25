#!/bin/bash

#epel
[ -d /data/www/epel/ ] || mkdir -p /data/www/epel/
rsync -avz --exclude-from=/data/www/exclude.list rsync://mirrors.tuna.tsinghua.edu.cn/epel//data/www/epel/
createrepo  /data/www/epel/