if [ -s "ssh_keys/docker-key.pem" ] && [ -s "ssh_keys/docker-key.pub" ] && [ -z "$1" ]; then
    echo Using existing key pair
else
    rm -rf ssh_keys/key*
    if [ -z "$1" ]; then
        echo No key pair exists and no private key arg was passed, generating new keys
        openssl genrsa -out ssh_keys/docker-key.pem 1024
        chmod 400 ssh_keys/docker-key.pem
        ssh-keygen -y -f ssh_keys/docker-key.pem > ssh_keys/docker-key.pub
    else
        echo Using private key $1 for key pair
        cp $1 ssh_keys/docker-key.pem
        chmod 400 ssh_keys/docker-key.pem
        ssh-keygen -y -f ssh_keys/docker-key.pem > ssh_keys/docker-key.pub
    fi
fi
