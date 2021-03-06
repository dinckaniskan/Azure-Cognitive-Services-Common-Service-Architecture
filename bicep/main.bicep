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

param baseName string = uniqueString(resourceGroup().id)

param storageAccountName string = 'svcstg${baseName}'
param appServiceAppName string = 'svcapp${baseName}'
param functionAppName string = 'svcfn${baseName}'
param keyVaultAppName string = 'svckv${baseName}'
param formRecognizerName string = 'formrecog2${baseName}'
param appInsightsName string = 'appinsight${baseName}'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

module appInsights 'modules/appInsights.bicep' = {
  name: appInsightsName
  params:{
    name: appInsightsName
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    appServiceAppName: appServiceAppName
    environmentType: environmentType
    appSettings:  [
      {
        name: 'formrecognizer_key'
        value: formRecognizer.outputs.cognitivekey1
      }
      {
        name: 'formrecognizer_endpoint'
        value: formRecognizer.outputs.endpoint
      }
      {
        name: 'formrecognizer_model_id'
        value: 'payslip'
      }
      {
        name: 'deseaisq_STORAGE'
        value: 'TO BE ADDED'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appInsights.outputs.key
      }
    ]
  }
}

module functionApp 'modules/functionApp.bicep' = {
  name: 'functionApp'
  params: {
    functionAppName: functionAppName
    hostingPlanId: appService.outputs.appServicePlanId
    storageAccountName: storageAccountName
    environmentType: environmentType
    appSettings: [
      {
        name: 'formrecognizer_model_id'
        value: 'payslip'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appInsights.outputs.key
      }
    ]
  }
}

module storageDrop 'modules/storageAccount.bicep' = {
  name: 'storageDrop'
  params:{
    storageAccountName: storageAccountName
    environmentType: environmentType
    containersList: [
      'drop'
      'example1'
      'example2'
    ]
  }
}

module keyVault 'modules/keyVault.bicep' = {
  name: keyVaultAppName
  params:{
    name: keyVaultAppName
    principalId: functionApp.outputs.systemMsiPrincipalId
  }
}

module formRecognizer 'modules/formRecognizer.bicep' = {
  name: formRecognizerName
  params:{
    environmentType: environmentType
    name: formRecognizerName
  }
}

output appServiceAppName string = appService.outputs.appServiceAppHostName
output key string = formRecognizer.outputs.cognitivekey1
