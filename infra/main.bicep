// ============================================================================
// PRISMAgentic Studio - Main Infrastructure Orchestration
// ============================================================================
// This is the main entry point for all infrastructure deployment.
// It orchestrates the deployment of all modules in the correct order.
// ============================================================================

targetScope = 'subscription'

// ============================================================================
// Parameters
// ============================================================================

@minLength(1)
@maxLength(64)
@description('Name of the environment (e.g., dev, staging, prod)')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Optional. Resource group name override')
param resourceGroupName string = ''

@description('Tags to apply to all resources')
param tags object = {}

// Feature flags
@description('Enable private endpoints for enhanced security')
param enablePrivateEndpoints bool = false

@description('Enable zone redundancy for high availability')
param enableZoneRedundancy bool = false

@description('Enable Microsoft Purview for data governance')
param enablePurview bool = false

@description('Enable Microsoft Defender for Cloud')
param enableDefender bool = true

// OpenAI configuration
@description('Azure OpenAI model deployments')
param openAiModelDeployments array = [
  {
    name: 'gpt-4o'
    model: 'gpt-4o'
    version: '2024-05-13'
    capacity: 30
  }
]

// Cosmos DB configuration
@description('Cosmos DB throughput in RU/s')
param cosmosDbThroughput int = 4000

// ============================================================================
// Variables
// ============================================================================

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var defaultTags = {
  'azd-env-name': environmentName
  'app-name': 'prismagentic-studio'
  'environment': environmentName
  'managed-by': 'bicep'
}

var allTags = union(defaultTags, tags)

// Resource names
var rgName = !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'

// ============================================================================
// Resource Group
// ============================================================================

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
  tags: allTags
}

// ============================================================================
// Observability (Deploy First - Required by other modules)
// ============================================================================

module observability './observability/main.bicep' = {
  name: 'observability-${resourceToken}'
  scope: rg
  params: {
    location: location
    environmentName: environmentName
    tags: allTags
    resourceToken: resourceToken
  }
}

// ============================================================================
// Security Foundation
// ============================================================================

module security './security/main.bicep' = {
  name: 'security-${resourceToken}'
  scope: rg
  params: {
    location: location
    environmentName: environmentName
    tags: allTags
    resourceToken: resourceToken
    logAnalyticsWorkspaceId: observability.outputs.logAnalyticsWorkspaceId
    enableDefender: enableDefender
  }
}

// ============================================================================
// Core Infrastructure
// ============================================================================

module core './core/main.bicep' = {
  name: 'core-${resourceToken}'
  scope: rg
  params: {
    location: location
    environmentName: environmentName
    tags: allTags
    resourceToken: resourceToken
    keyVaultName: security.outputs.keyVaultName
    logAnalyticsWorkspaceId: observability.outputs.logAnalyticsWorkspaceId
    appInsightsConnectionString: observability.outputs.appInsightsConnectionString
    appInsightsInstrumentationKey: observability.outputs.appInsightsInstrumentationKey
    enablePrivateEndpoints: enablePrivateEndpoints
    enableZoneRedundancy: enableZoneRedundancy
    openAiModelDeployments: openAiModelDeployments
    cosmosDbThroughput: cosmosDbThroughput
  }
}

// ============================================================================
// AI Foundry
// ============================================================================

module aiFoundry './core/ai-foundry.bicep' = {
  name: 'ai-foundry-${resourceToken}'
  scope: rg
  params: {
    location: location
    environmentName: environmentName
    tags: allTags
    resourceToken: resourceToken
    keyVaultId: security.outputs.keyVaultId
    storageAccountId: core.outputs.storageAccountId
    appInsightsId: observability.outputs.appInsightsId
    openAiEndpoint: core.outputs.openAiEndpoint
    openAiName: core.outputs.openAiName
    aiSearchEndpoint: core.outputs.aiSearchEndpoint
  }
}

// ============================================================================
// Data Governance (Optional)
// ============================================================================

module governance './governance/main.bicep' = if (enablePurview) {
  name: 'governance-${resourceToken}'
  scope: rg
  params: {
    location: location
    environmentName: environmentName
    tags: allTags
    resourceToken: resourceToken
  }
}

// ============================================================================
// Outputs
// ============================================================================

// Resource Group
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_LOCATION string = location

// Observability
output APPLICATIONINSIGHTS_CONNECTION_STRING string = observability.outputs.appInsightsConnectionString
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = observability.outputs.logAnalyticsWorkspaceId

// Security
output AZURE_KEY_VAULT_NAME string = security.outputs.keyVaultName
output AZURE_KEY_VAULT_ENDPOINT string = security.outputs.keyVaultEndpoint

// Core Services
output AZURE_OPENAI_ENDPOINT string = core.outputs.openAiEndpoint
output AZURE_OPENAI_NAME string = core.outputs.openAiName
output AZURE_COSMOS_ENDPOINT string = core.outputs.cosmosEndpoint
output AZURE_COSMOS_DATABASE string = core.outputs.cosmosDatabaseName
output AZURE_REDIS_HOST string = core.outputs.redisHost
output AZURE_SIGNALR_ENDPOINT string = core.outputs.signalREndpoint
output AZURE_SEARCH_ENDPOINT string = core.outputs.aiSearchEndpoint

// Service URIs
output SERVICE_WEB_URI string = core.outputs.staticWebAppUrl
output SERVICE_API_URI string = core.outputs.functionAppUrl
output SERVICE_DECISION_ENGINE_URI string = core.outputs.decisionEngineUrl

// AI Foundry
output AZURE_AI_HUB_NAME string = aiFoundry.outputs.aiHubName
output AZURE_AI_PROJECT_NAME string = aiFoundry.outputs.aiProjectName