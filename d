from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.security import SecurityCenter

# Replace with your subscription ID
SUBSCRIPTION_ID = "sub-corp3-d-70656-ops-1"

# Initialize Azure clients
credential = DefaultAzureCredential()
resource_client = ResourceManagementClient(credential, SUBSCRIPTION_ID)
compute_client = ComputeManagementClient(credential, SUBSCRIPTION_ID)
network_client = NetworkManagementClient(credential, SUBSCRIPTION_ID)
security_client = SecurityCenter(credential, SUBSCRIPTION_ID)

def check_disk_encryption(vm):
    """Check if OS and data disks are encrypted with customer-managed keys."""
    compliance = True
    for disk in [vm.storage_profile.os_disk] + vm.storage_profile.data_disks:
        if not disk.managed_disk.encryption_settings or not disk.managed_disk.encryption_settings.enabled:
            compliance = False
            print(f"VM {vm.name}: Disk {disk.name} is not encrypted with customer-managed keys.")
    return compliance

def check_defender_enabled(vm):
    """Check if Microsoft Defender is enabled on the VM."""
    settings = security_client.advanced_threat_protection.get(vm.id)
    if not settings.is_enabled:
        print(f"VM {vm.name}: Microsoft Defender is NOT enabled.")
        return False
    return True

def check_open_ports(vm):
    """Check for open management ports."""
    for nic in vm.network_profile.network_interfaces:
        nic_name = nic.id.split('/')[-1]
        nic_details = network_client.network_interfaces.get(vm.resource_group_name, nic_name)
        for rule in nic_details.ip_configurations:
            if rule.public_ip_address:  # Public IP detected
                print(f"VM {vm.name}: Open public port detected.")
                return False
    return True

def check_nsg_rules(resource_group_name, nic_name):
    """Check if NSG rules are compliant for the NIC."""
    compliance = True
    nic = network_client.network_interfaces.get(resource_group_name, nic_name)
    if nic.network_security_group:
        nsg_name = nic.network_security_group.id.split('/')[-1]
        nsg = network_client.network_security_groups.get(resource_group_name, nsg_name)
        for rule in nsg.security_rules:
            if rule.access == "Allow" and rule.direction == "Inbound":
                print(f"NSG {nsg_name} has an open inbound rule: {rule.name}")
                compliance = False
    else:
        print(f"NIC {nic_name} has no NSG associated.")
        compliance = False
    return compliance

def check_jit(vm):
    """Check if JIT is enabled for the VM."""
    jit_config = security_client.jit_network_access_policies.list(vm.resource_group_name)
    for policy in jit_config:
        if policy.id == vm.id:
            return True
    print(f"VM {vm.name}: JIT is NOT enabled.")
    return False

def main():
    # List all resource groups
    for rg in resource_client.resource_groups.list():
        print(f"\nResource Group: {rg.name}")
        
        # List VMs in the resource group
        for vm in compute_client.virtual_machines.list(rg.name):
            print(f"\nChecking VM: {vm.name}")

            compliance = {
                "Disk Encryption": check_disk_encryption(vm),
                "Microsoft Defender": check_defender_enabled(vm),
                "Open Ports": check_open_ports(vm),
                "NSG Rules": all([check_nsg_rules(rg.name, nic.id.split('/')[-1]) for nic in vm.network_profile.network_interfaces]),
                "JIT Access": check_jit(vm),
            }
            
            print(f"\nCompliance Report for VM {vm.name}:")
            for policy, is_compliant in compliance.items():
                status = "Compliant" if is_compliant else "Non-Compliant"
                print(f"  {policy}: {status}")

if __name__ == "__main__":
    main()
