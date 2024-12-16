struct

terraform-module/
│
├── main.tf          # Main logic of the module
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── README.md        # Documentation

main.tf

terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azapi" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

resource "azapi_update_resource" "remove_identity" {
  type       = "Microsoft.Compute/virtualMachines@2024-07-01"
  resource_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group}/providers/Microsoft.Compute/virtualMachines/${var.vm_name}"

  body = {
    identity = null
  }
}



vars.tf

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}

variable "resource_group" {
  description = "The name of the Azure resource group"
  type        = string
}

variable "vm_name" {
  description = "The name of the Azure virtual machine"
  type        = string
}


outputs.tf

output "vm_resource_id" {
  description = "The resource ID of the virtual machine"
  value       = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group}/providers/Microsoft.Compute/virtualMachines/${var.vm_name}"
}


readme.md

# Azure VM Identity Removal Module

This module removes the identity from an existing Azure Virtual Machine.

## Usage

```hcl
module "remove_vm_identity" {
  source           = "./path-to-your-module"
  subscription_id  = "your-subscription-id"
  tenant_id        = "your-tenant-id"
  resource_group   = "your-resource-group"
  vm_name          = "your-vm-name"
}

Inputs
Variable	Description	Type	Required
subscription_id	The Azure subscription ID	string	yes
tenant_id	The Azure tenant ID	string	yes
resource_group	The Azure resource group name	string	yes
vm_name	The Azure virtual machine name	string	yes

Outputs
Output	Description
vm_resource_id	The resource ID of the VM


---

### **5. How to Use the Module**
1. Place the module folder in your Terraform project.
2. Reference the module using the `source` parameter.

**Example:**

```hcl
module "remove_vm_identity" {
  source           = "./terraform-module"
  subscription_id  = "d81199c9-db9f-4fd1-bef6-b3a84fd3f306"
  tenant_id        = "d5106b4b-92ce-4ae1-8f40-4fd0edde0717bc"
  resource_group   = "c750f6ca-a6c3-4d12-a052-aeabcc060186"
  vm_name          = "cb4vujrtnb8zzbu"
}
