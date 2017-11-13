#!/bin/bash

# Enviroment
PATH=/usr/local/sbin:/usr/bin:/bin

# Configure The Directory of Backup
HTDOCS=/www/htdocs
DATADIR=/www/mysql
BACKUPDIR=/backup
SAVE=14
ROOT=root
ROOTPASS=

# special
SPECIAL=$HTDOCS/cmstop/public/www/special

# define
MYSQLDIR=$BACKUPDIR/mysql
WEBDIR=$BACKUPDIR/www
TMPDIR=$BACKUPDIR/mysql/tmp
DATETIME=`date -d now +%Y-%m-%d_%H-%M`

# Create Directory
if [ ! -d $MYSQLDIR ]; then
  mkdir -p $MYSQLDIR
fi
if [ ! -d $WEBDIR ]; then
  mkdir -p $WEBDIR
fi
rm -rf $TMPDIR
mkdir -p $TMPDIR

# ----- Backup MySQL -----
DBLIST=`ls -p $DATADIR | grep / | grep -v performance_schema | tr -d /`

# Backup with Database
for dbname in $DBLIST
do
    mysqldump -u$ROOT -p$ROOTPASS $dbname > $TMPDIR/$dbname.sql
done

# create MySQL tar
cd $MYSQLDIR
tar -czvf $MYSQLDIR/mysql_backup.$DATETIME.tar.gz ./tmp
rm -fr $TMPDIR
[ -d $MYSQLDIR ] && find $MYSQLDIR -type f -mtime +$SAVE -delete

# ----- Backup Web -----
cd $HTDOCS
tar --exclude=cmstop/data/* --exclude=cmstop/public/upload/* --exclude=cmstop/public/www/* --exclude=.svn --exclude=*gz --exclude=*zip --exclude=*bk --exclude=*bak -czf $WEBDIR/cmstop_backup.$DATETIME.tar.gz ./cmstop
tar --exclude=.svn --exclude=*gz --exclude=*zip --exclude=*bk --exclude=*bak -czf $WEBDIR/public,www,special.$DATETIME.tar.gz $SPECIAL
[ -d $WEBDIR ] && find $WEBDIR -type f -mtime +$SAVE -delete

# ----- Restart syslog/rsyslog -----
[ -x "/etc/init.d/rsyslog" ] && /etc/init.d/rsyslog restart
[ -x "/etc/init.d/syslog" -a ! -f "/etc/init.d/rsyslog" ] && /etc/init.d/rsyslog restart

# ----- Reset Directory Permission -----
[ -d $HTDOCS/cmstop ] || exit 1
[ -d $HTDOCS/cmstop ] && cd $HTDOCS/cmstop
find ./ -type d | grep -v 'public/www\|public/upload\|^./data$\|.svn.*$' | xargs chown root:nginx
find ./ -type f | grep -v 'public/www\|public/upload\|^./data$\|.svn.*$' | xargs chown root:nginx
find ./ -type d | grep -v 'public/www\|public/upload\|^./data$\|.svn.*$' | xargs chmod 550
find ./ -type f | grep -v 'public/www\|public/upload\|^./data$\|.svn.*$' | xargs chmod 440

chown -R nginx:nginx ./data/
chown -R nginx:nginx ./public/www/
chown -R nginx:nginx ./public/upload/
chown -R nginx:nginx ./public/img/apps/special/templates
chown -R nginx:nginx ./public/img/apps/special/ui/themes
chown -R nginx:nginx ./public/img/apps/special/scheme

chmod -R 700 ./data/
chmod -R 700 ./public/www/
chmod -R 700 ./public/upload/
chmod -R 700 ./public/img/apps/special/templates
chmod -R 700 ./public/img/apps/special/ui/themes
chmod -R 700 ./public/img/apps/special/scheme
