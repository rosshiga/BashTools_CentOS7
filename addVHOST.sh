#!/bin/sh
####################
# A minimal CentOS 7 Deployment Script
#
#
DOMAIN=""
###################
if ! [ $(id -u) = 0 ]; then
   echo "Not root!"
   exit 1
fi

if [ -z "$DOMAIN" ]; then
   echo "Set hostname (example.com): "
   read DOMAIN
fi




systemctl stop nginx

mkdir /var/www/$DOMAIN

cat >>/etc/nginx/conf.d/$DOMAIN.conf<<EOL
server {
        listen   80; ## listen for ipv4
        listen   443 ssl;

        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

        server_name  $DOMAIN;
        root /var/www/$DOMAIN;



        location / {
                index index.html index.htm;
        }



        location ~ /\. {
                deny  all;
        }
}
EOL
certbot certonly --standalone -d $DOMAIN
echo -n "$DOMAIN is working a vhost" >> /var/www/$DOMAIN/index.html

systemctl start nginx
