#!/bin/bash

echo Installing Apache...
sudo apt-get -y update
sudo apt-get install -y apache2

echo Copying Consul Template for Apache into upstart...
sudo cp /ops/upstart/consul_template.conf /etc/init/consul_template.conf
