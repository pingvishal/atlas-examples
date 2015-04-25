variable "docker_image" {}
variable "count" {
    default = 1
}
variable "atlas_username" {}
variable "atlas_token" {}
variable "atlas_environment" {}
variable "user" {
    default = "docker"
}
variable "key_file" {}
variable "agent" {
    default = false
}
