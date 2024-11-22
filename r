resource "azurerm_role_definition" "custom_role" {
  name        = local.crd.crd_role_1.name
  scope       = local.crd.crd_role_1.scope
  description = local.crd.crd_role_1.description

  actions     = local.crd.crd_role_1.actions
  not_actions = local.crd.crd_role_1.not_actions

  data_actions     = local.crd.crd_role_1.data_actions
  not_data_actions = local.crd.crd_role_1.not_data_actions

  assignable_scopes = local.crd.crd_role_1.assignable_scopes
}

resource "azurerm_role_assignment" "rbac" {
  scope              = var.key_vault_id
  role_definition_id = azurerm_role_definition.custom_role.id
  principal_id       = azurerm_storage_account.sa.identity.0.principal_id
  principal_type     = "ServicePrincipal"
}
