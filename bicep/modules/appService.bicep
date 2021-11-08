param location string = resourceGroup().location
param name string

@allowed([
  'test'
  'dev'
  'prod'
])
param environmentType string

param appSettings array

param vnetName string = ''
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetName string = '${name}sn'
param subnetAddressPrefix string = '10.0.0.0/24'

var appServicePlanName = '${name}plan'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2_v3' : (environmentType == 'test') ? 'P1v3' : 'F1'
var appServicePlanTierName = (environmentType == 'prod') ? 'PremiumV3' : (environmentType == 'test') ? 'Standard' : 'Free'


resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    tier: appServicePlanTierName
   capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: appSettings
    }
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
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
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

