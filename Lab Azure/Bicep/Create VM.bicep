param vmName string = 'testvm'
param location string = 'eastus'
param adminUsername string = 'azureuser'
param sshPublicKey string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMVJv32uUfKCFIL1WxctRjLEtQ6TxzUvNjBCsXoIt9Na+lWTd1cEBCuXcZ3M/XmpDzjCFSYmzgMBRZy4yFERzi2/Qw2ohWyMBQh1gU266suVJGHyNnx1DVufbWpG1mZy3g4P4k2sK2wwW2byF6P6T9YvjZhOXyt50YMtlxgCba1dCEfjy5JmyVQzcQxJP5566Nwab9uKsgI5tjOfnDYvehvUweImfQM7JeazlXcHDkgPaZ21CCiIsSwzziWPTLRhzEX36txLPXtKNDvIzP6+dcnGwqF3yjjVfP/n2gfbOPhhhIlrGrG4SHMx/jqGi7AS5m3GIkk5P2JZhJEiu27Qdq2lH256tU78rPV/6u+p8S2VrxDLZcAUNALGBfIJy/Nd4Q1YcTRe0seKfSdJh4Cn1UQl+OLFLNb8rqM3k5Tybkbs7VOEzG9eQWXV9sRDADoA+hqPPo9Q77R9ZtoQLfup8iQI0Ickb1gox2TFacM9dFKPtn5EyMbL1GEhhgMKxBEDE= generated-by-azure'

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${vmName}_OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: '/subscriptions/ebe95d37-01bc-4988-ad84-7887e5cfa866/resourceGroups/testvm_group/providers/Microsoft.Network/networkInterfaces/testvm546_z1'
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
