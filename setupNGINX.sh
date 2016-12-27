#!/bin/bash
realuser=$(logname) 

if ! [ $(id -u) = 0 ]; then
   echo "Not root!"
   exit 1
fi

#Install
yum -y install nginx certbot


#Allow 80, 443
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

#Remove default index.html
rm -f /usr/share/nginx/html/index.html
hostname > /usr/share/nginx/html/index.html
echo -n " is working" >> /usr/share/nginx/html/index.html

#Create public html folder
mkdir /var/www
chown nginx:nginx -R /var/www/

#Generate DH Group
openssl dhparam 2048 -out /etc/nginx/dh.pem
chmod 700 /etc/nginx/dh.pem

#Add calling user to nginx group
usermod -aG nginx $realuser

#Start and autoboot
systemctl start nginx
systemctl enable nginx