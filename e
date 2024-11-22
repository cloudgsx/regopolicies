# Custom role definition
resource "azurerm_role_definition" "custom_crypto_role" {
  name        = local.crd.crd_role_1.name
  scope       = local.crd.crd_role_1.scope
  description = local.crd.crd_role_1.description

  permissions {
    actions         = local.crd.crd_role_1.actions
    not_actions     = local.crd.crd_role_1.not_actions
    data_actions    = local.crd.crd_role_1.data_actions
    not_data_actions = local.crd.crd_role_1.not_data_actions
  }

  assignable_scopes = local.crd.crd_role_1.assignable_scopes
}

# Role assignment for the custom role
resource "azurerm_role_assignment" "custom_crypto_role_assignment" {
  scope                = var.key_vault_id
  role_definition_name = azurerm_role_definition.custom_crypto_role.name
  principal_id         = azurerm_disk_encryption_set.des.identity.0.principal_id
}
