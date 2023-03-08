param environmentName string
param location string = resourceGroup().location
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param cosmosConnectionString string
param functionAppUrl string

param appSettings array = [
  {
    name: 'APPINSIGHTS_CONN_STRING'
    value: appInsightsConnectionString
  }
  {
    name: 'DATABASE_NAME'
    value: 'todo-db'
  }
  {
    name: 'DATABASE_URL'
    value: cosmosConnectionString
  }
  {
    name: 'TASK_PROCESSOR_URL'
    value: '${functionAppUrl}/api/ProcessTasks?'
  }
]

module appserviceplan 'host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  params: {
    environmentName: environmentName
    location: location
    kind: 'linux'
    reserved: true
    sku: {
      name: 'B1'
      tier: 'Basic'
    }
    purpose: 'todoapp'
  }
}

module appservice 'host/appservice.bicep' = {
  name: 'appservice'
  params: {
    environmentName: environmentName
    location: location
    appServicePlanId: appserviceplan.outputs.appServicePlanId
    runtimeName: 'node'
    runtimeVersion: '16-lts'
    purpose: 'todoapp'
    appSettings: appSettings
  }
}

output todoAppURL string = appservice.outputs.uri
