resource "null_resource" "vm_size_validation" {
  count = local.valid_vm_size ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'ERROR: VM size ${var.vm_size} is not available in ${var.location}!' && exit 1"
  }
}
