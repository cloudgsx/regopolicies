package terraform.azure.dns

# Deny rules for DNS configuration
deny_list := [output |  # Explicitly convert deny output to a list
    zone := input.planned_values.root_module.resources[_]
    zone.type == "azurerm_private_dns_zone"  # Match the type from the JSON mock data
    not valid_dns_zone(zone)
    output := {
        "name": zone.values.name,
        "resource_group": zone.values.resource_group_name,
        "error": "Invalid DNS zone configuration"
    }
]

# Function to validate DNS zone names and resource group organization
valid_dns_zone(zone) {
    # Ensure the name matches a specific format
    re_match("^privatelink\\.[a-zA-Z0-9-]+\\.vaultcore\\.azure\\.net$", zone.values.name)
    # Ensure the resource group name matches expected format
    startswith(zone.values.resource_group_name, "rg-")
    contains(zone.values.resource_group_name, "-dns")
}


Key Updates:
Type Check:

Adjusted to work with the type "azurerm_private_dns_zone" from the JSON mock data.
Validation for Zone Name:

Updated to validate DNS zone names like privatelink.vaultcore.azure.net.
Validation for Resource Group Name:

Added rules to validate that the resource group name starts with rg- and contains -dns.
How It Works:
This Rego policy iterates over all resources in the input.planned_values.root_module.resources field.
It checks the type and validates both the DNS zone name and the resource group name.
If any validation fails, it adds an entry to the deny_list with the name, resource group, and an error message.
