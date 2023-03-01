param environmentName string
param location string = resourceGroup().location
param purpose string

// Reference Properties
param appServicePlanId string

// Runtime Properties
@allowed([
  'dotnet', 'dotnetcore', 'dotnet-isolated', 'node', 'python', 'java', 'powershell', 'custom'
])
param runtimeName string
param runtimeVersion string
param runtimeNameAndVersion string = '${runtimeName}|${runtimeVersion}'

// App settings
param appSettings array = []
param enableOryxBuild bool = contains(kind, 'linux')


// Microsoft.Web/sites Properties
param kind string = 'app,linux'

// Microsoft.Web/sites/config
param allowedOrigins array = []
param alwaysOn bool = false
param appCommandLine string = ''
param clientAffinityEnabled bool = false
param linuxFxVersion string = runtimeNameAndVersion
param minimumElasticInstanceCount int = -1
param numberOfWorkers int = -1
param use32BitWorkerProcess bool = false

var abbrs = loadJsonContent('../../abbreviations.json')
var tags = { 'azd-env-name': environmentName, 'azd-service-name': 'web' }

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: '${abbrs.webSitesAppService}${environmentName}-${purpose}'
  location: location
  tags: tags
  kind: kind
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: 'FtpsOnly'
      appCommandLine: appCommandLine
      numberOfWorkers: numberOfWorkers != -1 ? numberOfWorkers : null
      minimumElasticInstanceCount: minimumElasticInstanceCount != -1 ? minimumElasticInstanceCount : null
      use32BitWorkerProcess: use32BitWorkerProcess
      cors: {
        allowedOrigins: union([ 'https://portal.azure.com', 'https://ms.portal.azure.com' ], allowedOrigins)
      }
      appSettings: union(appSettings, [
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: string(true)
        }
        {
          name: 'ENABLE_ORYX_BUILD'
          value: string(enableOryxBuild)
        }
      ])
    }
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: true
  }
}

output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
