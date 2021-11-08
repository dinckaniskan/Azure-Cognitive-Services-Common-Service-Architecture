param location string = resourceGroup().location
param storageAccountName string

@allowed([
  'test'
  'dev'
  'prod'
])
param environmentType string

param containersList array

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

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

resource rStorageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = [for containerName in containersList: {
  name: '${storageAccount.name}/default/${containerName}'
  properties: {}
}]

// output storageAccount object = storageAccount
