param location string = resourceGroup().location
param vmName string
param adminUsername string
param adminPassword string
param vmSize string = 'Standard_B1s'

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
    name: '${vmName}-nsg'
    location: location
    properties: {
        securityRules: [
            {
                name: 'AllowRDP'
                properties: {
                    priority: 1000
                    direction: 'Inbound'
                    access: 'Allow'
                    protocol: 'Tcp'
                    sourcePortRange: '*'
                    destinationPortRange: '3389'
                    sourceAddressPrefix: '*'
                    destinationAddressPrefix: '*'
                }
            }
        ]
    }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
    name: '${vmName}-pip'
    location: location
    properties: {
        publicIPAllocationMethod: 'Dynamic'
    }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
    name: '${vmName}-vnet'
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.0.0.0/16'
            ]
        }
        subnets: [
            {
                name: 'default'
                properties: {
                    addressPrefix: '10.0.0.0/24'
                    networkSecurityGroup: {
                        id: nsg.id
                    }
                }
            }
        ]
    }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
    name: '${vmName}-nic'
    location: location
    properties: {
        ipConfigurations: [
            {
                name: 'ipconfig1'
                properties: {
                    subnet: {
                        id: vnet.properties.subnets[0].id
                    }
                    privateIPAllocationMethod: 'Dynamic'
                    publicIPAddress: {
                        id: publicIp.id
                    }
                }
            }
        ]
    }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
    name: vmName
    location: location
    properties: {
        hardwareProfile: {
            vmSize: vmSize
        }
        osProfile: {
            computerName: vmName
            adminUsername: adminUsername
            adminPassword: adminPassword
        }
        storageProfile: {
            imageReference: {
                publisher: 'MicrosoftWindowsServer'
                offer: 'WindowsServer'
                sku: '2019-Datacenter'
                version: 'latest'
            }
            osDisk: {
                createOption: 'FromImage'
            }
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: nic.id
                }
            ]
        }
    }
}