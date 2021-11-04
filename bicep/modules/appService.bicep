param location string = resourceGroup().location
param appServiceAppName string

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

param appSettings array

var appServicePlanName = '${appServiceAppName}plan'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2_v3' : 'F1'
var appServicePlanTierName = (environmentType == 'prod') ? 'PremiumV3' : 'Free'

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    tier: appServicePlanTierName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: appSettings
    }
  }
  
}
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
output appServicePlanId string = appServicePlan.id
