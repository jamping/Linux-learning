#!/bin/bash
#
#

PATH=/sbin:/usr/local/sbin:/usr/sbin:/usr/bin:/bin

# ----- Custom Config -----
role="all"          		# all|admin|cms|web/app|www|mysql|video，参考 Install.txt
dbhost="localhost"			# 数据库服务器IP，默认localhost, 数据库服务器独立，请填写数据库服务器内网IP
redishost="127.0.0.1"		# Redis服务器IP，默认127.0.0.1, 非本机，请填写 Redis服务器内网IP
nlpshost="127.0.0.1"		# nlp服务器IP，  默认127.0.0.1, 非本机，请填写 Nlp服务器内网IP(一般跟数据库服务器保持一致)
domain="zzb.hj"
<<<<<<< HEAD
ADMIN="sitepub"
=======
ADMIN="pubstage"
>>>>>>> 606baba96435932aa08ae6a3cc24b47a1b5a65ae
htdocs="/data/www"
mysql="/data/mysql"
nlpdata="/data/nlp"
backup="/backup"
NLP="Nlp.zip"
TimeZone="/usr/share/zoneinfo/Asia/Shanghai"    # 时区，国外服务器请置空
ADMIN_PORT=                                     # 后台端口，如果要使用80，请填写80; 默认为空即随机
ADMIN_PORT=${ADMIN_PORT:=$(($RANDOM%10000))}
# ChineseSupport=0                                # 是否安装中文支持: 1是，0否(默认)

# ----- Ads Config -----
company_name=""
company_url=""
user_email=""
email_cc=""
user_password=""

# ----- Install Config -----
INSTALLDIR="/usr/local/server"
LOGDIR="/var/log/server"
YUM="/etc/yum.repos.d"
SRC="/usr/local/src"
CURDIR="$CURDIR"

# ----- DB Config -----
DB_HOST="localhost"
DB_USER="_video"
DB_PASS="video_pass"
DB_NAME="_video"
ROOT_PASS="root_pass"

# ----- Net Adapter Config -----
for net in $(ls /etc/sysconfig/network-scripts/ifcfg-e*);do sed -i 's#^ONBOOT=.*#ONBOOT=yes#' $net; done
grep ^ONBOOT /etc/sysconfig/network-scripts/ifcfg-eth*

# ----- Net Adapter Config -----
ipaddress=$(ifconfig|grep 'inet addr:'|awk '{print $2}'|tr -d 'addr:'|grep '^10\.\|^192\.\|^172\.'|sed 's#^# #g'|tr -d '\n')

# ----- DNS Config -----
grep 202.106.0.20    /etc/resolv.conf||echo 'nameserver 202.106.0.20' >> /etc/resolv.conf
grep 219.141.136.10  /etc/resolv.conf||echo 'nameserver 219.141.136.10' >> /etc/resolv.conf
grep 114.114.114.114 /etc/resolv.conf||echo 'nameserver 114.114.114.114' >> /etc/resolv.conf
grep 8.8.8.8         /etc/resolv.conf||echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
grep 4.4.4.4         /etc/resolv.conf||echo 'nameserver 4.4.4.4' >> /etc/resolv.conf

# ----- DateTime Config for inland Server -----
netstat -antp|grep LISTEN|grep ntpd && /etc/init.d/ntpd stop
chkconfig ntpd off
[ -f /etc/localtime -a ! -f /etc/localtime.default ] && cp /etc/localtime /etc/localtime.default
[ -f /etc/localtime -a -f $TimeZone ] && mv /etc/localtime /etc/localtime.$(date +%F_%T)
[ -f $TimeZone ] && \cp $TimeZone /etc/localtime
/usr/sbin/ntpdate us.pool.ntp.org
hwclock --systohc

# ----- Limits Config -----
grep '# Custom Limits' /etc/security/limits.conf> /dev/null 2>&1 ||cat >> /etc/security/limits.conf <<LIMITS
# Custom Limits $(date +%F_%T)
*   soft    nproc  65535
*   hard    nproc  65535
*   soft    nofile  65535
*   hard    nofile  65535
LIMITS
ulimit -HSn 65535

# ----- Charset Config -----
[ -f /etc/sysconfig/i18n -a ! -f /etc/sysconfig/i18n.default ] && mv /etc/sysconfig/i18n /etc/sysconfig/i18n.default
[ -f '/etc/sysconfig/i18n' ] && mv /etc/sysconfig/i18n /etc/sysconfig/i18n.$(date +%F_%T)
cat > /etc/sysconfig/i18n <<I18N
LANG="zh_CN.UTF-8"
LC_ALL="zh_CN.UTF-8"
LC_LANG="zh_CN.UTF-8"
LC_CTYPE="zh_CN.UTF-8"
LC_NUMERIC="zh_CN.UTF-8"
LC_TIME="zh_CN.UTF-8"
LC_COLLATE="zh_CN.UTF-8"
LC_MONETARY="zh_CN.UTF-8"
LC_MESSAGES="zh_CN.UTF-8"
LC_PAPER="zh_CN.UTF-8"
LC_NAME="zh_CN.UTF-8"
LC_ADDRESS="zh_CN.UTF-8"
LC_TELEPHONE="zh_CN.UTF-8"
LC_MEASUREMENT="zh_CN.UTF-8"
LC_IDENTIFICATION="zh_CN.UTF-8"
SYSFONT="latarcyrheb-sun16"
SUPPORTED="zh_CN:zh:en_US.UTF-8:en_US:en:zh_CN.GB18030"
#SUPPORTED="zh_HK.UTF-8:zh_HK:zh:zh_CN.UTF-8:zh_CN:zh:zh_SG.UTF-8:zh_SG:zh:zh_TW.UTF-8:zh_TW:zh:en_US.UTF-8:en_US:en"
#SYSFONT="lat0-sun16"
I18N
source /etc/sysconfig/i18n

# ------ Color Config ------
grep '^# Custom Color Config' /etc/profile>/dev/null 2>&1 || cat >> /etc/profile <<COLOR

# Custom Color Config $(date +%F_%T)
export red='\e[1;31m'
export redbg='\e[1;41m'
export blue='\e[1;34m'
export bluebg='\e[1;44m'
export green='\e[1;32m'
export greenbg='\e[1;42m'
export eol='\e[0m'
COLOR
source /etc/profile

# ------ Check Server Distribution ------
x86_64=`uname -i`
distribution=`cat /etc/redhat-release|awk '{print $1}'`
release=''
_ERROR=""
[ "$distribution" == "CentOS" ] && release=`cat /etc/redhat-release|awk '{print int($3)}'`
[ "$distribution" == "Red" ] && release=`cat /etc/redhat-release|awk '{print int($7)}'`
[ "$distribution" != "CentOS" ] && [ "$distribution" != "Red" ] && _ERROR="${redbg}${green}Error: System not CentOS or RedHat, please check distribution...{$eol}"
[ "$_ERROR" != "" ] && echo -e $_ERROR

# ----- Check Root User Privileges -----
if [ $(id -u) != 0 ]; then
    echo -e "${redbg}${green}Error: You Must Be root To Run This Script, su root Please ...{$eol}"
    exit 1
fi

# ----- Check The Domain And Admin -----
if [ -z $domain ]; then
	echo -e "${redbg}${green}Error: You Should Define The Domain IN shell/config.sh First ...{$eol}"
	exit 1
fi
if [ "$domain" == ".ccc" -o "$ADMIN" == "admin" -o  "$ADMIN" == "backyard" ]; then
    echo -e "${redbg}${green}Error: You Should Change \"domain\" and \"admin\"  IN shell/config.sh First ...{$eol}"
    exit 1
fi
if [ $domain == '.ccc' ]; then
	echo -e "${redbg}${green}Error:  Default Domain is .ccc, Please Modifiy ...{$eol}"
	exit 1
fi

# ------ Clear Install Log -----
[ -f $CURDIR/install.log ] && mv $CURDIR/install.log $CURDIR/install.log.$(date +%F_%T)

# ------ Add Defination to Env -----
grep '^# Custom Config' /etc/profile >/dev/null 2>&1||cat >> /etc/profile <<CONFIG

# Custom Config $(date +%F_%T)
CURDIR="$CURDIR"
role="$role"
domain="$domain"
ADMIN="$ADMIN"
htdocs="$htdocs"
mysql="$mysql"
backup="$backup"
nlpdata="$nlpdata"
ISWAF="$ISWAF"
ADMIN_PORT="$ADMIN_PORT"
TimeZone="$TimeZone"
CONFIG

grep '^# Install Config' /etc/profile >/dev/null 2>&1||cat >> /etc/profile <<INSTALL

# Install Config $(date +%F_%T)
INSTALLDIR="$INSTALLDIR"
LOGDIR="$LOGDIR"
YUM="$YUM"
SRC="$SRC"
CURDIR="$CURDIR"
INSTALL

grep '^# Hosts Config' /etc/hosts >/dev/null 2>&1||cat >> /etc/hosts <<HOSTS

# Hosts Config $(date +%F_%T)
127.0.0.1 $ADMIN.$domain
#127.0.0.1 app.$domain m.$domain api.$domain
#127.0.0.1 img.$domain upload.$domain www.$domain
HOSTS
[ "$role" == "" ] && echo '' >> /etc/hosts

[ "$0" == "Server-v.sh" -a "$(grep '^# Video Config' /etc/profile)" == 0 ] && cat >> /etc/profile <<VIDEO

# ----- Video Config -----
DB_HOST="$DB_HOST"
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DB_NAME="$DB_NAME"
ROOT_PASS="$ROOT_PASS"
VIDEO

source /etc/profile

# alias
grep '^# Custom Alias' ~/.bashrc >/dev/null 2>&1 || cat >> ~/.bashrc <<ALIAS

# Custom Alias $(date +%F_%T)
alias vi="/usr/bin/vim"
alias tophp="cd $INSTALLDIR/php"
alias tomysql="cd $INSTALLDIR/mysql"
alias tonginx="cd $INSTALLDIR/nginx"
alias toweb="cd $htdocs"
alias tolog="cd $LOGDIR"
ALIAS
source ~/.bashrc

# @todo: 完善vim配置文件
# ~/.vimrc
grep '^# Custom vimrc' ~/.vimrc >/dev/null 2>&1 || cat >> ~/.vimrc <<VIMRC
" # Custom .vimrc $(date +%F_%T)
" Fix Backspace for MacOSX
" set backspace=indent,eol,start  
" filetype on
syntax on set termencoding=utf-8
VIMRC
