variable "ami" {}
variable "security_group" {}
variable "key_name" {}
variable "instance_type" {}
variable "availability_zone" {}
variable "count" {
    default = 1
}

output "ip_address" {
    value = "${aws_instance.docker_base.public_ip}"
}
