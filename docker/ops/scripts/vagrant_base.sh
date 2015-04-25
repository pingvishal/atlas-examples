#!/bin/bash

echo Setting local variables...
VAGRANTHOME="/home/vagrant"
PROFILE="$VAGRANTHOME/.bashrc"
TMP="/tmp"
FORCE_INSTALLS=$1
BIN="/usr/bin"
GOROOT="$BIN/go"
GOPATH="$VAGRANTHOME/go"
MITCHELLHPATH="$GOPATH/src/github.com/mitchellh"
GOXPATH="$MITCHELLHPATH/gox"
PACKERPATH="$MITCHELLHPATH/packer"
BRANCHNAME="h-docker"

echo Setting environment variables...
sudo echo "[[ -r $VAGRANTHOME/.bashrc ]] && . $VAGRANTHOME/.bashrc" >> $VAGRANTHOME/.bash_profile

sudo echo "export ATLAS_USERNAME='$2'" >> $PROFILE
sudo echo "export ATLAS_TOKEN='$3'" >> $PROFILE
sudo echo "export AWS_ACCESS_KEY='$4'" >> $PROFILE
sudo echo "export AWS_SECRET_KEY='$5'" >> $PROFILE
sudo echo "export DOCKER_LOGIN_EMAIL='$6'" >> $PROFILE
sudo echo "export DOCKER_USER_NAME='$7'" >> $PROFILE
sudo echo "export DOCKER_PASSWORD='$8'" >> $PROFILE
sudo echo "export DOCKER_LOGIN_SERVER='$9'" >> $PROFILE
sudo echo "alias t='terraform'" >> $PROFILE
sudo echo "alias p='packer'" >> $PROFILE

echo Installing dependencies...
sudo apt-get -y update
sudo apt-get install -y wget
sudo apt-get install -y tar
sudo apt-get install -y bzr
sudo apt-get install -y git
sudo apt-get install -y mercurial
sudo apt-get install -y unzip

cd $TMP

if ! [ -s "go.tar.gz" ] || [ $FORCE_INSTALLS ]; then
    echo Fetching go...
    sudo wget https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz -q -O go.tar.gz
else
    echo Skipping Go fetch, already fetched...
fi

if ! [ -d "$GOROOT" ] || ! [ "$(ls -A $GOROOT)" ] || [ $FORCE_INSTALLS ]; then
    echo Installing Go...
    tar xzf go.tar.gz
    sudo cp -rf go $BIN
else
    echo Skipping Go install, already installed...
fi

sudo echo -e "\nexport GOROOT=$GOROOT" >> $PROFILE
export GOROOT=$GOROOT
sudo echo "export GOPATH=$GOPATH" >> $PROFILE
export GOPATH=$GOPATH
sudo echo "export PATH=$PATH:$GOROOT/bin:$GOPATH/bin" >> $PROFILE
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

if ! [ -d "$GOXPATH" ] || ! [ "$(ls -A $GOXPATH)" ] || [ $FORCE_INSTALLS ]; then
    echo Fetching gox...
    go get -u github.com/mitchellh/gox
else
    echo Skipping gox fetch, already fetched...
fi

cd $MITCHELLHPATH

if ! [ -d "$PACKERPATH" ] || ! [ "$(ls -A $PACKERPATH)" ] || [ $FORCE_INSTALLS ]; then
    echo Fetching Packer from GitHub...
    sudo git clone https://github.com/mitchellh/packer.git
else
    echo Skipping Packer fetch, already fetched...
fi

sudo echo "export PACKERPATH=$PACKERPATH" >> $PROFILE
cd $PACKERPATH

if [ $(git branch | sed -n -e 's/^\* \(.*\)/\1/p') != "$BRANCHNAME" ] || [ $FORCE_INSTALLS ]; then
    echo Applying Packer patch https://github.com/mitchellh/packer/pull/1993
    sudo git checkout master
    sudo git pull
    sudo git fetch origin pull/1993/head:$BRANCHNAME
    sudo git checkout $BRANCHNAME
    sudo git rebase origin/master
else
    echo Skipping Packer patch, already applied...
fi

if ! [ -d "$PACKERPATH/bin" ] || ! [ "$(ls -A $PACKERPATH/bin)" ] || [ $FORCE_INSTALLS ]; then
    echo Building Packer binaries in $PACKERPATH/bin...
    # make dev
    make bin
else
    echo Skipping building of binaries in $PACKERPATH/bin, already built...
fi

if ! [ -s "/etc/packer.d" ]; then
    echo Configuring Packer logs
    sudo mkdir -p /etc/packer.d
    sudo chmod -R 777 /etc/packer.d
    sudo chmod a+w /var/log
fi

cd $TMP

if ! [ -s "terraform.zip" ] || [ $FORCE_INSTALLS ]; then
    echo Fetching Terraform...
    sudo wget https://dl.bintray.com/mitchellh/terraform/terraform_0.4.2_linux_amd64.zip -q -O terraform.zip
else
    echo Skipping Terraform fetch, already fetched...
fi

if ! [ -d "terraform" ] || ! [ "$(ls -A terraform)" ] || [ $FORCE_INSTALLS ]; then
    echo Installing Terraform...
    unzip terraform.zip -d terraform
    sudo chmod +x terraform
    sudo cp -rf terraform/. $BIN
    sudo mkdir -p /etc/terraform.d
    sudo chmod -R 777 /etc/terraform.d
    sudo chmod a+w /var/log
else
    echo Skipping Terraform install, already installed...
fi

echo Setting login directory...
sudo echo -e "\ncd $VAGRANTHOME/ops" >> $PROFILE
