#!/bin/bash
set -e

echo "🚀 Starting PRISMAgentic Studio post-create setup..."

# ============================================================================
# Python Environment Setup
# ============================================================================
echo "📦 Setting up Python environment..."

# Activate virtual environment
source /opt/venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install root requirements
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
fi

# Install development requirements
if [ -f "requirements-dev.txt" ]; then
    pip install -r requirements-dev.txt
fi

# Install Decision Engine dependencies
if [ -f "src/decision-engine/requirements.txt" ]; then
    pip install -r src/decision-engine/requirements.txt
fi

# Install Azure Functions dependencies
if [ -f "src/api/functions/requirements.txt" ]; then
    pip install -r src/api/functions/requirements.txt
fi

# Install ML dependencies
if [ -f "src/ml/environments/training.yaml" ]; then
    echo "⚠️  ML dependencies defined in conda environment - install separately if needed"
fi

# ============================================================================
# Node.js Environment Setup
# ============================================================================
echo "📦 Setting up Node.js environment..."

# Install UI dependencies
if [ -f "src/ui/package.json" ]; then
    cd src/ui
    npm install
    cd ../..
fi

# ============================================================================
# Azure CLI Configuration
# ============================================================================
echo "🔧 Configuring Azure CLI..."

# Enable Bicep
az bicep install 2>/dev/null || true
az bicep upgrade 2>/dev/null || true

# Configure defaults
az config set core.collect_telemetry=false 2>/dev/null || true
az config set core.only_show_errors=true 2>/dev/null || true

# ============================================================================
# Git Configuration
# ============================================================================
echo "🔧 Configuring Git..."

# Initialize Git LFS
git lfs install 2>/dev/null || true

# Set up pre-commit hooks if available
if [ -f ".pre-commit-config.yaml" ]; then
    pip install pre-commit
    pre-commit install
fi

# ============================================================================
# Create Local Environment Files
# ============================================================================
echo "📝 Creating local environment files..."

# Create local.settings.json for Azure Functions if not exists
if [ ! -f "src/api/functions/local.settings.json" ]; then
    cat > src/api/functions/local.settings.json << 'EOF'
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "COSMOS_CONNECTION_STRING": "",
    "REDIS_CONNECTION_STRING": "",
    "OPENAI_API_KEY": ""
  }
}
EOF
    echo "✅ Created src/api/functions/local.settings.json"
fi

# Create .env for Decision Engine if not exists
if [ ! -f "src/decision-engine/.env" ]; then
    cat > src/decision-engine/.env << 'EOF'
# Decision Engine Local Configuration
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO

# Cosmos DB
COSMOS_ENDPOINT=
COSMOS_KEY=
COSMOS_DATABASE=prismagentic
COSMOS_GRAPH_CONTAINER=SegmentGraph
COSMOS_STATE_CONTAINER=ExperimentState

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# App Configuration
APP_CONFIG_ENDPOINT=

# Feature Flags
ENABLE_CACHING=true
CACHE_TTL_SECONDS=60
EOF
    echo "✅ Created src/decision-engine/.env"
fi

# Create .env for UI if not exists
if [ ! -f "src/ui/.env.local" ]; then
    cat > src/ui/.env.local << 'EOF'
# UI Local Configuration
VITE_API_BASE_URL=http://localhost:7071/api
VITE_SIGNALR_URL=http://localhost:7071/api
VITE_AUTH_ENABLED=false
EOF
    echo "✅ Created src/ui/.env.local"
fi

# ============================================================================
# Directory Setup
# ============================================================================
echo "📁 Setting up directories..."

# Create necessary directories
mkdir -p .azure
mkdir -p tests/reports
mkdir -p docs/images/screenshots

# ============================================================================
# Final Messages
# ============================================================================
echo ""
echo "✅ PRISMAgentic Studio development environment is ready!"
echo ""
echo "📋 Quick Start Commands:"
echo "  azd auth login        - Login to Azure"
echo "  azd up                - Deploy everything"
echo "  azd provision         - Provision infrastructure only"
echo "  azd deploy            - Deploy applications only"
echo ""
echo "🧪 Development Commands:"
echo "  cd src/ui && npm run dev           - Start UI dev server"
echo "  cd src/decision-engine && uvicorn main:app --reload  - Start Decision Engine"
echo "  cd src/api/functions && func start - Start Azure Functions"
echo ""
echo "🧪 Test Commands:"
echo "  pytest tests/unit/                 - Run unit tests"
echo "  pytest tests/integration/          - Run integration tests"
echo ""