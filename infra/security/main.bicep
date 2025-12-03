// ============================================================================
// Security Module - Main Orchestration
// ============================================================================

targetScope = 'resourceGroup'

param location string
param environmentName string
param tags object
param resourceToken string
param logAnalyticsWorkspaceId string
param enableDefender bool = true

var abbrs = loadJsonContent('../abbreviations.json')

// ============================================================================
// Key Vault
// ============================================================================

module keyVault './key-vault.bicep' = {
  name: 'key-vault-${resourceToken}'
  params: {
    location: location
    name: '${abbrs.keyVaults}${resourceToken}'
    tags: tags
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// ============================================================================
// Managed Identities
// ============================================================================

module managedIdentities './managed-identities.bicep' = {
  name: 'managed-identities-${resourceToken}'
  params: {
    location: location
    environmentName: environmentName
    tags: tags
    resourceToken: resourceToken
    keyVaultName: keyVault.outputs.name
  }
}

// ============================================================================
// Defender for Cloud (Optional)
// ============================================================================

module defender './defender.bicep' = if (enableDefender) {
  name: 'defender-${resourceToken}'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// ============================================================================
// Outputs
// ============================================================================

output keyVaultId string = keyVault.outputs.id
output keyVaultName string = keyVault.outputs.name
output keyVaultEndpoint string = keyVault.outputs.endpoint
output decisionEngineIdentityId string = managedIdentities.outputs.decisionEngineIdentityId
output decisionEngineIdentityClientId string = managedIdentities.outputs.decisionEngineIdentityClientId