param environmentName string
param location string = resourceGroup().location
param purpose string

param kind string
param reserved bool = false
param sku object

var abbrs = loadJsonContent('../../abbreviations.json')
var tags = { 'azd-env-name': environmentName }

resource appserviceplan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${abbrs.webServerFarms}${environmentName}-${purpose}'
  location: location
  tags: tags
  sku: sku
  kind: kind
  properties: {
    reserved: reserved
  }
}

output appServicePlanId string = appserviceplan.id
