param name string
param location string = resourceGroup().location

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output key string = appInsights.properties.InstrumentationKey
