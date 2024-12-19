Step 1: Prerequisites
Ensure both VMs are:
Deployed in Azure.
Running and reachable via their respective IPs.
Located in a virtual network (VNet).
Network Watcher is enabled for the region where the VMs are deployed (you mentioned it is already enabled).
Step 2: Configure Connection Monitor
You can configure the Connection Monitor using either the Azure Portal, Azure CLI, or PowerShell. Below is how to do it in the portal and CLI.

Using Azure Portal
Navigate to Network Watcher:

Go to the Azure Portal.
Search for Network Watcher in the search bar and select it.
Go to Connection Monitor:

Under Network Watcher, select Connection Monitor.
Create a Connection Monitor:

Click on + Add to create a new Connection Monitor.
Provide a name for the Connection Monitor.
Select the Subscription and Resource Group.
Configure the Source and Destination:

Source:
Choose Virtual Machine as the source type.
Select the VM you want to monitor as the source.
Specify the NIC or Private IP of the source VM.
Destination:
Choose Virtual Machine or provide the IP/FQDN of the destination VM.
If it's another VM, select it and specify its NIC or IP.
Select Protocols:

Under Protocol configuration, specify the protocols to monitor:
TCP: Specify the port (e.g., 80, 443).
ICMP: Use to check basic connectivity and latency.
HTTP: Specify the URL path if applicable.
Review and Create:

Review the settings and click Create to deploy the Connection Monitor.


Step 3: View Results
In the Azure Portal, navigate to Network Watcher > Connection Monitor.
Select your Connection Monitor.
Review the metrics:
Latency: Check average and maximum latency.
Packet Loss: View any packet drops.
Connectivity: Validate if the connection is up or down.
Additional Notes
Custom Ports: You can configure custom ports for TCP and HTTP checks based on your application requirements.
Thresholds: You can define thresholds for latency and packet loss to trigger alerts.
Continuous Monitoring: Connection Monitor runs periodically and collects data over time, providing trends.




Using Azure CLI
Run the following commands to configure Connection Monitor:

Create Connection Monitor:

bash
Copiar código
az network watcher connection-monitor create \
    --resource-group <ResourceGroupName> \
    --location <Region> \
    --name <ConnectionMonitorName> \
    --source-resource <SourceVMResourceID> \
    --dest-resource <DestinationVMResourceID> \
    --protocol tcp \
    --port 80
Add Additional Protocols: To add ICMP or HTTP monitoring:

bash
Copiar código
az network watcher connection-monitor test-configuration add \
    --connection-monitor <ConnectionMonitorName> \
    --resource-group <ResourceGroupName> \
    --name icmpCheck \
    --protocol icmp

az network watcher connection-monitor test-configuration add \
    --connection-monitor <ConnectionMonitorName> \
    --resource-group <ResourceGroupName> \
    --name httpCheck \
    --protocol http \
    --url-path "/"
Verify Configuration:

bash
Copiar código
az network watcher connection-monitor show \
    --resource-group <ResourceGroupName> \
    --name <ConnectionMonitorName>





tf code

provider "azurerm" {
  features {}
}

resource "azurerm_connection_monitor" "example" {
  name                = "example-connection-monitor"
  location            = "eastus"
  resource_group_name = "example-resource-group"
  network_watcher_name = "existing-network-watcher" # Replace with your existing Network Watcher's name

  # Source VM
  source {
    virtual_machine_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Compute/virtualMachines/<source-vm-name>"
  }

  # Destination VM
  destination {
    virtual_machine_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Compute/virtualMachines/<destination-vm-name>"
  }

  # Protocols to monitor
  test_configuration {
    name     = "tcp-check"
    protocol = "Tcp"
    port     = 80 # Change port as needed
  }

  test_configuration {
    name     = "icmp-check"
    protocol = "Icmp"
  }

  test_configuration {
    name        = "http-check"
    protocol    = "Http"
    url_path    = "/"
    port        = 80
    method      = "Get"
  }
}
