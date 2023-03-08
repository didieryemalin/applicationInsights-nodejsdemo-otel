param environmentName string
param location string = resourceGroup().location
param email string
param name string = 'office365'

var tags = { 'azd-env-name': environmentName }

resource office365connection 'Microsoft.Web/connections@2016-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    displayName: email
    statuses: [
      {
        status: 'Connected'
      }
    ]
    api: {
      name: name
      displayName: 'Office 365 Outlook'
      description: 'Microsoft Office 365 is a cloud-based service that is designed to help meet your organization\'s needs for robust security, reliability, and user productivity.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1618/1.0.1618.3179/${name}/icon.png'
      brandColor: '#0078D4'
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, name)
      type: 'Microsoft.Web/locations/managedApis'
    }
  }
}

output connectionApiId string = office365connection.properties.api.id
output id string = office365connection.id
