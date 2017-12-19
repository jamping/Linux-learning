#!/bin/bash

[ -d /data/www/centos/ ] || mkdir -p /data/www/centos/
rsync -avz --exclude-from=/data/www/exclude.list rsync://mirrors.tuna.tsinghua.edu.cn/centos/ /data/www/centos/
createrepo /data/www/centos/
