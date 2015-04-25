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

resource "aws_security_group" "allow_tcp" {
    name = "allow_tcp"
    description = "Allow all inbound tcp traffic"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 2375
        to_port = 2375
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
      Name = "allow_tcp"
    }
}

resource "aws_key_pair" "docker" {
    key_name = "docker-key-pair"
    public_key = "${file(var.public_key)}"
}

module "docker_base" {
    source = "./docker_base"
    ami = "${atlas_artifact.base_ami.metadata_full.region-us-east-1}"
    security_group = "${aws_security_group.allow_tcp.name}"
    key_name = "${aws_key_pair.docker.key_name}"
    instance_type = "${var.base_instance_type}"
    availability_zone = "${var.base_availability_zone}"
    count = "${var.base_count}"
}

provider "docker" {
    # host = "tcp://${module.docker_base.ip_address}:2375/"
    host = "tcp://52.1.247.231:2375/"
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
}

module "docker_app" {
    source = "./docker_app"
    docker_image = "${var.docker_app_image}"
    count = "${var.app_count}"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    key_file = "${var.private_key}"
}
