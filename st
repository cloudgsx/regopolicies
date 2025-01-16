data "external" "check_capacity" {
  program = ["bash", "-c", <<EOT
    result=$(az vm list-skus --location ${var.location} --query "[?name=='${var.vm_size}' && capabilities[?name=='vCPUs']]")
    restricted=$(echo "$result" | jq -r '.[].restrictions[] | select(.reasonCode=="NotAvailableForSubscription")')

    if [ -n "$restricted" ]; then
        echo '{"status": "restricted"}'
        exit 1 # Exit with an error code to stop Terraform
    else
        echo '{"status": "available"}'
    fi
  EOT]
}
