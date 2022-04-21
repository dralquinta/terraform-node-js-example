# Instance Creator

resource "oci_core_instance" "_REPLACE_" {
	display_name = "_REPLACE_"
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
	compartment_id = var.tenancy_ocid
	create_vnic_details {
		assign_private_dns_record = "true"
		assign_public_ip = "true"
		subnet_id = var.subnet_ocid
	}
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
	is_pv_encryption_in_transit_enabled = "true"
	shape = var.shape
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
	  oci_core_instance._REPLACE_
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
	  host = oci_core_instance._REPLACE_.public_ip  # TODO: change to private (to use only from JumpGate)
	  user = "ubuntu"
	  private_key = file(var.ssh_private_key)

	}
	provisioner "remote-exec" {
		inline = [
			"set +x",
			"#!/bin/sh",
			"docker run hello-world 2>/tmp/docker.log",
			"date >> /tmp/date.txt",
			"echo 'GH_DCKR_TKN=${var.GH_DCKR_TKN}' >> /home/ubuntu/.bashrc",
			"echo 'DOCKER_PASS=${var.DOCKER_PASS}' >> /home/ubuntu/.bashrc",
			"echo 'DOCKER_USER=${var.DOCKER_USER}' >> /home/ubuntu/.bashrc",
		]
		
	}
	
}