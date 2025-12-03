// ============================================================================
// Managed Identities
// ============================================================================

targetScope = 'resourceGroup'

param location string
param environmentName string
param tags object
param resourceToken string
param keyVaultName string

var abbrs = loadJsonContent('../abbreviations.json')

// Decision Engine Identity
resource decisionEngineIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${abbrs.managedIdentities}decision-${resourceToken}'
  location: location
  tags: tags
}

// AI Hub Identity
resource aiHubIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${abbrs.managedIdentities}aihub-${resourceToken}'
  location: location
  tags: tags
}

// Key Vault Access for Decision Engine
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource decisionEngineKvAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, decisionEngineIdentity.id, 'Key Vault Secrets User')
  scope: keyVault
  properties: {
    principalId: decisionEngineIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalType: 'ServicePrincipal'
  }
}

output decisionEngineIdentityId string = decisionEngineIdentity.id
output decisionEngineIdentityClientId string = decisionEngineIdentity.properties.clientId
output decisionEngineIdentityPrincipalId string = decisionEngineIdentity.properties.principalId
output aiHubIdentityId string = aiHubIdentity.id
output aiHubIdentityClientId string = aiHubIdentity.properties.clientId