pip install azure-mgmt-compute azure-mgmt-subscription azure-identity

import json
from azure.identity import DefaultAzureCredential
from azure.mgmt.subscription import SubscriptionClient
from azure.mgmt.compute import ComputeManagementClient

# Azure credential and setup
credential = DefaultAzureCredential()

def get_subscriptions(credential):
    """Fetch all available Azure subscriptions."""
    subscription_client = SubscriptionClient(credential)
    subscriptions = subscription_client.subscriptions.list()
    return [sub.subscription_id for sub in subscriptions]

def check_vm_skus(subscription_id, region, vm_size, credential):
    """Check if the specified VM size is available in the given region."""
    compute_client = ComputeManagementClient(credential, subscription_id)
    sku_list = compute_client.resource_skus.list()
    for sku in sku_list:
        if sku.name == vm_size and any(loc.location == region for loc in sku.locations):
            zones = sku.location_info[0].zones if sku.location_info else None
            return {"available": True, "zones": zones}
    return {"available": False, "zones": None}

def main():
    # Define parameters
    vm_size = "Standard_L8s_v3"
    regions = ["eastus", "westus", "centralus"]  # Add more regions if needed

    # Initialize result dictionary
    report = {}

    # Fetch subscriptions
    print("Fetching subscriptions...")
    subscription_ids = get_subscriptions(credential)

    # Iterate over subscriptions
    for sub_id in subscription_ids:
        print(f"Checking subscription: {sub_id}")
        report[sub_id] = {}

        # Check VM SKU availability in each region
        for region in regions:
            print(f"  Checking region: {region}")
            result = check_vm_skus(sub_id, region, vm_size, credential)
            report[sub_id][region] = result

    # Save the report to a JSON file
    with open("vm_sku_availability_report.json", "w") as f:
        json.dump(report, f, indent=4)

    print("Report generated: vm_sku_availability_report.json")

if __name__ == "__main__":
    main()
