#!/bin/bash
# copy right all rights recived by DataGalaxy
#

LOG=/var/log/core/main/errors.log
DIR=/var/log/core/main

if grep -Fxq "convert_videos" $LOG
then 
    rm $DIR/* 
    mongo apscheduler --eval "db.main.remove({_id: 'convert_videos'})"
    supervisiorctl restart core
fi 
