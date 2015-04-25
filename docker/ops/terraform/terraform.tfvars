/* You can either use this terraform.tfvars file to pass variables
to terraform and ignore it from version control, or just
pass them in through the command line as noted in variables.tf
See https://www.terraform.io/intro/getting-started/variables.html */

# Required Variables
atlas_token = "YOUR_ATLAS_TOKEN"
atlas_username = "YOUR_ATLAS_USERNAME"
aws_access_key = "YOUR_AWS_ACCESS_KEY"
aws_secret_key = "YOUR_AWS_SECRET_KEY"

# Optional Configuration Variables - Uncomment and populate to override
# the variables below with your desired configuration to
# override the defaults in ops/terraform/variables.tf
# artifact_base = "docker_base"
# region = "us-east-1"
# public_key = "ssh_keys/docker-key.pub"
# private_key = "ssh_keys/docker-key.pem"
# base_instance_type = "t2.micro"
# base_availability_zone = "us-east-1a"
# base_count = 1
# docker_cert_path = ""
# atlas_environment = "docker"
# docker_consul_image = "bensojona/packer:consul_1429915814"
# consul_count = 3
# docker_app_image = "bensojona/packer:app_1429915393"
# app_count = 1
