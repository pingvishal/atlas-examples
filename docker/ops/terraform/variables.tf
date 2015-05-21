/* The variables required for a Terraform command to run
properly can be passed in at the command line as shown below,
or you can use the terraform.tfvars file and Terraform will
populate the variables from there and all you will have to
run is the Terraform command e.g.'terraform apply'

terraform apply \
    -var "atlas_token=${ATLAS_TOKEN}" \
    -var "atlas_username=${ATLAS_USERNAME}" \
    -var "aws_access_key=${AWS_ACCESS_KEY}" \
    -var "aws_secret_key=${AWS_SECRET_KEY}"

See https://www.terraform.io/intro/getting-started/variables.html */

# Required Variables
variable "atlas_token" {
    description = "Atlas token"
}
variable "atlas_username" {
    description = "Atlas username"
}
variable "aws_access_key" {
    description = "AWS access key"
}
variable "aws_secret_key" {
    description = "AWS secret access key"
}

# Optional Configuration Variables
variable "artifact_base" {
    description = "Name of Atlas artifact for Docker base"
    default = "docker_base"
}
variable "region" {
    description = "AWS region to host your network"
    default = "us-east-1"
}
variable "public_key" {
    description = "Public key file located in ops/terraform/ssh_keys/docker-key.pub, use ops/terraform/scripts/generate_key_pair.sh to generate"
    default = "ssh_keys/docker-key.pub"
}
variable "private_key" {
    description = "Private key file located in ops/terraform/ssh_keys/docker-key.pem, use ops/terraform/scripts/generate_key_pair.sh to generate"
    default = "ssh_keys/docker-key.pem"
}
variable "base_instance_type" {
    description = "AWS instance type Docker containers will run on"
    default = "t2.micro"
}
variable "base_availability_zone" {
    description = "AWS availability zone"
    default = "us-east-1a"
}
variable "base_count" {
    description = "Count of base instances Docker containers will run on"
    default = 1
}
variable "docker_host_ip" {
    description = "Public IP address of Docker host"
}
variable "docker_cert_path" {
    description = "Path to a directory with certificate information for connecting to the Docker host via TLS"
    default = ""
}
variable "atlas_environment" {
    description = "Environment infrastructure will be hosted under in Atlas"
    default = "docker"
}

# Consul cluster specific variables
variable "docker_consul_image" {
    description = "Docker image name for Consul cluster"
    default = "bensojona/consul_image:latest"
}
variable "consul_count" {
    description = "Count of nodes in Consul cluster"
    default = 3
}

# App specific variables
variable "docker_apache_image" {
    description = "Docker image name for app"
    default = "bensojona/apache_image:latest"
}
variable "app_count" {
    description = "Count of nodes for app"
    default = 1
}
