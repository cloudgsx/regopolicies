package terraform.azure.dns

# Deny rules for DNS configuration
deny_list := [output |  # Explicitly convert deny output to a list
    zone := input.planned_values.root_module.resources[_]
    zone.type == "azurerm_dns_zone"
    not valid_dns_zone(zone)

    output := {
        "name": zone.values.name,
        "resource_group": zone.values.resource_group_name,
        "error": "Invalid DNS zone configuration"
    }
]

# Function to validate DNS zone names and resource group organization
valid_dns_zone(zone) {
    re_match("^[a-z0-9-]+\\.(prod|staging|dev)\\.company\\.com$", zone.values.name)
    zone.values.resource_group_name == concat("-", [zone.values.tags.environment, "dns-rg"])
}



test

package terraform.azure.dns

# Test Case: Invalid DNS Zone Name
test_invalid_dns_zone_name {
    input := {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "azurerm_dns_zone",
                        "values": {
                            "name": "invalid-zone-name",  # Invalid name
                            "tags": { "environment": "prod" },
                            "resource_group_name": "prod-dns-rg"
                        }
                    }
                ]
            }
        }
    }

    # Capture deny_list output
    result := data.terraform.azure.dns.deny_list

    # Expected output
    expected := [
        {
            "name": "invalid-zone-name",
            "resource_group": "prod-dns-rg",
            "error": "Invalid DNS zone configuration"
        }
    ]

    # Compare arrays directly
    result == expected
}

# Test Case: Valid DNS Zone
test_valid_dns_zone {
    input := {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "azurerm_dns_zone",
                        "values": {
                            "name": "example.prod.company.com",  # Valid name
                            "tags": { "environment": "prod" },
                            "resource_group_name": "prod-dns-rg"
                        }
                    }
                ]
            }
        }
    }

    # Capture deny_list output
    result := data.terraform.azure.dns.deny_list

    # Expected empty array
    result == []
}
