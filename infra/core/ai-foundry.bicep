// ============================================================================
// Azure AI Foundry - AI Hub + AI Project
// ============================================================================

targetScope = 'resourceGroup'

param location string
param environmentName string
param tags object
param resourceToken string
param keyVaultId string
param storageAccountId string
param appInsightsId string
param openAiEndpoint string
param openAiName string
param aiSearchEndpoint string

var abbrs = loadJsonContent('../abbreviations.json')

// ============================================================================
// AI Hub (Workspace)
// ============================================================================

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: '${abbrs.aiHub}${resourceToken}'
  location: location
  tags: union(tags, {
    'azd-service-name': 'ai-hub'
  })
  kind: 'Hub'
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'PRISMAgentic AI Hub - ${environmentName}'
    description: 'AI Hub for PRISMAgentic Studio multi-agent system'
    
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: appInsightsId
    
    publicNetworkAccess: 'Enabled'
    
    managedNetwork: {
      isolationMode: 'AllowInternetOutbound'
    }
  }
}

// ============================================================================
// AI Project
// ============================================================================

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: '${abbrs.aiProject}${resourceToken}'
  location: location
  tags: union(tags, {
    'azd-service-name': 'ai-project'
  })
  kind: 'Project'
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'PRISMAgentic Studio - ${environmentName}'
    description: 'AI Project for marketing experimentation agents'
    hubResourceId: aiHub.id
    publicNetworkAccess: 'Enabled'
  }
}

// ============================================================================
// Connection: Azure OpenAI
// ============================================================================

resource openAiConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-04-01' = {
  parent: aiHub
  name: 'aoai-connection'
  properties: {
    category: 'AzureOpenAI'
    target: openAiEndpoint
    authType: 'ApiKey'
    isSharedToAll: true
    metadata: {
      ApiType: 'Azure'
      ResourceId: resourceId('Microsoft.CognitiveServices/accounts', openAiName)
    }
    credentials: {
      key: listKeys(resourceId('Microsoft.CognitiveServices/accounts', openAiName), '2024-04-01-preview').key1
    }
  }
}

// ============================================================================
// Connection: Azure AI Search
// ============================================================================

resource aiSearchConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-04-01' = {
  parent: aiHub
  name: 'search-connection'
  properties: {
    category: 'CognitiveSearch'
    target: aiSearchEndpoint
    authType: 'ApiKey'
    isSharedToAll: true
    credentials: {
      key: '' // Will be populated post-deployment
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================

output aiHubId string = aiHub.id
output aiHubName string = aiHub.name
output aiProjectId string = aiProject.id
output aiProjectName string = aiProject.name
output aiHubPrincipalId string = aiHub.identity.principalId
output aiProjectPrincipalId string = aiProject.identity.principalId