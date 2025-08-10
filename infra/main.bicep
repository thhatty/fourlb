targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Specifies the virtual machine administrator username.')
param adminUsername string 

@description('Specifies the virtual machine administrator password.')
@secure()
param adminPassword string = newGuid()

@description('Size of the virtual machine')
param vmSize string = 'Standard_B2ats_v2'

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

@description('The current user id. Will be supplied by azd')
param currentUserId string = newGuid()

var tags = {
  'azd-env-name': environmentName
}

var resourceUniquifier = toLower(uniqueString(subscription().id, environmentName, location))

// Demo Network Configuration Table
// Each demo's VNet, subnet, and IP configuration are defined here for clarity and reuse
var demoNetworkConfig = {
  lb1: {
    vNetName: '${environmentName}-vnet1'
    vNetAddressPrefix: '10.1.0.0/16'
    vNetSubnetName: 'BackendSubnet'
    vNetSubnetAddressPrefix: '10.1.0.0/24'
    bastionName: '${environmentName}-bastion'
    bastionSubnetName: 'AzureBastionSubnet'
    vNetBastionSubnetAddressPrefix: '10.1.1.0/24'
    nsgName: '${environmentName}-nsg1'
    lbinboundPublicIpAddressName: '${environmentName}-lbinboundPublicIP'
    lboutboundPublicIpAddressName: '${environmentName}-lboutboundPublicIP'
    bastionPublicIPAddressName: '${environmentName}-bastionPublicIP'
  }
  agw: {
    vNetName: '${environmentName}-vnet2'
    vNetAddressPrefix: '10.2.0.0/16'
    vNetSubnetName: 'BackendSubnet'
    vNetSubnetAddressPrefix: '10.2.0.0/24'
    vNetBackendSubnetAddressPrefix: '10.2.1.0/24'
    nsgName: '${environmentName}-nsg2'
    publicIpName: '${environmentName}-gwPublicIP'
    nicName: 'net-int'
    ipConfigName: 'ipconfig'
    appGatewayName: 'myAppGateway'
  }
  tm: {
    // Traffic Manager uses web apps in multiple locations, not a VNet
    webAppLocations: [
      'Central US'
      'Germany West Central'
      'UK West'
    ]
    webAppLocationSuffix: [
      'centralus'
      'centralindia'
      'ukwest'
    ]
  }
  fd: {
    // Front Door demo uses App Service and Front Door, not a VNet
    appName: '${environmentName}-fd-app-${resourceUniquifier}'
    appServicePlanName: '${environmentName}-appServicePlan'
    frontDoorProfileName: take('${environmentName}-frontDoorProfile-${resourceUniquifier}', 60)
    frontDoorEndpointName: take('${environmentName}-fd-endpoint-${resourceUniquifier}', 60)
  }
}

//Common Resource Group for common resources
resource rgCommon 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-common-${environmentName}'
  location: location
  tags: tags
}

module vault 'br/public:avm/res/key-vault/vault:0.11.1' = {
  scope: rgCommon
  name: 'vaultDeployment'
  params: {
    name: take('kv-${environmentName}-${resourceUniquifier}',24)
    enablePurgeProtection: false
    location: rgCommon.location
    tags: tags
    secrets: [
      {
        name: 'adminPassword'
        value: adminPassword
      }

    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Secrets Officer'
        principalId: currentUserId
      }
    ]
  }
}

resource rg1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-lb1-${environmentName}'
  location: location
  tags: tags
}

module resources './lb1.bicep' = {
  scope: rg1
  name: 'resourcesDeployment'
  params: {
    location: location
    tags: tags
    environmentName: environmentName
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
    OSVersion: OSVersion
    lbName: '${environmentName}-lb'
    lbSkuName: 'Standard'
    lbinboundPublicIpAddressName: demoNetworkConfig.lb1.lbinboundPublicIpAddressName
    lboutboundPublicIpAddressName: demoNetworkConfig.lb1.lboutboundPublicIpAddressName
    lbinboundFrontEndName: 'LoadBalancerFrontEnd'
    lboutbound: 'LoadBalancerOutboundIP'
    lbBackendPoolName: 'LoadBalancerBackEndPool'
    lbProbeName: 'loadBalancerHealthProbe'
    nsgName: demoNetworkConfig.lb1.nsgName
    vNetName: demoNetworkConfig.lb1.vNetName
    vNetAddressPrefix: demoNetworkConfig.lb1.vNetAddressPrefix
    vNetSubnetName: demoNetworkConfig.lb1.vNetSubnetName
    vNetSubnetAddressPrefix: demoNetworkConfig.lb1.vNetSubnetAddressPrefix
    bastionName: demoNetworkConfig.lb1.bastionName
    bastionSubnetName: demoNetworkConfig.lb1.bastionSubnetName
    vNetBastionSubnetAddressPrefix: demoNetworkConfig.lb1.vNetBastionSubnetAddressPrefix
    bastionPublicIPAddressName: demoNetworkConfig.lb1.bastionPublicIPAddressName
    vmStorageAccountType: 'Premium_LRS'
  }
}

resource rg2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-agw-${environmentName}'
  location: location
  tags: tags
}


module resources2 './agw.bicep' = {
  scope: rg2
  name: 'resourcesDeployment2'
  params: {
    location: location
    tags: tags
    environmentName: environmentName
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
    vmName: 'gwvm'
    vNetName: demoNetworkConfig.agw.vNetName
    nicName: demoNetworkConfig.agw.nicName
    ipConfigName: demoNetworkConfig.agw.ipConfigName
    publicIpName: demoNetworkConfig.agw.publicIpName
    nsgName: demoNetworkConfig.agw.nsgName
    appGatewayName: demoNetworkConfig.agw.appGatewayName
    vNetAddressPrefix: demoNetworkConfig.agw.vNetAddressPrefix
    vNetSubnetAddressPrefix: demoNetworkConfig.agw.vNetSubnetAddressPrefix
    vNetBackendSubnetAddressPrefix: demoNetworkConfig.agw.vNetBackendSubnetAddressPrefix
  }
}

resource rg3 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-tm-${environmentName}'
  location: location
  tags: tags
}

module trafficManager './tm.bicep' = {
  scope: rg3
  name: 'trafficManagerDeployment'
  params: {
    environmentName: environmentName
    tags: tags
    uniqueDnsName: 'tm-${resourceUniquifier}'
    webAppLocations: demoNetworkConfig.tm.webAppLocations
    webAppLocationSuffix: demoNetworkConfig.tm.webAppLocationSuffix
    appSvcPlanNamePrefix: '${environmentName}-appsvcplan'
    webAppNamePrefix: '${environmentName}-webapp-${resourceUniquifier}'
  }
}

resource rg4 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-fd-${environmentName}'
  location: location
  tags: tags
}

module frontDoor './fd.bicep' = {
  scope: rg4
  name: 'frontDoorDeployment'
  params: {
    environmentName: environmentName
    tags: tags
    location: location
    appName: demoNetworkConfig.fd.appName
    appServicePlanName: demoNetworkConfig.fd.appServicePlanName
    appServicePlanSkuName: 'S1'
    appServicePlanCapacity: 1
    frontDoorProfileName: demoNetworkConfig.fd.frontDoorProfileName
    frontDoorSkuName: 'Standard_AzureFrontDoor'
    frontDoorEndpointName: demoNetworkConfig.fd.frontDoorEndpointName
  }
}

output AZURE_KEY_VAULT_NAME string = vault.outputs.name
