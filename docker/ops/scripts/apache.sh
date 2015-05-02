#!/bin/bash

echo Installing Apache...
sudo apt-get -y update
sudo apt-get install -y apache2

echo Copying Consul Template for Apache into runit...
sudo mkdir -p /etc/service/consul_template
sudo cp /ops/runit/consul_template.sh /etc/service/consul_template/run
