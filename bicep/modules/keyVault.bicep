param name string
param location string = resourceGroup().location
param  principalId string
param tenantId string = subscription().tenantId

@description('Specifies all secrets {"secretName":"","secretValue":""} ')
param secretsObject array


resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: principalId
        permissions: {
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource secrets 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = [for secret in secretsObject: {
  name:  '${keyVault.name}/${secret.name}'
  properties: {
    value: secret.value
  }
}]

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
