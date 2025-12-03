// ============================================================================
// Azure App Configuration
// ============================================================================

targetScope = 'resourceGroup'

param location string
param name string
param tags object
param logAnalyticsWorkspaceId string

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-09-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

// Default feature flags for rings
resource ringFlags 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-09-01-preview' = [for ring in ['ring0', 'ring1', 'ring2', 'ga']: {
  parent: appConfig
  name: '.appconfig.featureflag~2F${ring}'
  properties: {
    value: '{"id":"${ring}","description":"${ring} deployment ring","enabled":false}'
    contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
  }
}]

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'appconfig-diagnostics'
  scope: appConfig
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'HttpRequest'
        enabled: true
      }
      {
        category: 'Audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output id string = appConfig.id
output name string = appConfig.name
output endpoint string = appConfig.properties.endpoint