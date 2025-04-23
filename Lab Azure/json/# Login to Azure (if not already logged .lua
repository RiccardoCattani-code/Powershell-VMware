# Login to Azure (if not already logged in)
az login

# Set the subscription to use
az account set --subscription 6b678711-e207-4bbe-bad3-cb45178f095c

# Create the virtual machine
az vm create \
--resource-group "[sandbox resource group name]" \
--location westus \
--name SampleVM \
--image Ubuntu2204 \
--admin-username azureuser \
--generate-ssh-keys \
--verbose