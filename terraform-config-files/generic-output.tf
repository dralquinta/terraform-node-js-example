output "private_ip" {
  description = "Private IP of the instance created"
  value       = oci_core_instance._REPLACE_.private_ip
}
output "time_created" {
  description = " Instance creation time"
  value       = oci_core_instance._REPLACE_.time_created
}
output "state" {
  description = "State of the instance created"
  value       = oci_core_instance._REPLACE_.state
}
output "shape" {
  description = "Shape of the instance created"
  value       = oci_core_instance._REPLACE_.shape
}
output "instance_id" {
  description = "OCID of the instance created"
  value       = oci_core_instance._REPLACE_.id
}
output "display_name" {
  description = "Name of the instance created"
  value       = oci_core_instance._REPLACE_.display_name
}