param environmentName string
param location string = resourceGroup().location

param collections array = []
param cosmosDatabaseName string

var abbrs = loadJsonContent('../abbreviations.json')

module cosmos 'cosmos-mongo-account.bicep' = {
  name: 'cosmos-mongo-account'
  params: {
    environmentName: environmentName
    location: location
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2022-08-15' = {
  name: '${abbrs.documentDBDatabaseAccounts}${environmentName}/${cosmosDatabaseName}'
  properties: {
    resource: { id: cosmosDatabaseName }
  }

  resource list 'collections' = [for collection in collections:{
    name: collection.name
    properties: {
      resource: {
        id: collection.id
        shardKey:{ _id: collection.shardKey }
        indexes: [ { key: { keys: [ collection.indexKey ] } } ]
      }
    }
  }]

  dependsOn:[
    cosmos
  ]
}

output cosmosConnectionString string = cosmos.outputs.cosmosConnectionString
output cosmosDatabaseName string = database.name
output cosmosEndpoint string = cosmos.outputs.cosmosEndpoint
output cosmosResourceId string = cosmos.outputs.cosmosResourceId
