echo Configuring Docker app
# TODO: Write shell script to configure Docker app
echo Copying Docker app config into upstart...
sudo cp /ops/upstart/docker_app.conf /etc/init/docker_app.conf
