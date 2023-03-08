param environmentName string
param location string = resourceGroup().location
param email string

module office365connection './logic/office365connection.bicep' = {
  name: 'office365connection'
  params: {
    environmentName: environmentName
    location: location
    email: email
  }
}

module logicapp './logic/logic.bicep' = {
  name: 'logicapp'
  params: {
    environmentName: environmentName
    location: location
    connectionId: office365connection.outputs.id
    connectionApiId: office365connection.outputs.connectionApiId
  }
}

output logicAppUrl string = logicapp.outputs.httpTriggerUrl
