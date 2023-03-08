targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Prefix for the resource group that will be created to hold all Azure resources')
param environmentName string

@minLength(1)
@description('The Azure location where your resources will be deployed.')
param location string

@description('email of the user')
param email string = ''


// Optional: Override the resource group name here to override the azd naming convention
param resourceGroupName string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    email: email
  }
}

output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_LOCATION string = location
output TODO_APP_URL string = resources.outputs.todoAppUrl
