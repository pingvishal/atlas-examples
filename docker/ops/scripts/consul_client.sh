#!/bin/sh
echo Consul Configuration...
echo '{"service": {"name": "docker", "tags": ["consul", "client", "docker"]}}' \
        >/etc/consul.d/bootstrap.json

echo Copying Consul client config into runit...
sudo mkdir -p /etc/service/consul
sudo cp /ops/runit/consul_client.sh /etc/service/consul/run
sudo chmod +x /etc/service/consul/run
