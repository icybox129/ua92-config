#!/bin/bash
sudo -i
sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
apt update
apt upgrade -y
useradd -m nick
apt install nginx -y
apt install mysql-server -y
apt install php-fpm php php-mysql php-curl php-gd php-imagick php-mbstring php-xml php-xmlrpc -y
apt install certbot python3-certbot-nginx -y
apt install unzip -y
mysql_secure_installation <<EOF
n
y
y
y
y
EOF
wget -P /etc/php/8.1/fpm/pool.d/ https://raw.githubusercontent.com/icybox129/ua92-config/main/wp_icybox_co_uk.conf
wget -P /etc/nginx/conf.d/ https://raw.githubusercontent.com/icybox129/ua92-config/main/wp.icybox.co.uk.conf
cd /etc/php/8.1/fpm/pool.d/
mv www.conf{,.disabled}
systemctl restart php8.1-fpm.service
nginx -s reload
certbot --nginx -d wptest.icybox.co.uk <<EOF
test@test.com
y 
n
EOF
cd /home/nick
wget https://wordpress.org/latest.zip
unzip latest.zip
mv wordpress/ public_html
chown -R nick:www-data /home/nick/public_html/
cd /home/nick/public_html/
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s wp-config-sample.php
systemctl restart php8.1-fpm.service
nginx -s
chown -R nick:www-data /home/nick/
echo "Start up completed!" > /home/nick/log.txt