# Azure Enterprise Hub & Spoke Infrastructure Model

This repository contains a production-ready, highly reusable **Infrastructure as Code (IaC)** blueprint using **Terraform**. It implements a custom parent-child modular topology tailored for an Azure Enterprise Landing Zone environment.

The architecture decouples core networking capabilities (firewalls, gateways, shared DNS) managed by Central IT from isolated application zones (Spokes) handed off to individual workload development teams.

---

## 🏗️ Architecture Design Overview

The deployment follows a hierarchical layout configured completely through decoupled child modules:

1. **Central Hub Network:** Houses security boundaries, egress traffic engines (`AzureFirewallSubnet`), and on-premises cross-premises integration layers (`GatewaySubnet`).
2. **Autonomous Spokes:** Reusable virtual networks provisioned with decoupled tier subnets for App and DB microservices.
3. **Transit Peering:** Automated bidirectional virtual network peering allowing data-center transit while retaining explicit isolation from neighboring spokes.

---

## 📂 Repository Directory Structure

```text
├── README.md               # Architecture definition & onboarding documentation
├── .gitignore              # Safeguards against committing local provider caches & state files
├── main.tf                 # Parent/Root Configuration (Orchestrates infrastructure)
├── variables.tf            # Global Parent Input Variables
├── outputs.tf              # Aggregated Stack Outputs
└── modules/
    ├── hub_network/        # Child Module: Centralized Infrastructure Shared Boundary
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── spoke_network/      # Child Module: Reusable Application Sandbox Template
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## ⚙️ Network Address Space Map

To prevent overlapping address spaces and operational traffic collisions, the default environment uses the following allocation layout:

| Network Segment | Target Layer Allocation | Purpose / Component |
| :--- | :--- | :--- |
| **Hub Core Space** | `10.100.0.0/16` | Global Hub Network Management |
| ↳ *Firewall Segment* | `10.100.1.0/24` | `AzureFirewallSubnet` Edge Inspection |
| ↳ *Gateway Segment* | `10.100.2.0/24` | `GatewaySubnet` On-Prem ExpressRoute/VPN |
| **Spoke A (HR App)** | `10.101.0.0/16` | App Sandbox Environment 01 |
| **Spoke B (Finance App)**| `10.102.0.0/16` | App Sandbox Environment 02 |

---

## 🚀 Quickstart Local Deployment Guide

### Prerequisites
* [Terraform CLI](https://hashicorp.com) installed locally (v1.3+ recommended).
* [Azure CLI](https://microsoft.com) authenticated against your corporate Azure Tenant.
* Elevated permissions at your target Subscriptions to handle Virtual Network Peerings (`Network Contributor` minimal role).

### Local Execution Workflow

1. **Clone the Repository:**
   ```bash
   git clone https://github.com
   cd Hub_Spoke_Model
   ```

2. **Authenticate with Azure:**
   ```bash
   az login
   az account set --subscription "YOUR_TARGET_SUBSCRIPTION_ID"
   ```

3. **Initialize the Workspace:**
   *Downloads providers and parses child modules. Local cache is stored safely outside version control via `.gitignore` settings.*
   ```bash
   terraform init
   ```

4. **Review Structural Changes:**
   ```bash
   terraform plan
   ```

5. **Deploy the Topology:**
   ```bash
   terraform apply
   ```

---

## ⚠️ Important Governance Practices

* **State Security:** Do not run production deployments using a local backend state (`.tfstate`). Migrate this parent stack to an authenticated **Remote Azure Storage Account Backend** before sharing code across multiple engineers.
* **Network Expansion:** When initializing a new application workload, pick a fresh, non-conflicting `/16` or `/22` block to prevent peering validation errors within the root `main.tf` mapping layer.