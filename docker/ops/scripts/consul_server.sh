#!/bin/bash

echo Copying Consul server config into runit...
echo '{"service": {"name": "consul", "tags": ["consul", "server", "cluster"]}}' \
        >/etc/consul.d/bootstrap.json

# runit
sudo mkdir -p /etc/service/consul
sudo cp /ops/runit/consul_server.sh /etc/service/consul/run
sudo chmod +x /etc/service/consul/run
