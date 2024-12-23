package terraform.azure.dns

# Deny rules for DNS configuration
deny_list := [output |  
    resource := input.resource_changes[_]             # Iterate over resource_changes
    resource.change.after != null                     # Ensure there's an "after" field
    resource.type == "azurerm_private_dns_zone"       # Check the resource type
    not valid_dns_zone(resource.change.after)         # Validate DNS zone
    output := {
        "name": resource.change.after.name,
        "resource_group": resource.change.after.resource_group_name,
        "error": "Invalid DNS zone configuration"
    }
]

# Function to validate DNS zone names and resource group organization
valid_dns_zone(zone) {
    re_match("^privatelink\\.[a-zA-Z0-9-]+\\.vaultcore\\.azure\\.net$", zone.name)   # Validate name matches pattern
    startswith(zone.resource_group_name, "rg-")                                    # Resource group starts with "rg-"
    contains(zone.resource_group_name, "-dns")                                     # Resource group contains "-dns"
}
