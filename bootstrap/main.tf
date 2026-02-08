terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Explicitly use "Azure subscription 1"
  subscription_id = "6346877f-9b0c-4549-aa42-65062902ebdd"
}

# Check if resource group exists using Azure CLI
data "external" "rg_check" {
  program = ["bash", "-c", <<-EOT
    if az group show --name '${var.resource_group_name}' &>/dev/null; then
      echo '{"exists":"true"}'
    else
      echo '{"exists":"false"}'
    fi
  EOT
  ]
}

# Create resource group for Terraform state if it doesn't exist
resource "azurerm_resource_group" "tfstate" {
  count = data.external.rg_check.result.exists == "false" ? 1 : 0

  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Sandbox"
    Owner       = "stoyan.stoyanov@sirma.com"
    CostCenter  = "Sandbox-Owners"
    Purpose     = "Terraform State Storage"
    ManagedBy   = "Terraform Bootstrap"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Get existing resource group data if it exists
data "azurerm_resource_group" "existing" {
  count = data.external.rg_check.result.exists == "true" ? 1 : 0
  name  = var.resource_group_name
}

# Determine the actual resource group location
locals {
  resource_group_location = data.external.rg_check.result.exists == "true" ? data.azurerm_resource_group.existing[0].location : azurerm_resource_group.tfstate[0].location
  resource_group_name     = var.resource_group_name
}

# Generate a deterministic storage account name or use existing
resource "random_id" "storage_suffix" {
  count = var.storage_account_name == null ? 1 : 0

  byte_length = 4

  keepers = {
    resource_group = local.resource_group_name
  }
}

locals {
  storage_account_name = var.storage_account_name != null ? var.storage_account_name : "${var.storage_account_prefix}${random_id.storage_suffix[0].hex}"
}

# Check if storage account exists using Azure CLI
data "external" "sa_check" {
  program = ["bash", "-c", <<-EOT
    if az storage account show --name '${local.storage_account_name}' --resource-group '${local.resource_group_name}' &>/dev/null; then
      echo '{"exists":"true"}'
    else
      echo '{"exists":"false"}'
    fi
  EOT
  ]

  depends_on = [
    azurerm_resource_group.tfstate
  ]
}

# Create storage account for Terraform state if it doesn't exist
resource "azurerm_storage_account" "tfstate" {
  count = data.external.sa_check.result.exists == "false" ? 1 : 0

  name                     = local.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security settings
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  tags = {
    Environment = "Sandbox"
    Owner       = "stoyan.stoyanov@sirma.com"
    CostCenter  = "Sandbox-Owners"
    Purpose     = "Terraform State Storage"
    ManagedBy   = "Terraform Bootstrap"
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    azurerm_resource_group.tfstate
  ]
}

# Get existing storage account data if it exists
data "azurerm_storage_account" "existing" {
  count               = data.external.sa_check.result.exists == "true" ? 1 : 0
  name                = local.storage_account_name
  resource_group_name = local.resource_group_name

  depends_on = [
    azurerm_resource_group.tfstate
  ]
}

# Get the actual storage account ID and key
locals {
  storage_account_id = data.external.sa_check.result.exists == "true" ? data.azurerm_storage_account.existing[0].id : azurerm_storage_account.tfstate[0].id
  storage_account_primary_key = data.external.sa_check.result.exists == "true" ? data.azurerm_storage_account.existing[0].primary_access_key : azurerm_storage_account.tfstate[0].primary_access_key
}

# Check if container exists using Azure CLI
data "external" "container_check" {
  program = ["bash", "-c", <<-EOT
    if az storage container show --name '${var.container_name}' --account-name '${local.storage_account_name}' --account-key '${local.storage_account_primary_key}' &>/dev/null; then
      echo '{"exists":"true"}'
    else
      echo '{"exists":"false"}'
    fi
  EOT
  ]

  depends_on = [
    azurerm_storage_account.tfstate,
    data.azurerm_storage_account.existing
  ]
}

# Create blob container for state files if it doesn't exist
resource "azurerm_storage_container" "tfstate" {
  count = data.external.container_check.result.exists == "false" ? 1 : 0

  name                  = var.container_name
  storage_account_id    = local.storage_account_id
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.tfstate
  ]
}
