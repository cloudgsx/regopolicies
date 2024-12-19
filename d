result=$(az vm list-skus --location westus --query "[?name=='Standard_L8s_v3' && locationInfo[?length(zones) > \`0\`]]" -o json)

if [ -z "$result" ]; then
  echo "No capacity available for Standard_L8s_v3 in westus. Halting deployment."
  exit 1
else
  echo "Capacity available for Standard_L8s_v3 in westus. Proceeding with deployment."
fi


  resource "null_resource" "check_vm_allocation" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Checking Azure capacity for VM size: ${var.vm_size} in region: ${var.location}..."
      result=$(az vm list-skus --location ${var.location} --query "[?name=='${var.vm_size}' && locationInfo[?length(zones) > \`0\`]]" -o json)
      if [ -z "$result" ]; then
        echo "No capacity available for ${var.vm_size} in ${var.location}. Halting deployment."
        exit 1
      else
        echo "Capacity available for ${var.vm_size} in ${var.location}. Proceeding with deployment."
      fi
    EOT
  }
}
