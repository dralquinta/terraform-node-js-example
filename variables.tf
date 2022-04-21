variable "tenancy_ocid" {
}

variable "compartment_ocid" {
}

variable "ssh_public_key" {
}

variable "ssh_private_key" {
}

variable "private_key_path" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "region" {
}

variable "custom_image_ocid" {
}

variable "subnet_ocid" {
}

variable "ad" {
}

variable "wait_time" {
}

variable "shape" {
}

variable "memory" {
  default = "4" 
}

variable "cpus" {
  default = "2" 
}

variable "GH_DCKR_TKN" {
    type        = string
    description = "This is your github token saved in your env variables."
}
variable "DOCKER_PASS" {
    type        = string
    description = "This is your dockerhub password saved in your env variables."
}
variable "DOCKER_USER" {
    type        = string
    description = "This is your dockerhub username saved in your env variables."
}