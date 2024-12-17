# Update the VM to assign user-assigned managed identities
resource "azapi_update_resource" "assign_identities" {
  type        = "Microsoft.Compute/virtualMachines@2023-03-01"
  resource_id = azurerm_linux_virtual_machine.example_vm.id

  body = jsonencode({
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = { 
        for id in var.managed_identity_ids : id => {}
      }
    }
  })
}


variable "remove_identity" {
  description = "Flag to determine if the identity should be removed"
  type        = bool
  default     = false
}

# Optional Identity Removal
resource "azapi_update_resource" "remove_identity" {
  count = var.remove_identity ? 1 : 0

  type        = "Microsoft.Compute/virtualMachines@2023-03-01"
  resource_id = azurerm_linux_virtual_machine.example_vm.id

  body = jsonencode({
    identity = {
      type                   = "None"
      userAssignedIdentities = null
    }
  })
