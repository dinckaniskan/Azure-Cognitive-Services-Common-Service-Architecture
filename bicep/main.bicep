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
param formRecognizerName string = 'formrecog3${baseName}'
param aciFormRecognizerName string = 'formrecog3${baseName}aci'
param computerVisionName string = 'computervision2${baseName}'
param aciComputerVisionName string = 'computervision2${baseName}aci'

param appInsightsName string = 'appinsight${baseName}'

@allowed([
  'test'
  'dev'
  'prod'
])
param environmentType string
param deployAci bool = false

module appInsights 'modules/appInsights.bicep' = {
  name: appInsightsName
  params:{
    name: appInsightsName
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    name: appServiceAppName
    vnetName: 'vnet${baseName}'
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
    secretsObject: [
      {
        name: 'formrecognizer_key'
        value: formRecognizer.outputs.cognitivekey1      
      }
    ]
  }
}

module formRecognizer 'modules/cognitiveAccount.bicep' = {
  name: formRecognizerName
  params:{
    skuName: 'S0'
    name: formRecognizerName
    kind: 'FormRecognizer'
  }
}

module aciform 'modules/aciCognitive.bicep' =  if (deployAci) {
  name: aciFormRecognizerName
  params: {
    apiKey: formRecognizer.outputs.cognitivekey1
    billingEndpoint: formRecognizer.outputs.endpoint
    name: aciFormRecognizerName
    environmentType: environmentType
    image: 'mcr.microsoft.com/azure-cognitive-services/vision/read:3.2'
  }
}

module computerVision 'modules/cognitiveAccount.bicep' = {
  name: computerVisionName
  params:{
    skuName: 'S1'
    name: computerVisionName
    kind: 'ComputerVision'
  }
}

module aci 'modules/aciCognitive.bicep' = if (deployAci) {
  name: aciComputerVisionName
  params:{
    name: aciComputerVisionName
    apiKey: computerVision.outputs.cognitivekey1
    billingEndpoint: computerVision.outputs.endpoint
    environmentType: environmentType
    image:'mcr.microsoft.com/azure-cognitive-services/vision/read:3.2'
  }
}

output appServiceAppName string = appService.outputs.appServiceAppHostName
output key string = formRecognizer.outputs.cognitivekey1
