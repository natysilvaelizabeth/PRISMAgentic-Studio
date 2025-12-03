// ============================================================================
// Azure Container Apps - Decision Engine
// ============================================================================

targetScope = 'resourceGroup'

param location string
param name string
param tags object
param containerAppsEnvironmentId string
param containerImage string
param containerPort int = 8000
param envVars array = []
param minReplicas int = 1
param maxReplicas int = 10
param cpu string = '0.5'
param memory string = '1Gi'

// ============================================================================
// Container App
// ============================================================================

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  tags: union(tags, {
    'azd-service-name': 'decision-engine'
  })
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    
    configuration: {
      activeRevisionsMode: 'Single'
      
      ingress: {
        external: true
        targetPort: containerPort
        transport: 'http'
        allowInsecure: false
        
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
        
        corsPolicy: {
          allowedOrigins: ['*']
          allowedMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
          allowedHeaders: ['*']
          maxAge: 3600
        }
      }
      
      registries: []
      
      secrets: []
    }
    
    template: {
      containers: [
        {
          name: 'decision-engine'
          image: containerImage
          
          resources: {
            cpu: json(cpu)
            memory: memory
          }
          
          env: envVars
          
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: '/health'
                port: containerPort
              }
              initialDelaySeconds: 10
              periodSeconds: 30
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/ready'
                port: containerPort
              }
              initialDelaySeconds: 5
              periodSeconds: 10
            }
          ]
        }
      ]
      
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        
        rules: [
          {
            name: 'http-scaling'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================

output id string = containerApp.id
output name string = containerApp.name
output fqdn string = containerApp.properties.configuration.ingress.fqdn
output latestRevisionFqdn string = containerApp.properties.latestRevisionFqdn