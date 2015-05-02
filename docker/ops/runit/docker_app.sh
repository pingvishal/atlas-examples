#!/bin/sh

# echo Configuring Docker Apache app...
# IP_ADDRESS = {{ ip_address }}
# sudo mkdir -p /var/www/$IP_ADDRESS/public_html
# sudo chown -R root:root /var/www/$IP_ADDRESS/public_html
# sudo chmod -R 755 /var/www
# sudo cp -rf /app /var/www/$IP_ADDRESS/public_html

# echo Configuring virtual host
# SITES_AVAILABLE = /etc/apache2/sites-available/$IP_ADDRESS
# sudo cp -f /etc/apache2/sites-available/default $SITES_AVAILABLE
# echo "ServerName $IP_ADDRESS" >> $SITES_AVAILABLE
# echo "DocumentRoot /var/www/$IP_ADDRESS/public_html" >> $SITES_AVAILABLE
# sudo a2ensite $IP_ADDRESS

# echo symlinking app directory to default
# ls -s /app /var/www/default

# echo configuring htdocs
# HTDOCS = /usr/local/apache2/htdocs
# HTDOCS = /etc/apache2/htdocs
# sudo cp -rf /app $HTDOCS

# echo configuring httpd.conf
# HTTPD_CONF = /usr/local/apache2/conf/httpd.conf
# HTTPD_CONF = /etc/apache2/conf/httpd.conf
# sudo sed -i -- 's/DocumentRoot \/var\/www\//\/app/g' $HTTPD_CONF
# sudo sed -i -- 's/Directory "\/var\/www\/"/\/app/g' $HTTPD_CONF
# sudo cp -rf /app/httpd.conf $HTTPD_CONF

sudo sv restart apache2
