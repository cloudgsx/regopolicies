rego

package terraform.azure.aks

# Deny rules for AKS configuration
deny[msg] {
    cluster := input.planned_values.root_module.resources[_]
    cluster.type == "azurerm_kubernetes_cluster"
    not valid_aks_cluster(cluster)
    msg := sprintf("Invalid AKS cluster configuration: %v", [cluster.values.name])
}

# Validate AKS cluster
valid_aks_cluster(cluster) {
    # Verify network policy
    cluster.values.network_profile.network_policy == "azure"

    # Verify RBAC is enabled
    cluster.values.role_based_access_control.enabled == true

    # Validate default node pool configuration
    valid_node_pool(cluster.values.default_node_pool)
}

# Validate node pool configuration
valid_node_pool(node_pool) {
    # Ensure node pool configuration is not null
    node_pool != null

    # Example condition: Node pool must have a minimum node count of 1
    node_pool.min_count >= 1
}


===
mock

{
  "planned_values": {
    "root_module": {
      "resources": [
        {
          "type": "azurerm_kubernetes_cluster",
          "values": {
            "name": "example-aks-cluster",
            "network_profile": {
              "network_policy": "azure"
            },
            "role_based_access_control": {
              "enabled": true
            },
            "default_node_pool": {
              "min_count": 2
            }
          }
        }
      ]
    }
  }
}
===

# Azure AKS Cluster Validation OPA Policy

This repository contains an OPA Rego policy to validate Terraform configurations for Azure AKS clusters. It enforces security and configuration best practices, ensuring compliance with organizational standards.

---

## **Policy Rules**

### **Validation Rules**
1. **Network Policy**: The AKS cluster must use the `azure` network policy.
2. **RBAC**: Role-based access control (RBAC) must be enabled.
3. **Node Pool Configuration**:
   - Default node pool must not be null.
   - Must define a `min_count` with a value of at least `1`.

### **Deny Conditions**
The policy will deny configurations that:
- Do not specify `azure` as the network policy.
- Have RBAC disabled.
- Have invalid or missing default node pool configurations.

---

## **Mock Testing**

### **Test Valid AKS Cluster Configuration**
You can use the following mock input to validate the policy:

refer to test1.json
