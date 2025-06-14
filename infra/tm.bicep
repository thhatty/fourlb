targetScope = 'resourceGroup'

@description('The name of the environment for resource naming and tagging.')
param environmentName string

@description('Resource tags to apply to all resources.')
param tags object

@description('Relative DNS profile name for the traffic manager profile, resulting FQDN will be <uniqueDnsName>.trafficmanager.net, and it must be globally unique.')
param uniqueDnsName string

var webAppNamePrefix = 'TMLabWebApp-${take(uniqueString(resourceGroup().id,subscription().subscriptionId),3)}-'
var webAppLocations = [
  'Central US'
  'Germany West Central'
  'UK West'
]
var webAppLocationSuffix = [
  'CentralUS'
  'germanywestcentral'
  'ukwest'
]
var appSvcPlanNamePrefix = 'TMLabAppSvcPlan'
var repoURL = 'https://github.com/pdtit/TrafficMgr'
var branch = 'master'



resource appSvcPlan 'Microsoft.Web/serverfarms@2024-11-01' = [
  for (item, i) in webAppLocations: {
    name: '${appSvcPlanNamePrefix}-${webAppLocationSuffix[i]}'
    location: item
    properties: {
      elasticScaleEnabled: false
    }
    sku: {
      name: 'S1'
      tier: 'Free'
    }
    tags: tags
  }
]

resource webApp 'Microsoft.Web/sites@2022-03-01' = [
  for (item, i) in webAppLocations: {
    name: '${webAppNamePrefix}${webAppLocationSuffix[i]}'
    location: item
    properties: {
      serverFarmId: resourceId('Microsoft.Web/serverfarms', '${appSvcPlanNamePrefix}-${webAppLocationSuffix[i]}')
      httpsOnly: true
    }
    dependsOn: [
      appSvcPlan
    ]
    
    tags: tags
  }
]

resource webApp_SourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = [
  for i in range(0, length(webAppLocations)): {
    name: '${webAppNamePrefix}${webAppLocationSuffix[i]}/web'
    properties: {
      repoUrl: repoURL
      branch: branch
      isManualIntegration: true
    }
    dependsOn: [
      webApp
    ]
  }
]

resource ExampleTMProfile 'Microsoft.Network/trafficManagerProfiles@2018-04-01' = {
  name: 'TMProfile-${environmentName}'
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: uniqueDnsName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/default.aspx'
    }
  }
}

resource ExampleTMProfile_Endpoint 'Microsoft.Network/trafficmanagerprofiles/AzureEndpoints@2022-04-01' = [
  for i in range(0, length(webAppLocations)): {
    parent: ExampleTMProfile
    name: 'Endpoint${i}'
    properties: {
      targetResourceId: resourceId('Microsoft.Web/Sites/', '${webAppNamePrefix}${webAppLocationSuffix[i]}')
      endpointStatus: 'Enabled'
    }
    dependsOn: [
      webApp
    ]
  }
]
