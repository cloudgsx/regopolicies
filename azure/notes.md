Network Security and Isolation
Public IP Address Restriction: Ensure VMs are not assigned a public IP unless explicitly needed.
Check: Deny if public_ip_address_id is set.
Network Security Group (NSG) Association: Ensure each VM network interface is associated with a Network Security Group for traffic filtering.
Check: Deny if network_security_group_id is not set in network_interface.
Allowed Ports: Restrict the VM's NSG to allow only specific ports, such as 22 (SSH) and 3389 (RDP), based on organizational standards.
Check: Deny if NSG rules allow open access (e.g., 0.0.0.0/0) on disallowed ports.
2. Resource Tagging
Mandatory Tags: Require specific tags for cost tracking, environment, owner, etc.
Check: Deny if required tags (e.g., Owner, Environment, CostCenter) are missing or incorrect.
3. OS and Security Updates
OS Version: Ensure the VM OS version is compliant with organizational security standards (e.g., disallow unsupported or outdated OS versions).
Check: Deny if os_profile.windows_config.provision_vm_agent is not set, as this may indicate an unmanageable VM.
Automatic Updates: Enforce that automatic OS updates are enabled, especially for Windows VMs.
Check: Deny if enable_automatic_updates is set to false for Windows configurations.
4. Disk and Storage Compliance
Managed Disks: Require all disks to be managed disks for better reliability and performance.
Check: Deny if VM is using unmanaged disks (e.g., managed_disk_id is missing).
Premium Storage Requirement: Enforce premium storage for critical VMs to meet performance requirements.
Check: Deny if storage_account_type is not set to Premium_LRS for critical workloads.
5. Encryption and Key Management
Key Vault Integration: Ensure disk encryption keys are stored in Azure Key Vault for added security.
Check: Deny if encryption_settings does not specify a key_vault_key_id.
Double Encryption: Require double encryption (e.g., platform-managed encryption along with customer-managed keys) for sensitive VMs.
Check: Deny if encryption_settings.disk_encryption_key.key_url is missing or not set to the key in Key Vault.
6. Instance Type and Size Constraints
Instance SKU Restrictions: Allow only specific VM SKUs or limit maximum instance types for cost management.
Check: Deny if the vm_size is outside allowed types (e.g., no Standard_A* for production).
Instance Count and Scaling Limits: Ensure that autoscaling or instance scaling is within specific limits for resource control.
Check: Deny if VM count exceeds a specified maximum (useful for environments with budget constraints).
7. Backup and Disaster Recovery
Backup Configuration: Ensure VMs are configured for backups using Azure Backup.
Check: Deny if the VM is missing a backup policy or not associated with Azure Recovery Services Vault.
Availability Zones or Sets: Require VMs to be in availability zones or sets for high availability.
Check: Deny if availability_set_id or zone is not set for VMs requiring high availability.
8. Identity and Access Management
Managed Identity Requirement: Ensure that a managed identity (system-assigned or user-assigned) is enabled on the VM.
Check: Deny if identity is not set, to enforce managed identities over embedding credentials.
Role Assignment Check: Ensure VM identity is not granted excessive Azure roles that could lead to security risks.
Check: Deny if the assigned role has permissions exceeding required levels (e.g., Contributor on sensitive resources).
9. Compliance Checks for Specific Workloads
Security Baseline Compliance: Verify that VMs meet specific security benchmarks (e.g., CIS benchmarks).
Check: Deny if settings like admin_username, ssh_key, and boot_diagnostics do not meet security standards.
