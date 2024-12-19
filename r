# Terraform Managed Identity Assignment for Virtual Machines

This Terraform module configures Azure Virtual Machines to use managed identities dynamically. The configuration ensures that:

- At least one managed identity is assigned during VM creation.
- Identities can be unassigned explicitly when allowed.
- Accidental unassignment is prevented unless explicitly permitted using a flag.

## Features

- Dynamically assigns user-assigned managed identities to Virtual Machines.
- Supports unassignment of all identities using a `allow_unassignment` flag.
- Enforces validation to prevent accidental unassignment of identities.

## Usage

### Input Variables

#### `managed_identity_ids`
- **Description**: List of user-assigned managed identities to be assigned to the VM.
- **Type**: `list(string)`
- **Default**: N/A (must be provided during VM creation)

#### `allow_unassignment`
- **Description**: Boolean flag to explicitly allow unassigning all identities from the VM.
- **Type**: `bool`
- **Default**: `false`

### Validation Logic

- When `allow_unassignment = false`, `managed_identity_ids` must contain at least one identity.
- When `allow_unassignment = true`, `managed_identity_ids` can be empty, allowing all identities to be unassigned.

### Example Usage

#### Assign Managed Identities
```hcl
variable "managed_identity_ids" {
  default = ["identity1", "identity2"]
}

variable "allow_unassignment" {
  default = false
}

resource "azapi_update_resource" "identity" {
  type        = "Microsoft.Compute/virtualMachines@2023-03-01"
  resource_id = azurerm_linux_virtual_machine.vm.id

  body = {
    identity = {
      type                   = length(var.managed_identity_ids) > 0 ? "UserAssigned" : "None"
      userAssignedIdentities = length(var.managed_identity_ids) > 0 ? { for id in var.managed_identity_ids : id => {} } : null
    }
  }
}
```

#### Unassign Managed Identities (Explicitly Allowed)
```hcl
variable "managed_identity_ids" {
  default = []
}

variable "allow_unassignment" {
  default = true
}

resource "azapi_update_resource" "identity" {
  type        = "Microsoft.Compute/virtualMachines@2023-03-01"
  resource_id = azurerm_linux_virtual_machine.vm.id

  body = {
    identity = {
      type                   = length(var.managed_identity_ids) > 0 ? "UserAssigned" : "None"
      userAssignedIdentities = length(var.managed_identity_ids) > 0 ? { for id in var.managed_identity_ids : id => {} } : null
    }
  }
}
```

### Input Variable Validation

The following validation ensures safe usage:
```hcl
variable "managed_identity_ids" {
  description = "List of user-assigned managed identities to be assigned to the VM"
  type        = list(string)

  validation {
    condition     = var.allow_unassignment || length(var.managed_identity_ids) > 0
    error_message = "At least one managed identity must be provided unless allow_unassignment is set to true."
  }
}
```

### Outputs
- None

## Workflow

1. **Assign Identities:**
   - Populate `managed_identity_ids` with a list of identities.
   - Set `allow_unassignment = false`.

2. **Unassign Identities:**
   - Set `managed_identity_ids` to an empty list (`[]`).
   - Set `allow_unassignment = true` to explicitly allow unassignment.

3. **Prevent Accidental Unassignment:**
   - If `allow_unassignment = false` and `managed_identity_ids` is empty, Terraform will throw a validation error during the plan phase.

## Important Notes

- The `type` field in the `identity` resource is set dynamically:
  - `"UserAssigned"` when identities are provided.
  - `"None"` when identities are explicitly unassigned.
- This configuration is flexible and ensures compliance while allowing intentional unassignment when needed.

## License

This module is open-sourced under the MIT License.
