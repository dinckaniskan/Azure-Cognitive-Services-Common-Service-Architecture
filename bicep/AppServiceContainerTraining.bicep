@description('The name of the app service that you wish to create.')
param name string
param location string = resourceGroup().location

param vnetName string = '${name}vnet'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetName1 string = '${name}sn1'
param subnetName2 string = '${name}sn2'
param subnetAddressPrefix1 string = '10.0.0.0/24'
param subnetAddressPrefix2 string = '10.0.1.0/24'

// param appSettings array = []

var servicePlanName = '${name}plan'

var dockerRegistryUrl = 'mcr.microsoft.com'
var imageNameAndTag = 'azure-cognitive-services/custom-form/labeltool:latest-2.1'
var token = ''
var commandLine = './run.sh eula=accept'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  kind: 'linux'
  name: servicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'P1v3'
    family: 'PremiumV2'
  }
  dependsOn: []
}

resource appServiceApp 'Microsoft.Web/sites@2016-08-01' = {
  name: name
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${dockerRegistryUrl}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: 'bicepAppServiceContainer'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: token
        }
      ]
      linuxFxVersion: 'DOCKER|${dockerRegistryUrl}/${imageNameAndTag}'
      alwaysOn: true
      appCommandLine: commandLine
    }
    serverFarmId: appServicePlan.id
  }
}


resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = if (vnetName != '') {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName1
        properties: {
          addressPrefix: subnetAddressPrefix1
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: subnetName2
        properties: {
          addressPrefix: subnetAddressPrefix2
        }
      }
    ]
  }
}

resource webappVnet 'Microsoft.Web/sites/networkConfig@2020-06-01' = if (vnetName != '') {
  parent: appServiceApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: vnet.properties.subnets[0].id
    swiftSupported: true
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
output appServicePlanId string = appServicePlan.id
output vnetId string = vnet.id
