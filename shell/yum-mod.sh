#!/bin/bash
#
#

PATH=/sbin:/usr/local/sbin:/usr/sbin:/usr/bin:/bin

# ------ Check SELinux Status -----
selinux=$(sestatus | awk '{print $3}')
if [ "$selinux" != "disabled" ]; then
    sed -i "s#SELINUX=.*#SELINUX=disabled#g" /etc/selinux/config
    echo -e "${redbg}${green}Error: SELinux is Enforcing, \"/etc/selinux/config\" has been changed, you need to reboot and try again... ${eol}"
    exit 1
fi

# ----- Check The Nlp Software -----
#if [ ! -f $CURDIR/$NLP ]; then
#    echo -e "${redbg}${green}Error: Your Tar Don't Have The NLP Software: \"$CURDIR/$NLP\" ...{$eol}"
#    exit 1
#fi

# ------ Check Installation -----
IS_INSTALLED=0
netstat -antp|grep LISTEN|grep mysqld && echo -e "${redbg}${green}Error: mysqld is already running, please stop and uninstall first... ${eol}" && IS_INSTALLED=1
netstat -antp|grep LISTEN|grep httpd && echo -e "${redbg}${green}Error: httpd is already running, please stop and uninstall first... ${eol}" && IS_INSTALLED=1 
netstat -antp|grep LISTEN|grep nginx && echo -e "${redbg}${green}Error: nginx is already running, please stop and uninstall first... ${eol}" && IS_INSTALLED=1 
netstat -antp|grep LISTEN|grep 'php-fpm\|php-cgi' && echo -e "${redbg}${green}Error: php-fpm is already running, please and uninstall stop first... ${eol}" && IS_INSTALLED=1
netstat -antp|grep LISTEN|grep redis && echo -e "${redbg}${green}Error: redis is already running, please stop and uninstall first... ${eol}" && IS_INSTALLED=1
[ "$IS_INSTALLED" != "0" ] && exit 1

# ----- Create Directories -----
[ -d $INSTALLDIR ] || mkdir -p $INSTALLDIR
[ -d $LOGDIR ] || mkdir -p $LOGDIR
[ -d $SRC ] || mkdir -p $SRC

# ----- Create repo for localinstall -----
[ "$1" != "" -a -f "/etc/yum.repos.d/$1.repo" ] && mv /etc/yum.repos.d/$1.repo /etc/yum.repos.d/$1.repo.$(date +%F_%T)
[ "$1" != "" ] && cat > /etc/yum.repos.d/$1.repo <<REPO
[$1]
name=$1
baseurl=file:///mirrors/
enable=1
gpgcheck=0
REPO

# ----- Yum Hosts -----
grep 208.74.123.74  /etc/hosts > /dev/null 2>&1 || echo "208.74.123.74 mirror.centos.org" >> /etc/hosts
grep 182.92.105.31   /etc/hosts > /dev/null 2>&1 || echo "182.92.105.31 mirrors.cmstop" >> /etc/hosts
grep 78.46.17.228   /etc/hosts > /dev/null 2>&1 || echo "78.46.17.228 pkgs.repoforge.org tree.repoforge.org rpmforge.sw.be" >> /etc/hosts
grep 193.1.193.67   /etc/hosts > /dev/null 2>&1 || echo "193.1.193.67 apt.sw.be" >> /etc/hosts
grep 5.77.39.20     /etc/hosts > /dev/null 2>&1 || echo "5.77.39.20 pear.php.net" >> /etc/hosts

# ----- yum Installing -----
# wget http://mirrors.sohu.com/help/CentOS-Base-sohu.repo
# rpm --import http://mirrors.sohu.com/centos/RPM-GPG-KEY-CentOS-5
# curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
# curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 

# just for centos6 x86_64
[ "$1" == "mruse" -a "$release" == "6" -a  "$(uname -i)" == 'x86_64' ] && sed -i 's#baseurl=.*#baseurl=http://mirrors.mruse.cn:8080/centos/6/x86_64/#g' /etc/yum.repos.d/$1.repo

#yum_param="-C --nogpgcheck --noplugins --skip-broken "
[ "$1" != "" ] && yum_param=$yum_param"--disablerepo=* --enablerepo=$1 "
#[ "$1" != "" ] && sed -i 's#^keepcache=.*#keepcache=1#g' /etc/yum.conf
[ "$1" != "" ] && yum clean all
[ "$1" != "" ] && yum $yum_param -y update

#[ $ChineseSupport -eq 1 ] && yum $yum_param -y install "@Chinese Support" chinese-support fonts-chinese cracklib-dicts

yum $yum_param -y update
yum $yum_param -y update bash glibc* nscd kernel-devel
yum $yum_param -y install ntp ntpdate man createrepo at vsftpd inotify-tools subversoin parted tree
yum $yum_param -y install vim lrzsz wget zip unzip mlocate dos2unix unix2dos dmidecode lshw
yum $yum_param -y install chkconfig vixie-cron crontabs screen tree e2fsprogs sed ftp sar oprofiled
yum $yum_param -y install tcpdump telnet sysstat lsof strace iptraf iotop ifstat openssh-clients

yum $yum_param -y install setuptool ntsysv system-config-firewall-tui system-config-network-tui gcc gcc-c++ 
yum $yum_param -y install autoconf automake make cmake libtool libXaw dialog expect expat-devel
yum $yum_param -y install libevent libevent-devel patch rsync httpd sendmail
yum $yum_param -y install vsftpd ipvsadm keepalived

cd $CURDIR/tar/
# release=`cat /etc/redhat-release|awk '{print int($3)}'`
if [ "$1" == "" ]; then
    case $release in
        6)
        if [ `uname -m` == 'x86_64' ]; then
            [ -f rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm ] || wget http://repository.it4i.cz/mirrors/repoforge/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
            rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
        else
            [ -f rpmforge-release-0.5.3-1.el5.rf.i386.rpm ] || wget http://repository.it4i.cz/mirrors/repoforge/redhat/el6/en/i386/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
            rpm -ivh rpmforge-release-0.5.3-1.el6.rf.i686.rpm
        fi
        ;;
        7)        
            [ -f rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm ] || wget http://repository.it4i.cz/mirrors/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
            rpm -ivh rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm        
        ;;
        *);;
    esac
fi

yum $yum_param -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel
yum $yum_param -y install glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn 
yum $yum_param -y install libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libpcap libpcap-devel
yum $yum_param -y install libmcrypt libmcrypt-devel readline-devel pcre-devel net-snmp net-snmp-devel memcached
yum $yum_param -y install libtool-ltdl-devel libaio libaio-devel bison gd-devel perl perl-devel perl-ExtUtils-Embed
yum $yum_param -y install nfs* portmap* rpcbind* java
yum $yum_param -y install rkhunter chkrootkit tripwire neon apr apr-util fail2ban

# Clear hosts
sed -i 's#123.58.173.186.*##g' /etc/hosts
sed -i 's#208.74.123.74.*##g' /etc/hosts
sed -i 's#182.92.105.31.*##g' /etc/hosts
sed -i 's#78.46.17.228.*##g' /etc/hosts
sed -i 's#193.1.193.67.*##g' /etc/hosts
sed -i 's#5.77.39.20.*##g' /etc/hosts
sed -i  '/^$/d' /etc/hosts
