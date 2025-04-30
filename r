Why Your dynamic Block Is Correct:
hcl
Copiar
Editar
dynamic "delegation" {
  for_each = each.value["delegation"]

  content {
    name = delegation.value["name"]

    service_delegation {
      name    = delegation.value["service_name"]
      actions = delegation.value["actions"]
    }
  }
}
Breakdown:
each.value["delegation"] → loops over the list of delegation entries in the subnet config.

delegation.value["name"] → pulls the name from each entry.

delegation.value["service_name"] and ["actions"] → match your variable structure exactly.

This renders exactly what the AzureRM provider expects:

hcl
Copiar
Editar
delegation {
  name = "..."

  service_delegation {
    name    = "..."
    actions = [ ... ]
  }
}
