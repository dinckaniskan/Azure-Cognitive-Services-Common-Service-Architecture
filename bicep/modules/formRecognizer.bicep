param location string
param name string

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var skuName = (environmentType == 'prod') ? 'S0' : 'F0'

resource cogService 'Microsoft.CognitiveServices/accounts@2017-04-18' = {
  name: name
  kind: 'FormRecognizer'
  location: location
  sku: {
    name: skuName
  }
}

output cognitivekeys object = listKeys(cogService.id, '2016-02-01-preview')
output cognitivekey1 string = listKeys(cogService.id, '2016-02-01-preview').key1
output cognitivekey2 string = listKeys(cogService.id, '2016-02-01-preview').key2
output endpoint string = reference(cogService.id, '2016-02-01-preview').endpoint
