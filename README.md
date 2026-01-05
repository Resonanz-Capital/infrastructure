# Azure Infrastructure with Terraform and Terragrunt

This project provides a complete Azure infrastructure setup using Terraform and Terragrunt. It includes modules for all major Azure services and is organized by environments (dev, stage, prod).

## Bootstrap Module

Before running the main infrastructure modules, you need to create the initial Azure resources for remote state management. This is done using the bootstrap module:

```bash
cd bootstrap
terraform init
terraform apply
```

This creates:
- Resource group for bootstrap resources
- Storage account for Terraform state
- Storage container for state files

## Project Structure

```
.
├── live/
│   ├── terragrunt.hcl              # Root configuration
│   ├── 1. dev/                     # Development environment
│   │   ├── terragrunt.hcl          # Environment configuration
│   │   ├── vnet/                   # Virtual Network
│   │   ├── vpn-gateway/            # VPN Gateway
│   │   ├── application-gateway/    # Application Gateway
│   │   ├── acr/                    # Azure Container Registry
│   │   ├── app-service/            # App Service
│   │   ├── app-service-containers/ # App Service for Containers
│   │   ├── sql-database/           # SQL Database
│   │   ├── redis-cache/            # Redis Cache
│   │   ├── storage-account/        # Storage Account
│   │   ├── log-analytics/          # Log Analytics
│   │   ├── diagnostic-settings/    # Diagnostic Settings
│   │   └── alerting/               # Alerting
│   ├── 2. stage/                   # Staging environment
│   └── 3. prod/                    # Production environment
└── modules/                        # Terraform modules
    ├── vnet/                       # Virtual Network
    ├── vpn-gateway/                # VPN Gateway
    ├── application-gateway/        # Application Gateway
    ├── acr/                        # Azure Container Registry
    ├── app-service/                # App Service
    ├── app-service-containers/     # App Service for Containers
    ├── sql-database/               # SQL Database
    ├── redis-cache/                # Redis Cache
    ├── storage-account/            # Storage Account
    ├── log-analytics/              # Log Analytics
    ├── diagnostic-settings/        # Diagnostic Settings
    └── alerting/                   # Alerting
```

## Modules

1. **VNet** - Virtual Network with subnets
2. **VPN Gateway** - VPN Gateway and Connection
3. **Application Gateway** - Application Gateway (WAF)
4. **ACR** - Azure Container Registry
5. **App Service** - Azure App Service
6. **App Service for Containers** - App Service running containers
7. **SQL Database** - Azure SQL Database
8. **Redis Cache** - Azure Redis Cache
9. **Storage Account** - Azure Storage Account
10. **Log Analytics** - Log Analytics Workspace
11. **Diagnostic Settings** - Diagnostic settings for resources
12. **Alerting** - Metric and Activity Log alerts

## Prerequisites

- Terraform >= 1.0
- Terragrunt >= 0.32
- Azure CLI
- Azure subscription

## Usage

1. Authenticate to Azure:
   ```bash
   az login
   ```

2. Navigate to the desired environment:
   ```bash
   cd live/1. dev
   ```

3. Initialize Terragrunt:
   ```bash
   terragrunt init
   ```

4. Plan the infrastructure:
   ```bash
   terragrunt plan
   ```

5. Apply the infrastructure:
   ```bash
   terragrunt apply
   ```

## Configuration

Each environment has its own configuration file (`terragrunt.hcl`) that defines environment-specific variables. Modules are configured in their respective directories under the `live` folder.

## Dependencies

Modules are connected through dependencies. For example, the VPN Gateway depends on the VNet module for subnet IDs.

## Remote State

The project uses Azure Storage Account for remote state management. Configuration is in the root `live/terragrunt.hcl` file.
