#!/bin/bash

#epel
[ -d /data/www/epel/6/ ] || mkdir -p /data/www/epel/6/
rsync -avz --exclude-from=/data/www/exclude.list rsync://mirrors.tuna.tsinghua.edu.cn/epel/6/ /data/www/epel/6/
createrepo --update /data/www/epel/6/

[ -d /data/www/epel/7/ ] || mkdir -p /data/www/epel/7/
rsync -avz --exclude-from=/data/www/exclude.list rsync://mirrors.tuna.tsinghua.edu.cn/epel/7/ /data/www/epel/7/
createrepo --update /data/www/epel/7/
