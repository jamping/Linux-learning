#!/bin/bash
#
#
#

########## Function Start ##########
function INSTALL_OTHER()
{

if [ ! -f $INSTALLDIR/php/bin/php ]; then
    echo "${redbg}${green}Error: PHP Install Failed, Check...${eol}"
    exit 1
fi

cd $CURDIR/tar
[ -f libiconv-1.14.tar.gz  ] || wget http://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz 
[ -f coreseek-3.2.14.tar.gz ] || wget http://www.coreseek.cn/uploads/csft/3.2/coreseek-3.2.14.tar.gz
[ -f redis-3.0.2.tar.gz ] || wget http://download.redis.io/releases/redis-3.0.2.tar.gz
[ -f iftop-0.17.tar.gz ] || wget http://www.ex-parrot.com/~pdw/iftop/download/iftop-0.17.tar.gz

rm -rf $SRC/libiconv*
rm -rf $SRC/coreseek*
rm -rf $SRC/redis*
rm -rf $SRC/iftop*

tar -zxvf $CURDIR/tar/libiconv-1.14.tar.gz -C $SRC
tar -zxvf $CURDIR/tar/coreseek-3.2.14.tar.gz -C $SRC
tar -zxvf $CURDIR/tar/redis-3.0.2.tar.gz -C $SRC
tar -zxvf $CURDIR/tar/iftop-0.17.tar.gz -C $SRC

# ----- Coreseek Installing -----
echo "==================== INSTALL_Coreseek ===================="
clear
cd $SRC/libiconv-1.14
./configure --prefix=/usr/local/libiconv --enable-static
make && make install

cd $SRC/coreseek-3.2.14/mmseg-3.2.14
./bootstrap
./configure --prefix=$INSTALLDIR/mmseg
make && make install

cd ../csft-3.2.14
./configure \
--prefix=$INSTALLDIR/coreseek \
--with-mmseg \
--with-mmseg-includes=$INSTALLDIR/mmseg/include/mmseg \
--with-mmseg-libs=$INSTALLDIR/mmseg/lib \
--with-mysql \
--with-mysql-includes=$INSTALLDIR/mysql/include \
--with-mysql-libs=$INSTALLDIR/mysql/lib \
--with-iconv=/usr/local/libiconv

# for RedHat6.3 Error: 
#sed -i  's#^LIBS =.*#LIBS = -lm -lexpat -liconv -L/usr/local/lib#g' ./src/Makefile

make && make install
cp $CURDIR/conf/csft.conf $INSTALLDIR/coreseek/etc/csft.conf
sed -i 's#/usr/local/server#'$INSTALLDIR'#g' $INSTALLDIR/coreseek/etc/csft.conf
cd $SRC/coreseek-3.2.14/csft-3.2.14/api/libsphinxclient/
./buildconf.sh
./configure
make
make install

grep "$INSTALLDIR/coreseek/bin/" /etc/profile || echo 'export PATH=$PATH:'$INSTALLDIR'/coreseek/bin/' >> /etc/profile
source /etc/profile

# iptables: move to iptables-mod.sh
# opened_3312=$(iptables -n -L|grep ':3312\|:searchd'|tr -d '\n')
# line_num22=$(iptables --line-number -n -L|grep :22|awk '{print $1}')
# [ "$intranet" != "" ] && intranet=" -s $intranet"
# if [ "$opened_3312" == "" ]; then
#     iptables -I INPUT $[ $line_num22 + 1 ] -m state --state NEW -m tcp -p tcp $intranet --dport 3312 -j ACCEPT
#     /etc/init.d/iptables save
# fi

# ----- Redis Installing -----
cd $SRC/redis-3.0.2

[ -d "$INSTALLDIR/redis-server" ] || mkdir -p $INSTALLDIR/redis-server
param=''
[ $(uname -i) != "x86_64" ] && param=' CFLAGS="-march=i686" '
make $param PREFIX=$INSTALLDIR/redis-server install
[ -d "$LOGDIR/redis" ] || mkdir -p $LOGDIR/redis
chmod 750 $LOGDIR/redis

ipaddress=$(ifconfig|grep 'inet addr:'|awk '{print $2}'|tr -d 'addr:'|grep '^10\.\|^127\.\|^192\.\|^172\.'|sed 's#^# #g'|tr -d '\n')
[ -f "$INSTALLDIR/redis-server/redis.conf" ] && mv $INSTALLDIR/redis-server/redis.conf $INSTALLDIR/redis-server/redis.conf.$(date +%F_%T)
[ -f /etc/init.d/redis ] && mv /etc/init.d/redis /etc/init.d/redis.$(date +%F_%T)
[ -f /etc/init.d/redis-server ] && mv /etc/init.d/redis-server /etc/init.d/redis-server.$(date +%F_%T)
cp $CURDIR/conf/redis.conf $INSTALLDIR/redis-server/
sed -i 's#/usr/local/server#'$INSTALLDIR'#g' $INSTALLDIR/redis-server/redis.conf
sed -i 's#/var/log/server/redis#'$LOGDIR/redis'#g' $INSTALLDIR/redis-server/redis.conf
grep '^rename-command CONFIG' $INSTALLDIR/redis-server/redis.conf||sed -i '331irename-command CONFIG ""' $INSTALLDIR/redis-server/redis.conf
grep '^bind' $INSTALLDIR/redis-server/redis.conf||sed -i "36ibind $ipaddress" $INSTALLDIR/redis-server/redis.conf

[ -f /etc/init.d/redis-server  -a ! -f /etc/init.d/redis-server.default ] && mv -f /etc/init.d/redis-server /etc/init.d/redis-server.default
[ -f /etc/init.d/redis-server ] && mv -f /etc/init.d/redis-server /etc/init.d/redis-server.$(date +%F_%T)
cp $CURDIR/daemon/redis-server.daemon /etc/init.d/redis-server
sed -i 's#/usr/local/server#'$INSTALLDIR'#g' /etc/init.d/redis-server
chmod 755 /etc/init.d/redis-server

[ -d $LOGDIR/redis ] || mkdir -p $LOGDIR/redis
chmod 750 $LOGDIR/redis

chkconfig redis-server on
/etc/init.d/redis-server restart

grep "$INSTALLDIR/redis-server/bin" /etc/profile || echo 'export PATH=$PATH:'$INSTALLDIR'/redis-server/bin' >> /etc/profile
source /etc/profile

iptables
opened_6379=$(iptables -n -L|grep ':6379\|:redis'|tr -d '\n')
line_num22=$(iptables --line-number -n -L|grep :22|awk '{print $1}')
[ "$intranet" != "" ] && intranet=" -s $intranet"
if [ "$opened_6379" == "" -a "$line_num22" != "" ]; then
    iptables -I INPUT $[ $line_num22 + 1 ] -m state --state NEW -m tcp -p tcp $intranet --dport 6379 -j ACCEPT
    /etc/init.d/iptables save
fi

# ----- Nlp Installing -----
$INSTALLDIR/mysql/bin/mysql -uroot -e "create database if not exists cmstop_nlp default character set utf8 collate utf8_general_ci";
$INSTALLDIR/mysql/bin/mysql -uroot cmstop_nlp < $CURDIR/Nlp/cmstop_nlp.sql;
[ -d "$LOGDIR/nlp" ] || mkdir -p $LOGDIR/nlp
[ -d "$nlpdata" ] || mkdir -p $nlpdata
unzip -o $CURDIR/Nlp.zip -d $CURDIR/
unzip -o $CURDIR/Nlp/initdic.zip -d  $nlpdata/
unzip -o $CURDIR/Nlp/lucenedata.zip -d $nlpdata/
unzip -o $CURDIR/Nlp/tomcat.zip -d $INSTALLDIR/
find $INSTALLDIR//tomcat/ -type d -exec chmod 755 {} \;
find $INSTALLDIR//tomcat/ -type f -exec chmod 644 {} \;
chmod +x $INSTALLDIR/tomcat/bin/*.sh

[ -f "$INSTALLDIR/tomcat/webapps/ROOT/WEB-INF/classes/config.properties" ] && mv $INSTALLDIR/tomcat/webapps/ROOT/WEB-INF/classes/config.properties $INSTALLDIR/tomcat/webapps/ROOT/WEB-INF/classes/config.properties.$(date +%F_%T)
cat > $INSTALLDIR/tomcat/webapps/ROOT/WEB-INF/classes/config.properties <<CONFIGPROPERTY
LogPath=$LOGDIR/nlp/
LuceneDir=$nlpdata/lucenedata
StopWordsFilePath=$nlpdata/initdic/StopWords.txt
docFrq=$nlpdata/initdic/docFrq.txt
docCount=1069126
relateDiff=3
limitFactor=1
oneWordFactor=0.1
numWordFactor=0.5
engWordFactor=0.8
mqWordFactor=0.5
redisHost=localhost
redisPort=6379
redisPwd=111111
CONFIGPROPERTY

[ -f "$INSTALLDIR/tomcat/webapps/ROOT/WEB-INF/classes/library.properties" ] && mv $INSTALLDIR/tomcat/webapps/ROOT/WEB-INF/classes/library.properties $INSTALLDIR/tomcat/webapps/ROOT/WEB-INF/classes/library.properties.$(date +%F_%T)
cat > $INSTALLDIR/tomcat/webapps/ROOT/WEB-INF/classes/library.properties <<LIBRARYPROPERTY
userLibrary=$nlpdata/initdic/default.dic
ambiguityLibrary=$nlpdata/initdic/ambiguity.dic
LIBRARYPROPERTY
# DB
# $INSTALLDIR/tomcat/webapps/ROOT/META-INF/context.xml
# DB
# $INSTALLDIR/tomcat/conf/Catalina/localhost/ROOT.xml
# Start 
$INSTALLDIR/tomcat/bin/startup.sh
grep ^$INSTALLDIR/tomcat/bin/startup.sh /etc/rc.local || echo "$INSTALLDIR/tomcat/bin/startup.sh" >> /etc/rc.local

grep "$INSTALLDIR/tomcat/bin/" /etc/profile || echo 'export PATH=$PATH:'$INSTALLDIR'/tomcat/bin/' >> /etc/profile
source /etc/profile

# ----- NFS config -----
# -------------- share server nfs --------------
[ -f "/etc/sysconfig/nfs" -a ! -f "/etc/sysconfig/nfs.default" ] && cp /etc/sysconfig/nfs /etc/sysconfig/nfs.default
sed -i 's/^#RQUOTAD_PORT=875/RQUOTAD_PORT=875/g' /etc/sysconfig/nfs
sed -i 's/^#MOUNTD_PORT=892/MOUNTD_PORT=892/g' /etc/sysconfig/nfs

[ -f "/etc/exports" ] || touch /etc/exports
grep 'CmsTop exports' /etc/exports || cat >> /etc/exports <<EXPORTS
# CmsTop exports $(date +%F_%T)
# ------------- share server iptables -------------
# -A INPUT -p tcp -s 192.168.0.2 --dport 111 -j ACCEPT
# -A INPUT -p tcp -s 192.168.0.2 --dport 875 -j ACCEPT
# -A INPUT -p tcp -s 192.168.0.2 --dport 892 -j ACCEPT
# -A INPUT -p tcp -s 192.168.0.2 --dport 2049 -j ACCEPT
# -A INPUT -p udp -s 192.168.0.2 --dport 111 -j ACCEPT
# -A INPUT -p udp -s 192.168.0.2 --dport 875 -j ACCEPT
# -A INPUT -p udp -s 192.168.0.2 --dport 892 -j ACCEPT
# -A INPUT -p udp -s 192.168.0.2 --dport 2049 -j ACCEPT
# -------------- share server exports --------------
# /data/www/cmstop 192.168.0.2/24(rw,sync,insecure) 192.168.0.23/24(ro,sync,insecure)
# /data/www/cmstop 192.168.0.2(rw,no_root_squash,no_all_squash,sync,insecure)
# /data/www/cmstop 192.168.0.2/24(rw,sync,no_root_squash,anonuid=0,anongid=0,insecure)
# /etc/init.d/rpcbind restart;/etc/init.d/nfs restart
# -------------- mount server mount --------------
# mount -t nfs 192.168.0.1:/data/www/cmstop /data/www/cmstop
# grep nfs /etc/rc.local||echo 'mount -t nfs 192.168.0.1:/data/www /data/www' >> /etc/rc.local
# ------------- @end | CmsTop exports -------------
EXPORTS

# ----- iftop Installing -----
# @denpendence: yum install flex byacc libpcap libpcap-devel ncurses ncurses-devel
cd $SRC/iftop-0.17/
#sed -i 's#PREFIX = /usr/local/#PREFIX = '$INSTALLDIR/iftop'#g' ./Makefile
./configure 
make
make install

# ----- nmon Installing -----
[ $(uname -i) == "x86_64" -a $(cat /etc/redhat-release|awk '{print int($3)}') == 6 ] && cp $CURDIR/tar/nmon_x86_64_centos6 /usr/bin/nmon
[ $(uname -i) == "x86_64" -a $(cat /etc/redhat-release|awk '{print int($3)}') == 5 ] && cp $CURDIR/tar/nmon_x86_64_centos5 /usr/bin/nmon
chmod +x /usr/bin/nmon

# ------ rar for Linux ------
[ -f "$SRC/rarlinux-x64-5.2.1.tar.gz" ]||wget -P $SRC/ http://www.rarlab.com/rar/rarlinux-x64-5.2.1.tar.gz
tar -C $SRC/ -zxvf $SRC/rarlinux-x64-5.2.1.tar.gz
cd $SRC/


# @todo: 日志分析工具
# --- GoAccess Installing --- 
yum -y install glib2 glib2-devel GeoIP-devel  ncurses-devel

}
########## Function End ##########

INSTALL_OTHER 2>&1 | tee -a $CURDIR/install.log
