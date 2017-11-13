#!/bin/bash

########## Function Start ##########
# @todo: nginx limit mod
# @todo: nginx xss module: https://github.com/openresty/xss-nginx-module
# @todo: nginx iswaf module:
function INSTALL_NGINX18()
{

groupadd nginx -g 10000
useradd -u 10000 -s /sbin/nologin -M -g nginx nginx

cd $CURDIR/tar
[ -f nginx-1.8.0.tar.gz ] || wget http://nginx.org/download/nginx-1.8.0.tar.gz
[ -f LuaJIT-2.0.4.tar.gz ] || wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
[ -f lua-nginx-module-0.9.15.tar.gz ] || wget https://github.com/openresty/lua-nginx-module/archive/v0.9.15.tar.gz -O lua-nginx-module-0.9.15.tar.gz
[ -f echo-nginx-module-0.57.tar.gz ] || wget https://github.com/openresty/echo-nginx-module/archive/v0.57.tar.gz -O echo-nginx-module-0.57.tar.gz
[ -f ngx_devel_kit-0.2.19.tar.gz ] || wget https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz -O ngx_devel_kit-0.2.19.tar.gz
[ -f redis2-nginx-module-0.11.tar.gz ] || wget https://github.com/openresty/redis2-nginx-module/archive/v0.11.tar.gz -O redis2-nginx-module-0.11.tar.gz
[ -f set-misc-nginx-module-0.28.tar.gz ] || wget https://github.com/openresty/set-misc-nginx-module/archive/v0.28.tar.gz -O set-misc-nginx-module-0.28.tar.gz

[ -d "$SRC/nginx-1.8.0" ] && rm -rf $SRC/nginx-1.8.0 $SRC/nginx-1.8.0*
[ -d "$SRC/LuaJIT-2.0.4" ] && rm -rf $SRC/LuaJIT-2.0.4*
[ -d "$SRC/lua-nginx-module-0.9.15" ] && rm -rf $SRC/lua-nginx-module-0.9.15*
[ -d "$SRC/echo-nginx-module-0.57" ] && rm -rf $SRC/echo-nginx-module-0.57*
[ -d "$SRC/ngx_devel_kit-0.2.19" ] && rm -rf $SRC/ngx_devel_kit-0.2.19 $SRC/ngx_devel_kit-0.2.19*
[ -d "$SRC/redis2-nginx-module-0.11" ] && rm -rf $SRC/redis2-nginx-module-0.11*
[ -d "$SRC/set-misc-nginx-module-0.28" ] && rm -rf $SRC/set-misc-nginx-module-0.28*

tar -zxvf $CURDIR/tar/nginx-1.8.0.tar.gz -C $SRC/
tar -zxvf $CURDIR/tar/LuaJIT-2.0.4.tar.gz -C $SRC/
tar -zxvf $CURDIR/tar/ngx_devel_kit-0.2.19.tar.gz -C $SRC/
tar -zxvf $CURDIR/tar/lua-nginx-module-0.9.15.tar.gz -C $SRC/
tar -zxvf $CURDIR/tar/redis2-nginx-module-0.11.tar.gz -C $SRC/
tar -zxvf $CURDIR/tar/echo-nginx-module-0.57.tar.gz -C $SRC/
tar -zxvf $CURDIR/tar/set-misc-nginx-module-0.28.tar.gz -C $SRC/

cd $SRC/LuaJIT-2.0.4
make
make install

# export LUAJIT_LIB=/usr/local/lib
# export LUAJIT_INC=/usr/local/include/luajit-2.0
# export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH

echo "==================== INSTALL_NGINX1.8 ===================="
clear
cd $SRC/nginx-1.8.0
./configure \
--user=nginx \
--group=nginx \
--prefix=$INSTALLDIR/nginx \
--conf-path=$INSTALLDIR/nginx/conf/nginx.conf \
--pid-path=$INSTALLDIR/nginx/nginx.pid \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-mail \
--with-mail_ssl_module \
--with-http_gunzip_module \
--with-http_image_filter_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module \
--add-module=$SRC/lua-nginx-module-0.9.15 \
--add-module=$SRC/echo-nginx-module-0.57 \
--add-module=$SRC/ngx_devel_kit-0.2.19 \
--add-module=$SRC/redis2-nginx-module-0.11 \
--add-module=$SRC/set-misc-nginx-module-0.28 
# --with-http_perl_module \

[ "$?" == 1 ] && exit

make && make install


echo "/usr/local/lib" > /etc/ld.so.conf.d/lua_lib.conf
ldconfig

[ -d $htdocs/default ] || mkdir -p $htdocs/default
chown -R root:nginx $htdocs

# ---- Create robots.txt
cat > $htdocs/default/robots.txt <<ROBOTS
User-Agent: *
Disallow: /
ROBOTS

[ -d $LOGDIR/nginx ] || mkdir -p $LOGDIR/nginx
chown -R nginx:nginx $LOGDIR/nginx
chmod 750 $LOGDIR/nginx

cd $INSTALLDIR/nginx/conf/
[ -f nginx.conf -a ! -f nginx.conf.default ] && mv nginx.conf nginx.conf.default
[ -f nginx.conf ] && mv -f nginx.conf nginx.conf.$(date +%F_%T)
cp $CURDIR/conf/nginx.conf $INSTALLDIR/nginx/conf/
cp $CURDIR/conf/injection.lua $INSTALLDIR/nginx/conf/
cp $CURDIR/conf/cc.lua $INSTALLDIR/nginx/conf/
sed -i 's#/www/htdocs#'$htdocs'#g' $INSTALLDIR/nginx/conf/nginx.conf
sed -i 's#cmstop.loc#'$domain'#g' $INSTALLDIR/nginx/conf/nginx.conf
sed -i 's#/var/log/nginx#'$LOGDIR/nginx'#g' $INSTALLDIR/nginx/conf/nginx.conf
sed -i 's#/var/log/server/nginx#'$LOGDIR/nginx'#g' $INSTALLDIR/nginx/conf/nginx.conf
sed -i 's#/usr/local/server/nginx#'$INSTALLDIR/nginx'#g' $INSTALLDIR/nginx/conf/nginx.conf
mkdir -p $INSTALLDIR/nginx/conf/vhosts

# ----- Copy vhosts conf -----
cp $CURDIR/conf/cmstop.nginx.admin.conf $INSTALLDIR/nginx/conf/vhosts/$domain.admin.conf
cp $CURDIR/conf/cmstop.nginx.app.conf $INSTALLDIR/nginx/conf/vhosts/$domain.app.conf
cp $CURDIR/conf/cmstop.nginx.conf $INSTALLDIR/nginx/conf/vhosts/$domain.www.conf
# $admin
sed -i 's#admin.cmstop#'$ADMIN'.cmstop#' $INSTALLDIR/nginx/conf/vhosts/$domain.admin.conf
[ "$ADMIN_PORT" != "80" ] && sed -i 's#80#'$ADMIN_PORT'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.admin.conf
# injection.lua
sed -i 's#/usr/local/server#'$INSTALLDIR'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.app.conf
# port
sed -i 's#127.0.0.1:9000#127.0.0.1:9001#g' $INSTALLDIR/nginx/conf/vhosts/$domain.app.conf
sed -i 's#127.0.0.1:9000#127.0.0.1:9001#g' $INSTALLDIR/nginx/conf/vhosts/$domain.admin.conf
# $htdocs
sed -i 's#/www/htdocs#'$htdocs'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.admin.conf
sed -i 's#/www/htdocs#'$htdocs'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.app.conf
sed -i 's#/www/htdocs#'$htdocs'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.www.conf
# $domain
sed -i 's#cmstop.loc#'$domain'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.admin.conf
sed -i 's#cmstop.loc#'$domain'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.app.conf
sed -i 's#cmstop.loc#'$domain'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.www.conf
# $LOGDIR
sed -i 's#/var/log/nginx#'$LOGDIR/nginx'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.admin.conf
sed -i 's#/var/log/nginx#'$LOGDIR/nginx'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.app.conf
sed -i 's#/var/log/nginx#'$LOGDIR/nginx'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.www.conf
# \.cmstop\.loc
sed -i 's#\\.cmstop\\.loc#'${domain//\./\\\\.}'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.app.conf

# ----- Copy Mobile Detect conf -----
cp $CURDIR/conf/cmstop.nginx.mobile-detect.inc $INSTALLDIR/nginx/conf/vhosts/$domain.mobile-detect.inc
sed -i 's#cmstop.loc#'$domain'#g' $INSTALLDIR/nginx/conf/vhosts/$domain.mobile-detect.inc

[ -f /etc/init.d/nginx ] && mv -f /etc/init.d/nginx /etc/init.d/nginx.$(date +%F_%T)
cp $CURDIR/daemon/nginx.daemon /etc/init.d/nginx
sed -i 's#/usr/local/server#'$INSTALLDIR'#g' /etc/init.d/nginx
chmod 755 /etc/init.d/nginx

[ -f /etc/logrotate.d/nginxlog ] && mv /etc/logrotate.d/nginxlog /etc/logrotate.d/nginxlog.$(date +%F_%T)
\cp $CURDIR/conf/nginxlog /etc/logrotate.d/
sed -i 's#/var/log/nginx#'$LOGDIR/nginx'#g' /etc/logrotate.d/nginxlog
[ -f /etc/init.d/syslog ] && /etc/init.d/syslog restart
[ -f /etc/init.d/rsyslog ] && /etc/init.d/rsyslog restart

# access.inc, /etc/hosts.deny
for ip in $(grep -v '^#\|^$' $CURDIR/conf/hosts.deny|awk '{print $1}') 
do
	# nginx deny
	echo "deny $ip;" >> $INSTALLDIR/nginx/conf/vhosts/access-deny.inc
	# tcpwrapper deny
	echo "ALL:$ip" >> /etc/hosts.deny
done

# auth.inc
cat >> $INSTALLDIR/nginx/conf/vhosts/access-auth.inc <<AUTH
# -------------------------------------------------------------------------------------- #
# yum -y install httpd
# date | md5sum
# htpasswd -c -d -b $INSTALLDIR/nginx/conf/vhosts/access-authpass username password
# /etc/init.d/nginx restart
# -------------------------------------------------------------------------------------- #
# username:password
# -------------------------------------------------------------------------------------- #
include vhosts/access-deny.inc;

allow 127.0.0.1;
allow 10.2.20.0/24;
allow 172.18.1.0/24;
allow 192.168.1.0/24;
allow 124.205.213.58;
allow all;  # 后台上传
#deny all;

#satisfy all;
satisfy any;
auth_basic "Welcome, ^_^";
auth_basic_user_file vhosts/access-authpass;
AUTH

# access-authpass
rpm -qa | grep httpd || yum -y install httpd && chkconfig httpd off
auth_username="$domain"
auth_password=`openssl rand -base64 16`
htpasswd -c -d -b $INSTALLDIR/nginx/conf/vhosts/access-authpass $auth_username $auth_password
echo "$auth_username:$auth_password" >> $INSTALLDIR/nginx/conf/vhosts//auth_password

# iptables move to iptables-mod.sh
# opened_80=`iptables -L|grep http|tr -d '\n'`
# line_num22=$(iptables --line-number -n -L|grep 22|head -1|awk '{print int($1)}')
# insert_num=$[ $line_num22 + 1 ]
# [ "$opened_80" == "" ] && iptables -I INPUT $insert_num -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
# iptables -I INPUT $[ $line_num22 + 2 ] -m state --state NEW -m tcp -p tcp --dport $ADMIN_PORT -j ACCEPT
# /etc/init.d/iptables save

grep "$INSTALLDIR/nginx/sbin/" /etc/profile || echo 'export PATH=$PATH:'$INSTALLDIR'/nginx/sbin/' >> /etc/profile
source /etc/profile

chkconfig nginx on
/etc/init.d/nginx start

[ "$?" == 0 ] || echo -e "${redbg}${green}Error: Failed to Start nginx, please Check ...{$eol}" && exit 1

}
########## Function End ##########

INSTALL_NGINX18 2>&1 | tee -a $CURDIR/install.log
