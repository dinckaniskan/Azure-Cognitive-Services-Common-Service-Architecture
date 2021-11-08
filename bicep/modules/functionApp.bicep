//Thanks: https://chriskingdon.com/2021/07/02/bicep-tips-tricks-1/
param location string = resourceGroup().location
param functionAppName string
param storageAccountName string = 'svcfnstg${uniqueString(resourceGroup().id)}'
param appSettings array 

@allowed([
  'test'
  'nonprod'
  'prod'
])
param environmentType string
param hostingPlanId string

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'


var standardAppSettings = [
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
  }
  {
    'name': 'FUNCTIONS_EXTENSION_VERSION'
    'value': '~3'
  }
  {
    'name': 'FUNCTIONS_WORKER_RUNTIME'
    'value': 'dotnet'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
  }
]

var appSettingsCombined = concat(appSettings, standardAppSettings)

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity:{
    type:'SystemAssigned'    
  }
properties: {
    httpsOnly: true
    serverFarmId: hostingPlanId
    clientAffinityEnabled: true
    siteConfig: {
      appSettings: appSettingsCombined
    }
  }
}

output systemMsiPrincipalId string = functionApp.identity.principalId
