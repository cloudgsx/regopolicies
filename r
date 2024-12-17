1. OPA Policy (Key Vault Validation)

package terraform.azure.keyvault

# Input: Terraform plan file
import input.planned_values as tfplan

# Define rules for Key Vault validation
deny[msg] {
    vault := tfplan.root_module.resources[_]
    vault.type == "azurerm_key_vault"
    not valid_keyvault_configuration(vault)
    msg := sprintf("Invalid Key Vault configuration for %v. Ensure SKU is 'premium' and access policy allows Deny actions.", [vault.values.name])
}

# Validate Key Vault configuration
valid_keyvault_configuration(vault) {
    vault.values.sku_name == "premium"  # SKU must be 'premium'
    required_tags_present(vault.values.tags)
    check_network_acls(vault.values.network_acls)
}

# Check required tags
required_tags_present(tags) {
    tags["Environment"]
    tags["Owner"]
}

# Validate Network ACLs for Deny action
check_network_acls(acls) {
    acls.default_action == "Deny"
}


2. Mock Terraform Plan JSON

{
  "planned_values": {
    "root_module": {
      "resources": [
        {
          "type": "azurerm_key_vault",
          "name": "example_keyvault",
          "values": {
            "name": "example-keyvault-001",
            "sku_name": "premium",
            "tags": {
              "Environment": "production",
              "Owner": "cloudteam"
            },
            "network_acls": {
              "default_action": "Deny",
              "ip_rules": ["10.0.0.0/24"]
            }
          }
        },
        {
          "type": "azurerm_key_vault",
          "name": "invalid_keyvault",
          "values": {
            "name": "invalid-keyvault-001",
            "sku_name": "standard",
            "tags": {
              "Owner": "cloudteam"
            },
            "network_acls": {
              "default_action": "Allow"
            }
          }
        }
      ]
    }
  }
}



readme

# Azure Key Vault OPA Policy Validation

## Overview

This repository contains an Open Policy Agent (OPA) policy that validates Azure Key Vault resources in Terraform configurations to ensure compliance with organizational policies.

---

## Validation Rules

1. **SKU Check**: Key Vault must use `premium` SKU.
2. **Network ACLs**: Default network ACL action must be set to `Deny`.
3. **Tags**: Key Vault resources must include:
   - `Environment` tag
   - `Owner` tag

---

## Policy File: `keyvault_validation.rego`

This OPA policy ensures the above rules are followed.

### Usage

1. Install Open Policy Agent (OPA):  
   [https://www.openpolicyagent.org/docs/latest/install/](https://www.openpolicyagent.org/docs/latest/install/)

2. Prepare the Terraform plan as JSON:  
   ```bash
   terraform plan -out=tfplan.binary
   terraform show -json tfplan.binary > tfplan.json

evaluate:
opa eval --format pretty -i tfplan.json -d keyvault_validation.rego "data.terraform.azure.keyvault.deny"


example output

Invalid Key Vault configuration for invalid-keyvault-001. Ensure SKU is 'premium' and access policy allows Deny actions.
