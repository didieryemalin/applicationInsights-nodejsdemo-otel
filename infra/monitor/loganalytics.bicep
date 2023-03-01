param environmentName string
param location string = resourceGroup().location

var abbrs = loadJsonContent('../abbreviations.json')
var tags = {'azd-env-name': environmentName}

resource loganalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${abbrs.operationalInsightsWorkspaces}${environmentName}'
  location: location
  tags: tags
  properties: any({
    retentionInDays: 30
    features:{
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

output logAnalyticsWorkspaceName string = loganalytics.name
output logAnalyticsWorkspaceId string = loganalytics.id
