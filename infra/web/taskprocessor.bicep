param environmentName string
param location string = resourceGroup().location
param email string
param appplicationInsightsConnectionString string
param cosmosConnectionString string


module storage '../misc/storage.bicep' = {
  name: 'storageaccount'
  params: {
    environmentName: environmentName
    location: location
    purpose: 'taskprocessor'
  }
}

module emailservice 'emailservice.bicep' = {
  name: 'emailservice'
  params: {
    environmentName: environmentName
    location: location
    email: email
  }
}

module appserviceplan './host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  params: {
    environmentName: environmentName
    location: location
    purpose: 'func'
    kind: 'functionapp'
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
    }
  }
}

module functionapp './host/functionapp.bicep' = {
  name: 'functionapp'
  params: {
    environmentName: environmentName
    location: location
    appServicePlanId: appserviceplan.outputs.appServicePlanId
    appplicationInsightsConnectionString: appplicationInsightsConnectionString
    cosmosConnectionString: cosmosConnectionString
    emailServiceUri: emailservice.outputs.logicAppUrl
    purpose: 'taskprocessor'
    storageConnectionString: storage.outputs.connectionstring
  }
}

output functionappname string = functionapp.name
output functionappurl string = functionapp.outputs.url
