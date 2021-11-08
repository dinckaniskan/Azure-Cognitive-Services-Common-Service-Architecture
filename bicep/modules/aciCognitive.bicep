//Note that some cognitive containers are gated previews so must be enabled for your subscription- see https://aka.ms/cscontainers-faq

param location string = resourceGroup().location
param name string
param image string
// param appSettings array 
param port int = 5000

@allowed([
  'test'
  'nonprod'
  'prod'
])
param environmentType string
@secure()
param apiKey string
param billingEndpoint string


var cpu = (environmentType == 'prod') ? 4 : 2
var memoryInGB = (environmentType == 'prod') ? 8 : 2

resource aci 'Microsoft.ContainerInstance/containerGroups@2021-07-01' = {
  name: name
  location: location
  properties: {
    osType: 'Linux'
    containers: [
    {
      name: '${name}container1'
      properties: {
        image: image
        ports:[
          {
            port: port
            protocol: 'TCP'
          }
        ]
        environmentVariables: [
          {
            name: 'ApiKey'
            secureValue: apiKey
          }
          {
            name: 'Eula'
            value: 'accept'
          }
          {
            name: 'Billing'
            value: billingEndpoint
          }
        ]
        resources: {
          requests: {
            cpu: cpu
            memoryInGB: memoryInGB
          }
        }
      }
    }
    ]
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
  }
}
