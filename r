VM Size Validation in Terraform using AzAPI
📚 Purpose
This module ensures that only available Azure VM sizes in a specific region are used when deploying virtual machines.

Before creating any resources, Terraform Plan will:

Dynamically query available SKUs from Azure.

Check if the requested VM size is actually available in the target region.

Fail early with a custom error message if the size is not available.

✅ This guarantees no wasted apply runs and no late surprises during deployment.

⚡ Why This Approach?
Azure VM sizes are:

Region-dependent: not all sizes are available in all Azure regions.

Frequently changing: new SKUs are added, some SKUs are retired.

Instead of manually hardcoding lists of allowed sizes (which quickly go stale),
this approach dynamically queries live Azure SKUs at plan-time using the AzAPI provider.

This keeps the module:

Dynamic ✅

Always up-to-date ✅

Fully validated during plan ✅

🛠 Terraform 1.8+ Requirement
This module uses the error() function introduced in Terraform 1.8.0.

🔔 You must be running Terraform 1.8.0 or newer for the validation to happen at plan-time.

If you use an older Terraform version (1.7 or below),
the error() function does not exist and validation will not work properly.

✍️ Code Explanation
1. Query current subscription ID
hcl
Copiar
Editar
data "azurerm_client_config" "current" {}
Grabs the subscription ID dynamically, so no need to hardcode.

2. Fetch all Azure Compute SKUs available
hcl
Copiar
Editar
data "azapi_resource_action" "skus" {
  type        = "Microsoft.Compute@2021-07-01"
  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Compute"
  action      = "skus?api-version=2021-07-01&$filter=location%20eq%20'${var.location}'"
  method      = "GET"
  response_export_values = ["*"]
}
Calls Azure Management API to fetch all VM SKUs.

Filters by location.

Parses full SKU metadata.

3. Process and Filter SKUs
hcl
Copiar
Editar
locals {
  raw_vm_skus = [...]
  all_vm_skus = [...]
}
Parse raw JSON response

Capture important fields (name, family, vCPUs, memory, locations, etc.)

Make it easy to query in Terraform.

4. Check if Requested VM Size is Available
hcl
Copiar
Editar
locals {
  matching_vm_skus = [
    for sku in local.all_vm_skus : sku
    if sku.name == var.vm_size && contains(sku.locations, var.location)
  ]

  valid_vm_size = length(local.matching_vm_skus) > 0
}
✅ Ensures:

VM size name matches

VM size is available in the requested region

5. Fail Fast During Plan if Invalid
hcl
Copiar
Editar
locals {
  vm_size_validation = local.valid_vm_size ? "" : error("ERROR: VM size '${var.vm_size}' is not available in '${var.location}'!")
}
✅ If the requested VM size is not found →
Terraform Plan will immediately fail with a clean custom error message.

6. Optional Visible Output
hcl
Copiar
Editar
output "vm_size_validation_result" {
  value = local.valid_vm_size
}
✅ Shows true or false during plan, so it's obvious if validation succeeded.

✨ Example Behavior
Valid Size
bash
Copiar
Editar
Outputs:

vm_size_validation_result = true
✅ Plan proceeds.

Invalid Size
bash
Copiar
Editar
Error: ERROR: VM size 'Standard_NP10s' is not available in 'eastus'!
❌ Plan fails early.

📢 Key Benefits

Benefit	Description
Live validation	No stale hardcoded lists
Plan-time checking	Fail fast, not after apply
Clean error messages	Easy troubleshooting
Always up-to-date	As Azure SKUs evolve
