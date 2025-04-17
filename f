data "azapi_resource_action" "vm_skus" {
  type        = "Microsoft.Compute/locations"
  resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Compute/locations/${var.location}"
  action      = "listVMSizes"

  response_export_values = ["value"]
}
