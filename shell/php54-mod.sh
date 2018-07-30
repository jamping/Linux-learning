#!/bin/bash

# @todo: php54升级
# htdocs="/application/nginx/html"
# INSTALLDIR=/application
# CURDIR=/root/tools
# SRC=/root/tools/src
########## Function Start ##########
function INSTALL_PHP54()
{

if [ ! -f $INSTALLDIR/mysql/bin/mysql ]; then
    echo -e "${redbg}Error: MySQL Install Failed， Check ...${eol}"
    exit 1
fi

rm -rf $SRC/php-5.4.25
rm -rf $SRC/memcache-3.0.8
rm -rf $SRC/redis-2.2.4
rm -rf $SRC/scws-1.2.2
rm -rf $SRC/xcache-3.1.0
rm -rf $SRC/freetds-0.91
rm -rf $SRC/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64

cd $CURDIR/tar
[ -f php-5.4.25.tar.gz ]||wget http://mirrors.cmstop/cmstop/sources/php-5.4.25.tar.gz
[ -f memcache-3.0.8.tgz ]||wget http://pecl.php.net/get/memcache-3.0.8.tgz
[ -f redis ]||wget http://mirrors.cmstop/cmstop/sources/redis
[ -f scws-1.2.2.tar.bz2 ]||wget http://mirrors.cmstop/cmstop/sources/scws-1.2.2.tar.bz2
[ -f scws-dict-chs-utf8.tar.bz2 ]||wget http://mirrors.cmstop/cmstop/sources/scws-dict-chs-utf8.tar.bz2
[ -f xcache-3.1.0.tar.gz ]||wget http://mirrors.cmstop/cmstop/sources/xcache-3.1.0.tar.gz
[ -f freetds-stable.tgz ]||wget ftp://ftp.freetds.org/pub/freetds/stable/freetds-stable.tgz
[ -f xhprof-0.9.4.tgz ]||wget http://pecl.php.net/get/xhprof-0.9.4.tgz
[ -f yaf-2.3.3.tgz ]|| wget http://pecl.php.net/get/yaf-2.3.3.tgz

tar -zxvf $CURDIR/tar/php-5.4.25.tar.gz -C $SRC
tar -zxvf $CURDIR/tar/memcache-3.0.8.tgz -C $SRC
tar -zxvf $CURDIR/tar/redis -C $SRC
tar -jxvf $CURDIR/tar/scws-1.2.2.tar.bz2 -C $SRC
tar -jxvf $CURDIR/tar/scws-dict-chs-utf8.tar.bz2 -C $SRC
tar -zxvf $CURDIR/tar/xcache-3.1.0.tar.gz -C $SRC
tar -zxvf $CURDIR/tar/freetds-stable.tgz -C $SRC
tar -zxvf $CURDIR/tar/xhprof-0.9.4.tgz -C $SRC
tar -zxvf $CURDIR/tar/yaf-2.3.3.tgz -C $SRC

echo "==================== INSTALL_PHP54 ===================="
[ $(uname -i) == 'x86_64' ] && libdir="lib64"
[ $(uname -i) == 'x86_64' ] || libdir="lib"

clear
cd $SRC/php-5.4.25
./configure --prefix=$INSTALLDIR/php \
--with-config-file-path=$INSTALLDIR/php/etc \
--with-libdir=$libdir \
--enable-mysqlnd \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--enable-pdo \
--with-pdo-mysql=mysqlnd \
--with-iconv-dir=/usr/local \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--enable-pcntl \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--with-curlwrappers \
--enable-fpm \
--enable-mbstring \
--enable-mbregex \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--with-mcrypt \
--with-snmp \
--enable-json \
--enable-dom \
--enable-ftp

if [ $? -eq 1 ]; then
    echo -e "${redbg}${green}Install PHP error occurs when \"./configure\", please check...${eol}"
    exit 1
fi

[ $(uname -i) == 'x86_64' ] || make ZEND_EXTRA_LIBS='-liconv'
[ $(uname -i) == 'x86_64' ] && make
make install

if [  ! -d "$INSTALLDIR/php/" ]; then
    echo -e "${redbg}${green}Install PHP failed, please check...${eol}"
    exit 1
fi

cd $SRC/memcache-3.0.8
$INSTALLDIR/php/bin/phpize
./configure --with-php-config=$INSTALLDIR/php/bin/php-config
make
make install

cd $SRC/redis-2.2.4
$INSTALLDIR/php/bin/phpize
./configure --with-php-config=$INSTALLDIR/php/bin/php-config
make
make install

cd $SRC/xcache-3.1.0
$INSTALLDIR/php/bin/phpize
./configure --with-php-config=$INSTALLDIR/php/bin/php-config
make
make install

cd $SRC/scws-1.2.2
./configure --prefix=$INSTALLDIR/scws
make
make install
cd phpext
$INSTALLDIR/php/bin/phpize
./configure --with-scws=$INSTALLDIR/scws --with-php-config=$INSTALLDIR/php/bin/php-config
make
make install
\cp $SRC/dict.utf8.xdb $INSTALLDIR/scws/etc
chmod 644 -R $INSTALLDIR/scws/etc/*

# ----- xhprof Extensions -----
cd $SRC/xhprof-0.9.4/extension/
$INSTALLDIR/php/bin/phpize
./configure --with-php-config=$INSTALLDIR/php/bin/php-config
make
make install
mkdir -p $htdocs/xhprof
\scp $SRC/xhprof-0.9.4/xhprof_html $htdocs/xhprof/
\scp $SRC/xhprof-0.9.4/xhprof_lib $htdocs/xhprof/
sed -i '909d' $htdocs/xhprof/xhprof_lib/utils/xhprof_lib.php
sed -i "909i\$p = implode(',', explode(',', \$p));" $htdocs/xhprof/xhprof_lib/utils/xhprof_lib.php

# ----- Yaf Installing -----
cd $SRC/yaf-2.3.3
$INSTALLDIR/php/bin/phpize 
./configure --with-php-config=$INSTALLDIR/php/bin/php-config 
make
make install

# ----- mssql Extensions -----
cd $SRC/freetds-0.91/
./configure --prefix=/usr/local/freetds --with-tdsver=8.0 --enable-msdblib
make && make install
grep 'freetds/lib/' /etc/ld.so.conf.d/freetds.conf || echo "/usr/local/freetds/lib/" > /etc/ld.so.conf.d/freetds.conf
[ -f /usr/local/freetds/lib/libsybdb.so.4 ] && mv /usr/local/freetds/lib/libsybdb.so.4 /usr/local/freetds/lib/libsybdb.so.4.$(date +%F_%T) 
ln -s /usr/local/freetds/lib/libsybdb.so.5.0.0 /usr/local/freetds/lib/libsybdb.so.4
/sbin/ldconfig
[ -f '/usr/local/freetds/etc/freetds.conf' ] && mv /usr/local/freetds/etc/freetds.conf /usr/local/freetds/etc/freetds.conf.$(date +%F_%T)
cat > /usr/local/freetds/etc/freetds.conf <<FREETDS
[global]
    # TDS protocol version
;       tds version = 4.2

    # Whether to write a TDSDUMP file for diagnostic purposes
    # (setting this to /tmp is insecure on a multi-user system)
;       dump file = /tmp/freetds.log
;       debug flags = 0xffff

    # Command and connection timeouts
;       timeout = 10
;       connect timeout = 10

    # If you get out-of-memory errors, it may mean that your client
    # is trying to allocate a huge buffer for a TEXT field.
    # Try setting 'text size' to a more reasonable limit
    text size = 64512

    host = mssql.yourdomain.com
    port = 1433
    tds version = 8.0
    client charset = UTF-8
FREETDS

cd $SRC/php-5.4.25/ext/mssql
$INSTALLDIR/php/bin/phpize
./configure --with-php-config=$INSTALLDIR/php/bin/php-config --with-mssql=/usr/local/freetds/
make && make install
grep mssql.so $INSTALLDIR/php/etc/php.ini || cat >> $INSTALLDIR/php/etc/php.ini <<MSSQL

;[mssql]
;extension = mssql.so
MSSQL

# ----- Oracle Extensions -----
# todo

# ----- Zend Extensions -----
cd $CURDIR/tar
if [ `uname -m` = 'x86_64' ]; then
    [ -f ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz ]||wget http://mirrors.cmstop/cmstop/sources/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
    tar xvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz -C $SRC
    \cp $SRC/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so  $INSTALLDIR/php/lib/php/extensions/no-debug-non-zts-20100525/ZendGuardLoader.so
else
    [ -f ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz ]||wget http://mirrors.cmstop/cmstop/sources/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
    tar xvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz -C $SRC
    \cp $SRC/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so $INSTALLDIR/php/lib/php/extensions/no-debug-non-zts-20100525/ZendGuardLoader.so
fi

[ -f /etc/php.ini -a ! -f /etc/php.ini.default ] && mv /etc/php.ini /etc/php.ini.default
[ -f /etc/php.ini ] && mv /etc/php.ini /etc/php.ini.$(date +%F_%T)

cd $INSTALLDIR/php/etc/
[ -f php.ini -a ! -f php.ini.default ] && mv php.ini php.ini.default
[ -f php.ini ] && mv php.ini php.ini.$(date +%F_%T)
[ -f php-fpm.conf -a ! -f php-fpm.conf.default ] && mv php-fpm.conf php-fpm.conf.default
[ -f php-fpm.conf ] && mv php-fpm.conf php-fpm.conf.$(date +%F_%T)

cp $CURDIR/conf/php54.ini $INSTALLDIR/php/etc/php.ini
cp $CURDIR/conf/php-fpm54.conf $INSTALLDIR/php/etc/php-fpm.conf
\cp $CURDIR/conf/info.php $htdocs

sed -i 's#/usr/lib/php/modules#'$INSTALLDIR/php/lib/php/extensions/no-debug-non-zts-20100525'#g' $INSTALLDIR/php/etc/php.ini
sed -i 's#/usr/local/server#'$INSTALLDIR'#g' $INSTALLDIR/php/etc/php.ini
sed -i 's#/www/htdocs#'$htdocs'#g' $INSTALLDIR/php/etc/php.ini
sed -i 's#/var/log/php#'$LOGDIR/php'#g' $INSTALLDIR/php/etc/php.ini
sed -i 's#/var/log/server/php#'$LOGDIR/php'#g' $INSTALLDIR/php/etc/php.ini
sed -i 's#/www/htdocs#'$htdocs'#g' $INSTALLDIR/php/etc/php-fpm.conf
sed -i 's#/var/log/php#'$LOGDIR/php'#g' $INSTALLDIR/php/etc/php-fpm.conf

mkdir -p /tmp/session
chown -R nginx:nginx /tmp/session

[ -d $LOGDIR/php ]||mkdir -p $LOGDIR/php
chown -R nginx:nginx $LOGDIR/php

[ -f /etc/init.d/php-fpm -a ! -f /etc/init.d/php-fpm.default ] && mv /etc/init.d/php-fpm /etc/init.d/php-fpm.default
[ -f /etc/init.d/php-fpm ] && mv /etc/init.d/php-fpm /etc/init.d/php-fpm.$(date +%F_%T)

cp $SRC/php-5.4.25/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm

grep "$INSTALLDIR/php/bin/" /etc/profile || echo 'export PATH=$PATH:'$INSTALLDIR'/php/bin/' >> /etc/profile
source /etc/profile

chkconfig php-fpm on
/etc/init.d/php-fpm start

}
########## Function End ##########

INSTALL_PHP54 2>&1 | tee -a $CURDIR/install.log
