output "vm_size_validation_check" {
  value = local.valid_vm_size ? "VM size is valid" : local.selected_zone["__force_error"]
  description = "Forces error if no valid VM size/zone is found"
}
