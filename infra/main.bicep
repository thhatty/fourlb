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


var tags = {
  'azd-env-name': environmentName
  
}

// Organize resources in a resource group
resource rg1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-lb1-${environmentName}'
  location: location
  tags: tags
}

//invoke the resources.bicep file
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
  }
}

//now create the second resource group
resource rg2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-lb2-${environmentName}'
  location: location
  tags: tags
}
//invoke the resources.bicep file for the second resource group
module resources2 './lb2.bicep' = {
  scope: rg2
  name: 'resourcesDeployment2'
  params: {
    location: location
    tags: tags
    environmentName: environmentName
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize

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
    uniqueDnsName: 'tm-${uniqueString(rg3.id, subscription().subscriptionId)}'
  }
}
