package terraform.azure.dns

# Test Case: Invalid DNS Zone Name
test_invalid_dns_zone_name {
    # Mock input data simulating an invalid DNS zone configuration
    input := {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "azurerm_dns_zone",
                        "values": {
                            "name": "invalid-zone-name",  # Invalid name format
                            "tags": { "environment": "prod" },
                            "resource_group_name": "prod-dns-rg"
                        }
                    }
                ]
            }
        }
    }
    
    # Call the deny rule and verify it produces the expected output
    result := data.terraform.azure.dns.deny
    expected := [{
        "name": "invalid-zone-name",
        "resource_group": "prod-dns-rg",
        "error": "Invalid DNS zone configuration"
    }]

    result == expected
}

# Test Case: Valid DNS Zone
test_valid_dns_zone {
    # Mock input data simulating a valid DNS zone configuration
    input := {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "azurerm_dns_zone",
                        "values": {
                            "name": "example.prod.company.com",
                            "tags": { "environment": "prod" },
                            "resource_group_name": "prod-dns-rg"
                        }
                    }
                ]
            }
        }
    }

    # Call the deny rule and ensure no results are returned
    result := data.terraform.azure.dns.deny
    result == []
}
