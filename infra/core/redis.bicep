// ============================================================================
// Azure Cache for Redis
// ============================================================================

targetScope = 'resourceGroup'

param location string
param name string
param tags object
param sku string = 'Standard'
param keyVaultName string
param logAnalyticsWorkspaceId string
param enablePrivateEndpoints bool = false
param enableZoneRedundancy bool = false

// SKU configuration
var skuConfig = {
  Basic: {
    name: 'Basic'
    family: 'C'
    capacity: 0
  }
  Standard: {
    name: 'Standard'
    family: 'C'
    capacity: 1
  }
  Premium: {
    name: 'Premium'
    family: 'P'
    capacity: 1
  }
}

// ============================================================================
// Redis Cache
// ============================================================================

resource redis 'Microsoft.Cache/redis@2024-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: skuConfig[sku]
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: enablePrivateEndpoints ? 'Disabled' : 'Enabled'
    
    redisConfiguration: {
      'maxmemory-policy': 'allkeys-lru'
      'maxmemory-reserved': '50'
    }
    
    redisVersion: '6'
    
    replicasPerMaster: enableZoneRedundancy ? 1 : 0
    replicasPerPrimary: enableZoneRedundancy ? 1 : 0
  }
  zones: enableZoneRedundancy ? ['1', '2', '3'] : []
}

// ============================================================================
// Diagnostics
// ============================================================================

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'redis-diagnostics'
  scope: redis
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// ============================================================================
// Store Connection String in Key Vault
// ============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource redisConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'redis-connection-string'
  properties: {
    value: '${redis.properties.hostName}:${redis.properties.sslPort},password=${redis.listKeys().primaryKey},ssl=True,abortConnect=False'
  }
}

resource redisPrimaryKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'redis-primary-key'
  properties: {
    value: redis.listKeys().primaryKey
  }
}

// ============================================================================
// Outputs
// ============================================================================

output id string = redis.id
output name string = redis.name
output hostName string = redis.properties.hostName
output sslPort int = redis.properties.sslPort