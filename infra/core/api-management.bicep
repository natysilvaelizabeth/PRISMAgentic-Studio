// ============================================================================
// Azure API Management
// ============================================================================

targetScope = 'resourceGroup'

param location string
param name string
param tags object
param sku string = 'Developer'
param publisherEmail string
param publisherName string
param appInsightsId string
param appInsightsInstrumentationKey string
param decisionEngineUrl string
param functionsUrl string

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
    capacity: sku == 'Consumption' ? 0 : 1
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

// Logger for Application Insights
resource apimLogger 'Microsoft.ApiManagement/service/loggers@2023-09-01-preview' = {
  parent: apim
  name: 'appinsights-logger'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

// Decision Engine Backend
resource decisionEngineBackend 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apim
  name: 'decision-engine'
  properties: {
    protocol: 'http'
    url: 'https://${decisionEngineUrl}'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

// Functions Backend
resource functionsBackend 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apim
  name: 'functions'
  properties: {
    protocol: 'http'
    url: 'https://${functionsUrl}'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

// API: PRISMAgentic
resource api 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' = {
  parent: apim
  name: 'prismagentic-api'
  properties: {
    displayName: 'PRISMAgentic Studio API'
    description: 'API for PRISMAgentic Studio marketing experimentation platform'
    subscriptionRequired: true
    path: 'api'
    protocols: ['https']
    serviceUrl: 'https://${functionsUrl}/api'
  }
}

// Health check operation
resource healthOperation 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = {
  parent: api
  name: 'health'
  properties: {
    displayName: 'Health Check'
    method: 'GET'
    urlTemplate: '/health'
  }
}

// Assignment operation
resource assignOperation 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = {
  parent: api
  name: 'assign'
  properties: {
    displayName: 'Get Variant Assignment'
    method: 'POST'
    urlTemplate: '/v1/assign'
    description: 'Get variant assignment for a customer'
  }
}

output id string = apim.id
output name string = apim.name
output gatewayUrl string = apim.properties.gatewayUrl