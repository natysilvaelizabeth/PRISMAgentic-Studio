// ============================================================================
// Azure OpenAI Service
// ============================================================================

targetScope = 'resourceGroup'

param location string
param name string
param tags object
param modelDeployments array
param keyVaultName string
param logAnalyticsWorkspaceId string

// ============================================================================
// Azure OpenAI Account
// ============================================================================

resource openAiAccount 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// ============================================================================
// Model Deployments
// ============================================================================

@batchSize(1)
resource deployments 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = [for deployment in modelDeployments: {
  parent: openAiAccount
  name: deployment.name
  sku: {
    name: 'Standard'
    capacity: deployment.capacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: deployment.model
      version: deployment.version
    }
    raiPolicyName: 'Microsoft.Default'
  }
}]

// ============================================================================
// Content Safety
// ============================================================================

resource contentSafety 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: '${name}-safety'
  location: location
  tags: tags
  kind: 'ContentSafety'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: '${name}-safety'
    publicNetworkAccess: 'Enabled'
  }
}

// ============================================================================
// Diagnostics
// ============================================================================

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'openai-diagnostics'
  scope: openAiAccount
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'Audit'
        enabled: true
      }
      {
        category: 'RequestResponse'
        enabled: true
      }
      {
        category: 'Trace'
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

// ============================================================================
// Store Keys in Key Vault
// ============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource openAiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'openai-api-key'
  properties: {
    value: openAiAccount.listKeys().key1
  }
}

resource contentSafetyKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'content-safety-api-key'
  properties: {
    value: contentSafety.listKeys().key1
  }
}

// ============================================================================
// Outputs
// ============================================================================

output id string = openAiAccount.id
output name string = openAiAccount.name
output endpoint string = openAiAccount.properties.endpoint
output contentSafetyEndpoint string = contentSafety.properties.endpoint