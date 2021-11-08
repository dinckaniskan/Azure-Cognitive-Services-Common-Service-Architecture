param location string = resourceGroup().location
param name string
@allowed([
  'Academic' 
  'Bing.Autosuggest' 
  'Bing.Search'
  'Bing.Speech' 
  'Bing.SpellCheck' 
  'ComputerVision' 
  'ContentModerator'
  'CustomSpeech' 
  'Emotion' 
  'Face' 
  'FormRecognizer'
  'LUIS' 
  'Recommendations'
  'SpeakerRecognition' 
  'Speech' 
  'SpeechTranslation' 
  'TextAnalytics'
  'TextTranslation' 
  'WebLM'
  ])
param kind string



@allowed([
  'test'
  'dev'
  'prod'
])
param environmentType string

var skuName = (environmentType == 'prod') ? 'S0' : 'F0'

resource cogService 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: name
  kind: kind
  location: location
  sku: {
    name: skuName
  }
  properties:{
    restore: true
  }

}

output cognitivekeys object = listKeys(cogService.id, '2016-02-01-preview')
output cognitivekey1 string = listKeys(cogService.id, '2016-02-01-preview').key1
output cognitivekey2 string = listKeys(cogService.id, '2016-02-01-preview').key2
output endpoint string = reference(cogService.id, '2016-02-01-preview').endpoint
