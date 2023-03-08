param environmentName string
param location string = resourceGroup().location
param logAnalyticsWorkspaceId string

var abbrs = loadJsonContent('../abbreviations.json')
var tags = {'azd-env-name': environmentName}

resource applicationinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${abbrs.insightsComponents}${environmentName}'
  location: location
  kind: 'web'
  tags: tags
  properties:{
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

output applicationInsightsName string = applicationinsights.name
output applicationInsightsConnectionString string = applicationinsights.properties.ConnectionString
output applicationInsightsInstrumentationKey string = applicationinsights.properties.InstrumentationKey
