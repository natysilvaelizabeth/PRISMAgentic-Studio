// ============================================================================
// Data Governance Module
// ============================================================================

targetScope = 'resourceGroup'

param location string
param environmentName string
param tags object
param resourceToken string

var abbrs = loadJsonContent('../abbreviations.json')

// Microsoft Purview
resource purview 'Microsoft.Purview/accounts@2021-12-01' = {
  name: '${abbrs.purviewAccounts}${resourceToken}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    managedResourceGroupName: '${abbrs.resourceGroups}purview-${environmentName}'
  }
}

output purviewId string = purview.id
output purviewName string = purview.name
output purviewEndpoint string = purview.properties.endpoints.catalog
```

---

## Archivos de Requisitos

### `requirements.txt` (raíz)
```
# PRISMAgentic Studio - Root Requirements
# Common dependencies used across the project

# Azure SDKs
azure-identity>=1.15.0
azure-keyvault-secrets>=4.7.0
azure-cosmos>=4.5.1
azure-storage-blob>=12.19.0
azure-ai-inference>=1.0.0b1

# Configuration
python-dotenv>=1.0.0
pydantic>=2.5.0
pydantic-settings>=2.1.0

# Utilities
httpx>=0.25.0
tenacity>=8.2.0

# Testing
pytest>=7.4.0
pytest-cov>=4.1.0
pytest-asyncio>=0.21.0

# Code Quality
black>=23.0.0
ruff>=0.1.0
mypy>=1.7.0
pre-commit>=3.6.0
```

### `requirements-dev.txt`
```
# Development dependencies
-r requirements.txt

# Testing
pytest-mock>=3.12.0
pytest-xdist>=3.5.0
responses>=0.24.0
fakeredis>=2.20.0
locust>=2.20.0

# Documentation
mkdocs>=1.5.0
mkdocs-material>=9.5.0

# Type stubs
types-redis>=4.6.0
types-requests>=2.31.0