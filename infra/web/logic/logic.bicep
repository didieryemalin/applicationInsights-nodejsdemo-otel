param environmentName string
param location string = resourceGroup().location
param connectionId string
param connectionApiId string

var abbrs = loadJsonContent('../../abbreviations.json')
var tags = { 'azd-env-name': environmentName }
var workflowSchema = 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'


resource logicapp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: '${abbrs.logicWorkflows}${environmentName}'
  location: location
  tags: tags
  properties:{
    definition: {
      '$schema': workflowSchema
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {
          }
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              properties: {
                completedTasks: {
                  type: 'string'
                }
                currentTasks: {
                  type: 'string'
                }
                emailAddress: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      actions: {
        Response: {
          runAfter: {
            'Send_an_email_(V2)': [
              'Succeeded'
            ]
          }
          type: 'Response'
          kind: 'Http'
          inputs: {
            body: {
              success: true
            }
            statusCode: 200
          }
        }
        'Send_an_email_(V2)': {
          runAfter: {
          }
          type: 'ApiConnection'
          inputs: {
            body: {
              Body: '<p><strong>Current Tasks:</strong><br>\n<br>\n@{triggerBody()?[\'currentTasks\']}<br>\n<br>\n<strong>Completed Tasks:</strong><br>\n<br>\n@{triggerBody()?[\'completedTasks\']}<br>\n</p>'
              Importance: 'Normal'
              Subject: 'Your tasks'
              To: '@triggerBody()?[\'emailAddress\']'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v2/Mail'
          }
        }
      }
    }
    parameters: {
      '$connections': {
        value: {
          office365: {
            connectionId: connectionId
            connectionName: 'office365'
            id: connectionApiId
          }
        }
      }
    }
  }
}

output httpTriggerUrl string = listCallbackURL('${logicapp.id}/triggers/manual', '2019-05-01').value
