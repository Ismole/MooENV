#!/bin/bash

VER=1.0.1
SELF_PATH=$(cd $(dirname $0);pwd)
EXEC_DATE=$(date +%Y%m%d)
STORE_DIR=${SELF_PATH}/src
DOWNLOAD_SITE='http://syslab.ismole.com/downloads/MooENV/packages'
PACKAGES_RES='mooenv.res'
RUN_TIME=$(date  +%Y%m%d-%H:%M:%S)
CHECK_MD5=1

. $SELF_PATH/include/global_functions

# /* Arguments {{{*/
if [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    cat $SELF_PATH/include/help
    exit 0
elif [ "$1" = '-v' ] || [ "$1" = '--version' ]; then
    echo MooENV-"$VER"
    exit 0
elif [ "$1" = '-c' ] || [ "$1" = '--check-update' ]; then
    L_VER=`curl -s http://syslab.ismole.com/downloads/MooENV/latest_ver | tr -d '\r\n'`
    Comp_Ver $VER $L_VER
    if [ $VER_COMP = 'gt' ]; then
        Color_Msg yellow 'What is this fucking version? You are faster than me?' # Just a kidding :)
    elif [ $VER_COMP = 'lt' ]; then
        Color_Msg red 'A New Version of MooENV Found!'
        Color_Msg cyan "The latest version is $L_VER"
        Color_Msg cyan "The current version is $VER"
    else
        Color_Msg green 'You have the latest version!'
        Color_Msg cyan "The current version is $VER"
    fi
    echo -ne "\n"
    exit 0
fi
# */}}}

# Are you root?
if [ `id -u` -ne '0' ]; then
    echo 'MooENV needs root privilege to run!'
    echo 'Please login with root or su root.'
    exit 1
fi

# /* Check System Health {{{*/
DMESG_ERR=`dmesg | grep error | grep -v 'error=0x04'`
if [ -n "$DMESG_ERR" ]; then
    Color_Msg red 'System Error Were Detected!'
    Color_Msg red 'Please fix these errors before continue.'
    echo -ne "\n"
    echo "$DMESG_ERR" && exit 1
fi
# */}}}

# /* Check Platform {{{*/
if [ `uname -i` = 'x86_64' ]; then
    PLATFORM='x86_64'
else
    PLATFORM='i386'
fi

if cat /etc/issue|grep 'CentOS' > /dev/null 2>&1 ;then
    echo -ne "\n"
else
    Color_Msg red 'MooENV Do Not Support Your OS Release.'
    Color_Msg red 'Please Install CentOS 5/6 On Your Server.'
    exit 1
fi

if cat /etc/issue|grep '5.' > /dev/null 2>&1; then
    OS=5
elif cat /etc/issue|grep '6.' > /dev/null 2>&1; then
    OS=6
else
    Color_Msg red 'MooENV Do Not Support This Version Of CentOS'
    Color_Msg red 'CentOS 5 and 6 Are Supported.'
    exit 1
fi
# */}}}

# Shell Environment
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
alias cp='cp'
alias mv='mv'
alias rm='rm'

. $SELF_PATH/id.conf

# Installation Wizard
. $SELF_PATH/include/wizard
. ${STORE_DIR}/mooenv.res
. $SELF_PATH/include/updata

# System Modify
. $SELF_PATH/include/system_mod

if [ -f "/root/.MooENV/report.txt" ] ;then
    Color_Msg cyan "You have already intall the MooENV,do you want to updata ? (Y/N)"
    read UP_FLAG
    while :
    do
        case $UP_FLAG in
            "Y"|"y"|yes|YES)
            if [ -f ${STORE_DIR}/mooenv.res.updata ]; then
                rm -f ${STORE_DIR}/mooenv.res.updata
            fi
            wget -c -t0 -nH ${DOWNLOAD_SITE}/mooenv.res.updata -O ${STORE_DIR}/mooenv.res.updata || Install_Failed ' getting mooenv.res.updata'
            . ${STORE_DIR}/mooenv.res.updata
            MooENV_Updata
            break 1
               ;;
            "N"|"n"|no|NO)

                  # Install MySQL Server
                  . $SELF_PATH/include/install_mysql

                  # Install MySQL Xtrabackup
                  . $SELF_PATH/include/install_xtrabackup

                  # Install HTTP Server
                  . $SELF_PATH/include/install_httpd

                  # Install PHP
                  . $SELF_PATH/include/install_php

                  # Install NoSQL
                  . $SELF_PATH/include/install_nosql

                  # Backup
                  . $SELF_PATH/include/backup

                  # Service
                  . $SELF_PATH/include/service

                  # Report
                  . $SELF_PATH/include/report

                  break 1
               ;;
            *)
               Color_Msg red "\nInvaild answer, select angin. "
               Color_Msg cyan "You have already intall the MooENV,do you want to updata ? (Y/N)"
               read  UP_FLAG
               continue
               ;;
        esac
    done

else

    # Install MySQL Server
    . $SELF_PATH/include/install_mysql

    # Install MySQL Xtrabackup
    . $SELF_PATH/include/install_xtrabackup

    # Install HTTP Server
    . $SELF_PATH/include/install_httpd

    # Install PHP
    . $SELF_PATH/include/install_php

    # Install NoSQL
    . $SELF_PATH/include/install_nosql

    # Backup
    . $SELF_PATH/include/backup

    # Service
    . $SELF_PATH/include/service

    # Report
    . $SELF_PATH/include/report
fi
if [ "$INST_TYPE" = "1" ] ;then
    . $SELF_PATH/include/install_pma
    . $SELF_PATH/include/config_web_virtual_host
fi
. $SELF_PATH/include/install_pptpd
. $SELF_PATH/include/create_mysql_db
. $SELF_PATH/include/install_pureftpd


echo 'export PATH="$PATH:/usr/local/mysql/bin:/usr/local/nginx/bin:/usr/local/php/bin:/usr/local/memcached/bin"' >> /etc/profile

Color_Msg green "All Done!"
Color_Msg yellow "To get MooENV environment information read /root/.MooENV/report.txt first!"
