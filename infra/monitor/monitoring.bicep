param environmentName string
param location string = resourceGroup().location

module loganalytics 'loganalytics.bicep' = {
  name: 'loganalytics'
  params:{
    environmentName: environmentName
    location: location
  }
}

module applicationinsights 'applicationinsights.bicep' = {
  name: 'applicationinsights'
  params:{
    environmentName: environmentName
    location: location
    logAnalyticsWorkspaceId: loganalytics.outputs.logAnalyticsWorkspaceId
  }
}

output logAnalyticsWorkspaceName string = loganalytics.outputs.logAnalyticsWorkspaceName
output logAnalyticsWorkspaceId string = loganalytics.outputs.logAnalyticsWorkspaceId
output applicationInsightsName string = applicationinsights.outputs.applicationInsightsName
output applicationInsightsConnectionString string = applicationinsights.outputs.applicationInsightsConnectionString
output applicationInsightsInstrumentationKey string = applicationinsights.outputs.applicationInsightsInstrumentationKey

