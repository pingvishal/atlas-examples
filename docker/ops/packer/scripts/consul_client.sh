echo Copying Consul client config into upstart...
echo '{"service": {"name": "docker", "tags": ["consul", "client", "docker"]}}' \
        >/etc/consul.d/bootstrap.json
sudo cp /ops/upstart/consul_client.conf /etc/init/consul.conf
