param environmentName string
param location string = resourceGroup().location
param purpose string

var abbrs = loadJsonContent('../abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var tags = { 
  'azd-env-name': environmentName
  'purpose': purpose
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${abbrs.storageStorageAccounts}${resourceToken}'
  tags: tags
  location: location
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
  properties:{
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls:{
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

output name string = storage.name
output id string = storage.id
output connectionstring string = 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${listKeys(storage.id, storage.apiVersion).keys[1].value}'
