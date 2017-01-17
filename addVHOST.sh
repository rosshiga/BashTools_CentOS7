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
        listen   443 ssl http2;

        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

        server_name  $DOMAIN;
        root /var/www/$DOMAIN;

        ssl_session_cache shared:SSL:20m;
        ssl_session_timeout 60m;
        ssl_prefer_server_ciphers on;
        ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;
        ssl_dhparam /etc/nginx/dh.pem;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_stapling on;
        ssl_stapling_verify on;
        ssl_trusted_certificate /etc/letsencrypt/live/$DOMAIN/chain.pem;
       resolver 8.8.8.8 8.8.4.4;






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
