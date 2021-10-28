/*  LICENCE SEE: https://github.com/gitstua/bicepdemosbystu/blob/main/LICENSE
    This template can be run by following these steps:
    1. Install Azure CLI or connect to Cloud Shell 
    2. Verify connected to the correct account 
    3. Create a resource group:
      az group create -l australiaeast -n myResourceGroup 
    4. Create a deployment
      az deployment group create -g myResourceGroup -f .\filename.bicep 
    NOTE: You can specify parameters if you choose. If not specified params are defaulted based on resourcegroup name 
          if specified resources are named based on baseName e.g. 
          az deployment group create -g MyResourceGroup --template-file filename.bicep --parameters baseName=dev34
*/

param location string = resourceGroup().location
param storageAccountName string = 'svcstg${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'svcapp${uniqueString(resourceGroup().id)}'
param functionAppName string = 'svcfn${uniqueString(resourceGroup().id)}'
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    appServiceAppName: appServiceAppName
    location: location
    environmentType: environmentType
  }
}

module functionApp 'modules/functionApp.bicep' = {
  name: 'functionApp'
  params: {
    functionAppName: functionAppName
    location: location
    hostingPlanId: appService.outputs.appServicePlanId
    storageAccountName: storageAccountName
    environmentType: environmentType
  }
}

module storageDrop 'modules/storageAccount.bicep' = {
  name: 'storageDrop'
  params:{
    storageAccountName: storageAccountName
    location: location
    environmentType: environmentType

  }
}

output appServiceAppName string = appService.outputs.appServiceAppHostName
