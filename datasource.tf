data "oci_identity_compartments" "COMPARTMENTS" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  filter {
    name   = "name"
    values = [var.compartment_name]
  }
}


data "oci_identity_compartments" "NWCOMPARTMENTS" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  filter {
    name   = "name"
    values = [var.network_compartment_name]
  }
}


data "oci_core_subnets" "SUBNET" {
  compartment_id = local.nw_compartment_ocid
  vcn_id         = local.vcn_id
  filter {
    name   = "display_name"
    values = [var.subnet_name]
  }
}


data "oci_core_vcns" "VCN" {
  compartment_id = local.nw_compartment_ocid
  filter {
    name   = "display_name"
    values = [var.vcn_display_name]
  }
}


locals {
  compartment_ocid    = lookup(data.oci_identity_compartments.COMPARTMENTS.compartments[0], "id")
  nw_compartment_ocid = lookup(data.oci_identity_compartments.NWCOMPARTMENTS.compartments[0], "id")

  vcn_id = lookup(data.oci_core_vcns.VCN.virtual_networks[0], "id")


  private_subnet_ocid = length(data.oci_core_subnets.SUBNET.subnets) > 0 ? data.oci_core_subnets.SUBNET.subnets[0].id : null
}