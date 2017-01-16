#!/bin/bash

if ! [ $(id -u) = 0 ]; then
   echo "Not root!"
   exit 1
fi


if [ -z "$DOMAIN" ]; then
   echo "Remove hostname (example.com): "
   read DOMAIN
fi

systemctl stop nginx


rm -rf /var/www/$DOMAIN

rm -f /etc/nginx/conf.d/$DOMAIN.conf

systemctl start nginx

