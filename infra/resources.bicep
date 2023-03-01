param environmentName string
param location string = resourceGroup().location
param email string


// Monitor application with Application Insights and Log Analytics as workspace
module monitoring 'monitor/monitoring.bicep' = {
  name: 'monitoring'
  params:{
    environmentName: environmentName
    location: location
  }
}

// Cosmos Mongo ToDo Database
module cosmos 'db/db.bicep' = {
  name: 'cosmos'
  params:{
    environmentName:environmentName
    location: location
  }
}

// Email Service function App and Email Service Logic App
module taskprocessor './web/taskprocessor.bicep' = {
  name: 'taskprocessor'
  params: {
    environmentName: environmentName
    location: location
    appplicationInsightsConnectionString: monitoring.outputs.applicationInsightsConnectionString
    cosmosConnectionString: cosmos.outputs.cosmosConnectionString
    email: email
  }
}

// Todo App
module todoapp 'web/app.bicep' = {
  name: 'todoapp'
  params:{
    environmentName: environmentName
    location: location
    appInsightsConnectionString: monitoring.outputs.applicationInsightsConnectionString
    appInsightsInstrumentationKey: monitoring.outputs.applicationInsightsInstrumentationKey
    cosmosConnectionString: cosmos.outputs.cosmosConnectionString
    functionAppUrl: taskprocessor.outputs.functionappurl
  }
}

output todoAppUrl string = todoapp.outputs.todoAppURL
