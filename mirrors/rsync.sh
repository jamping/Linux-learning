#!/bin/bash

#alpine
[ -d /data/www/alpine/ ] || mkdir -p /data/www/alpine/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/alpine/ /data/www/alpine/
createrepo --update /data/www/alpine/

#anaconda
[ -d /data/www/anaconda/ ] || mkdir -p /data/www/anaconda/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/anaconda/ /data/www/anaconda/
createrepo --update /data/www/anaconda/

#archlinux
[ -d /data/www/archlinux/ ] || mkdir -p /data/www/archlinux/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/archlinux/ /data/www/archlinux/
createrepo --update /data/www/archlinux/

#archlinuxarm
[ -d /data/www/archlinuxarm/ ] || mkdir -p /data/www/archlinuxarm/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/ /data/www/archlinuxarm/
createrepo --update /data/www/archlinuxarm/

#archlinuxcn
[ -d /data/www/archlinuxcn/ ] || mkdir -p /data/www/archlinuxcn/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/ /data/www/archlinuxcn/
createrepo --update /data/www/archlinuxcn/

#apache
[ -d /data/www/apache/ ] || mkdir -p /data/www/apache/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/apache/ /data/www/apache/
createrepo --update /data/www/apache/

#centos
[ -d /data/www/centos/ ] || mkdir -p /data/www/centos/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/centos/ /data/www/centos/
createrepo --update /data/www/centos/

#CRAN
[ -d /data/www/CRAN/ ] || mkdir -p /data/www/CRAN/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/CRAN/ /data/www/CRAN/
createrepo --update /data/www/CRAN/

#cygwin
[ -d /data/www/cygwin/ ] || mkdir -p /data/www/cygwin/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/cygwin/ /data/www/cygwin/
createrepo --update /data/www/cygwin/

#debian
[ -d /data/www/debian/ ] || mkdir -p /data/www/debian/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/debian/ /data/www/debian/
createrepo --update /data/www/debian/

#deepin
[ -d /data/www/deepin/ ] || mkdir -p /data/www/deepin/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/deepin/ /data/www/deepin/
createrepo --update /data/www/deepin/

#docker-ce
[ -d /data/www/docker-ce/ ] || mkdir -p /data/www/docker-ce/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/docker-ce/ /data/www/docker-ce/
createrepo --update /data/www/docker-ce/

#epel
[ -d /data/www/epel/ ] || mkdir -p /data/www/epel/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/epel/ /data/www/epel/
createrepo  --update /data/www/epel/

#elrepo
[ -d /data/www/elrepo/ ] || mkdir -p /data/www/elrepo/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/elrepo/ /data/www/elrepo/
createrepo --update /data/www/elrepo/

#fedora
[ -d /data/www/fedora/ ] || mkdir -p /data/www/fedora/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/fedora/ /data/www/fedora/
createrepo --update /data/www/fedora/

#gnu
[ -d /data/www/gnu/ ] || mkdir -p /data/www/gnu/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/gnu/ /data/www/gnu/
createrepo --update /data/www/gnu/

#kali
[ -d /data/www/kali/ ] || mkdir -p /data/www/kali/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/kali/ /data/www/kali/
createrepo --update /data/www/kali/
 
#kernel
[ -d /data/www/kernel/ ] || mkdir -p /data/www/kernel/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/kernel/ /data/www/kernel/
createrepo --update /data/www/kernel/

#mariadb
[ -d /data/www/mariadb/ ] || mkdir -p /data/www/mariadb/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/mariadb/ /data/www/mariadb/
createrepo --update /data/www/mariadb/

#mongodb
[ -d /data/www/mongodb/ ] || mkdir -p /data/www/mongodb/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/mongodb/ /data/www/mongodb/
createrepo --update /data/www/mongodb/

#mysql
[ -d /data/www/mysql/ ] || mkdir -p /data/www/mysql/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/mysql/ /data/www/mysql/
createrepo --update /data/www/mysql/

#nodesource
[ -d /data/www/nodesource/ ] || mkdir -p /data/www/nodesource/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/nodesource/ /data/www/nodesource/
createrepo --update /data/www/nodesource/

#percona
[ -d /data/www/percona/ ] || mkdir -p /data/www/percona/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/percona/ /data/www/percona/
createrepo --update /data/www/percona/

#postgresql
[ -d /data/www/postgresql/ ] || mkdir -p /data/www/postgresql/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/postgresql/ /data/www/postgresql/
createrepo --update /data/www/postgresql/

#puppy
[ -d /data/www/puppy/ ] || mkdir -p /data/www/puppy/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/puppy/ /data/www/puppy/
createrepo --update /data/www/puppy/

#pypi
[ -d /data/www/pypi/ ] || mkdir -p /data/www/pypi/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/pypi/ /data/www/pypi/
createrepo --update /data/www/pypi/

#repoforge
[ -d /data/www/repoforge/ ] || mkdir -p /data/www/repoforge/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/repoforge/ /data/www/repoforge/
createrepo --update /data/www/repoforge/

#rpmfusion
[ -d /data/www/rpmfusion/ ] || mkdir -p /data/www/rpmfusion/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/rpmfusion/ /data/www/rpmfusion/
createrepo --update /data/www/rpmfusion/

#saltstack
[ -d /data/www/saltstack/ ] || mkdir -p /data/www/saltstack/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/saltstack/ /data/www/saltstack/
createrepo --update /data/www/saltstack/

#ubuntu
[ -d /data/www/ubuntu/ ] || mkdir -p /data/www/ubuntu/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/ubuntu/ /data/www/ubuntu/
createrepo --update /data/www/ubuntu/

#ubuntu-releases 
[ -d /data/www/ubuntu-releases/ ] || mkdir -p /data/www/ubuntu-releases/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/ /data/www/ubuntu-releases/
createrepo --update /data/www/ubuntu-releases/

#virtualbox
[ -d /data/www/virtualbox/ ] || mkdir -p /data/www/virtualbox/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/virtualbox/ /data/www/virtualbox/
createrepo --update /data/www/virtualbox/

#zabbix
[ -d /data/www/zabbix/ ] || mkdir -p /data/www/zabbix/
rsync -avz  --delete rsync://mirrors.tuna.tsinghua.edu.cn/zabbix/ /data/www/zabbix/
createrepo --update /data/www/zabbix/