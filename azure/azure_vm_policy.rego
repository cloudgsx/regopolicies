package azure_vm_policy

# Define input to be checked (assume Terraform JSON plan output)
vm = input.resource_changes[_]
vm_type := vm.type
vm_change := vm.change.after
disk := vm_change.storage_os_disk

# Disk size check: disk size must be between 50 and 150 GB
deny[msg] {
    vm_type == "azurerm_virtual_machine"
    not disk_size_valid
    msg := "Disk size must be between 50 and 150 GB."
}

disk_size_valid {
    disk.disk_size_gb >= 50
    disk.disk_size_gb <= 150
}

# Disk encryption check: disk must be encrypted
deny[msg] {
    vm_type == "azurerm_virtual_machine"
    not disk_encrypted
    msg := "OS disk must be encrypted."
}

disk_encrypted {
    disk.encryption_settings[0].enabled == true
}

# Security recommendations: enforce other general best practices
deny[msg] {
    vm_type == "azurerm_virtual_machine"
    not admin_username_compliant
    msg := "Admin username should not be 'admin', 'root', or 'administrator' for security reasons."
}

admin_username_compliant {
    not contains(vm_change.admin_username, "admin")
    not contains(vm_change.admin_username, "root")
    not contains(vm_change.admin_username, "administrator")
}

# Example of additional security check for VM instance size (optional)
deny[msg] {
    vm_type == "azurerm_virtual_machine"
    not instance_size_compliant
    msg := "VM instance size must be set to a size within organizational standards (e.g., 'Standard_DS1_v2')."
}

instance_size_compliant {
    # Define a list of approved instance sizes
    approved_sizes := {"Standard_DS1_v2", "Standard_DS2_v2", "Standard_DS3_v2"}
    approved_sizes[vm_change.vm_size]
}
