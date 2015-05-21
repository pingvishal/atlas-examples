#!/bin/sh
echo Installing Docker
wget -qO- https://get.docker.io/ | sh
sudo sed -i -- 's/#DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"/DOCKER_OPTS="-H tcp:\/\/0.0.0.0:2375 -H unix:\/\/\/var\/run\/docker.sock"/g' /etc/default/docker
echo "DOCKER_OPTS=\"-r=true \${DOCKER_OPTS}\"" | sudo tee --append /etc/default/docker
sudo service docker restart
