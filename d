package terraform.azure.dns

import rego.v1

# Deny rules for DNS configuration
deny_list := [output |  
    resource := input.resource_changes[_]
    print("Evaluating resource:", resource)             # Print the resource being evaluated
    resource.change.after != null
    resource.type == "azurerm_private_dns_zone"
    not valid_dns_zone(resource.change.after)
    output := {
        "name": resource.change.after.name,
        "resource_group": resource.change.after.resource_group_name,
        "error": "Invalid DNS zone configuration"
    }
]

# Function to validate DNS zone names and resource group organization
valid_dns_zone(zone) = true if {
    print("Validating DNS Zone Name:", zone.name)        # Print the DNS name being validated
    print("Validating Resource Group Name:", zone.resource_group_name)
    is_valid_name(zone.name)
    is_valid_resource_group(zone.resource_group_name)
}

# Validate DNS zone name matches the required pattern
is_valid_name(name) = true if {
    print("Checking DNS Zone Name Regex Match:", name)   # Print the DNS name before regex match
    regex.match("^privatelink\\.[a-zA-Z0-9-]+\\.vaultcore\\.azure\\.net$", name)
}

# Validate resource group name follows the required format
is_valid_resource_group(resource_group_name) = true if {
    print("Checking Resource Group Name Prefix and Suffix:", resource_group_name) # Print the resource group name
    startswith(resource_group_name, "rg-")
    contains(resource_group_name, "-dns")
}
