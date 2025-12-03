// ============================================================================
// Azure Cosmos DB - Graph + NoSQL Containers
// ============================================================================

targetScope = 'resourceGroup'

param location string
param name string
param tags object
param throughput int = 4000
param keyVaultName string
param logAnalyticsWorkspaceId string
param enablePrivateEndpoints bool = false
param enableZoneRedundancy bool = false

// Database name
var databaseName = 'prismagentic'

// ============================================================================
// Cosmos DB Account
// ============================================================================

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: enableZoneRedundancy
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: enablePrivateEndpoints
    publicNetworkAccess: enablePrivateEndpoints ? 'Disabled' : 'Enabled'
    
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: enableZoneRedundancy
      }
    ]
    
    capabilities: [
      {
        name: 'EnableGremlin'
      }
      {
        name: 'EnableServerless'
      }
    ]
    
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: enableZoneRedundancy ? 'Geo' : 'Local'
      }
    }
  }
}

// ============================================================================
// Gremlin Database (for Graph)
// ============================================================================

resource gremlinDatabase 'Microsoft.DocumentDB/databaseAccounts/gremlinDatabases@2024-02-15-preview' = {
  parent: cosmosAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

// ============================================================================
// Gremlin Container: SegmentGraph
// ============================================================================

resource segmentGraphContainer 'Microsoft.DocumentDB/databaseAccounts/gremlinDatabases/graphs@2024-02-15-preview' = {
  parent: gremlinDatabase
  name: 'SegmentGraph'
  properties: {
    resource: {
      id: 'SegmentGraph'
      partitionKey: {
        paths: ['/partitionKey']
        kind: 'Hash'
        version: 2
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/embedding/*'
          }
          {
            path: '/"_etag"/?'
          }
        ]
      }
    }
    options: {
      throughput: throughput
    }
  }
}

// ============================================================================
// SQL Database (for NoSQL containers)
// ============================================================================

resource sqlDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-02-15-preview' = {
  parent: cosmosAccount
  name: '${databaseName}-state'
  properties: {
    resource: {
      id: '${databaseName}-state'
    }
  }
}

// ============================================================================
// SQL Container: ExperimentState
// ============================================================================

resource experimentStateContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-02-15-preview' = {
  parent: sqlDatabase
  name: 'ExperimentState'
  properties: {
    resource: {
      id: 'ExperimentState'
      partitionKey: {
        paths: ['/segmentId']
        kind: 'Hash'
        version: 2
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/experimentId/?'
          }
          {
            path: '/segmentId/?'
          }
          {
            path: '/updatedAt/?'
          }
        ]
        excludedPaths: [
          {
            path: '/betas/*'
          }
          {
            path: '/*'
          }
        ]
      }
      defaultTtl: -1  // No expiration by default
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
    options: {
      throughput: throughput / 2
    }
  }
}

// ============================================================================
// SQL Container: AuditLog
// ============================================================================

resource auditLogContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-02-15-preview' = {
  parent: sqlDatabase
  name: 'AuditLog'
  properties: {
    resource: {
      id: 'AuditLog'
      partitionKey: {
        paths: ['/experimentId']
        kind: 'Hash'
        version: 2
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/timestamp/?'
          }
          {
            path: '/agentName/?'
          }
          {
            path: '/action/?'
          }
        ]
        excludedPaths: [
          {
            path: '/*'
          }
        ]
      }
      defaultTtl: 7776000  // 90 days
    }
    options: {
      throughput: 400
    }
  }
}

// ============================================================================
// Diagnostics
// ============================================================================

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'cosmos-diagnostics'
  scope: cosmosAccount
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
      {
        category: 'QueryRuntimeStatistics'
        enabled: true
      }
      {
        category: 'PartitionKeyStatistics'
        enabled: true
      }
      {
        category: 'PartitionKeyRUConsumption'
        enabled: true
      }
      {
        category: 'ControlPlaneRequests'
        enabled: true
      }
      {
        category: 'GremlinRequests'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Requests'
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

resource cosmosConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'cosmos-connection-string'
  properties: {
    value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

resource cosmosGremlinEndpointSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'cosmos-gremlin-endpoint'
  properties: {
    value: 'wss://${cosmosAccount.name}.gremlin.cosmos.azure.com:443/'
  }
}

resource cosmosPrimaryKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'cosmos-primary-key'
  properties: {
    value: cosmosAccount.listKeys().primaryMasterKey
  }
}

// ============================================================================
// Outputs
// ============================================================================

output id string = cosmosAccount.id
output name string = cosmosAccount.name
output endpoint string = cosmosAccount.properties.documentEndpoint
output gremlinEndpoint string = 'wss://${cosmosAccount.name}.gremlin.cosmos.azure.com:443/'
output databaseName string = databaseName
output graphContainerName string = segmentGraphContainer.name
output stateContainerName string = experimentStateContainer.name