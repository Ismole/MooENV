#!/bin/bash

WEB_ROOT="/data/www/"
BAK_DIR="/backup/www/"
[ ! -d $BAK_DIR ] && mkdir -p $BAK_DIR

rsync -av --progress $WEB_ROOT $BAK_DIR
