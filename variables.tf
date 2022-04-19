variable "tenancy_ocid" {
}

variable "compartment_ocid" {
}

variable "ssh_public_key" {
}

variable "ssh_private_key" {
  default = "./keys/SSH/id_rsa"
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
  default = "ocid1.image.oc1.sa-santiago-1.aaaaaaaaqre5wczm5kmvoh373ljuukomkcv6lofz4jfl6lzn46u5m7bgt56a" # Image with docker installed
}

variable "subnet_ocid" {

}
variable "ad" {

}

variable "wait_time" {

}

variable "name" { default = "test" }
variable "memory" { default = "2" }
variable "cpus" { default = "2" }

variable "user_data" {
  default = null
}

variable "compartment_name" {
  description = "The name of the compartment in which to create the instance"
}

variable "network_compartment_name" {
  description = "value of the compartment name where the network is"
}

variable "subnet_name" {
  description = "value of the subnet name"

}

variable "vcn_display_name" {
  description = "value of the vcn display name"
}
