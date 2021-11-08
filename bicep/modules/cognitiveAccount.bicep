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

var restoreSoftDeleted = false

@allowed([
  'test'
  'dev'
  'prod'
])
param environmentType string

//TODO: handle if non prod we use F1 (note: only one free per subscription)
var skuName = (environmentType == 'prod') ? 'S0' : 'S0'

resource cogService 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: name
  kind: kind
  location: location
  sku: {
    name: skuName
  }
  properties:{
    restore: restoreSoftDeleted
  }

}

output cognitivekeys object = listKeys(cogService.id, '2016-02-01-preview')
output cognitivekey1 string = listKeys(cogService.id, '2016-02-01-preview').key1
output cognitivekey2 string = listKeys(cogService.id, '2016-02-01-preview').key2
output endpoint string = reference(cogService.id, '2016-02-01-preview').endpoint
