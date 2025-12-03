// ============================================================================
// Core Infrastructure Module
// ============================================================================

targetScope = 'resourceGroup'

// Parameters
param location string
param environmentName string
param tags object
param resourceToken string
param keyVaultName string
param logAnalyticsWorkspaceId string
param appInsightsConnectionString string
param appInsightsInstrumentationKey string
param enablePrivateEndpoints bool
param enableZoneRedundancy bool
param openAiModelDeployments array
param cosmosDbThroughput int

var abbrs = loadJsonContent('../abbreviations.json')

// ============================================================================
// Storage Account (Shared)
// ============================================================================

module storage './storage.bicep' = {
  name: 'storage-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.storageAccounts}${resourceToken}'
    tags: tags
    enablePrivateEndpoints: enablePrivateEndpoints
  }
}

// ============================================================================
// Azure OpenAI
// ============================================================================

module openAi './openai.bicep' = {
  name: 'openai-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.cognitiveServicesOpenAi}${resourceToken}'
    tags: tags
    modelDeployments: openAiModelDeployments
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// ============================================================================
// Azure AI Search
// ============================================================================

module aiSearch './ai-search.bicep' = {
  name: 'ai-search-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.searchServices}${resourceToken}'
    tags: tags
    sku: 'basic'
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// ============================================================================
// Cosmos DB
// ============================================================================

module cosmosDb './cosmos-db.bicep' = {
  name: 'cosmos-db-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.cosmosDBDatabaseAccounts}${resourceToken}'
    tags: tags
    throughput: cosmosDbThroughput
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    enablePrivateEndpoints: enablePrivateEndpoints
    enableZoneRedundancy: enableZoneRedundancy
  }
}

// ============================================================================
// Redis Cache
// ============================================================================

module redis './redis.bicep' = {
  name: 'redis-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.cachesRedis}${resourceToken}'
    tags: tags
    sku: enableZoneRedundancy ? 'Premium' : 'Standard'
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    enablePrivateEndpoints: enablePrivateEndpoints
    enableZoneRedundancy: enableZoneRedundancy
  }
}

// ============================================================================
// SignalR Service
// ============================================================================

module signalR './signalr.bicep' = {
  name: 'signalr-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.signalRServices}${resourceToken}'
    tags: tags
    sku: 'Standard_S1'
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// ============================================================================
// App Configuration
// ============================================================================

module appConfig './app-configuration.bicep' = {
  name: 'app-config-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.appConfigurationStores}${resourceToken}'
    tags: tags
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// ============================================================================
// Container Apps Environment
// ============================================================================

module containerAppsEnv './container-apps-env.bicep' = {
  name: 'container-apps-env-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.appContainerEnvironments}${resourceToken}'
    tags: tags
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    appInsightsConnectionString: appInsightsConnectionString
  }
}

// ============================================================================
// Decision Engine (Container App)
// ============================================================================

module decisionEngine './container-apps.bicep' = {
  name: 'decision-engine-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.appContainerApps}decision-${resourceToken}'
    tags: tags
    containerAppsEnvironmentId: containerAppsEnv.outputs.environmentId
    containerImage: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest' // Placeholder
    containerPort: 8000
    envVars: [
      {
        name: 'COSMOS_ENDPOINT'
        value: cosmosDb.outputs.endpoint
      }
      {
        name: 'REDIS_HOST'
        value: redis.outputs.hostName
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsightsConnectionString
      }
      {
        name: 'APP_CONFIG_ENDPOINT'
        value: appConfig.outputs.endpoint
      }
    ]
    minReplicas: 1
    maxReplicas: 10
  }
}

// ============================================================================
// Azure Functions
// ============================================================================

module functions './functions.bicep' = {
  name: 'functions-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.functionApps}${resourceToken}'
    tags: tags
    storageAccountName: storage.outputs.name
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
    appInsightsConnectionString: appInsightsConnectionString
    cosmosDbConnectionString: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=cosmos-connection-string)'
    redisConnectionString: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=redis-connection-string)'
    keyVaultName: keyVaultName
  }
}

// ============================================================================
// Static Web App
// ============================================================================

module staticWebApp './static-web-app.bicep' = {
  name: 'static-web-app-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.staticWebApps}${resourceToken}'
    tags: tags
    sku: 'Standard'
  }
}

// ============================================================================
// API Management
// ============================================================================

module apim './api-management.bicep' = {
  name: 'apim-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.apiManagementService}${resourceToken}'
    tags: tags
    sku: 'Developer'
    publisherEmail: 'admin@prismagentic.io'
    publisherName: 'PRISMAgentic Studio'
    appInsightsId: logAnalyticsWorkspaceId
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
    decisionEngineUrl: decisionEngine.outputs.fqdn
    functionsUrl: functions.outputs.defaultHostName
  }
}

// ============================================================================
// Front Door (Edge Protection)
// ============================================================================

module frontDoor './front-door.bicep' = {
  name: 'front-door-${resourceToken}'
  params: {
    name: '${abbrs.frontDoor}${resourceToken}'
    tags: tags
    sku: 'Standard_AzureFrontDoor'
    staticWebAppHostname: staticWebApp.outputs.defaultHostname
    apimHostname: apim.outputs.gatewayUrl
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// ============================================================================
// Outputs
// ============================================================================

output storageAccountId string = storage.outputs.id
output storageAccountName string = storage.outputs.name
output openAiEndpoint string = openAi.outputs.endpoint
output openAiName string = openAi.outputs.name
output aiSearchEndpoint string = aiSearch.outputs.endpoint
output cosmosEndpoint string = cosmosDb.outputs.endpoint
output cosmosDatabaseName string = cosmosDb.outputs.databaseName
output redisHost string = redis.outputs.hostName
output signalREndpoint string = signalR.outputs.hostName
output staticWebAppUrl string = 'https://${staticWebApp.outputs.defaultHostname}'
output functionAppUrl string = 'https://${functions.outputs.defaultHostName}'
output decisionEngineUrl string = 'https://${decisionEngine.outputs.fqdn}'
output apimGatewayUrl string = apim.outputs.gatewayUrl
output frontDoorEndpoint string = frontDoor.outputs.endpoint