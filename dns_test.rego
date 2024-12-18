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

    # Capture the deny output
    result := data.terraform.azure.dns.deny

    # Expected result as a list (array)
    expected := [
        {
            "name": "invalid-zone-name",
            "resource_group": "prod-dns-rg",
            "error": "Invalid DNS zone configuration"
        }
    ]

    # Check for equality
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

    # Capture the deny output
    result := data.terraform.azure.dns.deny

    # Ensure no violations
    result == []
}
