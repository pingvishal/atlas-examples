sudo apt-get -y update

# Install Apache
echo Installing Apache...
sudo apt-get install -y apache
sudo service apache2 restart
