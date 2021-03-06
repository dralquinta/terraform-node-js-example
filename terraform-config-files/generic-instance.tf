# Instance Creator

resource "oci_core_instance" "_REPLACE_" {
  display_name = "_REPLACE_"
  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Oracle Java Management Service"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "OS Management Service Agent"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Management Agent"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Run Command"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Block Volume Management"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }
  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }
  availability_domain = var.ad
  compartment_id      = var.tenancy_ocid
  create_vnic_details {
    assign_private_dns_record = "true"
    assign_public_ip          = "false" # only private IP to use only from JumpGate
    subnet_id                 = local.private_subnet_ocid
  }
  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }
  is_pv_encryption_in_transit_enabled = "true"
  shape                               = var.shape
  shape_config {
    memory_in_gbs = var.memory
    ocpus         = var.cpus
  }
  source_details {
    # ID for Custom Image
    source_id   = local.custom_image_ocid
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
    type        = "ssh"
    host        = oci_core_instance._REPLACE_.private_ip # private IP to use only from JumpGate
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)

  }
  provisioner "remote-exec" {
    inline = [
      "set +x",
      "#!/bin/sh",
      "~/startup.sh 2>/tmp/startup.log",
      "~/launcherDocker.sh ${var.nickname} ${var.exchange} ${var.paper_trading} ${var.no_mail} ${var.bot_version} ${var.trade_config} ${var.iv} ${var.DOCKER_USER} ${var.DOCKER_PASS} 2>/tmp/launcherDocker.log",
      "~/launchZabbixAgent.sh 2>/tmp/launchZabbixAgent.log",
    ]

  }

}