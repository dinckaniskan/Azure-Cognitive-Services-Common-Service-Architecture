// Cognitive services formrecognizer 2.1 ACI https://docs.microsoft.com/en-us/azure/applied-ai-services/form-recognizer/deploy-label-tool#deploy-with-azure-container-instances-aci

param baseName string = uniqueString(resourceGroup().id)
param location string = resourceGroup().location

param vnetName string = 'vet${baseName}'
param networkProfileName string = 'netcfg${baseName}'
param interfaceConfigName string = 'ifcfg${baseName}'
param interfaceIpConfig string = 'ipcfg${baseName}'


param image string = 'mcr.microsoft.com/azure-cognitive-services/custom-form/labeltool:latest-2.1'
param containerGroupName string = 'ipcfg${baseName}'
param containerName string = 'ipcfg${baseName}'

param cpuCores int = 2
param memoryInGb int = 8
param port int = 3000
param commandLine string = './run.sh eula=accept'

var vnetAddressPrefix =  '10.0.0.0/16'
var subnet1AddressPrefix =  '10.0.0.0/24'
var subnet2AddressPrefix =  '10.0.1.0/24'


resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'aci-subnet-1'
        properties: {
          addressPrefix: subnet1AddressPrefix
          delegations: [
            {
              name: 'DelegationService'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: subnet2AddressPrefix
        }
      }
    ]
    }
}

resource networkProfile 'Microsoft.Network/networkProfiles@2020-11-01' = {
  name: networkProfileName
  location: location
  properties: {
    containerNetworkInterfaceConfigurations: [
      {
        name: interfaceConfigName
        properties: {
          ipConfigurations: [
            {
              name: interfaceIpConfig
              properties: {
                subnet: {
                  id: vnet.properties.subnets[0].id
                }
              }
            }
          ]
        }
      }
    ]
  }
}


resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          command: [
            commandLine
          ]
          image: image
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
    networkProfile: {
      id: networkProfile.id
    }
    restartPolicy: 'Always'
  }
}

output containerIPv4Address string = containerGroup.properties.ipAddress.ip
