#!/bin/sh
echo Installing dependencies...
sudo apt-get -y update
sudo apt-get install -y wget
sudo apt-get install -y unzip
cd /tmp

# Install Consul
if ! [ -s "consul.zip" ]; then
    echo Fetching Consul...
    sudo wget https://dl.bintray.com/mitchellh/consul/0.5.0_linux_amd64.zip -q -O consul.zip
else
    echo Skipping Consul fetch, already fetched...
fi

if [ -s "consul.zip" ]; then
    echo Installing Consul...
    unzip consul.zip
    sudo chmod +x consul
    sudo mv consul /usr/bin/consul
    sudo mkdir /etc/consul.d
    sudo chmod -R 777 /etc/consul.d
    sudo chmod a+w /var/log
else
    echo Consul install failed! Binaries not present...
fi
