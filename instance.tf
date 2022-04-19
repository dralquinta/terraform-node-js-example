# Instance Creator

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

variable "name" { default = "test"}
variable "memory" { default = "2"}
variable "cpus" { default = "2"}
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}


variable "user_data" {	
	default = null
}

  


resource "oci_core_instance" "testing" {
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
	availability_domain = var.ad
	compartment_id = var.compartment_ocid
	create_vnic_details {
		assign_private_dns_record = "true"
		assign_public_ip = "true"
		subnet_id = var.subnet_ocid
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
        ssh_authorized_keys = file(var.ssh_public_key)                
    } 
    preserve_boot_volume = false
}


resource "null_resource" "wait_for_cloud_init" {
	depends_on = [
	  oci_core_instance.testing
	]
	provisioner "local-exec" {
		command = "sleep ${var.wait_time}"
	}
}

resource "null_resource" "script_exec" {
	depends_on = [
	  null_resource.wait_for_cloud_init
	]
	connection {
	  type = "ssh"
	  host = oci_core_instance.testing.private_ip
	  user = "ubuntu"
	  private_key = file(var.ssh_private_key)

	}
	provisioner "remote-exec" {
		inline = [
			"set +x",
			"#!/bin/sh",
			"whoami > /tmp/root-output.txt",
			"date >> /tmp/date.txt",
			"docker run hello-world 2>/tmp/docker.log",
			"date >> /tmp/date.txt",
		]
		
	}
	
}