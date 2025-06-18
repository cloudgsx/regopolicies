locals {
  max_retries         = 3
  retry_delay_seconds = 5

  raw_vm_skus = flatten([
    for attempt in range(local.max_retries) : [
      for sku in try(jsondecode(data.azapi_resource_action.skus[attempt].output).value, []) : (
        sku.resourceType == "virtualMachines" ? {
          name         = sku.name
          resourceType = sku.resourceType
          tier         = sku.tier
          size         = sku.size
          family       = sku.family
          locations    = [for info in sku.locationInfo : info.location]
          capabilities = try({ for capability in sku.capabilities : capability.name => capability.value }, {})
        } : null
      )
    ]
  ])

  all_vm_skus = [
    for sku in local.raw_vm_skus : sku if sku != null
  ]

  matching_vm_skus = [
    for sku in local.all_vm_skus : sku
    if sku.name == var.vm_size && contains(sku.locations, var.location)
  ]

  valid_vm_size = length(local.matching_vm_skus) > 0
}
