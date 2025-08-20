@description('Specifies a project name that is used for generating resource names.')
param environmentName string

@description('Specifies the location for all of the resources created by this template.')
param location string = resourceGroup().location

@description('Specifies the virtual machine administrator username.')
param adminUsername string

@description('Specifies the virtual machine administrator password.')
@secure()
param adminPassword string = newGuid()

@description('Size of the virtual machine')
param vmSize string = 'Standard_B2ats_v2'

param tags object = {
  'azd-env-name': environmentName
}

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2016-datacenter-gensecond'
  '2016-datacenter-server-core-g2'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2019-datacenter-core-with-containers-g2'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'


@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('Name of the load balancer.')
param lbName string

@description('SKU name for the load balancer.')
param lbSkuName string

@description('Name of the inbound public IP address for the load balancer.')
param lbinboundPublicIpAddressName string

@description('Name of the outbound public IP address for the load balancer.')
param lboutboundPublicIpAddressName string

@description('Name of the inbound frontend for the load balancer.')
param lbinboundFrontEndName string

@description('Name of the outbound frontend for the load balancer.')
param lboutbound string

@description('Name of the backend pool for the load balancer.')
param lbBackendPoolName string

@description('Name of the health probe for the load balancer.')
param lbProbeName string

@description('Name of the network security group.')
param nsgName string

@description('Name of the virtual network.')
param vNetName string

@description('Address prefix for the virtual network.')
param vNetAddressPrefix string

@description('Name of the subnet in the virtual network.')
param vNetSubnetName string

@description('Address prefix for the subnet in the virtual network.')
param vNetSubnetAddressPrefix string

@description('Name of the bastion host.')
param bastionName string

@description('Name of the bastion subnet.')
param bastionSubnetName string

@description('Address prefix for the bastion subnet.')
param vNetBastionSubnetAddressPrefix string

@description('Name of the bastion public IP address.')
param bastionPublicIPAddressName string


@description('Storage account type for the VM.')
param vmStorageAccountType string

@description('Whether to deploy Azure Bastion resources')
param deployBastion bool = true

var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}

var maaTenantName = 'GuestAttestation'
var maaEndpoint = substring('emptyString', 0, 0)
var ascReportingEndpoint = substring('emptystring', 0, 0)
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.WindowsAttestation'
var extensionVersion = '1.0'

resource project_vm_1_networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = [for i in range(0, 3): {
  name: '${environmentName}-vm${(i + 1)}-networkInterface'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vNetName_vNetSubnetName.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, lbBackendPoolName)
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
  dependsOn: [
    lb
  ]
}]

resource project_vm_1_InstallWebServer 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [for i in range(0, 3): {
  name: '${environmentName}-vm${(i + 1)}/InstallWebServer'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item \'C:\\inetpub\\wwwroot\\iisstart.htm\' && powershell.exe Add-Content -Path \'C:\\inetpub\\wwwroot\\iisstart.htm\' -Value $(\'Hello World from \' + $env:computername)'
    }
  }
  dependsOn: [
    project_vm_1
  ]
}]

resource project_vm_1 'Microsoft.Compute/virtualMachines@2021-11-01' = [for i in range(1, 3): {
  name: '${environmentName}-vm${i}'
  location: location
  tags: tags
  zones: [
    string(i)
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: vmStorageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${environmentName}-vm${i}-networkInterface')
        }
      ]
    }
    osProfile: {
      computerName: '${environmentName}-vm${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
  dependsOn: [
    project_vm_1_networkInterface
  ]
}]

resource projectName_vm_1_3_GuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = [for i in range(1, 3): if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  name: '${environmentName}-vm${i}/GuestAttestation'
  location: location
  tags: tags
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: ascReportingEndpoint
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
  dependsOn: [
    project_vm_1
  ]
}]



resource vNetName_bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = if (deployBastion) {
  parent: vNet
  name: bastionSubnetName
  properties: {
    addressPrefix: vNetBastionSubnetAddressPrefix
  }
  dependsOn: [
    vNetName_vNetSubnetName
  ]
}

resource vNetName_vNetSubnetName 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: vNet
  name: vNetSubnetName
  properties: {
    addressPrefix: vNetSubnetAddressPrefix
    
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-08-01' = if (deployBastion) {
  name: bastionName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionPublicIPAddress.id
          }
          subnet: {
            id: vNetName_bastionSubnet.id
          }
        }
      }
    ]
  }
}

resource bastionPublicIPAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' = if (deployBastion) {
  name: bastionPublicIPAddressName
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2021-08-01' = {
  name: lbName
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbinboundFrontEndName
        properties: {
          publicIPAddress: {
            id: lbinboundPublicIPAddress.id
          }
        }
      }
      {
        name: lboutbound
        properties: {
          publicIPAddress: {
            id: lboutboundPublicIPAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBackendPoolName
      }
    ]
    loadBalancingRules: [
      {
        name: 'myHTTPRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, lbinboundFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, lbBackendPoolName)
          }
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          protocol: 'Tcp'
          enableTcpReset: true
          loadDistribution: 'Default'
          disableOutboundSnat: true
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, lbProbeName)
          }
        }
      }
    ]
    outboundRules: [
      {
        name: 'outboundtraffic'
        properties: {
          frontendIPConfigurations: [{
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, lboutbound)
          }
        ]
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, lbBackendPoolName)
          }
          allocatedOutboundPorts: 64
          enableTcpReset: true
          idleTimeoutInMinutes: 4
          protocol: 'tcp'
        }
      }

    ]
    probes: [
      {
        name: lbProbeName
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    
  }
}

resource lbinboundPublicIPAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: lbinboundPublicIpAddressName
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}
resource lboutboundPublicIPAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: lboutboundPublicIpAddressName
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vNet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetAddressPrefix
      ]
    }
  }
}

output location string = location
output name string = lb.name
output resourceGroupName string = resourceGroup().name
output resourceId string = lb.id
