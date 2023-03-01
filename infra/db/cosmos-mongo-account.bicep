param environmentName string
param location string = resourceGroup().location

var abbrs = loadJsonContent('../abbreviations.json')
var tags = { 'azd-env-name': environmentName }

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: '${abbrs.documentDBDatabaseAccounts}${environmentName}'
  kind: 'MongoDB'
  location: location
  tags: tags
  properties: {
    consistencyPolicy: { defaultConsistencyLevel:'Session' }
    locations:[
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    apiProperties: { serverVersion: '4.0' }
    capabilities: [ { name: 'EnableServerless' } ]
  }
}

output cosmosEndpoint string = cosmos.properties.documentEndpoint
output cosmosConnectionString string = cosmos.listConnectionStrings().connectionStrings[0].connectionString
output cosmosResourceId string = cosmos.id
