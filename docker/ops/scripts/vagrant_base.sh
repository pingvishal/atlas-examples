#!/bin/sh
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
PACKERBRANCHNAME="h-packer"
PACKERPATCH=1993
HASHICORPPATH="$GOPATH/src/github.com/hashicorp"
TERRAFORMPATH="$HASHICORPPATH/terraform"
TERRAFORMBRANCHNAME="h-terraform"
TERRAFORMPATCH=

echo Setting environment variables...
BASHPROFILE="[[ -r $VAGRANTHOME/.bashrc ]] && . $VAGRANTHOME/.bashrc"

if grep -Fxq "$BASHPROFILE" $VAGRANTHOME/.bash_profile; then
    echo $VAGRANTHOME/.bash_profile already updated
else
    echo "$BASHPROFILE" | sudo tee --append $VAGRANTHOME/.bash_profile
fi

sudo sh -c echo -e "\n" >> $PROFILE
echo "alias t='terraform'" | sudo tee --append $PROFILE
echo "alias p='packer'" | sudo tee --append $PROFILE
echo "export ATLAS_USERNAME='$2'" | sudo tee --append $PROFILE
echo "export ATLAS_TOKEN='$3'" | sudo tee --append $PROFILE
echo "export AWS_ACCESS_KEY='$4'" | sudo tee --append $PROFILE
echo "export AWS_SECRET_KEY='$5'" | sudo tee --append $PROFILE
echo "export DOCKER_LOGIN_EMAIL='$6'" | sudo tee --append $PROFILE
echo "export DOCKER_USER_NAME='$7'" | sudo tee --append $PROFILE
echo "export DOCKER_PASSWORD='$8'" | sudo tee --append $PROFILE
echo "export DOCKER_LOGIN_SERVER='$9'" | sudo tee --append $PROFILE

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

echo "export GOROOT=$GOROOT" | sudo tee --append $PROFILE
export GOROOT=$GOROOT
echo "export GOPATH=$GOPATH" | sudo tee --append $PROFILE
export GOPATH=$GOPATH
echo "export PATH=$PATH:$GOROOT/bin:$GOPATH/bin" | sudo tee --append $PROFILE
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
mkdir -p $MITCHELLHPATH
mkdir -p $HASHICORPPATH

# if ! [ -d "$GOXPATH" ] || ! [ "$(ls -A $GOXPATH)" ] || [ $FORCE_INSTALLS ]; then
    # echo Fetching gox...
    # go get -u github.com/mitchellh/gox
# else
    # echo Skipping gox fetch, already fetched...
# fi
echo Installing Hashi go dependencies...
go get -u github.com/tools/godep
go get -u github.com/mitchellh/gox

cd $MITCHELLHPATH

if ! [ -d "$PACKERPATH" ] || ! [ "$(ls -A $PACKERPATH)" ] || [ $FORCE_INSTALLS ]; then
    echo Fetching Packer from GitHub...
    sudo git clone https://github.com/mitchellh/packer.git
else
    echo Skipping Packer fetch, already fetched...
fi

echo "export PACKERPATH=$PACKERPATH" | sudo tee --append $PROFILE
cd $PACKERPATH

if [ $(git branch | sed -n -e 's/^\* \(.*\)/\1/p') != "$PACKERBRANCHNAME" ] || [ $FORCE_INSTALLS ]; then
    echo Applying Packer patch https://github.com/mitchellh/packer/pull/1993
    sudo git checkout master
    sudo git pull
    sudo git fetch origin pull/$PACKERPATCH/head:$PACKERBRANCHNAME
    sudo git checkout $PACKERBRANCHNAME
    sudo git rebase origin/master
else
    echo Skipping Packer patch, already applied...
fi

if ! [ -d "$PACKERPATH/bin" ] || ! [ "$(ls -A $PACKERPATH/bin)" ] || [ $FORCE_INSTALLS ]; then
    echo Building Packer binaries in $PACKERPATH/bin...
    make clean
    make updatedeps
    make
    make dev
    make bin
else
    echo Skipping building of binaries in $PACKERPATH/bin, already built...
fi

cd $HASHICORPPATH

echo Fetching Terraform from GitHub...
git clone https://github.com/hashicorp/terraform.git

echo "export TERRAFORMPATH=$TERRAFORMPATH" | tee --append $PROFILE
cd $TERRAFORMPATH
git checkout master
git pull

if [ $TERRAFORMPATCH ]; then
    echo Applying Terraform patch https://github.com/hashicorp/terraform/pull/$TERRAFORMPATCH
    git fetch origin pull/$TERRAFORMPATCH/head:$TERRAFORMBRANCHNAME
    git checkout $TERRAFORMBRANCHNAME
    git rebase origin/master
fi

echo Building Terraform binaries in $TERRAFORMPATH/bin...
make clean
make updatedeps
make
make dev
make bin

cd $TMP

# if ! [ -s "terraform.zip" ] || [ $FORCE_INSTALLS ]; then
    # echo Fetching Terraform...
    # sudo wget https://dl.bintray.com/mitchellh/terraform/terraform_0.5.0_linux_amd64.zip -q -O terraform.zip
# else
    # echo Skipping Terraform fetch, already fetched...
# fi

# if ! [ -d "terraform" ] || ! [ "$(ls -A terraform)" ] || [ $FORCE_INSTALLS ]; then
    # echo Installing Terraform...
    # sudo rm -rf terraform
    # sudo unzip terraform.zip -d terraform
    # sudo chmod +x terraform
    # sudo cp -rf terraform/. $BIN
# else
    # echo Skipping Terraform install, already installed...
# fi

echo Configuring Docker DNS...

if grep -Fxq "nameserver 8.8.8.8" /etc/resolv.conf; then
    echo nameserver 8.8.8.8 already exists...
else
    echo "nameserver 8.8.8.8" | sudo tee --append /etc/resolv.conf
fi

sudo sed -i -- 's/#DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"/DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"/g' /etc/default/docker
sudo service docker restart

echo Setting login directory...
echo "cd $VAGRANTHOME/ops" | sudo tee --append $PROFILE
