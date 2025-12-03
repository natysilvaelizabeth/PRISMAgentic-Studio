// ============================================================================
// Microsoft Defender for Cloud
// ============================================================================

targetScope = 'resourceGroup'

param logAnalyticsWorkspaceId string

// Enable Defender for Key Vault
resource defenderKeyVault 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'KeyVaults'
  properties: {
    pricingTier: 'Standard'
  }
}

// Enable Defender for Storage
resource defenderStorage 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'StorageAccounts'
  properties: {
    pricingTier: 'Standard'
  }
}

// Enable Defender for Containers
resource defenderContainers 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'Containers'
  properties: {
    pricingTier: 'Standard'
  }
}

// Enable Defender for App Service
resource defenderAppService 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'AppServices'
  properties: {
    pricingTier: 'Standard'
  }
}

// Enable Defender for Cosmos DB
resource defenderCosmosDb 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'CosmosDbs'
  properties: {
    pricingTier: 'Standard'
  }
}