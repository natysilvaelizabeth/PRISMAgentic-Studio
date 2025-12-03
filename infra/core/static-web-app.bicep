// ============================================================================
// Azure Static Web App
// ============================================================================

targetScope = 'resourceGroup'

param location string
param name string
param tags object
param sku string = 'Standard'

resource staticWebApp 'Microsoft.Web/staticSites@2023-12-01' = {
  name: name
  location: location
  tags: union(tags, {
    'azd-service-name': 'web'
  })
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    buildProperties: {
      skipGithubActionWorkflowGeneration: true
    }
  }
}

output id string = staticWebApp.id
output name string = staticWebApp.name
output defaultHostname string = staticWebApp.properties.defaultHostname
output apiKey string = listSecrets(staticWebApp.id, '2023-12-01').properties.apiKey