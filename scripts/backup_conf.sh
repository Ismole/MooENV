#!/bin/bash

srv_conf="/usr/local/php/etc /usr/local/nginx/conf /usr/local/apache2/conf"
sys_etc="/etc"
user_cron="/var/spool/cron"
user_sh="/usr/local/sbin"
conf="$srv_conf $sys_etc $user_cron $user_sh"

DATE=$(date +%Y%m%d)

#backup destination directory
BAK_DIR="/backup/conf"

[ ! -d $BAK_DIR ] && mkdir -p $BAK_DIR

tar -zcPf  $BAK_DIR/$IPADDR-conf-$DATE.tgz $conf

find $BAK_DIR -mtime +7 -type f | xargs rm -f
