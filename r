azurerm_key_vault, azurerm_private_endpoint, and azurerm_private_dns_zone_virtual_network_link, along with attributes like purge_protection_enabled, public_network_access_enabled, and private_service_connection, remains fully supported in v4.25.0.​

Notable Additions in v4.25.0 (Optional Enhancements)
While no immediate changes are necessary, v4.25.0 introduces several enhancements that you might find beneficial:​

Python 3.13 Support: Added for azurerm_linux_function_app, azurerm_linux_web_app, and their respective slots.​
Microsoft Learn
+2
GitHub
+2
Microsoft Learn
+2

New SKUs and Properties:

azurerm_log_analytics_workspace now supports the LACluster SKU.

azurerm_managed_disk allows disk expansion without downtime across all storage_account_type options.​
Microsoft Learn
+2
GitHub
+2
Microsoft Learn
+2

Enhanced Resource Capabilities:

azurerm_orchestrated_virtual_machine_scale_set includes new properties: upgrade_mode and rolling_upgrade_policy.

azurerm_nginx_deployment attributes like frontend_public, frontend_private, and network_interface are no longer marked as ForceNew, allowing for more flexible updates.
