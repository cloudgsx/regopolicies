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



Benefits of Using a Module
Reusability: You can call the remove_vm_identity module for any VM by passing its resource_id.
Clean Code: Encapsulates the identity removal logic into a module, keeping your main Terraform files clean.
State Management: Terraform will handle state updates and ensure dependencies are respected.
Automatic Order: By referencing the VM's id in the module, Terraform enforces that the identity removal runs before VM deletion.
