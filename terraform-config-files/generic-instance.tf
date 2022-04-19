# Instance Creator

variable "tenancy_ocid" {
}

variable "compartment_ocid" {
}

variable "ssh_public_key" {
    default = "./id_rsa.pub"
}

variable "ssh_private_key" {
    default = "./id_rsa"
}

variable "private_key_path" {
    default = "./03-26-00-03.pem"
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "region" {
    default = "us-ashburn-1"
}

variable "custom_image_ocid" {
	# default = "ocid1.image.oc1.iad.aaaaaaaadkmnptlftmo5nhkykldgqe65bm4l4o3dhizrqglaupercng5ozqa" // bot ubuntu
	# default = "ocid1.image.oc1.iad.aaaaaaaamc2xy64p4r4tcwjy26ksdkehrdrzjcacw4upaq7fnqict55as4kq" // config docker
	default = "ocid1.image.oc1.iad.aaaaaaaawehpckjmbpci6co2oibwxlx5ou7kjlllun22enhyvyxhftglfoaa" // infra_root
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

variable "name" {}
variable "memory" {}
variable "cpus" {}
variable "user_data" {}

resource "oci_core_instance" "_REPLACE_" {
	display_name = var.name
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "DISABLED"
			name = "Vulnerability Scanning"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Oracle Java Management Service"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "OS Management Service Agent"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Management Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Run Command"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Block Volume Management"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Bastion"
		}
	}
	availability_config {
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = "ssii:US-ASHBURN-AD-1"
	compartment_id = "ocid1.tenancy.oc1..aaaaaaaaurx6kiejqos56erltmqvj4hfwz6x3aoa673krc2l5pbvjlh7wnka"
	create_vnic_details {
		assign_private_dns_record = "true"
		assign_public_ip = "true"
		subnet_id = "ocid1.subnet.oc1.iad.aaaaaaaaospfynrnstsadj7hu7cprkgxent7iaofvzpknwcd53spdw77t7ma"
	}
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
	is_pv_encryption_in_transit_enabled = "true"
	shape = "VM.Standard.E3.Flex"
	shape_config {
		memory_in_gbs = var.memory
		ocpus = var.cpus
	}
	source_details {
		# ID for Custom Image
		source_id = var.custom_image_ocid
		source_type = "image"
	}
	metadata = {
        ssh_authorized_keys = file("./id_rsa.pub")
        user_data: var.user_data  
        # user_data = ${base64encode(file("./initial-script.sh"))}
    } 
    preserve_boot_volume = false
}
