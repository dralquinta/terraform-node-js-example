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

variable "custom_image_name" {
}

variable "private_vcn_name" {
}

variable "private_subnet_name" {
}

variable "ad" {
}

variable "wait_time" {
}


// VM Config

variable "shape" {
}

variable "memory" {
  default = "4"
}

variable "cpus" {
  default = "2"
}


// ENVIRONMENT VARIABLES - GITHUB & DOCKERHUB

variable "DOCKER_PASS" {
  type        = string
  description = "This is your dockerhub password saved in your env variables."
}
variable "DOCKER_USER" {
  type        = string
  description = "This is your dockerhub username saved in your env variables."
}


// BOT ARGS for launcherDocker.sh - passed from nodejs

variable "bot_name" {}
variable "exchange" {}
variable "paper_trading" {}
variable "no_mail" {}
variable "bot_version" {}
variable "trade_config" {}
variable "iv" {}