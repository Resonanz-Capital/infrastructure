terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
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

# Generate a deterministic storage account name using hash of resource group name
# This ensures the name is known at plan time (not dependent on apply)
locals {
  # Create a deterministic suffix from resource group name (8 characters from MD5 hash)
  storage_suffix = var.storage_account_name == null ? substr(md5(local.resource_group_name), 0, 8) : ""
  storage_account_name = var.storage_account_name != null ? var.storage_account_name : "${var.storage_account_prefix}${local.storage_suffix}"
}

# Check if storage account exists using Azure CLI
# NOTE: This check must NOT depend on any resources to avoid circular dependencies
data "external" "sa_check" {
  program = ["bash", "-c", <<-EOT
    if az storage account show --name '${local.storage_account_name}' --resource-group '${local.resource_group_name}' &>/dev/null; then
      echo '{"exists":"true"}'
    else
      echo '{"exists":"false"}'
    fi
  EOT
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
}

# Get the actual storage account ID (determine which one to use)
locals {
  storage_account_id = data.external.sa_check.result.exists == "true" ? data.azurerm_storage_account.existing[0].id : azurerm_storage_account.tfstate[0].id
  # Generate container name from deployment_name if not provided
  container_name = var.container_name != null ? var.container_name : "tfstate-${var.deployment_name}"
}

# Check if container exists using Azure CLI
data "external" "container_check" {
  program = ["bash", "-c", <<-EOT
    if az storage container show --name '${local.container_name}' --account-name '${local.storage_account_name}' &>/dev/null; then
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

# Create blob container for state files only if it doesn't exist
resource "azurerm_storage_container" "tfstate" {
  count = data.external.container_check.result.exists == "false" ? 1 : 0

  name                  = local.container_name
  storage_account_id    = local.storage_account_id
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.tfstate,
    data.azurerm_storage_account.existing
  ]
}

# Get existing container data if it exists
data "azurerm_storage_container" "existing" {
  count              = data.external.container_check.result.exists == "true" ? 1 : 0
  name               = local.container_name
  storage_account_id = local.storage_account_id
}
