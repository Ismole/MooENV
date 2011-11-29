#!/bin/bash

#backup dir as target-dir
BAK_DIR="/bak/mysql"
[ ! -d ${BAK_DIR} ] && mkdir -p ${BAK_DIR}

DATE=$(date +%Y%m%d)

#stdout && stderr log
exec >$BAK_DIR/$DATE-mysql_bak.out 2>&1

export PATH=$PATH:/usr/local/bin:/usr/local/mysql/bin
export HOME=/var/games
#alias innobackupex
innobackupex="/usr/local/bin/innobackupex"

#mysql account and password
MYUSR=root
MYPW="123456"


#check backup dir 
[ ! -d $BAK_DIR ] && mkdir -p $BAK_DIR

$innobackupex --user=$MYUSR --password=$MYPW --stream=tar $BAK_DIR | gzip >$BAK_DIR/$IPADDR-mysql-$DATE.tgz

find $BAK_DIR -mtime +7 -type f | xargs rm -rf
