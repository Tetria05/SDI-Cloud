#!/bin/bash
# contributers: Guus, Noa, Bodhi

db_name="espocrm"
db_user="espo"
db_pw="guus123"
ip=$(hostname -I)

apt update
apt install apache2 mysql-server php8.1 libapache2-mod-php8.1 php8.1-common php8.1-curl php8.1-mysql php8.1-opcache php8.1-intl php8.1-fpm php8.1-xmlrpc php8.1-bcmath php8.1-zip php8.1-mbstring php8.1-gd php8.1-cli php8.1-xml php8.1-zip wget unzip curl -y
sed -i "s/memory_limit = 128M/memory_limit = 256M/" /etc/php/8.1/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php/8.1/apache2/php.ini
sed -i "s/post_max_size = 8M/post_max_size = 100M/" /etc/php/8.1/apache2/php.ini
sed -i "s/max_execution_time = 30/max_execution_time = 180/" /etc/php/8.1/apache2/php.ini
sed -i "s/max_input_time = 60/max_input_time = 180/" /etc/php/8.1/apache2/php.ini

systemctl enable apache2
systemctl restart apache2

mysql -e "CREATE DATABASE ${db_name};"
mysql -e "CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_pw}';"
mysql -e "GRANT ALL ON ${db_name}.* TO '${db_user}'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

wget https://www.espocrm.com/downloads/EspoCRM-7.0.9.zip
unzip EspoCRM-7.0.9.zip
mv EspoCRM-7.0.9 espocrm
mv espocrm /var/www/
rm EspoCRM-7.0.9.zip
chown -R www-data:www-data /var/www/espocrm
chmod -R 755 /var/www/espocrm
ufw allow 80
touch /etc/apache2/sites-available/espocrm.conf

cat <<EOF>> /etc/apache2/sites-available/espocrm.conf
<VirtualHost $ip:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/espocrm
    ServerName example.com
    ServerAlias www.example.com

     <Directory /var/www/espocrm/>
          Options FollowSymlinks
          AllowOverride All
          Require all granted
     </Directory>

     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2dissite 000-default.conf
a2ensite espocrm.conf
a2enmod rewrite
systemctl restart apache2
