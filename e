data "external" "check_capacity" {
  program = ["bash", "-c", <<EOT
    result=$(az vm list-skus --location ${var.location} --query "[?name=='${var.vm_size}' && capabilities[?name=='vCPUs']]")
    restricted=$(echo "$result" | jq -r '.[].restrictions[] | select(.reasonCode=="NotAvailableForSubscription")')

    if [ -n "$restricted" ]; then
        echo '{"status": "restricted"}'
    else
        echo '{"status": "available"}'
    fi
  EOT]
}

resource "azurerm_virtual_machine" "example" {
  count = data.external.check_capacity.result["status"] == "available" ? 1 : 0

  name                  = "example-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.example.name
  vm_size               = var.vm_size
}
