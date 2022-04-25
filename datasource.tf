/*
data "oci_identity_compartments" "NWCOMPARTMENTS" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  filter {
    name   = "name"
    values = [var.network_compartment_name]
  }
}
*/

data "oci_core_vcns" "VCN" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "display_name"
    values = [var.private_vcn_name]
  }
}

data "oci_core_subnets" "SUBNET" {
  compartment_id = var.tenancy_ocid
  vcn_id         = local.private_vcn_ocid
  filter {
    name   = "display_name"
    values = [var.private_subnet_name]
  }
}

data "oci_core_images" "CUSTOM" { 
  compartment_id = var.tenancy_ocid
  filter {
    name   = "display_name"
    values = [var.custom_image_name]
  }
}

locals {
/* 
  compartment_ocid    = lookup(data.oci_identity_compartments.COMPARTMENTS.compartments[0], "id")
  nw_compartment_ocid = lookup(data.oci_identity_compartments.NWCOMPARTMENTS.compartments[0], "id")
*/

  private_subnet_ocid = length(data.oci_core_subnets.SUBNET.subnets) > 0 ? data.oci_core_subnets.SUBNET.subnets[0].id : null
  private_vcn_ocid = lookup(data.oci_core_vcns.VCN.virtual_networks[0], "id")
  custom_image_ocid = length(data.oci_core_images.CUSTOM.images) > 0 ? data.oci_core_images.CUSTOM.images.0.id : null
  
}