# PRISMAgentic Studio - Azure Infrastructure
## Fabric + Foundry Edition

**Agentic Progressive Ring Intelligence for Segment Marketing Analytics**

This repository contains the Azure infrastructure-as-code for deploying PRISMAgentic Studio using **Microsoft Fabric** and **Azure AI Foundry**.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PRISMAgentic STUDIO ARCHITECTURE                         │
│                       Fabric + Foundry Edition                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    AZURE AI FOUNDRY                                 │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │                    AI HUB (Shared)                            │ │   │
│  │  │  Connections: OpenAI │ Content Safety │ Search │ Cosmos DB   │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  │                              │                                      │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │                  AI PROJECT (PRISMAgentic)                    │ │   │
│  │  │                                                               │ │   │
│  │  │  AGENTS:                                                      │ │   │
│  │  │  • Campaign Orchestrator    • Safety Guardian                 │ │   │
│  │  │  • Experiment Conductor     • Segment Analyst                 │ │   │
│  │  │  • Variant Generator        • Uplift Modeling                 │ │   │
│  │  │  • Segment Relationship     • Campaign Insights Co-Pilot      │ │   │
│  │  │                                                               │ │   │
│  │  │  TOOLS:                                                       │ │   │
│  │  │  • Fabric Data Agent        • MAD Allocator                   │ │   │
│  │  │  • Cosmos Gremlin           • Bandit Optimizer                │ │   │
│  │  │  • App Config Manager       • Citation Verifier               │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    MICROSOFT FABRIC                                 │   │
│  │                                                                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │   │
│  │  │   OneLake   │  │ Real-Time   │  │    Data     │  │  Fabric   │ │   │
│  │  │   (Delta)   │  │ Intelligence│  │  Activator  │  │    IQ     │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘ │   │
│  │                                                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                   FABRIC DATA AGENT                         │   │   │
│  │  │  Exposes OneLake tables as tools for AI Foundry agents      │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    SUPPORTING SERVICES                              │   │
│  │  • Azure App Configuration (Feature Flags / Rings)                  │   │
│  │  • Azure Cosmos DB (Gremlin - Segment Graph)                        │   │
│  │  • Azure AI Search (RAG)                                            │   │
│  │  • Azure Key Vault (Secrets)                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 What's Deployed

### Bicep-Deployable (Automated)

| Service | Purpose |
|---------|---------|
| **Azure AI Hub** | Shared AI resources and connections |
| **Azure AI Project** | PRISMAgentic agents workspace |
| **Azure OpenAI** | GPT-4o, Embeddings for agents |
| **Azure AI Content Safety** | Safety validation |
| **Azure AI Search** | RAG for content retrieval |
| **Azure Cosmos DB (Gremlin)** | Segment Relationship Graph |
| **Azure App Configuration** | Feature flags for ring deployment |
| **Azure Key Vault** | Secrets management |
| **Networking** | VNet, NSGs, Private DNS |
| **Monitoring** | Log Analytics, Application Insights |

### Manual Configuration Required

| Service | Purpose | Automation |
|---------|---------|------------|
| **Microsoft Fabric Workspace** | Data platform | ✅ `setup_fabric.py` |
| **Fabric Lakehouse + Tables** | Delta tables | ✅ `setup_fabric.py` + notebook |
| **Fabric Data Agent** | Data access for agents | ✅ `setup_fabric.py` |
| **Foundry Connection** | Connect to Fabric | ✅ `configure_foundry_fabric.py` |
| **Agent Definitions** | Deploy to AI Foundry | ✅ `az ai project agent create` |

> **Note:** All "manual" steps have automation scripts available! See [Automation Scripts](#-automation-scripts) section.

---

## 🚀 Quick Start

### Prerequisites

```bash
# Azure CLI with ML extension
az --version  # 2.50+
az extension add --name ml --yes

# Login
az login
az account set --subscription "<subscription-id>"
```

### Deploy Infrastructure

```bash
# Clone repository
git clone <repo-url>
cd prismagentic-infra-v2

# Update parameters with your AAD Object ID
AAD_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
sed -i "s/<YOUR-AAD-OBJECT-ID>/$AAD_OBJECT_ID/g" parameters/dev.parameters.json

# Deploy
chmod +x scripts/*.sh
./scripts/deploy.sh -e dev -y
```

---

## 📁 Directory Structure

```
prismagentic-infra-v2/
├── main.bicep                        # Main orchestration
├── modules/
│   ├── networking.bicep              # VNet, NSGs, Private DNS
│   ├── monitoring.bicep              # Log Analytics, App Insights
│   ├── storage.bicep                 # Storage for AI Hub
│   ├── keyVault.bicep                # Key Vault
│   ├── appConfiguration.bicep        # Feature Flags
│   ├── cosmosDb.bicep                # Segment Graph (Gremlin)
│   ├── aiServices.bicep              # OpenAI, Safety, Search
│   └── aiFoundry.bicep               # AI Hub + AI Project
├── agents/
│   └── agent_definitions.yaml        # Agent YAML for Foundry
├── notebooks/
│   └── create_delta_tables.ipynb     # ⭐ Fabric notebook for table creation
├── parameters/
│   └── dev.parameters.json           # Environment parameters
├── scripts/
│   ├── deploy.sh                     # Azure infrastructure deployment
│   ├── setup_fabric.py               # ⭐ Fabric workspace/lakehouse/Data Agent
│   ├── configure_foundry_fabric.py   # ⭐ Foundry + Fabric integration
│   ├── init-cosmos-graph.sh          # Graph initialization
│   └── create-search-indexes.sh      # Search index creation
└── docs/
    └── ARCHITECTURE_FABRIC_FOUNDRY.md
```

---

## 🐍 Automation Scripts

### `setup_fabric.py` - Full Fabric Infrastructure

Creates everything in Microsoft Fabric programmatically via REST API:

```bash
# What it creates:
# 1. Fabric Workspace
# 2. Lakehouse with SQL endpoint  
# 3. AI Skill (Data Agent) with REST endpoint

# Authentication options:
# - DefaultAzureCredential (Azure CLI, Managed Identity)
# - Service Principal (for CI/CD)

python scripts/setup_fabric.py \
    --workspace-name PRISMAgentic-dev \
    --lakehouse-name prismagentic_lakehouse \
    --environment dev

# With Service Principal for CI/CD
python scripts/setup_fabric.py \
    --workspace-name PRISMAgentic-prod \
    --environment prod \
    --client-id $SP_CLIENT_ID \
    --client-secret $SP_CLIENT_SECRET \
    --tenant-id $TENANT_ID
```

**Output:**
```json
{
  "workspace_id": "abc123...",
  "lakehouse_id": "def456...",
  "ai_skill_id": "ghi789...",
  "foundry_endpoint": "https://api.fabric.microsoft.com/v1/workspaces/..."
}
```

### `configure_foundry_fabric.py` - Connect Foundry to Fabric

Creates the connection between AI Foundry and Fabric Data Agent:

```bash
python scripts/configure_foundry_fabric.py \
    --subscription-id $SUBSCRIPTION_ID \
    --resource-group rg-prisma-dev-eastus2 \
    --ai-hub-name aihub-prismadev-xxxx \
    --ai-project-name aiproj-prismadev-prismagentic \
    --fabric-workspace-id $WORKSPACE_ID \
    --fabric-aiskill-id $AISKILL_ID
```

### `create_delta_tables.ipynb` - Fabric Notebook

Creates all 9 Delta tables with proper schemas:
- `customers`, `segments`, `experiments`, `message_variants`
- `experiment_events`, `uplift_results`
- `safety_audit_log`, `ring_progression_log`, `fairness_audit_log`

Can be executed:
1. Uploaded to Fabric and run interactively
2. Via Fabric REST API job execution
3. Locally with Spark connected to OneLake

---

## 🔧 Post-Deployment Steps

### ✅ Fully Automated - No Portal Required!

All Fabric resources can be created programmatically via REST APIs and SDKs:

```bash
# Step 1: Deploy Azure infrastructure (Bicep)
./scripts/deploy.sh -e dev -y

# Step 2: Create Fabric workspace, lakehouse, and Data Agent
python scripts/setup_fabric.py \
    --workspace-name PRISMAgentic-dev \
    --lakehouse-name prismagentic_lakehouse \
    --environment dev

# Step 3: Create Delta tables (run in Fabric or locally with Spark)
# Option A: Upload and run notebook in Fabric
# Option B: Use Fabric REST API to run notebook

# Step 4: Configure Foundry + Fabric integration
python scripts/configure_foundry_fabric.py \
    --subscription-id $SUBSCRIPTION_ID \
    --resource-group rg-prisma-dev-eastus2 \
    --ai-hub-name aihub-prismadev-xxxx \
    --ai-project-name aiproj-prismadev-prismagentic \
    --fabric-workspace-id $FABRIC_WORKSPACE_ID \
    --fabric-aiskill-id $FABRIC_AISKILL_ID

# Step 5: Deploy agents
az ai project agent create \
    --file agents/agent_definitions.yaml
```

### Alternative: Manual Portal Steps

If you prefer the portal UI, here are the manual steps:

#### Step 1: Create Fabric Workspace (Portal)

1. Navigate to [Microsoft Fabric](https://app.fabric.microsoft.com)
2. Create a new workspace: `PRISMAgentic-dev`
3. Create the following Delta tables in OneLake:

```sql
-- Core Tables
customers          -- Customer profiles with features
segments           -- Segment definitions
message_variants   -- Variants with Message Genome
experiments        -- Experiment configurations
experiment_events  -- Allocation and outcome events

-- Analytics Tables
uplift_results     -- CATE estimates by segment
safety_audit_log   -- Immutable safety decisions
fairness_audit_log -- Fairness assessments
ring_progression   -- Ring advancement history
```

### Step 2: Create Fabric Data Agent

1. In Fabric workspace, go to **Data Engineering**
2. Create a new **Data Agent**
3. Configure access to your OneLake tables
4. Note the agent endpoint for AI Foundry configuration

### Step 3: Deploy Agents

```bash
# Using Azure AI CLI
az ai project agent create \
  --project-name aiproj-prismadev-prismagentic \
  --resource-group rg-prisma-dev-eastus2 \
  --file agents/agent_definitions.yaml

# Or via Python SDK
from azure.ai.projects import AIProjectClient

client = AIProjectClient(
    subscription_id="<sub>",
    resource_group_name="rg-prisma-dev-eastus2",
    project_name="aiproj-prismadev-prismagentic"
)

with open("agents/agent_definitions.yaml") as f:
    client.agents.create_from_yaml(f)
```

### Step 4: Initialize Supporting Services

```bash
# Initialize Cosmos DB graph with sample segments
./scripts/init-cosmos-graph.sh dev

# Create AI Search indexes for RAG
./scripts/create-search-indexes.sh dev
```

---

## 🤖 Agent Architecture

### Agent Inventory

| Agent | Role | Key Tools |
|-------|------|-----------|
| **Campaign Orchestrator** | Master coordinator | All sub-agents |
| **Experiment Conductor** | Variant allocation (MAD + MAB) | Fabric, App Config, MAD |
| **Safety Guardian** | Pre-send validation | Content Safety, Search |
| **Segment Analyst** | Customer segmentation | Fabric, Cosmos |
| **Variant Generator** | Message creation | Search, Embeddings |
| **Segment Relationship** | Transfer learning | Cosmos Gremlin |
| **Uplift Modeling** | Causal effect estimation | Fabric |
| **Campaign Insights Co-Pilot** | Interactive analytics | Fabric, Cosmos |

### Tool Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                    TOOL ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  FOUNDRY AGENT                    TOOLS                         │
│  ┌─────────────────┐             ┌─────────────────────────┐   │
│  │ Experiment      │             │ FABRIC DATA AGENT       │   │
│  │ Conductor       │────────────▶│ • Query experiments     │   │
│  │                 │             │ • Query segments        │   │
│  │                 │             │ • Query events          │   │
│  │                 │             │ • Write results         │   │
│  │                 │             └─────────────────────────┘   │
│  │                 │                                           │
│  │                 │             ┌─────────────────────────┐   │
│  │                 │────────────▶│ APP CONFIG MANAGER      │   │
│  │                 │             │ • Check ring eligibility │   │
│  │                 │             │ • Get variant config     │   │
│  │                 │             │ • Toggle kill switch     │   │
│  │                 │             └─────────────────────────┘   │
│  │                 │                                           │
│  │                 │             ┌─────────────────────────┐   │
│  │                 │────────────▶│ MAD ALLOCATOR           │   │
│  │                 │             │ • Variant allocation     │   │
│  │                 │             │ • Confidence sequences   │   │
│  └─────────────────┘             └─────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security

| Feature | Dev | Prod |
|---------|-----|------|
| Private Endpoints | ❌ | ✅ |
| VNet Integration | Optional | Required |
| Managed Identity | ✅ | ✅ |
| Key Vault RBAC | ✅ | ✅ |
| Diagnostic Logging | ✅ | ✅ |

---

## 💰 Estimated Costs (Dev)

| Service | Monthly Estimate |
|---------|------------------|
| Azure AI Foundry | ~$100-200 |
| Azure OpenAI | ~$200 (usage) |
| AI Search (Standard) | ~$250 |
| Cosmos DB (Serverless) | ~$25-50 |
| App Configuration | ~$40 |
| Other | ~$100 |
| **Total** | **~$700-900/month** |

*Microsoft Fabric costs depend on capacity units (F SKU) purchased separately*

---

## 📚 Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-studio/)
- [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric/)
- [Fabric Data Agents](https://learn.microsoft.com/fabric/data-engineering/data-agent)
- [Azure AI Agent Service](https://learn.microsoft.com/azure/ai-services/agents/)
- [PRISMAgentic Architecture](./docs/ARCHITECTURE_FABRIC_FOUNDRY.md)

---

## License

MIT License - See LICENSE file for details.