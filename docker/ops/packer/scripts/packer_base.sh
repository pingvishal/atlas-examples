#!/bin/bash

echo Setting local variables...
VAGRANTHOME="/home/vagrant"
PROFILE="$VAGRANTHOME/.bashrc"
FORCE_INSTALLS=$5
TMP="/tmp"
BIN="/usr/bin"
GOROOT="$BIN/go"
GOPATH="$VAGRANTHOME/go"
MITCHELLHPATH="$GOPATH/src/github.com/mitchellh"
GOXPATH="$MITCHELLHPATH/gox"
PACKERPATH="$MITCHELLHPATH/packer"
BRANCHNAME="h-docker"
BRANCHGITSHA="a7206aebd79738993ad1105faf6bc6be6161c90f"

echo Setting environment variables...
sudo echo "[[ -r $VAGRANTHOME/.bashrc ]] && . $VAGRANTHOME/.bashrc" >> $VAGRANTHOME/.bash_profile
sudo echo "export DOCKER_USER_NAME='$2'" >> $PROFILE
sudo echo "export DOCKER_PASSWORD='$3'" >> $PROFILE
sudo echo "export DOCKER_LOGIN_SERVER='$4'" >> $PROFILE

echo Installing dependencies...
sudo apt-get -y update
sudo apt-get install -y wget
sudo apt-get install -y bzr
sudo apt-get install -y git
sudo apt-get install -y mercurial
cd $TMP

if ! [ -s "$TMP/go.tar.gz" ] || [ $FORCE_INSTALLS ]; then
    echo Fetching go...
    sudo wget https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz -q -O go.tar.gz
else
    echo Skipping go fetch, already fetched...
fi

if ! [ -d "$GOROOT" ] || ! [ "$(ls -A $GOROOT)" ] || [ $FORCE_INSTALLS ]; then
    echo Installing go...
    tar xzf go.tar.gz
    sudo cp -rf go $BIN
else
    echo Skipping go install, already installed...
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

if [ $(git branch | sed -n -e 's/^\* \(.*\)/\1/p') != "$BRANCHNAME" ] || [ $(git rev-parse HEAD) != "$BRANCHGITSHA" ] || [ $FORCE_INSTALLS ]; then
    echo Applying Packer patch https://github.com/mitchellh/packer/pull/1993
    sudo git checkout master
    sudo git pull
    sudo git fetch origin pull/1993/head:$BRANCHNAME
    sudo git checkout $BRANCHNAME
    sudo git rebase origin/master
else
    echo Skipping Packer patch, already applied...
fi

echo Building Packer...

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

echo Setting login directory
sudo echo -e "\ncd $VAGRANTHOME/packer" >> $PROFILE
