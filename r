resource "random_id" "retry_trigger" {
  count       = local.max_retries
  byte_length = 4
}

data "azapi_resource_action" "skus" {
  count = local.max_retries

  type        = "Microsoft.Compute@2021-07-01"
  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Compute"
  
  # Add a random "dummy" query param to force refresh
  action      = "skus?api-version=2021-07-01&$filter=location%20eq%20'${var.location}'&rand=${random_id.retry_trigger[count.index].hex}"
  
  method      = "GET"
  response_export_values = ["*"]
}


triggers = {
  retry_id = random_id.retry_trigger[count.index + 1 < local.max_retries ? count.index + 1 : 0].hex
}
