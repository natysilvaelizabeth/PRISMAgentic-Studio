# PRISMAgentic Studio

<div align="center">

![PRISMAgentic Studio](./docs/images/logo.png)

**Personalized Real-time Intelligent Segmentation & Marketing Agentic Platform**

[![Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com)
[![AI Foundry](https://img.shields.io/badge/Azure%20AI%20Foundry-5C2D91?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/products/ai-studio)
[![Fabric](https://img.shields.io/badge/Microsoft%20Fabric-117865?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://www.microsoft.com/microsoft-fabric)
[![Agent Framework](https://img.shields.io/badge/Microsoft%20Agent%20Framework-6B2D91?style=for-the-badge&logo=microsoft&logoColor=white)](https://learn.microsoft.com/agent-framework/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

[Overview](#overview) • [Key Features](#key-features) • [Architecture](#architecture) • [Getting Started](#getting-started) • [Deployment](#deployment) • [Usage](#usage) • [Contributing](#contributing)

</div>

---

## Overview

**PRISMAgentic Studio** is an advanced AI-powered marketing experimentation platform that revolutionizes how organizations run personalized campaigns. Built on Azure AI Foundry with a multi-agent architecture, it enables **transfer learning across customer segments**, **adaptive optimization**, and **progressive deployment** — all while ensuring **fairness** and **safety** by design.

### The Problem We Solve

Traditional A/B testing faces three critical challenges:

| Challenge | Impact |
|-----------|--------|
| **Small segments can't learn** | New or niche segments never reach statistical significance |
| **Static allocation wastes traffic** | 50/50 splits accumulate regret while waiting for results |
| **No knowledge retention** | Each experiment starts from scratch, losing institutional learning |

### Our Solution

PRISMAgentic Studio introduces a fundamentally different approach:
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   TRANSFER LEARNING      ADAPTIVE BANDITS       PROGRESSIVE RINGS          │
│                                                                             │
│   Small segments         Optimize while         Deploy safely:             │
│   borrow knowledge       learning — no          1% → 10% → 30% → 100%      │
│   from similar ones      wasted traffic         with quality gates         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Result:** Experiments that previously took weeks now complete in days. Segments that were ignored now generate revenue. And every experiment makes the system smarter for the next one.

---

## Key Features

### 🧠 Transfer Learning Across Segments

New or small customer segments don't start from zero. They inherit knowledge from similar, established segments through a sophisticated knowledge graph.

- **3-Layer Node Structure:** Attributes (monthly) → GNN Embeddings (post-campaign) → Beta Beliefs (real-time)
- **Similarity Formula:** `w = 0.2 × attr_sim + 0.3 × embed_sim + 0.5 × response_sim`
- **Sample Reduction:** ~45% fewer samples needed to reach statistical significance

### ⚡ Real-Time Decision Engine

A deterministic, high-performance service handles all variant assignments:
```
┌─────────────────────────────────────────────────────────────────┐
│                  REAL-TIME DECISION ENGINE                      │
│                                                                 │
│   Request → Redis Cache → Thompson Sampling → Response          │
│                ↓ (miss)                                         │
│           Cosmos DB                                             │
│        (ExperimentState)                                        │
│                                                                 │
│   Latency: <50ms p99  |  Deterministic  |  Fully Auditable     │
└─────────────────────────────────────────────────────────────────┘
```

- **Separation of Concerns:** LLM agents handle orchestration and analysis; code handles real-time decisions
- **Predictable Latency:** <50ms p99 vs. hundreds of ms with LLM-in-the-loop
- **Full Auditability:** Every decision logged with exact parameters used

### 🎰 Adaptive Bandits (MAD Algorithm)

The Mixed Adaptive Deployment algorithm balances exploration and exploitation dynamically:
```
IF random() < δₜ  →  Thompson Sampling (exploit learned beliefs)
ELSE              →  Uniform Random (explore alternatives)

WHERE: δₜ = max(0.1, 1 - t/T)  // Decays from 1.0 to 0.1 over experiment
```

The **Segment Relationship Agent** configures transfer priors and parameters; the **Decision Engine** executes the algorithm deterministically.

### 🔄 Progressive Ring Deployment

Every campaign deploys through validated stages:

| Ring | Exposure | Purpose | Gate Criteria |
|------|----------|---------|---------------|
| **Ring 0** | 1% | Canary | No critical errors, no safety alerts |
| **Ring 1** | 10% | Early Adopters | Positive signal, no anomalies |
| **Ring 2** | 30% | Broader Validation | Statistical confidence, fairness audit |
| **GA** | 100% | General Availability | Business metrics validated |

**Kill Switch:** Any ring can instantly rollback if issues are detected.

### ⚖️ Fairness by Design

Continuous monitoring ensures equitable treatment across protected groups:

- **Demographic Parity:** Equal variant distribution across groups
- **Equalized Uplift:** Similar treatment effects across groups
- **Equal Opportunity:** Comparable true positive rates
- **Auto-Pause:** Experiments halt automatically on fairness violations

### 🛡️ Safety & Citations Pipeline

Every message variant passes through 4-stage validation:

1. **Content Safety** — Azure AI Content Safety API (hate, violence, sexual, self-harm)
2. **Brand Policy** — Tone, forbidden terms, messaging standards
3. **Factual Accuracy** — Claims verification, citation checking
4. **Legal Compliance** — Disclaimers, regional regulations, FTC guidelines

### 🎛️ Human-in-the-Loop Studio UI

A full-featured web interface puts humans in control:

| Module | Function |
|--------|----------|
| **Graph Explorer** | Interactive visualization of segment relationships |
| **Segment Inspector** | Deep-dive into attributes, embeddings, beliefs |
| **Experiment Designer** | Design A/B/n tests with prior strategy selection |
| **Prior Tuning Panel** | Manual control: Auto / Fresh / Manual prior config |
| **Campaign Dashboard** | Real-time KPIs, ring progress, alerts |
| **Audit & Logs** | Full traceability for compliance |

---

## Architecture

### Design Principles

PRISMAgentic Studio v2.0 follows these architectural principles:

| Principle | Implementation |
|-----------|----------------|
| **Deterministic Hot Path** | Real-Time Decision Engine handles all assignments in code, not LLMs |
| **Separated Data Concerns** | Graph topology (Gremlin) separated from experiment state (NoSQL) |
| **Decoupled Analytics** | Fabric for analytics/training; Cosmos for operational decisions |
| **Defense in Depth** | Front Door + WAF + APIM + Private Endpoints |
| **Observable by Default** | Centralized telemetry for all components |
| **Infrastructure as Code** | 100% Bicep, deployed via azd CLI |

### Technology Stack

<div align="center">

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Edge** | ![Azure Front Door](https://img.shields.io/badge/Front%20Door-0078D4?style=flat-square&logo=microsoftazure&logoColor=white) | Global load balancing, WAF, DDoS protection |
| **API** | ![API Management](https://img.shields.io/badge/API%20Management-0078D4?style=flat-square&logo=microsoftazure&logoColor=white) | Gateway, rate limiting, OAuth 2.0 |
| **AI Agents** | ![AI Foundry](https://img.shields.io/badge/AI%20Foundry-5C2D91?style=flat-square&logo=microsoftazure&logoColor=white) | Multi-agent orchestration, GPT-4o |
| **Decisions** | ![Container Apps](https://img.shields.io/badge/Container%20Apps-0078D4?style=flat-square&logo=microsoftazure&logoColor=white) | Real-time Thompson Sampling |
| **Graph** | ![Cosmos DB](https://img.shields.io/badge/Cosmos%20DB-0078D4?style=flat-square&logo=microsoftazure&logoColor=white) | Gremlin API for segment graph |
| **State** | ![Cosmos DB](https://img.shields.io/badge/Cosmos%20DB-0078D4?style=flat-square&logo=microsoftazure&logoColor=white) | NoSQL API for experiment state |
| **Cache** | ![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat-square&logo=redis&logoColor=white) | Hot cache for <50ms latency |
| **Analytics** | ![Fabric](https://img.shields.io/badge/Fabric-117865?style=flat-square&logo=microsoftazure&logoColor=white) | Real-Time Intelligence, OneLake |
| **ML** | ![Azure ML](https://img.shields.io/badge/Azure%20ML-0078D4?style=flat-square&logo=microsoftazure&logoColor=white) | GNN training, Feature Store |
| **UI** | ![React](https://img.shields.io/badge/React-61DAFB?style=flat-square&logo=react&logoColor=black) | Static Web App |

</div>

### High-Level Overview
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USERS                                          │
│                   Marketer │ Data Scientist │ Customer Apps                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      EDGE & PROTECTION                                      │
│                    Azure Front Door + WAF                                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    ▼                                 ▼
┌───────────────────────────────┐    ┌───────────────────────────────────────┐
│     PRISMAgentic STUDIO UI    │    │           API GATEWAY                 │
│  Azure Static Web Apps + React│    │      Azure API Management             │
└───────────────────────────────┘    └───────────────────────────────────────┘
                                                      │
                              ┌───────────────────────┴───────────────────────┐
                              ▼                                               ▼
┌─────────────────────────────────────────┐    ┌──────────────────────────────────────┐
│      REAL-TIME DECISION ENGINE          │    │     AZURE AI FOUNDRY (Control Plane) │
│         (Deterministic Service)         │    │                                      │
│                                         │    │  ┌────────────────────────────────┐  │
│   ┌─────────────┐    ┌─────────────┐   │    │  │ ORCHESTRATION (4)              │  │
│   │ Container   │    │   Redis     │   │    │  │ Campaign Orchestrator          │  │
│   │ Apps        │◄──►│   Cache     │   │    │  │ Ring Progression               │  │
│   │             │    │             │   │    │  │ Experiment Conductor           │  │
│   │ Thompson    │    └─────────────┘   │    │  │ Safety Guardian                │  │
│   │ Sampling    │           │          │    │  └────────────────────────────────┘  │
│   │ + MAD       │           ▼          │    │  ┌────────────────────────────────┐  │
│   └─────────────┘    ┌─────────────┐   │    │  │ FUNCTIONAL (4)                 │  │
│         │            │ Experiment  │   │    │  │ Segment Analyst                │  │
│         └───────────►│ State       │   │    │  │ Content Retrieval              │  │
│                      │ (Cosmos)    │   │    │  │ Variant Generator              │  │
│   Latency: <50ms     └─────────────┘   │    │  │ Campaign Insights Co-Pilot     │  │
└─────────────────────────────────────────┘    │  └────────────────────────────────┘  │
                                               │  ┌────────────────────────────────┐  │
                                               │  │ ANALYTICAL (6) — Async         │  │
                                               │  │ Uplift Modeling                │  │
                                               │  │ Fair Uplift                    │  │
                                               │  │ XAI Insights                   │  │
                                               │  │ Health Gate                    │  │
                                               │  │ Segment Relationship           │  │
                                               │  │ Non-Stationarity               │  │
                                               │  └────────────────────────────────┘  │
                                               └──────────────────────────────────────┘
                                                              │
            ┌─────────────────────────────────────────────────┼─────────────────────────────────────────────────┐
            ▼                                                 ▼                                                 ▼
┌───────────────────────────┐            ┌───────────────────────────────────┐            ┌───────────────────────────┐
│    MICROSOFT FABRIC       │            │      AZURE MACHINE LEARNING       │            │     AZURE COSMOS DB       │
│      (Analytics)          │            │                                   │            │      (Restructured)       │
│                           │            │  ┌─────────────────────────────┐  │            │                           │
│  ┌─────────────────────┐  │            │  │     GNN Endpoint            │  │            │  ┌─────────────────────┐  │
│  │      OneLake        │  │            │  │     GraphSAGE 64-128D       │  │            │  │   SegmentGraph      │  │
│  │   (Delta Tables)    │  │            │  └─────────────────────────────┘  │            │  │   (Gremlin API)     │  │
│  └─────────────────────┘  │            │  ┌─────────────────────────────┐  │            │  │                     │  │
│  ┌─────────────────────┐  │            │  │   Feature Store             │  │            │  │ Nodes + Edges       │  │
│  │ Real-Time Intel     │  │            │  │   (Online + Offline)        │  │            │  │ Attrs + Embeddings  │  │
│  │ Eventstream         │  │            │  └─────────────────────────────┘  │            │  └─────────────────────┘  │
│  │ Eventhouse          │  │            │  ┌─────────────────────────────┐  │            │  ┌─────────────────────┐  │
│  │ Data Activator      │  │            │  │   Training Cluster          │  │            │  │  ExperimentState    │  │
│  └─────────────────────┘  │            │  │   GPU NC6s_v3               │  │            │  │  (NoSQL API)        │  │
│  ┌─────────────────────┐  │            │  └─────────────────────────────┘  │            │  │                     │  │
│  │ Fabric Data Agent   │  │            │                                   │            │  │ Betas + Counters    │  │
│  │ Fabric IQ           │  │            │                                   │            │  │ Real-time updates   │  │
│  └─────────────────────┘  │            │                                   │            │  └─────────────────────┘  │
└───────────────────────────┘            └───────────────────────────────────┘            └───────────────────────────┘
            │                                                 │                                                 │
            └─────────────────────────────────────────────────┼─────────────────────────────────────────────────┘
                                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                          CROSS-CUTTING CONCERNS                                                     │
│                                                                                                                     │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────────────────────┐│
│  │  DATA GOVERNANCE    │  │   OBSERVABILITY     │  │ SECURITY & IDENTITY │  │         DEVOPS & MLOPS              ││
│  │                     │  │                     │  │                     │  │                                     ││
│  │  Microsoft Purview  │  │  App Insights       │  │  Entra ID           │  │  GitHub Actions                     ││
│  │  • Data Catalog     │  │  Log Analytics      │  │  Key Vault          │  │  Bicep IaC                          ││
│  │  • Lineage          │  │  Azure Monitor      │  │  Managed Identities │  │  MLOps Pipelines                    ││
│  │  • PII Detection    │  │  Dashboards         │  │  Private Endpoints  │  │  Agent Registry                     ││
│  │                     │  │  Alerts             │  │  Defender for Cloud │  │                                     ││
│  └─────────────────────┘  └─────────────────────┘  └─────────────────────┘  └─────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### The 14 Specialized Agents (Control Plane)

| # | Agent | Group | Responsibility | Temp |
|---|-------|-------|----------------|------|
| 1 | Campaign Orchestrator | Orchestration | Coordinates all agents, manages lifecycle | 0.2 |
| 2 | Ring Progression | Orchestration | Controls progressive deployment rings | 0.0 |
| 3 | Experiment Conductor | Orchestration | Logs events, coordinates setup | 0.0 |
| 4 | Safety Guardian | Orchestration | 4-stage content validation | 0.0 |
| 5 | Segment Analyst | Functional | Profiles segment attributes | 0.3 |
| 6 | Content Retrieval | Functional | Retrieves brand assets via RAG | 0.1 |
| 7 | Variant Generator | Functional | Creates message variants | 0.7 |
| 8 | Campaign Insights Co-Pilot | Functional | Natural language Q&A | 0.5 |
| 9 | Uplift Modeling | Analytical | Calculates CATE treatment effects | 0.1 |
| 10 | Fair Uplift | Analytical | Monitors fairness metrics | 0.1 |
| 11 | XAI Insights | Analytical | Generates SHAP explanations | 0.3 |
| 12 | Health Gate | Analytical | Detects anomalies | 0.0 |
| 13 | Segment Relationship | Analytical | Transfer learning & similarities | 0.1 |
| 14 | Non-Stationarity | Analytical | Detects market drift | 0.1 |

> **Note:** The Bandit Optimizer is now a **deterministic service** (Real-Time Decision Engine), not an LLM agent. The Segment Relationship agent configures its parameters.

### Data Architecture (Restructured)
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AZURE COSMOS DB (Restructured)                       │
│                                                                             │
│  ┌─────────────────────────────────┐  ┌─────────────────────────────────┐  │
│  │        SegmentGraph             │  │       ExperimentState           │  │
│  │        (Gremlin API)            │  │        (NoSQL API)              │  │
│  │                                 │  │                                 │  │
│  │  Vertices:                      │  │  Documents:                     │  │
│  │  • segmentId                    │  │  • segmentId (partition key)    │  │
│  │  • attributes (Layer 1)         │  │  • experimentId                 │  │
│  │  • embedding (Layer 2)          │  │  • betas: {A: {α,β}, B: {α,β}}  │  │
│  │  • embedding_version            │  │  • counters: {impressions, ...} │  │
│  │                                 │  │  • metrics: {conversion_rate}   │  │
│  │  Edges:                         │  │  • _etag (optimistic concurrency)│  │
│  │  • similarity (weight)          │  │                                 │  │
│  │  • attr_sim, embed_sim, resp_sim│  │  Update: Real-time (per event)  │  │
│  │                                 │  │  Partition: segmentId           │  │
│  │  Update: Monthly / Post-campaign│  │  TTL: Experiment duration       │  │
│  └─────────────────────────────────┘  └─────────────────────────────────┘  │
│                                                                             │
│  WHY SEPARATED?                                                             │
│  • Different update frequencies (monthly vs. real-time)                     │
│  • Different query patterns (graph traversal vs. key-value lookup)          │
│  • Reduced RU/s consumption                                                 │
│  • Optimistic concurrency for high-frequency beta updates                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Event Flow (Decoupled)
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           EVENT FLOW (Decoupled)                            │
│                                                                             │
│   Customer        Decision       Event                                      │
│   Request         Engine         Stream         Analytics    Operational    │
│      │               │              │               │             │         │
│      │   assign      │              │               │             │         │
│      │──────────────►│              │               │             │         │
│      │               │              │               │             │         │
│      │◄──────────────│ variant      │               │             │         │
│      │               │              │               │             │         │
│      │               │──log event──►│               │             │         │
│      │               │              │               │             │         │
│      │               │              │───────────────┼────────────►│         │
│      │               │              │               │     Azure   │         │
│      │               │              │               │    Function │         │
│      │               │              │               │      │      │         │
│      │               │              │               │      ▼      │         │
│      │               │              │               │  ┌───────┐  │         │
│      │               │              │               │  │Cosmos │  │         │
│      │               │              │               │  │State  │  │         │
│      │               │              │               │  └───────┘  │         │
│      │               │              │               │      │      │         │
│      │               │              │               │      ▼      │         │
│      │               │◄─────────────┼───────────────┼───Redis     │         │
│      │               │  invalidate  │               │  invalidate │         │
│      │               │              │               │             │         │
│      │               │              │──────────────►│             │         │
│      │               │              │   Eventhouse  │             │         │
│      │               │              │   (analytics) │             │         │
│      │               │              │       │       │             │         │
│      │               │              │       ▼       │             │         │
│      │               │              │   Dashboards  │             │         │
│      │               │              │   Training    │             │         │
│                                                                             │
│   KEY PRINCIPLE: Decision Engine depends ONLY on Cosmos/Redis               │
│                  Fabric is for analytics/training, not operational          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Project Structure
```
prismagentic-studio/
│
├── 📁 .azure/                    # Azure Developer CLI configuration
│   ├── config.yaml
│   └── 📁 workflows/
│       ├── azure-dev.yml
│       └── ci-cd.yml
│
├── 📁 .devcontainer/             # VS Code Dev Container
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── post-create.sh
│
├── 📁 .github/                   # GitHub Actions & templates
│   ├── 📁 workflows/
│   │   ├── ci.yml
│   │   ├── cd-dev.yml
│   │   ├── cd-staging.yml
│   │   ├── cd-prod.yml
│   │   └── mlops.yml
│   ├── 📁 ISSUE_TEMPLATE/
│   └── CODEOWNERS
│
├── 📁 infra/                     # Infrastructure as Code (Bicep)
│   ├── main.bicep
│   ├── main.parameters.json
│   ├── abbreviations.json
│   │
│   ├── 📁 core/                  # Core Azure services
│   │   ├── ai-foundry.bicep
│   │   ├── api-management.bicep
│   │   ├── container-apps.bicep       
│   │   ├── cosmos-db.bicep         
│   │   ├── front-door.bicep      
│   │   ├── functions.bicep
│   │   ├── machine-learning.bicep
│   │   ├── openai.bicep
│   │   ├── redis.bicep
│   │   ├── signalr.bicep
│   │   └── static-web-app.bicep
│   │
│   ├── 📁 fabric/                # Microsoft Fabric resources
│   │   ├── workspace.bicep
│   │   ├── lakehouse.bicep
│   │   └── eventstream.bicep
│   │
│   ├── 📁 security/              # Security & identity
│   │   ├── entra-id.bicep
│   │   ├── key-vault.bicep
│   │   ├── managed-identities.bicep
│   │   ├── private-endpoints.bicep
│   │   └── defender.bicep             
│   │
│   ├── 📁 governance/            # Data governance
│   │   └── purview.bicep
│   │
│   ├── 📁 observability/         # Monitoring & alerting
│   │   ├── app-insights.bicep
│   │   ├── log-analytics.bicep
│   │   ├── monitor.bicep
│   │   └── dashboards.bicep
│   │
│   └── 📁 environments/          # Per-environment parameters
│       ├── dev.parameters.json
│       ├── staging.parameters.json
│       └── prod.parameters.json
│
├── 📁 src/
│   │
│   ├── 📁 decision-engine/       # Real-Time Decision Engine (Container Apps)
│   │   ├── 📁 src/
│   │   │   ├── main.py           # FastAPI application
│   │   │   ├── bandit.py         # Thompson Sampling + MAD
│   │   │   ├── cache.py          # Redis client
│   │   │   ├── cosmos.py         # Cosmos DB client
│   │   │   ├── models.py         # Pydantic schemas
│   │   │   └── config.py
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── 📁 tests/
│   │       ├── test_bandit.py
│   │       ├── test_assignment.py
│   │       └── test_latency.py
│   │
│   ├── 📁 agents/                # AI Foundry Agents (Control Plane)
│   │   ├── 📁 _shared/
│   │   │   ├── tools.py
│   │   │   ├── prompts.py
│   │   │   └── schemas.py
│   │   │
│   │   ├── 📁 orchestration/     # Orchestration agents (4)
│   │   │   ├── 📁 campaign_orchestrator/
│   │   │   │   ├── agent.yaml
│   │   │   │   ├── 📁 prompts/
│   │   │   │   └── 📁 tools/
│   │   │   ├── 📁 ring_progression/
│   │   │   ├── 📁 experiment_conductor/
│   │   │   └── 📁 safety_guardian/
│   │   │
│   │   ├── 📁 functional/        # Functional agents (4)
│   │   │   ├── 📁 segment_analyst/
│   │   │   ├── 📁 content_retrieval/
│   │   │   ├── 📁 variant_generator/
│   │   │   └── 📁 campaign_insights/
│   │   │
│   │   └── 📁 analytical/        # Analytical agents (6)
│   │       ├── 📁 uplift_modeling/
│   │       ├── 📁 fair_uplift/
│   │       ├── 📁 xai_insights/
│   │       ├── 📁 health_gate/
│   │       ├── 📁 segment_relationship/
│   │       │   └── 📁 tools/
│   │       │       └── transfer_config.py 
│   │       └── 📁 non_stationarity/
│   │
│   ├── 📁 api/                   # Azure Functions API
│   │   ├── 📁 functions/
│   │   │   ├── host.json
│   │   │   ├── local.settings.json
│   │   │   ├── requirements.txt
│   │   │   ├── 📁 update_experiment_state/
│   │   │   ├── 📁 invalidate_cache/
│   │   │   ├── 📁 get_graph/
│   │   │   ├── 📁 calculate_prior_preview/
│   │   │   └── 📁 health_check/
│   │   │
│   │   └── 📁 endpoints/
│   │       ├── openapi.yaml
│   │       └── 📁 policies/
│   │
│   ├── 📁 ml/                    # Machine Learning
│   │   ├── 📁 gnn/               # Graph Neural Network
│   │   │   ├── model.py          # GraphSAGE architecture
│   │   │   ├── train.py
│   │   │   ├── inference.py
│   │   │   ├── data.py
│   │   │   └── config.yaml
│   │   │
│   │   ├── 📁 feature_store/     # Azure ML Feature Store
│   │   │   ├── 📁 feature_sets/
│   │   │   │   ├── segment_features.yaml
│   │   │   │   ├── behavior_features.yaml
│   │   │   │   └── engagement_features.yaml
│   │   │   └── feature_retrieval.py
│   │   │
│   │   ├── 📁 pipelines/         # MLOps pipelines
│   │   │   ├── train_gnn.yaml
│   │   │   ├── update_embeddings.yaml
│   │   │   └── evaluate_model.yaml
│   │   │
│   │   └── 📁 environments/
│   │       └── training.yaml
│   │
│   └── 📁 ui/                    # React Frontend
│       ├── package.json
│       ├── tsconfig.json
│       ├── vite.config.ts
│       ├── 📁 public/
│       ├── 📁 src/
│       │   ├── main.tsx
│       │   ├── App.tsx
│       │   ├── 📁 components/
│       │   │   ├── 📁 graph/       # Graph Explorer
│       │   │   ├── 📁 experiment/  # Experiment Designer
│       │   │   ├── 📁 dashboard/   # Campaign Dashboard
│       │   │   ├── 📁 segment/     # Segment Inspector
│       │   │   ├── 📁 audit/       # Audit Logs
│       │   │   └── 📁 common/
│       │   ├── 📁 pages/
│       │   ├── 📁 hooks/
│       │   ├── 📁 services/
│       │   ├── 📁 stores/
│       │   └── 📁 types/
│       └── 📁 tests/
│
├── 📁 tests/
│   ├── 📁 unit/
│   │   ├── 📁 decision_engine/
│   │   ├── 📁 agents/
│   │   └── 📁 api/
│   │
│   ├── 📁 integration/
│   │   ├── test_cosmos_integration.py
│   │   ├── test_agent_orchestration.py
│   │   ├── test_decision_flow.py
│   │   └── conftest.py
│   │
│   ├── 📁 e2e/
│   │   ├── test_campaign_lifecycle.py
│   │   ├── test_transfer_learning.py
│   │   └── test_fairness_audit.py
│   │
│   ├── 📁 load/
│   │   ├── locustfile.py
│   │   ├── 📁 scenarios/
│   │   └── 📁 reports/
│   │
│   └── 📁 contracts/             # Agent contract tests
│       ├── 📁 agent_contracts/
│       └── validate_contracts.py
│
├── 📁 docs/
│   ├── 📁 architecture/
│   │   ├── overview.md
│   │   ├── decision-engine.md  
│   │   ├── agents.md
│   │   ├── data-model.md
│   │   └── 📁 diagrams/
│   │
│   ├── 📁 api/
│   │   ├── rest-api.md
│   │   ├── agent-contracts.md
│   │   └── events.md
│   │
│   ├── 📁 guides/
│   │   ├── getting-started.md
│   │   ├── deployment.md
│   │   ├── creating-campaigns.md
│   │   ├── prior-tuning.md
│   │   └── troubleshooting.md
│   │
│   ├── 📁 operations/       
│   │   ├── monitoring.md
│   │   ├── alerting.md
│   │   ├── backup-restore.md
│   │   └── disaster-recovery.md
│   │
│   ├── 📁 governance/   
│   │   ├── data-governance.md
│   │   ├── fairness-compliance.md
│   │   └── audit-requirements.md
│   │
│   └── 📁 images/
│
├── 📁 scripts/
│   ├── setup.sh
│   ├── deploy.sh
│   ├── seed-data.sh
│   ├── init-cosmos-graph.py
│   ├── seed-segments.py
│   ├── run-load-test.sh
│   └── export-audit.py
│
├── azure.yaml                    # Azure Developer CLI manifest
├── requirements.txt
├── pyproject.toml
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CHANGELOG.md
└── SECURITY.md
```

---

## Getting Started

### Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Azure Subscription** | — | With Owner or Contributor role |
| **Azure CLI** | ≥ 2.50 | [Install guide](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| **Azure Developer CLI** | ≥ 1.5 | [Install guide](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) |
| **Node.js** | ≥ 18 LTS | For frontend development |
| **Python** | ≥ 3.11 | For agents, ML, and Decision Engine |
| **Docker** | ≥ 24 | For dev container and Decision Engine |

### Recommended: Use Dev Container

The fastest way to get started is using our pre-configured dev container:
```bash
# Clone the repository
git clone https://github.com/your-org/prismagentic-studio.git
cd prismagentic-studio

# Open in VS Code with Dev Containers extension
code .
# Press F1 → "Dev Containers: Reopen in Container"
```

The dev container includes:

- Azure CLI + azd CLI pre-installed
- Python 3.11 with all dependencies
- Node.js 18 LTS
- Docker-in-Docker for local testing
- VS Code extensions for Bicep, Python, TypeScript
- Pre-configured linters and formatters

### Manual Setup
```bash
# 1. Clone repository
git clone https://github.com/your-org/prismagentic-studio.git
cd prismagentic-studio

# 2. Install Azure CLI & azd
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
curl -fsSL https://aka.ms/install-azd.sh | bash

# 3. Python environment
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 4. Node.js dependencies
cd src/ui && npm install && cd ../..

# 5. Login to Azure
az login
azd auth login
```

---

## Deployment

### Quick Deploy with Azure Developer CLI
```bash
# Initialize environment (first time only)
azd init

# Provision infrastructure + Deploy all services
azd up
```

This single command will:

1. ✅ Create Azure Front Door + WAF
2. ✅ Deploy Static Web App with React UI
3. ✅ Configure API Management
4. ✅ Deploy Real-Time Decision Engine (Container Apps)
5. ✅ Set up Azure AI Foundry with 14 agents
6. ✅ Create Cosmos DB (SegmentGraph + ExperimentState)
7. ✅ Provision Azure ML workspace + Feature Store
8. ✅ Configure Microsoft Fabric workspace
9. ✅ Set up Redis Cache
10. ✅ Deploy Azure Functions
11. ✅ Configure Purview for data governance
12. ✅ Set up observability (App Insights, Log Analytics)
13. ✅ Apply all security configurations

### Step-by-Step Deployment

#### Step 1: Configure Environment
```bash
# Create environment
azd env new dev

# Set required variables
azd env set AZURE_LOCATION eastus2
azd env set AZURE_SUBSCRIPTION_ID <your-subscription-id>
azd env set ENABLE_PRIVATE_ENDPOINTS false  # true for production
```

#### Step 2: Provision Infrastructure
```bash
azd provision
```

#### Step 3: Deploy Applications
```bash
azd deploy
```

#### Step 4: Initialize Data Layer
```bash
# Initialize Cosmos DB graph structure
python scripts/init-cosmos-graph.py

# Seed sample segments (optional, for testing)
python scripts/seed-segments.py --sample-data
```

#### Step 5: Train Initial GNN
```bash
# Submit training job
az ml job create --file src/ml/pipelines/train_gnn.yaml
```

#### Step 6: Verify Deployment
```bash
# Health check
curl https://<your-apim>.azure-api.net/api/health

# Or use azd
azd monitor
```

### Environment Configurations

| Environment | Private Endpoints | Redundancy | Feature Store | Purview |
|-------------|-------------------|------------|---------------|---------|
| **dev** | ❌ | ❌ | ❌ | ❌ |
| **staging** | ✅ | ❌ | ✅ | ❌ |
| **prod** | ✅ | ✅ | ✅ | ✅ |
```bash
# Deploy to specific environment
azd up --environment prod
```

---

## Usage

### Accessing the Studio

After deployment:
```
https://<your-static-web-app>.azurestaticapps.net
```

### API Examples

#### Get Variant Assignment (Real-Time)
```bash
POST /api/v1/assign
Content-Type: application/json
Authorization: Bearer <token>

{
  "customerId": "cust-12345",
  "segmentId": "gen-z-suburban",
  "experimentId": "exp-2847",
  "context": {
    "channel": "mobile",
    "timestamp": "2024-11-29T14:30:00Z"
  }
}

# Response (< 50ms)
{
  "assignmentId": "assign-67890",
  "variantId": "variant-b",
  "variantContent": "⏰ 24 hours only: 40% off + free shipping",
  "ring": 1,
  "debug": {
    "sampledTheta": 0.142,
    "beliefs": {"alpha": 71, "beta": 398},
    "cached": true
  }
}
```

#### Log Conversion
```bash
POST /api/v1/events/conversion
Content-Type: application/json

{
  "assignmentId": "assign-67890",
  "converted": true,
  "revenue": 49.99,
  "timestamp": "2024-11-29T15:45:00Z"
}
```

#### Query Segment Graph
```bash
GET /api/v1/segments/{segmentId}/neighbors?limit=5

# Response
{
  "segmentId": "gen-z-suburban",
  "neighbors": [
    {"segmentId": "gen-z-urban", "similarity": 0.75, "components": {...}},
    {"segmentId": "millennials-suburban", "similarity": 0.60, "components": {...}}
  ]
}
```

---

## Testing
```bash
# Unit tests
pytest tests/unit/ -v

# Integration tests (requires Azure)
pytest tests/integration/ -v --azure-env dev

# End-to-end tests
pytest tests/e2e/ -v

# Load tests
locust -f tests/load/locustfile.py --host https://<apim-gateway>

# Contract validation
python tests/contracts/validate_contracts.py
```

### Performance Requirements

| Metric | Target | Critical |
|--------|--------|----------|
| Assignment latency (p50) | < 20ms | < 50ms |
| Assignment latency (p99) | < 50ms | < 100ms |
| Throughput | > 10,000 req/s | > 5,000 req/s |
| Availability | 99.95% | 99.9% |

---

## Monitoring

### Pre-built Dashboards

Access via Azure Portal → Monitor → Dashboards:

- **Operations Dashboard:** Latency, throughput, errors
- **Agent Dashboard:** Per-agent metrics, token consumption
- **Campaign Dashboard:** Active experiments, ring status
- **Fairness Dashboard:** Audit results, violations

### Key Alerts

| Alert | Condition | Severity |
|-------|-----------|----------|
| High Latency | p99 > 100ms for 5 min | Warning |
| Error Rate | > 1% for 5 min | Critical |
| Fairness Violation | Any violation | Critical |
| Ring Blocked | > 3 blocked/hour | Warning |
| Token Budget | > 80% consumed | Warning |

### Log Queries (KQL)
```kusto
// Assignment latency percentiles
AppRequests
| where Name == "POST /api/v1/assign"
| summarize p50=percentile(DurationMs, 50), 
            p99=percentile(DurationMs, 99) 
  by bin(TimeGenerated, 5m)

// Agent errors by type
AgentLogs
| where Level == "Error"
| summarize count() by AgentName, ErrorType, bin(TimeGenerated, 1h)

// Fairness audit failures
FairnessAuditLogs
| where Status in ("WARNING", "VIOLATION")
| project TimeGenerated, ExperimentId, ProtectedAttribute, Metric, Value, Threshold
```

---

## Security

### Defense in Depth
```
Internet
    │
    ▼
┌─────────────────────────────────────┐
│  Azure Front Door + WAF             │  ← DDoS, L7 protection
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│  API Management                     │  ← Auth, rate limiting
│  (OAuth 2.0 + API keys)             │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│  Private VNet                       │  ← Network isolation
│  • Decision Engine                  │
│  • Azure Functions                  │
│  • Cosmos DB (Private Endpoint)     │
│  • Redis (Private Endpoint)         │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│  Managed Identities                 │  ← No secrets in code
│  Key Vault (RBAC)                   │  ← Secrets management
└─────────────────────────────────────┘
```

### Compliance

- ✅ GDPR-ready with Purview data classification
- ✅ Full audit trail in Fabric
- ✅ Fairness monitoring with auto-pause
- ✅ PII minimization in LLM prompts

---

## Troubleshooting

<details>
<summary><strong>Decision Engine latency > 50ms</strong></summary>

1. Check Redis cache hit rate: `az redis show --query 'cacheHitRate'`
2. Review Cosmos DB RU consumption in metrics
3. Verify ExperimentState partition key usage
4. Check Container Apps scaling settings
```bash
# Scale Decision Engine
az containerapp update --name decision-engine --min-replicas 3 --max-replicas 10
```

</details>

<details>
<summary><strong>Transfer learning not working</strong></summary>

1. Verify SegmentGraph has neighbors with similarity > 0.3
2. Check GNN endpoint health
3. Review Segment Relationship agent logs
4. Confirm embeddings are current (check `embedding_version`)
```bash
# Query neighbors manually
az cosmosdb gremlin query \
  --query "g.V('gen-z-suburban').outE('similar').inV().limit(5)"
```

</details>

<details>
<summary><strong>Agents not responding</strong></summary>

1. Check AI Hub connectivity
2. Verify OpenAI quota not exceeded
3. Review agent telemetry in App Insights
4. Check managed identity permissions
```bash
# View agent logs
az ml online-deployment get-logs --name campaign-orchestrator
```

</details>

---

## Roadmap

### v1.x (Current)

- [x] Transfer learning across segments
- [x] Adaptive bandits (MAD algorithm)
- [x] Progressive ring deployment
- [x] Fairness monitoring
- [x] Real-Time Decision Engine

### v2.x (Planned)

- [ ] Multi-channel orchestration (email, push, SMS, web)
- [ ] Counterfactual simulation ("what if" scenarios)
- [ ] Customer journey orchestration
- [ ] Digital twin audiences for pre-testing

### v3.x (Future)

- [ ] Multimodal variant generation (images, videos)
- [ ] Self-evolving agents
- [ ] Federated learning across organizations

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Code Standards

| Language | Formatter | Linter | Type Checking |
|----------|-----------|--------|---------------|
| Python | Black | Ruff | mypy (strict) |
| TypeScript | Prettier | ESLint | tsc (strict) |
| Bicep | Built-in | Bicep linter | — |

### PR Requirements

- [ ] All tests passing
- [ ] Coverage ≥ 80% for new code
- [ ] Agent contracts validated
- [ ] Documentation updated
- [ ] No secrets in code

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

<div align="center">

Built with the Microsoft Azure ecosystem:

[![Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com)
[![AI Foundry](https://img.shields.io/badge/Azure%20AI%20Foundry-5C2D91?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/products/ai-studio)
[![Fabric](https://img.shields.io/badge/Microsoft%20Fabric-117865?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://www.microsoft.com/microsoft-fabric)
[![Agent Framework](https://img.shields.io/badge/Microsoft%20Agent%20Framework-6B2D91?style=for-the-badge&logo=microsoft&logoColor=white)](https://learn.microsoft.com/agent-framework/)

Additional technologies:

[![PyTorch](https://img.shields.io/badge/PyTorch%20Geometric-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white)](https://pytorch-geometric.readthedocs.io/)
[![React](https://img.shields.io/badge/React-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://react.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)

</div>

---

<div align="center">

**PRISMAgentic Studio** — *Marketing that learns, adapts, and respects.*

[Report Bug](https://github.com/your-org/prismagentic-studio/issues) • [Request Feature](https://github.com/your-org/prismagentic-studio/issues) • [Documentation](./docs/)

</div>