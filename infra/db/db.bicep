param environmentName string
param location string = resourceGroup().location

param collections array = [
  {
    name: 'tasks'
    id: 'tasks'
    shardKey: 'Hash'
    indexKey: '_id'
  }
  {
    name: 'email_notifications'
    id: 'email_notifications'
    shardKey: 'Hash'
    indexKey: '_id'
  }
]

param cosmosDatabaseName string = 'todo-db'

module cosmos 'cosmos-db.bicep' = {
  name: 'cosmos-mongo'
  params: {
    environmentName: environmentName
    location: location
    collections: collections
    cosmosDatabaseName: cosmosDatabaseName
  }
}

output cosmosConnectionString string = cosmos.outputs.cosmosConnectionString
