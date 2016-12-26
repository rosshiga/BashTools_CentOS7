#!/bin/bash
if ! [ $(id -u) = 0 ]; then
   echo "Not root!"
   exit 1
fi

#Install and enable nginx
yum -y install nginx certbot
systemctl start nginx
systemctl enable nginx

#Allow 80, 443
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

#Remove default index.html
rm -f /usr/share/nginx/html/index.html
hostname > /usr/share/nginx/html/index.html
echo -n " is working" >> /usr/share/nginx/html/index.html

mkdir /var/www
