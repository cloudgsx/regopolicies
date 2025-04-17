
data "azurerm_compute_resource_skus" "example" {
  filter {
    name   = "name"
    values = [var.vm_size]
  }
}

locals {
  vm_found = length(data.azurerm_compute_resource_skus.example.resources) > 0
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = local.vm_found ? 1 : 0

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  # ... rest of your VM settings ...
}

resource "null_resource" "fail_if_invalid_vm_size" {
  count = local.vm_found ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'ERROR: VM size ${var.vm_size} is invalid or unavailable in this region' && exit 1"
  }
}
