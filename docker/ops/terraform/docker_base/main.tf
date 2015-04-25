resource "aws_instance" "docker_base" {
    ami = "${var.ami}"
    security_groups = ["${var.security_group}"]
    key_name = "${var.key_name}"
    instance_type = "${var.instance_type}"
    availability_zone = "${var.availability_zone}"
    count = "${var.count}"

    tags {
      Name = "docker_base_${count.index+1}"
    }
}
