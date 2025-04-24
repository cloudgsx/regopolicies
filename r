no obvious breaking changes in the main.tf you posted that would conflict with this version.

Specifically:
azurerm_key_vault and azurerm_private_endpoint resources are still valid.

Attributes like purge_protection_enabled, public_network_access_enabled, and private_service_connection are still supported in 4.25.0.

The use of provider = azurerm.kv and azurerm.pnp (with aliases) is valid Terraform syntax.
