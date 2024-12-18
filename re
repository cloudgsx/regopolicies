resource "azurerm_linux_virtual_machine" "vm" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_L8s_v3"

  admin_username = "adminuser"
  network_interface_ids = [azurerm_network_interface.example.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  lifecycle {
    # Prevent automatic retries
    create_before_destroy = false
    ignore_changes        = [tags]
  }

  # Use explicit error handling
  provisioner "local-exec" {
    when    = create
    command = <<EOT
      echo "Checking for ZonalAllocationFailed error..."
      if [ "$(grep -i 'ZonalAllocationFailed' terraform.log)" ]; then
        echo "ZonalAllocationFailed detected. Deployment halted. Investigate manually."
        exit 1
      fi
    EOT
  }
}
