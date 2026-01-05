# GitHub GitOps Infrastructure Deployment Architecture

## Terraform/Terragrunt Based Azure Infrastructure

## Executive Summary

This document outlines a high-level architecture for deploying Azure infrastructure using GitHub Actions with GitOps principles, leveraging Terraform for infrastructure as code and Terragrunt for configuration management. The solution supports multi-environment deployments (dev, stage, prod) with full parameterization for regions, resource names, and tags.

---

## 1. Architecture Overview

### 1.1 GitOps Flow Diagram

┌────────────────────────────────────────────────────┐
│                         GitHub Repository                                                                                                    │
├────────────────────────────────────────────────────┤
│                                                                                                                                                                  │
│  Developer → Push/PR → main branch → GitHub Actions → Azure                                  │
│                                                              ↓                                   ↓                                                         │
│                                                 Branch Protection    Terraform Apply                                          │
│                                                         + Reviews                      (GitOps)                                                │
└──────────────────────────────────────────────-──────┘

|     |                                                                                                                          |
| --- | ------------------------------------------------------------------------------------------------------------------------ |
|     | GitOps Principles Applied                                                                                                |
|     | 1. Git as Single Source of Truth                               <br>     └─ All infrastructure defined in version control |
|     | 2. Declarative Configuration                                    <br>     └─ Terraform describes desired state            |
|     | 3. Automated Deployment                                         <br>    └─ GitHub Actions automatically applies changes  |
|     | 4. Continuous Reconciliation                                    <br>    └─ Drift detection and automated remediation     |
|     | 5. Immutable Infrastructure                                     <br>    └─ Changes via code, not manual modifications    |


### 1.2 Component Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      GitHub Repository                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │               Repository Structure                      │    │
│  ├─────────────────────────────────────────────────────────┤    │
│  │  /terraform/                                            │    │
│  │    ├── modules/                    # Reusable modules   │    │
│  │    │   ├── resource-group/                              │    │
│  │    │   ├── app-service/                                 │    │
│  │    │   ├── sql-server/                                  │    │
│  │    │   ├── redis-cache/                                 │    │
│  │    │   ├── storage-account/                             │    │
│  │    │   ├── key-vault/                                   │    │
│  │    │   └── app-insights/                                │    │
│  │    │                                                    │    │
│  │    ├── environments/              # Environment configs │    │
│  │    │   ├── dev/                                         │    │
│  │    │   │   ├── terragrunt.hcl                           │    │
│  │    │   │   └── terraform.tfvars                         │    │
│  │    │   ├── stage/                                       │    │
│  │    │   │   ├── terragrunt.hcl                           │    │
│  │    │   │   └── terraform.tfvars                         │    │
│  │    │   └── prod/                                        │    │
│  │    │       ├── terragrunt.hcl                           │    │
│  │    │       └── terraform.tfvars                         │    │
│  │    │                                                    │    │
│  │    ├── backend.tf                  # Remote state config│    │
│  │    ├── providers.tf                # Provider config    │    │
│  │    ├── main.tf                     # Root module        │    │
│  │    ├── variables.tf                # Input variables    │    │
│  │    └── outputs.tf                  # Output values      │    │
│  │                                                         │    │
│  │  /.github/                                              │    │
│  │    └── workflows/                  # GitHub Actions     │    │
│  │        ├── terraform-plan.yml      # PR validation      │    │
│  │        ├── terraform-apply.yml     # Deployment         │    │
│  │        └── drift-detection.yml     # Scheduled checks   │    │
│  │                                                         │    │
│  │  /terragrunt.hcl                   # Root Terragrunt    │    │
│  │  /README.md                        # Documentation      │    │
│  │  /.gitignore                       # Git ignore rules   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      GitHub Actions                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Pull Request → [Terraform Plan] → Review → Merge               │
│                        ↓                       ↓                │
│                  Comments on PR         [Terraform Apply]       │
│                                                ↓                │
│                                            Update Azure         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Azure Infrastructure                         │
├─────────────────────────────────────────────────────────────────┤
│  [Dev Environment] [Stage Environment] [Prod Environment]       │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Azure Resource Architecture Per Environment

```
┌────────────────────────────────────────────────────────────────┐
│           Resource Group: rg-{app}-{env}-{region}              │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  App Service Plan: asp-{app}-{env}-{region}              │  │
│  │  ├─ SKU: Terraform variable per environment              │  │
│  │  └─ Managed via: terraform/modules/app-service           │  │
│  │                                                          │  │
│  │  App Service: app-{app}-{env}-{region}                   │  │
│  │  ├─ App Settings: Injected from Key Vault references     │  │
│  │  ├─ Managed Identity: Enabled                            │  │
│  │  └─ Tags: From terraform.tfvars                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SQL Server: sql-{app}-{env}-{region}                    │  │
│  │  ├─ Admin: From GitHub Secrets                           │  │
│  │  ├─ AAD Authentication: Enabled                          │  │
│  │  │                                                       │  │
│  │  SQL Database: sqldb-{app}-{env}                         │  │
│  │  ├─ SKU: Variable per environment                        │  │
│  │  └─ Lifecycle: Managed by Terraform state                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Redis Cache: redis-{app}-{env}-{region}                 │  │
│  │  └─ Configuration: Terragrunt DRY approach               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Storage Account: st{app}{env}{region}                   │  │
│  │  └─ Containers: Defined in Terraform list variable       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Key Vault: kv-{app}-{env}-{region}                      │  │
│  │  ├─ Secrets: Managed by Terraform                        │  │
│  │  ├─ Access: GitHub Actions OIDC + App MSI                │  │
│  │  └─ Soft Delete: Enabled via Terraform                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Application Insights: appi-{app}-{env}-{region}         │  │
│  │  └─ Workspace: Linked to Log Analytics                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                │
└────────────────────────────────────────────────────────────────┘

All resources tracked in Terraform state stored in Azure Storage
```

---

## 2. Terraform/Terragrunt Structure

### 2.1 Directory Layout

```
repository-root/
│
├── terraform/
│   ├── modules/                        # Reusable Terraform modules
│   │   ├── resource-group/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── app-service/
│   │   │   ├── main.tf                 # App Service Plan + App Service
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── sql-server/
│   │   │   ├── main.tf                 # SQL Server + Database
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── redis-cache/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── storage-account/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── key-vault/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   └── app-insights/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   ├── environments/                   # Environment-specific configs
│   │   ├── dev/
│   │   │   ├── terragrunt.hcl         # Terragrunt config for dev
│   │   │   └── terraform.tfvars       # Dev variables
│   │   │
│   │   ├── stage/
│   │   │   ├── terragrunt.hcl
│   │   │   └── terraform.tfvars
│   │   │
│   │   └── prod/
│   │       ├── terragrunt.hcl
│   │       └── terraform.tfvars
│   │
│   ├── main.tf                         # Root module - orchestrates all
│   ├── variables.tf                    # Root variables
│   ├── outputs.tf                      # Root outputs
│   ├── providers.tf                    # Provider configuration
│   └── backend.tf                      # State backend config
│
├── terragrunt.hcl                      # Root Terragrunt config
│
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml          # Plan on PR
│       ├── terraform-apply.yml         # Apply on merge
│       ├── drift-detection.yml         # Scheduled drift check
│       └── terraform-destroy.yml       # Manual destroy (protected)
│
├── .gitignore
├── README.md
└── ARCHITECTURE.md
```

### 2.2 Terragrunt Configuration Pattern

**Root terragrunt.hcl** (DRY configuration):

```hcl
# Configure remote state backend
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate${get_env("ENVIRONMENT", "dev")}"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    use_oidc            = true
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  use_oidc = true
}
EOF
}

# Common inputs for all environments
inputs = {
  resource_prefix = "myapp"
}
```

**Environment-specific terragrunt.hcl** (e.g., `environments/dev/terragrunt.hcl`):

```hcl
# Include root configuration
include "root" {
  path = find_in_parent_folders()
}

# Point to root Terraform module
terraform {
  source = "../../"
}

# Environment-specific inputs
inputs = {
  environment = "dev"
  region      = "eastus"
  
  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Repository  = "github.com/org/repo"
    CostCenter  = "Engineering"
  }
  
  # Resource-specific configurations
  app_service_plan_sku = "B1"
  sql_database_sku     = "Basic"
  redis_cache_sku      = "Basic"
  redis_cache_capacity = 0
  storage_account_tier = "Standard"
  storage_replication  = "LRS"
  
  # Feature flags
  enable_private_endpoints = false
  enable_auto_scaling     = false
  
  # Backup settings
  sql_backup_retention_days = 7
}
```

### 2.3 Terraform Module Example

**modules/app-service/main.tf**:

```hcl
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.resource_prefix}-${var.environment}-${var.region}"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  os_type  = var.os_type
  sku_name = var.sku_name
  
  tags = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.resource_prefix}-${var.environment}-${var.region}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id
  
  site_config {
    always_on = var.always_on
    
    application_stack {
      node_version = var.node_version
    }
  }
  
  app_settings = merge(
    var.app_settings,
    {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = var.app_insights_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    }
  )
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

# Key Vault access for App Service MSI
resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_linux_web_app.main.identity[0].tenant_id
  object_id    = azurerm_linux_web_app.main.identity[0].principal_id
  
  secret_permissions = [
    "Get",
    "List"
  ]
}
```

---

## 3. GitHub Actions GitOps Workflows

### 3.1 Workflow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflows                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Pull Request Workflow (terraform-plan.yml)                  │
│     ┌──────────────────────────────────────────────────────┐    │
│     │ Trigger: Pull Request to main                        │    │
│     │                                                      │    │
│     │ Jobs:                                                │    │
│     │ ├─ Checkout code                                     │    │
│     │ ├─ Setup Terraform                                   │    │
│     │ ├─ Setup Terragrunt                                  │    │
│     │ ├─ Authenticate to Azure (OIDC)                      │    │
│     │ ├─ Terraform Format Check                            │    │
│     │ ├─ Terraform Validate                                │    │
│     │ ├─ Terragrunt Plan (per environment)                 │    │
│     │ ├─ Security Scan (Checkov/tfsec)                     │    │
│     │ ├─ Cost Estimation (Infracost)                       │    │
│     │ └─ Comment Plan Output on PR                         │    │
│     └──────────────────────────────────────────────────────┘    │
│                                                                 │
│  2. Deployment Workflow (terraform-apply.yml)                   │
│     ┌──────────────────────────────────────────────────────┐    │
│     │ Trigger: Push to main (after PR merge)               │    │
│     │                                                      │    │
│     │ Jobs:                                                │    │
│     │ ├─ Deploy to Dev (auto)                              │    │
│     │ │  └─ Terragrunt apply --auto-approve                │    │
│     │ │                                                    │    │
│     │ ├─ Deploy to Stage (requires approval)               │    │
│     │ │  ├─ Environment: staging                           │    │
│     │ │  ├─ Reviewers: required                            │    │
│     │ │  └─ Terragrunt apply --auto-approve                │    │
│     │ │                                                    │    │
│     │ └─ Deploy to Prod (requires approval)                │    │
│     │    ├─ Environment: production                        │    │
│     │    ├─ Reviewers: 2 required                          │    │
│     │    └─ Terragrunt apply --auto-approve                │    │
│     └──────────────────────────────────────────────────────┘    │
│                                                                 │
│  3. Drift Detection Workflow (drift-detection.yml)              │
│     ┌──────────────────────────────────────────────────────┐    │
│     │ Trigger: Schedule (daily at 6 AM UTC)                │    │
│     │                                                      │    │
│     │ Jobs:                                                │    │
│     │ ├─ Run Terraform Plan (all environments)             │    │
│     │ ├─ Detect configuration drift                        │    │
│     │ ├─ Create GitHub Issue if drift detected             │    │
│     │ └─ Send notification (Slack/Teams)                   │    │
│     └──────────────────────────────────────────────────────┘    │
│                                                                 │
│  4. Destroy Workflow (terraform-destroy.yml)                    │
│     ┌──────────────────────────────────────────────────────┐    │
│     │ Trigger: Manual workflow_dispatch only               │    │
│     │                                                      │    │
│     │ Jobs:                                                │    │
│     │ ├─ Require manual confirmation                       │    │
│     │ ├─ Multiple approval gates                           │    │
│     │ └─ Terragrunt destroy (selected environment)         │    │
│     └──────────────────────────────────────────────────────┘    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Terraform Plan Workflow (PR Validation)

**.github/workflows/terraform-plan.yml**:

```yaml
name: 'Terraform Plan'

on:
  pull_request:
    branches:
      - main
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform-plan.yml'

env:
  TF_VERSION: '1.6.0'
  TG_VERSION: '0.54.0'
  ARM_USE_OIDC: true

permissions:
  id-token: write
  contents: read
  pull-requests: write

jobs:
  terraform-plan:
    name: 'Terraform Plan - ${{ matrix.environment }}'
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        environment: [dev, stage, prod]
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Setup Terragrunt
        run: |
          wget https://github.com/gruntwork-io/terragrunt/releases/download/v${{ env.TG_VERSION }}/terragrunt_linux_amd64
          chmod +x terragrunt_linux_amd64
          sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
      
      - name: Azure Login (OIDC)
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets[format('AZURE_SUBSCRIPTION_ID_{0}', matrix.environment)] }}
      
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
        working-directory: ./terraform
      
      - name: Terragrunt Init
        run: terragrunt init
        working-directory: ./terraform/environments/${{ matrix.environment }}
      
      - name: Terragrunt Validate
        run: terragrunt validate
        working-directory: ./terraform/environments/${{ matrix.environment }}
      
      - name: Terragrunt Plan
        id: plan
        run: |
          terragrunt plan -out=tfplan -no-color | tee plan.txt
          echo "plan_output<<EOF" >> $GITHUB_OUTPUT
          cat plan.txt >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT
        working-directory: ./terraform/environments/${{ matrix.environment }}
        continue-on-error: true
      
      - name: Security Scan with Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: terraform/
          framework: terraform
          output_format: github_failed_only
      
      - name: Cost Estimation with Infracost
        uses: infracost/actions/setup@v2
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}
      
      - name: Generate Infracost Report
        run: |
          cd terraform/environments/${{ matrix.environment }}
          infracost breakdown --path . --format github-comment --out-file /tmp/infracost.txt
      
      - name: Comment Plan on PR
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `### Terraform Plan - ${{ matrix.environment }}
            
            #### Format Check 🖌\`${{ steps.fmt.outcome }}\`
            #### Validation 🤖\`${{ steps.validate.outcome }}\`
            #### Plan 📖\`${{ steps.plan.outcome }}\`
            
            <details><summary>Show Plan</summary>
            
            \`\`\`terraform
            ${{ steps.plan.outputs.plan_output }}
            \`\`\`
            
            </details>
            
            *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })
```

### 3.3 Terraform Apply Workflow (Deployment)

**.github/workflows/terraform-apply.yml**:

```yaml
name: 'Terraform Apply'

on:
  push:
    branches:
      - main
    paths:
      - 'terraform/**'
  workflow_dispatch:

env:
  TF_VERSION: '1.6.0'
  TG_VERSION: '0.54.0'
  ARM_USE_OIDC: true

permissions:
  id-token: write
  contents: read
  issues: write

jobs:
  deploy-dev:
    name: 'Deploy to Development'
    runs-on: ubuntu-latest
    environment: development
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Setup Terragrunt
        run: |
          wget https://github.com/gruntwork-io/terragrunt/releases/download/v${{ env.TG_VERSION }}/terragrunt_linux_amd64
          chmod +x terragrunt_linux_amd64
          sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
      
      - name: Azure Login (OIDC)
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID_DEV }}
      
      - name: Terragrunt Apply
        run: terragrunt apply -auto-approve
        working-directory: ./terraform/environments/dev
      
      - name: Smoke Tests
        run: |
          # Run basic health checks
          echo "Running smoke tests..."
          # Add your smoke test commands here

  deploy-stage:
    name: 'Deploy to Staging'
    runs-on: ubuntu-latest
    needs: deploy-dev
    environment:
      name: staging
      url: https://app-myapp-stage-eastus.azurewebsites.net
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Setup Terragrunt
        run: |
          wget https://github.com/gruntwork-io/terragrunt/releases/download/v${{ env.TG_VERSION }}/terragrunt_linux_amd64
          chmod +x terragrunt_linux_amd64
          sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
      
      - name: Azure Login (OIDC)
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID_STAGE }}
      
      - name: Terragrunt Apply
        run: terragrunt apply -auto-approve
        working-directory: ./terraform/environments/stage
      
      - name: Integration Tests
        run: |
          echo "Running integration tests..."
          # Add your integration test commands here

  deploy-prod:
    name: 'Deploy to Production'
    runs-on: ubuntu-latest
    needs: deploy-stage
    environment:
      name: production
      url: https://app-myapp-prod-eastus.azurewebsites.net
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Setup Terragrunt
        run: |
          wget https://github.com/gruntwork-io/terragrunt/releases/download/v${{ env.TG_VERSION }}/terragrunt_linux_amd64
          chmod +x terragrunt_linux_amd64
          sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
      
      - name: Azure Login (OIDC)
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID_PROD }}
      
      - name: Terragrunt Apply
        run: terragrunt apply -auto-approve
        working-directory: ./terraform/environments/prod
      
      - name: Smoke Tests
        run: |
          echo "Running production smoke tests..."
          # Add your smoke test commands here
      
      - name: Create Deployment Tag
        run: |
          git tag "release-$(date +%Y%m%d-%H%M%S)"
          git push origin --tags
```

### 3.4 Drift Detection Workflow

**.github/workflows/drift-detection.yml**:

```yaml
name: 'Drift Detection'

on:
  schedule:
    - cron: '0 6 * * *'  # Daily at 6 AM UTC
  workflow_dispatch:

env:
  TF_VERSION: '1.6.0'
  TG_VERSION: '0.54.0'
  ARM_USE_OIDC: true

permissions:
  id-token: write
  contents: read
  issues: write

jobs:
  detect-drift:
    name: 'Detect Drift - ${{ matrix.environment }}'
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        environment: [dev, stage, prod]
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Setup Terragrunt
        run: |
          wget https://github.com/gruntwork-io/terragrunt/releases/download/v${{ env.TG_VERSION }}/terragrunt_linux_amd64
          chmod +x terragrunt_linux_amd64
          sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
      
      - name: Azure Login (OIDC)
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets[format('AZURE_SUBSCRIPTION_ID_{0}', matrix.environment)] }}
      
      - name: Terragrunt Plan (Detect Drift)
        id: drift
        run: |
          terragrunt plan -detailed-exitcode -no-color | tee drift.txt
          echo "drift_detected=$?" >> $GITHUB_OUTPUT
        working-directory: ./terraform/environments/${{ matrix.environment }}
        continue-on-error: true
      
      - name: Create Issue if Drift Detected
        if: steps.drift.outputs.drift_detected == '2'
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const driftOutput = require('fs').readFileSync('terraform/environments/${{ matrix.environment }}/drift.txt', 'utf8');
            
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Configuration Drift Detected - ${{ matrix.environment }}`,
              body: `### ⚠️ Drift Detection Alert
              
              Configuration drift has been detected in the **${{ matrix.environment }}** environment.
              
              This means the actual Azure infrastructure state differs from what's defined in the Terraform code.
              
              <details><summary>Show Drift Details</summary>
              
              \`\`\`terraform
              ${driftOutput}
              \`\`\`
              
              </details>
              
              **Action Required:**
              1. Review the drift details above
              2. Either:
                 - Update Terraform code to match current state, OR
                 - Apply Terraform to remediate the drift
              
              **Environment:** ${{ matrix.environment }}
              **Detected:** ${new Date().toISOString()}
              **Workflow:** [Link](https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }})`,
              labels: ['infrastructure', 'drift-detected', '${{ matrix.environment }}']
            });
```

---

## 4. GitHub Repository Configuration

### 4.1 Required GitHub Secrets

Configure these secrets in GitHub repository settings:

```
Organization/Repository Secrets:
├── AZURE_CLIENT_ID              # Service Principal Client ID
├── AZURE_TENANT_ID              # Azure AD Tenant ID
├── AZURE_SUBSCRIPTION_ID_DEV    # Dev subscription ID
├── AZURE_SUBSCRIPTION_ID_STAGE  # Stage subscription ID
├── AZURE_SUBSCRIPTION_ID_PROD   # Prod subscription ID
├── INFRACOST_API_KEY           # (Optional) For cost estimation
└── SLACK_WEBHOOK_URL           # (Optional) For notifications
```

### 4.2 GitHub Environments Configuration

Create protected environments in GitHub:

```
Environments:
├── development
│   ├── No approval required
│   ├── Deployment branches: main only
│   └── Secrets: DEV-specific values
│
├── staging
│   ├── Required reviewers: 1
│   ├── Wait timer: 0 minutes
│   ├── Deployment branches: main only
│   └── Secrets: STAGE-specific values
│
└── production
    ├── Required reviewers: 2
    ├── Wait timer: 5 minutes
    ├── Deployment branches: main only
    ├── Secrets: PROD-specific values
    └── Protection rules: Prevent self-review
```

### 4.3 Branch Protection Rules

Configure branch protection for `main`:

```
Branch Protection Rules (main):
├── ✅ Require pull request before merging
│   ├── Required approvals: 1
│   └── Dismiss stale reviews
├── ✅ Require status checks to pass
│   ├── terraform-plan (dev)
│   ├── terraform-plan (stage)
│   └── terraform-plan (prod)
├── ✅ Require conversation resolution
├── ✅ Require linear history
├── ✅ Include administrators
└── ✅ Do not allow bypassing settings
```

---

## 5. Azure OIDC Authentication Setup

### 5.1 Federated Identity Configuration

```
Azure AD Configuration:
├── Create App Registration
│   └── Name: github-actions-terraform
│
├── Create Federated Credentials
│   ├── For PR validation:
│   │   ├── Subject: repo:org/repo:pull_request
│   │   └── Audience: api://AzureADTokenExchange
│   │
│   ├── For main branch deployment:
│   │   ├── Subject: repo:org/repo:ref:refs/heads/main
│   │   └── Audience: api://AzureADTokenExchange
│   │
│   └── For environment-specific:
│       ├── Subject: repo:org/repo:environment:production
│       └── Audience: api://AzureADTokenExchange
│
└── Assign Azure Roles
    ├── Dev Subscription: Contributor
    ├── Stage Subscription: Contributor
    └── Prod Subscription: Contributor
```

### 5.2 Benefits of OIDC vs Service Principal Secrets

```
✅ No long-lived credentials stored in GitHub
✅ Automatic token rotation
✅ Fine-grained access control per environment
✅ Audit trail in Azure AD
✅ Reduced security risk
✅ Compliance-friendly
```

---

## 6. Terraform State Management

### 6.1 Remote State Backend

**Backend Configuration** (generated by Terragrunt):

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstatedev"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
    use_oidc            = true
  }
}
```

### 6.2 State Storage Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│              Azure Storage Account (State Backend)               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Storage Account: sttfstate{env}                                │
│  ├── Location: Same as primary resources                        │
│  ├── Replication: GRS (Geo-Redundant)                           │
│  ├── Access: Private endpoint + Service Principal only          │
│  ├── Versioning: Enabled                                        │
│  ├── Soft Delete: 30 days retention                             │
│  └── Lock: CanNotDelete                                         │
│                                                                 │
│  Container: tfstate                                             │
│  ├── dev/terraform.tfstate                                      │
│  ├── stage/terraform.tfstate                                    │
│  └── prod/terraform.tfstate                                     │
│                                                                 │
│  State Locking:                                                 │
│  └── Azure Storage native blob leasing                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Separate state files per environment = Isolation & Safety
```

---

## 7. GitOps Workflow & Processes

### 7.1 Development Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                     Developer Workflow                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Create Feature Branch                                       │
│     └─ git checkout -b feature/add-redis-cache                  │
│                                                                 │
│  2. Make Infrastructure Changes                                 │
│     ├─ Edit: terraform/modules/redis-cache/main.tf              │
│     ├─ Edit: terraform/environments/dev/terraform.tfvars        │
│     └─ Test locally: terragrunt plan                            │
│                                                                 │
│  3. Commit and Push                                             │
│     ├─ git add .                                                │
│     ├─ git commit -m "Add Redis cache configuration"            │
│     └─ git push origin feature/add-redis-cache                  │
│                                                                 │
│  4. Create Pull Request                                         │
│     └─ GitHub UI → Create PR to main                            │
│                                                                 │
│  5. Automated Checks Run (GitHub Actions)                       │
│     ├─ Terraform format check                                   │
│     ├─ Terraform validate                                       │
│     ├─ Terragrunt plan (all environments)                       │
│     ├─ Security scan (Checkov)                                  │
│     ├─ Cost estimation (Infracost)                              │
│     └─ Results commented on PR                                  │
│                                                                 │
│  6. Code Review                                                 │
│     ├─ Team reviews infrastructure changes                      │
│     ├─ Review Terraform plan output                             │
│     └─ Approve PR                                               │
│                                                                 │
│  7. Merge to Main                                               │
│     └─ Squash and merge → Triggers deployment workflow          │
│                                                                 │
│  8. Automated Deployment                                        │
│     ├─ Dev: Auto-deploys immediately                            │
│     ├─ Stage: Requires 1 approval                               │
│     └─ Prod: Requires 2 approvals + wait timer                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Emergency Change Process

```
Emergency/Hotfix Process:
├── 1. Create hotfix branch from main
├── 2. Make minimal required changes
├── 3. Create PR with "HOTFIX:" prefix
├── 4. Fast-track review (1 senior approver)
├── 5. Merge and deploy
└── 6. Post-incident review and documentation
```

### 7.3 Rollback Process

```
Rollback Options:
├── Option 1: Git Revert
│   ├─ git revert <commit-hash>
│   ├─ Create PR with revert
│   └─ Follow normal deployment process
│
├── Option 2: Manual Terraform State
│   ├─ Check out previous working commit
│   ├─ Run terragrunt apply manually
│   └─ Document the manual intervention
│
└── Option 3: Import Existing Resources
    ├─ terraform import (if resources exist)
    ├─ Reconcile state
    └─ Commit corrected state
```

---

## 8. Environment-Specific Configurations

### 8.1 Development Environment

**terraform/environments/dev/terraform.tfvars**:

```hcl
# Development Environment Configuration

environment = "dev"
region      = "eastus"

tags = {
  Environment = "Development"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
  AutoShutdown = "Enabled"
}

# App Service
app_service_plan_sku = "B1"
app_service_always_on = false

# SQL Database
sql_database_sku = "Basic"
sql_backup_retention_days = 7
sql_geo_redundant_backup = false

# Redis Cache
redis_cache_sku = "Basic"
redis_cache_family = "C"
redis_cache_capacity = 0

# Storage Account
storage_account_tier = "Standard"
storage_account_replication = "LRS"
storage_containers = ["uploads", "logs"]

# Key Vault
key_vault_sku = "standard"

# Feature Flags
enable_private_endpoints = false
enable_auto_scaling = false
enable_advanced_threat_protection = false

# Scaling
app_service_min_instances = 1
app_service_max_instances = 1
```

### 8.2 Staging Environment

**terraform/environments/stage/terraform.tfvars**:

```hcl
# Staging Environment Configuration

environment = "stage"
region      = "eastus"

tags = {
  Environment = "Staging"
  ManagedBy   = "Terraform"
  CostCenter  = "Operations"
}

# App Service
app_service_plan_sku = "P1v3"
app_service_always_on = true

# SQL Database
sql_database_sku = "S2"
sql_backup_retention_days = 14
sql_geo_redundant_backup = true

# Redis Cache
redis_cache_sku = "Standard"
redis_cache_family = "C"
redis_cache_capacity = 1

# Storage Account
storage_account_tier = "Standard"
storage_account_replication = "GRS"
storage_containers = ["uploads", "logs", "backups"]

# Key Vault
key_vault_sku = "standard"

# Feature Flags
enable_private_endpoints = false
enable_auto_scaling = true
enable_advanced_threat_protection = true

# Scaling
app_service_min_instances = 2
app_service_max_instances = 5
```

### 8.3 Production Environment

**terraform/environments/prod/terraform.tfvars**:

```hcl
# Production Environment Configuration

environment = "prod"
region      = "eastus"

tags = {
  Environment = "Production"
  ManagedBy   = "Terraform"
  CostCenter  = "Operations"
  Criticality = "High"
  Compliance  = "Required"
}

# App Service
app_service_plan_sku = "P2v3"
app_service_always_on = true

# SQL Database
sql_database_sku = "S6"
sql_backup_retention_days = 35
sql_geo_redundant_backup = true
sql_long_term_retention = {
  weekly_retention  = "P4W"
  monthly_retention = "P12M"
  yearly_retention  = "P5Y"
}

# Redis Cache
redis_cache_sku = "Premium"
redis_cache_family = "P"
redis_cache_capacity = 1

# Storage Account
storage_account_tier = "Premium"
storage_account_replication = "GRS"
storage_containers = ["uploads", "logs", "backups", "archives"]

# Key Vault
key_vault_sku = "premium"  # HSM-backed keys

# Feature Flags
enable_private_endpoints = true
enable_auto_scaling = true
enable_advanced_threat_protection = true
enable_azure_defender = true

# Scaling
app_service_min_instances = 3
app_service_max_instances = 10

# High Availability
enable_zone_redundancy = true
enable_geo_replication = true

# Backup & DR
backup_frequency = "Daily"
backup_retention_days = 90
```

---

## 9. Security & Compliance

### 9.1 Security Scanning Integration

```
Security Tools in Pipeline:
├── Checkov
│   ├── Scans Terraform for misconfigurations
│   ├── Checks: 1000+ built-in policies
│   └── Output: GitHub annotations on PR
│
├── tfsec
│   ├── Static analysis of Terraform
│   ├── Identifies security issues
│   └── SARIF output for GitHub Security tab
│
├── Trivy
│   ├── Vulnerability scanning
│   ├── License compliance
│   └── Configuration audit
│
└── Azure Policy
    ├── Enforced at subscription level
    ├── Prevents non-compliant resources
    └── Continuous compliance monitoring
```

### 9.2 Secrets Management Strategy

```
Secrets Hierarchy:
├── GitHub Secrets (Encrypted)
│   ├── Azure credentials (OIDC config)
│   └── Third-party API keys
│
├── Azure Key Vault (Runtime)
│   ├── SQL connection strings
│   ├── Redis connection strings
│   ├── Storage account keys
│   └── Application secrets
│
└── Terraform Variables (Non-Sensitive)
    ├── Resource names
    ├── SKUs and configurations
    └── Tags and metadata

NEVER commit secrets to Git!
```

### 9.3 Access Control Matrix

```
┌───────────────┬─────────┬─────────┬──────────┐
│ Role/Resource │   Dev   │  Stage  │   Prod   │
├───────────────┼─────────┼─────────┼──────────┤
│ Developers    │  Write  │  Read   │   Read   │
│ DevOps Team   │  Write  │  Write  │   Read   │
│ SRE Team      │  Write  │  Write  │   Write  │
│ GitHub Actions│  Write  │  Write  │   Write  │
└───────────────┴─────────┴─────────┴──────────┘
```

---

## 10. Monitoring & Observability

### 10.1 Infrastructure Monitoring

```
Monitoring Stack:
├── Application Insights
│   ├── All resources instrumented
│   ├── Custom metrics and logs
│   └── Distributed tracing
│
├── Log Analytics Workspace
│   ├── Centralized logging
│   ├── Query across all resources
│   └── Retention: 90 days (prod)
│
├── Azure Monitor
│   ├── Resource health alerts
│   ├── Performance metrics
│   └── Cost alerts
│
└── GitHub Actions Insights
    ├── Workflow run history
    ├── Success/failure rates
    └── Execution time trends
```

### 10.2 Alerting Strategy

```
Alert Categories:
├── Infrastructure Health
│   ├── Resource availability < 99%
│   ├── High CPU/Memory (>80%)
│   └── Disk space warnings
│
├── Deployment Issues
│   ├── Failed workflow runs
│   ├── Drift detection findings
│   └── State lock conflicts
│
├── Security
│   ├── Unauthorized access attempts
│   ├── Key Vault access anomalies
│   └── Policy violations
│
└── Cost Management
    ├── Budget threshold exceeded
    ├── Unusual spending patterns
    └── Resource scaling events
```

---

## 11. Cost Optimization

### 11.1 Cost Management Features

```
Cost Optimization in GitOps:
├── Infracost Integration
│   ├── Estimates cost impact on each PR
│   ├── Shows cost diff before/after
│   └── Comments on PR with breakdown
│
├── Environment-Specific Sizing
│   ├── Dev: Minimal SKUs
│   ├── Stage: Production-like (reduced)
│   └── Prod: Optimized for performance
│
├── Auto-Scaling Policies
│   ├── Scale down during off-hours (dev/stage)
│   ├── Scale to zero for non-prod (weekends)
│   └── Predictive scaling (prod)
│
└── Reserved Instances
    ├── 1-year reservations for prod
    ├── Cost savings: 30-40%
    └── Managed via separate Terraform module
```

### 11.2 Cost Monitoring Dashboard

```
Azure Cost Management:
├── Budget Alerts
│   ├── Dev: $500/month
│   ├── Stage: $1,500/month
│   └── Prod: $5,000/month
│
├── Cost Allocation Tags
│   ├── Environment
│   ├── CostCenter
│   ├── Application
│   └── Owner
│
└── Regular Reviews
    ├── Weekly: Dev/Stage costs
    ├── Monthly: Prod cost analysis
    └── Quarterly: Optimization opportunities
```

---

## 12. Disaster Recovery & Business Continuity

### 12.1 Backup Strategy

```
Backup Configurations:
├── Terraform State
│   ├── Location: Azure Storage (GRS)
│   ├── Versioning: Enabled
│   ├── Soft Delete: 30 days
│   └── Point-in-time recovery: Available
│
├── Application Data
│   ├── SQL Database: Automated backups
│   │   ├── Dev: 7 days retention
│   │   ├── Stage: 14 days retention
│   │   └── Prod: 35 days + LTR
│   │
│   └── Storage Account: Geo-redundant
│       └── Prod: Read-access geo-redundant
│
└── Configuration (Git)
    ├── Repository: GitHub (geo-replicated)
    ├── Branches: Protected
    └── Commit history: Permanent record
```

### 12.2 Recovery Procedures

```
Disaster Recovery Scenarios:

1. Infrastructure Corruption
   └─ Restore from Terraform state backup
      └─ Timeframe: 1-2 hours

2. Region Failure (Production)
   ├─ Update terraform.tfvars with secondary region
   ├─ Run terragrunt apply
   └─ Timeframe: 2-4 hours

3. Data Loss
   ├─ SQL: Point-in-time restore
   ├─ Storage: Geo-redundant recovery
   └─ Timeframe: 1-2 hours

4. Configuration Rollback
   ├─ Git revert to last known good
   ├─ Deploy via standard pipeline
   └─ Timeframe: 30 minutes
```

---

## 13. Best Practices & Recommendations

### 13.1 Terraform/Terragrunt Best Practices

✅ **Module Design**

- Keep modules focused and reusable
- Version modules using Git tags
- Document inputs and outputs clearly
- Include examples for each module

✅ **State Management**

- Use remote state (Azure Storage)
- Enable state locking
- Never commit state files to Git
- Regular state backups

✅ **Code Quality**

- Run `terraform fmt` before commit
- Use `terraform validate` in CI
- Implement pre-commit hooks
- Comment complex logic

✅ **Terragrunt DRY**

- Share common configuration in root
- Use `dependencies` for resource ordering
- Leverage `include` blocks
- Keep environment configs minimal

### 13.2 GitOps Best Practices

✅ **Git Workflow**

- Use feature branches for changes
- Require PR reviews (minimum 1)
- Squash commits on merge
- Meaningful commit messages

✅ **Pipeline Design**

- Fail fast with validation checks
- Separate plan and apply stages
- Use environments for approvals
- Implement rollback procedures

✅ **Security**

- Use OIDC instead of service principal secrets
- Scan IaC for vulnerabilities
- Limit Azure permissions (least privilege)
- Rotate credentials regularly

✅ **Observability**

- Monitor workflow execution times
- Alert on failed deployments
- Track drift detection findings
- Maintain audit logs

### 13.3 GitHub Actions Optimization

✅ **Performance**

- Cache Terraform plugins
- Use matrix strategy for parallel execution
- Minimize workflow trigger paths
- Optimize checkout depth

✅ **Reliability**

- Implement retry logic
- Use timeout settings
- Handle partial failures gracefully
- Test workflows in isolation

---

## 14. Implementation Roadmap

### 14.1 Phase 1: Foundation (Week 1-2)

```
Tasks:
├── Set up GitHub repository
├── Configure branch protection rules
├── Create Azure AD App Registration (OIDC)
├── Set up Azure subscriptions (dev/stage/prod)
├── Create Terraform state storage accounts
├── Configure GitHub secrets and environments
└── Document access procedures
```

### 14.2 Phase 2: Infrastructure Code (Week 3-4)

```
Tasks:
├── Create Terraform module structure
│   ├── Resource group module
│   ├── App Service module
│   ├── SQL Server module
│   ├── Redis Cache module
│   ├── Storage Account module
│   ├── Key Vault module
│   └── App Insights module
│
├── Create Terragrunt configurations
│   ├── Root terragrunt.hcl
│   └── Environment-specific configs
│
└── Test modules locally
    ├── Validate syntax
    ├── Test in dev environment
    └── Verify outputs
```

### 14.3 Phase 3: CI/CD Pipelines (Week 5-6)

```
Tasks:
├── Create GitHub Actions workflows
│   ├── terraform-plan.yml
│   ├── terraform-apply.yml
│   ├── drift-detection.yml
│   └── terraform-destroy.yml
│
├── Integrate security scanning
│   ├── Checkov
│   ├── tfsec
│   └── Infracost
│
├── Configure notifications
│   ├── Slack/Teams integration
│   └── Email alerts
│
└── Test end-to-end deployment
    ├── Dev environment
    ├── Stage environment
    └── Prod environment
```

### 14.4 Phase 4: Optimization & Documentation (Week 7-8)

```
Tasks:
├── Performance optimization
│   ├── Workflow caching
│   ├── Parallel execution
│   └── Resource right-sizing
│
├── Documentation
│   ├── Architecture diagrams
│   ├── Runbooks
│   ├── Troubleshooting guide
│   └── Developer onboarding
│
├── Monitoring setup
│   ├── Application Insights dashboards
│   ├── Cost monitoring
│   └── Alert configuration
│
└── Team training
    ├── GitOps principles
    ├── Terraform best practices
    └── Incident response procedures
```

---

## 15. Troubleshooting Guide

### 15.1 Common Issues

```
Issue: Terraform State Lock
├── Symptom: "Error acquiring state lock"
├── Cause: Previous run didn't release lock
└── Solution:
    ├── Check Azure Storage for lock blob
    ├── Verify no other workflows running
    └── Force unlock: terragrunt force-unlock <LOCK_ID>

Issue: OIDC Authentication Failure
├── Symptom: "Failed to get token"
├── Cause: Federated credential misconfigured
└── Solution:
    ├── Verify subject claim in Azure AD
    ├── Check GitHub secrets are correct
    └── Ensure environment name matches

Issue: Drift Detected
├── Symptom: Resources modified outside Terraform
├── Cause: Manual changes in Azure Portal
└── Solution:
    ├── Review drift detection report
    ├── Option 1: Update Terraform to match
    ├── Option 2: Re-apply Terraform
    └── Document the change

Issue: Cost Overrun
├── Symptom: Budget alert triggered
├── Cause: Incorrect SKU or scaling config
└── Solution:
    ├── Review cost breakdown
    ├── Adjust terraform.tfvars
    ├── Create PR with optimization
    └── Monitor after deployment
```

### 15.2 Emergency Procedures

```
Emergency Rollback:
1. Identify problematic commit
2. Create hotfix branch
3. Revert changes: git revert <commit>
4. Create emergency PR
5. Fast-track review and merge
6. Monitor deployment

Complete Environment Recovery:
1. Check Terraform state backup
2. Restore state if corrupted
3. Run terragrunt plan to verify
4. Apply with: terragrunt apply
5. Validate all resources
6. Run smoke tests
```

---

## 16. Comparison: Bicep vs Terraform/Terragrunt

### 16.1 Why Terraform/Terragrunt?

```
Advantages:
✅ Multi-cloud support (Azure, AWS, GCP)
✅ Mature ecosystem and community
✅ Terragrunt adds DRY configuration
✅ Better state management
✅ More third-party integrations
✅ Provider agnostic

Trade-offs:
⚠️ Additional learning curve
⚠️ HCL syntax (different from ARM)
⚠️ State management complexity
⚠️ Requires separate tooling
```

### 16.2 Key Differences

```
┌──────────────────┬─────────────────┬──────────────────┐
│     Feature      │     Bicep       │    Terraform     │
├──────────────────┼─────────────────┼──────────────────┤
│ Cloud Support    │  Azure only     │   Multi-cloud    │
│ State Management │  Automatic      │   Manual setup   │
│ Language         │  ARM-like DSL   │   HCL            │
│ Tooling          │  Azure native   │   Third-party    │
│ Community        │  Growing        │   Large/mature   │
│ Preview Features │  Fast support   │   Delayed        │
│ Learning Curve   │  Lower (Azure)  │   Moderate       │
└──────────────────┴─────────────────┴──────────────────┘
```

---

## 17. Additional Resources

### 17.1 Documentation Links

- **Terraform Azure Provider**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **Terragrunt**: https://terragrunt.gruntwork.io/
- **GitHub Actions**: https://docs.github.com/en/actions
- **Azure OIDC**: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure

### 17.2 Sample Repository Structure

```
See Appendix B for:
├── Complete main.tf example
├── Sample module (app-service)
├── Complete terragrunt.hcl
├── Full GitHub Actions workflow
└── terraform.tfvars for all environments
```

---

## Appendix A: Sample Terraform Code

### Root main.tf

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Resource Group
module "resource_group" {
  source = "./modules/resource-group"
  
  name     = "rg-${var.resource_prefix}-${var.environment}-${var.region}"
  location = var.location
  tags     = var.tags
}

# App Service
module "app_service" {
  source = "./modules/app-service"
  
  resource_prefix     = var.resource_prefix
  environment         = var.environment
  region              = var.region
  location            = var.location
  resource_group_name = module.resource_group.name
  
  sku_name           = var.app_service_plan_sku
  app_insights_key   = module.app_insights.instrumentation_key
  key_vault_id       = module.key_vault.id
  
  tags = var.tags
  
  depends_on = [module.resource_group]
}

# SQL Server and Database
module "sql_server" {
  source = "./modules/sql-server"
  
  resource_prefix     = var.resource_prefix
  environment         = var.environment
  region              = var.region
  location            = var.location
  resource_group_name = module.resource_group.name
  
  database_sku              = var.sql_database_sku
  backup_retention_days     = var.sql_backup_retention_days
  geo_redundant_backup      = var.sql_geo_redundant_backup
  
  admin_username = var.sql_admin_username
  admin_password = var.sql_admin_password
  
  tags = var.tags
  
  depends_on = [module.resource_group]
}

# Redis Cache
module "redis_cache" {
  source = "./modules/redis-cache"
  
  resource_prefix     = var.resource_prefix
  environment         = var.environment
  region              = var.region
  location            = var.location
  resource_group_name = module.resource_group.name
  
  sku_name  = var.redis_cache_sku
  family    = var.redis_cache_family
  capacity  = var.redis_cache_capacity
  
  tags = var.tags
  
  depends_on = [module.resource_group]
}

# Storage Account
module "storage_account" {
  source = "./modules/storage-account"
  
  resource_prefix     = var.resource_prefix
  environment         = var.environment
  region              = var.region
  location            = var.location
  resource_group_name = module.resource_group.name
  
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  containers               = var.storage_containers
  
  tags = var.tags
  
  depends_on = [module.resource_group]
}

# Key Vault
module "key_vault" {
  source = "./modules/key-vault"
  
  resource_prefix     = var.resource_prefix
  environment         = var.environment
  region              = var.region
  location            = var.location
  resource_group_name = module.resource_group.name
  
  sku_name = var.key_vault_sku
  
  secrets = {
    "sql-connection-string"   = module.sql_server.connection_string
    "redis-connection-string" = module.redis_cache.connection_string
    "storage-account-key"     = module.storage_account.primary_access_key
  }
  
  tags = var.tags
  
  depends_on = [
    module.resource_group,
    module.sql_server,
    module.redis_cache,
    module.storage_account
  ]
}

# Application Insights
module "app_insights" {
  source = "./modules/app-insights"
  
  resource_prefix     = var.resource_prefix
  environment         = var.environment
  region              = var.region
  location            = var.location
  resource_group_name = module.resource_group.name
  
  tags = var.tags
  
  depends_on = [module.resource_group]
}
```

---

## Appendix B: Complete Workflow Example

```yaml
# Complete terraform-apply.yml with all features
name: 'Terraform Apply - Production Ready'

on:
  push:
    branches: [main]
    paths: ['terraform/**']
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options: [dev, stage, prod]

env:
  TF_VERSION: '1.6.0'
  TG_VERSION: '0.54.0'
  ARM_USE_OIDC: true

permissions:
  id-token: write
  contents: read
  issues: write
  pull-requests: write

jobs:
  deploy:
    name: 'Deploy to ${{ matrix.environment }}'
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        environment: ${{ github.event_name == 'workflow_dispatch' && [github.event.inputs.environment] || ['dev', 'stage', 'prod'] }}
      max-parallel: 1
      fail-fast: false
    
    environment:
      name: ${{ matrix.environment }}
      url: https://app-myapp-${{ matrix.environment }}-eastus.azurewebsites.net
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
          terraform_wrapper: false
      
      - name: Setup Terragrunt
        run: |
          wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v${{ env.TG_VERSION }}/terragrunt_linux_amd64
          chmod +x terragrunt_linux_amd64
          sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
          terragrunt --version
      
      - name: Azure Login (OIDC)
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets[format('AZURE_SUBSCRIPTION_ID_{0}', upper(matrix.environment))] }}
      
      - name: Cache Terraform Plugins
        uses: actions/cache@v3
        with:
          path: |
            ~/.terraform.d/plugin-cache
          key: terraform-${{ runner.os }}-${{ hashFiles('**/.terraform.lock.hcl') }}
          restore-keys: |
            terraform-${{ runner.os }}-
      
      - name: Terragrunt Init
        run: terragrunt init -upgrade
        working-directory: ./terraform/environments/${{ matrix.environment }}
        env:
          TF_PLUGIN_CACHE_DIR: ${{ github.workspace }}/.terraform.d/plugin-cache
      
      - name: Terragrunt Plan
        id: plan
        run: |
          terragrunt plan -out=tfplan -no-color 2>&1 | tee plan.txt
          echo "exitcode=${PIPESTATUS[0]}" >> $GITHUB_OUTPUT
        working-directory: ./terraform/environments/${{ matrix.environment }}
        continue-on-error: true
      
      - name: Terragrunt Apply
        if: steps.plan.outputs.exitcode == '0' || steps.plan.outputs.exitcode == '2'
        run: terragrunt apply -auto-approve tfplan
        working-directory: ./terraform/environments/${{ matrix.environment }}
      
      - name: Verify Deployment
        run: |
          echo "Running post-deployment verification..."
          # Add verification scripts here
          
      - name: Notify on Failure
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Deployment Failed - ${{ matrix.environment }}`,
              body: `Deployment to ${{ matrix.environment }} failed.\n\nWorkflow: ${context.workflow}\nRun: ${context.runNumber}`,
              labels: ['deployment-failure', '${{ matrix.environment }}']
            })
```

---

## Document Control

| Version | Date       | Author | Changes                                   |
| ------- | ---------- | ------ | ----------------------------------------- |
| 1.0     | 2025-12-15 | Stoyan | Initial GitHub GitOps architecture design |

---

**End of Document**