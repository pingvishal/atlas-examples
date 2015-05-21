#!/bin/sh
echo Installing Apache...
sudo apt-get -y update
sudo apt-get install -y apache2

# Making sure Apache runs on boot
echo Copying Apache into my_init.d...
sudo mkdir -p /etc/my_init.d
sudo cp /ops/runit/apache_base.sh /etc/my_init.d/apache2ctl.sh
sudo chmod +x /etc/my_init.d/apache2ctl.sh

sudo echo -e "\nServerName localhost" >> /etc/apache2/apache2.conf
