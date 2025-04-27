#-- Create a virtual network with a specified address space and subnet  prefixes
#-- https://learn.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_create

az network vnet create --name vnet 
--resource-group "learn-00b2ecf6-c189-4501-99da-26578f748219" 
--address-prefixes 10.0.0.0/16 
--subnet-name publicsubnet 
--subnet-prefixes 10.0.0.0/24