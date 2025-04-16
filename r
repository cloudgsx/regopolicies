resource "azurerm_image_builder_template" "example" {
  name                = "example-image-template"
  resource_group_name = var.resource_group
  location            = var.location

  source {
    type      = "PlatformImage"
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }

  customize {
    type  = "Shell"
    name  = "install-nginx"
    script_uri = "https://<storage-account>/scripts/install-nginx.sh"
  }

  distribute {
    type                   = "ManagedImage"
    image_id               = azurerm_image.example.id
    run_output_name        = "custom-ubuntu-image"
    location               = var.location
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aib.id]
  }
}
