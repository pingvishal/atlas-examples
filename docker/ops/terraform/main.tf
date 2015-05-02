provider "atlas" {
    token = "${var.atlas_token}"
}

resource "atlas_artifact" "base_ami" {
    name = "${var.atlas_username}/${var.artifact_base}"
    type = "aws.ami"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "aws_security_group" "allow_all" {
    name = "allow_all"
    description = "Allow all inbound traffic"

    tags {
      Name = "allow_all"
    }

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "docker" {
    key_name = "docker-key-pair"
    public_key = "${file(var.public_key)}"
}

module "docker_base" {
    source = "./docker_base"
    ami = "${atlas_artifact.base_ami.metadata_full.region-us-east-1}"
    security_group = "${aws_security_group.allow_all.name}"
    key_name = "${aws_key_pair.docker.key_name}"
    instance_type = "${var.base_instance_type}"
    availability_zone = "${var.base_availability_zone}"
    count = "${var.base_count}"
}

provider "docker" {
    # host = "tcp://${module.docker_base.ip_address}:2375/"
    host = "tcp://${var.docker_host_ip}:2375/"
    cert_path = "${var.docker_cert_path}"
}

module "docker_consul" {
    source = "./docker_consul"
    docker_image = "${var.docker_consul_image}"
    count = "${var.consul_count}"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    key_file = "${var.private_key}"
    host = "${module.docker_base.ip_address}"
}

/*
module "docker_app" {
    source = "./docker_app"
    docker_image = "${var.docker_app_image}"
    count = "${var.app_count}"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    key_file = "${var.private_key}"
    host = "${module.docker_base.ip_address}"
}
*/
