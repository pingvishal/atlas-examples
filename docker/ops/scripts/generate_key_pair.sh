#!/bin/sh
if [ -s "terraform/ssh_keys/docker-key.pem" ] && [ -s "terraform/ssh_keys/docker-key.pub" ] && [ -z "$1" ]; then
    echo Using existing key pair
else
    rm -rf terraform/ssh_keys/docker-key.*
    if [ -z "$1" ]; then
        echo No key pair exists and no private key arg was passed, generating new keys
        openssl genrsa -out terraform/ssh_keys/docker-key.pem 1024
        chmod 400 terraform/ssh_keys/docker-key.pem
        ssh-keygen -y -f terraform/ssh_keys/docker-key.pem > terraform/ssh_keys/docker-key.pub
    else
        echo Using private key $1 for key pair
        cp $1 terraform/ssh_keys/docker-key.pem
        chmod 400 terraform/ssh_keys/docker-key.pem
        ssh-keygen -y -f terraform/ssh_keys/docker-key.pem > terraform/ssh_keys/docker-key.pub
    fi
fi
