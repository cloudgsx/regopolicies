provider "azapi" {
  # Configure the Azure provider
  subscription_id = "your_subscription_id"
  tenant_id       = "your_tenant_id"
}

resource "azapi_update_resource" "remove_identity" {
  type = "Microsoft.Compute/virtualMachines@2021-11-01"
  
  # Specify the resource ID of the virtual machine
  resource_id = "/subscriptions/your_subscription_id/resourceGroups/your_resource_group/providers/Microsoft.Compute/virtualMachines/your_vm_name"

  body = jsonencode({
    identity = {
      type = "None"
    }
  })
}
