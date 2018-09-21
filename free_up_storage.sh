#!/bin/bash
# copy right all rights recived by DataGalaxy

# sudo crontab -e (you should put it here)

NGINX_DIR=/var/log/nginx
MONGO_DIR=/var/log/mongod 
FIDS_DIR=/var/log/fids 

rm $NGINX_DIR/* && sleep 2
rm $MONGO_DIR/* && sleep 2
rm $FIDS_DIR/* && sleep 2

supervisiorctl restart nginx
supervisiorctl restart mongod
firestart
