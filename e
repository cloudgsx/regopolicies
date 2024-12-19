result=$(az vm list-skus --location westus --query "[?name=='Standard_L8s_v3' && locationInfo[?zones!=\`[]\`]]" -o json)

if [ -z "$result" ]; then
  echo "No capacity available for Standard_L8s_v3 in westus. Halting deployment."
  exit 1
else
  echo "Capacity available for Standard_L8s_v3 in westus. Proceeding with deployment."
fi
