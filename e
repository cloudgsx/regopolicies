module "remove_vm_identity" {
  source = "./modules/remove_vm_identity"

  # Pass the VM's resource ID to the module
  vm_id = azurerm_virtual_machine.example.id
}

resource "azurerm_virtual_machine" "example" {
  name                = "my-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  vm_size             = "Standard_DS1_v2"

  # Add lifecycle to ensure dependency
  lifecycle {
    precondition {
      condition     = module.remove_vm_identity != null
      error_message = "Failed to remove identity before deleting the VM."
    }
  }
}
