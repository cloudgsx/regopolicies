Azure VM Pre-Deployment Check
This Terraform module includes a pre-deployment validation script to ensure the requested Azure VM size is available in the specified region and for your subscription before proceeding with deployment. It checks:

Subscription Restrictions: Ensures the VM size is not restricted (NotAvailableForSubscription) in the target region.
Capacity Availability: Verifies that there is sufficient capacity in at least one availability zone in the region.
How It Works
Pre-Check Logic:

Uses Azure CLI (az vm list-skus) to query VM availability.
Checks for:
Subscription Restrictions: If the VM size is restricted, the deployment is halted.
Zone Capacity: If no zones are available, the deployment is halted.
Deployment Flow:

If the VM size is available and there is capacity, Terraform proceeds to create the VM.
If any pre-check fails, Terraform stops with a clear error message.
Error Messages
Subscription Restriction:

arduino
Copiar código
VM size <VM_SIZE> is not available for subscription in <REGION>. Halting deployment.
Capacity Issue:

php
Copiar código
No capacity available for <VM_SIZE> in <REGION>. Halting deployment.
