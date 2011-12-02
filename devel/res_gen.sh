#!/bin/bash

PKG_DIR='./upload/packages'

declare -u VAR_NAME
rm -f ${PKG_DIR}/mooenv.res

for I in `ls ${PKG_DIR}`
do
    VAR_NAME=`echo $I | cut -d\- -f1`
    MD5SUM=`md5sum ${PKG_DIR}/$I | awk '{print $1}'`
    echo "${VAR_NAME}_SRC='$I|$MD5SUM'" >> ${PKG_DIR}/mooenv.res
done
