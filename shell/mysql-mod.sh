#!/bin/bash
#
########## Function Start ##########
function INSTALL_MYSQL56()
{

groupadd -g 10001 mysql
useradd -u 10001 -s /sbin/nologin -M -g mysql mysql

cd $CURDIR/tar
[ -f "mysql-5.6.36.tar.gz" ] || wget http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.36.tar.gz

tar xvzf mysql-5.6.36.tar.gz -C $SRC
echo "==================== INSTALL_MYSQL56 ===================="
clear
cd $SRC/mysql-5.6.36
[ -f CMakeCache.txt ] && mv CMakeCache.txt CMakeCache.txt.$(date +%F_%T)
cmake \
-DCMAKE_INSTALL_PREFIX=$INSTALLDIR/mysql \
-DSYSCONFDIR=$INSTALLDIR/mysql/ \
-DMYSQL_DATADIR=/data/mysql/ \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DLINUX_NATIVE_AIO=1

if [ $? -eq 1 ]; then
    echo -e "${redbg}${green}Install MySQL error occurs when \"./cmake\", please check...${eol}"
    exit 1
fi

make && make install

cd $INSTALLDIR/mysql
[ -f "my.cnf" -a ! -f "my.cnf.default" ] && mv my.cnf my.cnf.default
[ -f "my.cnf" ] && mv my.cnf.$(date +%F_+%T)
[ -f "~/.my.cnf" -a ! -f "~/.my.cnf.default" ] && mv my.cnf my.cnf.default
[ -f "~/.my.cnf" ] && mv ~/.my.cnf.$(date +%F_+%T)

cp $CURDIR/conf/my.cnf $INSTALLDIR/mysql/my.cnf
sed -i 's#/www/mysql#'$mysql'#g' $INSTALLDIR/mysql/my.cnf
sed -i 's#/var/log/mysql#'$LOGDIR/mysql'#g' $INSTALLDIR/mysql/my.cnf

[ -d "$mysql" ] && mv $mysql $mysql.$(date +%F_%T)
[ -d "$mysql" ] || mkdir -p $mysql
[ -d "$LOGDIR/mysql" ] || mkdir -p $LOGDIR/mysql
chown -R mysql:mysql $mysql
chown -R mysql:mysql $INSTALLDIR/mysql
chown -R mysql:mysql $LOGDIR/mysql
chmod 750 $mysql
chmod 750 $LOGDIR/mysql

$INSTALLDIR/mysql/scripts/mysql_install_db \
--defaults-file=$INSTALLDIR/mysql/my.cnf \
--basedir=$INSTALLDIR/mysql \
--datadir=$mysql \
--user=mysql \
--explicit_defaults_for_timestamp

[ -f "/etc/my.cnf" -a ! -f "/etc/my.cnf.default" ] && mv /etc/my.cnf /etc/my.cnf.default
[ -f "/etc/my.cnf" ] && mv /etc/my.cnf /etc/my.cnf.$(date +%F_%T)

[ -f "/etc/init.d/mysqld" -a ! -f "/etc/init.d/mysqld.default" ] && mv /etc/init.d/mysqld /etc/init.d/mysqld.default
[ -f "/etc/init.d/mysqld" ] && mv /etc/init.d/mysqld /etc/init.d/mysqld.$(date +%F_%T)
cp $INSTALLDIR/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod 755 /etc/init.d/mysqld

[ `uname -i` == 'x86_64' -a ! -L "$INSTALLDIR/mysql/lib64" ] && ln -s $INSTALLDIR/mysql/lib $INSTALLDIR/mysql/lib64

grep "$INSTALLDIR/mysql/lib" /etc/ld.so.conf.d/mysql.conf || echo "$INSTALLDIR/mysql/lib" > /etc/ld.so.conf.d/mysql.conf
grep '/usr/local/lib' /etc/ld.so.conf.d/mysql.conf || echo "/usr/local/lib" >> /etc/ld.so.conf.d/mysql.conf
ldconfig -p

grep "$INSTALLDIR/mysql/bin/" /etc/profile || echo 'export PATH=$PATH:'$INSTALLDIR'/mysql/bin/' >> /etc/profile
source /etc/profile

[ -S "/tmp/mysql.sock" ] && echo -e "${redbg}${green}/tmp/mysql.sock exists, please check if mysqld is already running...${eol}"
#ln -s $INSTALLDIR/mysql/lib/* /lib/

# iptables move to iptalbes-mod.sh
# opened_3306=$(iptables -L|grep ':3306\|:mysql'|tr -d '\n')
# line_num22=$(iptables --line-number -n -L|grep :22|awk '{print $1}')
# [ "$intranet" != "" ] && intranet=" -s $intranet"
# if [ "$opened_3306" == "" -a "$line_num22" != "" ]; then
#     iptables -I INPUT $[ $line_num22 + 1 ] -m state --state NEW -m tcp -p tcp $intranet --dport 3306 -j ACCEPT
#     /etc/init.d/iptables save
# fi

# Optimize
#sed -i "s#innodb_buffer_pool_size.*#innodb_buffer_pool_size = "$(echo "scale=0;$(free|grep Mem|awk '{print $4}')/1024/100*80"|bc)"M#g" $INSTALLDIR/mysql/my.cnf 
sed -i 's#innodb_thread_concurrency.*#innodb_thread_concurrency = '$(cat /proc/cpuinfo|grep processor|wc -l)'#' $INSTALLDIR/mysql/my.cnf

# Compatibility
[ -L "/tmp/mysql.sock" ] && rm -f /tmp/mysql.sock
[ -S "/tmp/mysql.sock" ] && ln -s /tmp/mysql.sock /var/lib/mysql/

# security
rm -rf ~/.mysql_history 
ln -s /dev/null ~/.mysql_history
[ ~ == "/root" ] || rm -rf /root/.mysql_history
[ ~ == "/root" ] || ln -s /dev/null /root/.mysql_history

# Start && BootOn
chkconfig mysqld on
/etc/init.d/mysqld start
}
########## Function End ##########

INSTALL_MYSQL56 2>&1 | tee -a $CURDIR/install.log
