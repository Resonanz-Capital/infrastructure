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
  }
}

provider "azurerm" {
  features {}

  # Explicitly use "Azure subscription 1"
  subscription_id = "6346877f-9b0c-4549-aa42-65062902ebdd"
}

# Try to get existing resource group (will be null if it doesn't exist)
data "azurerm_resource_group" "existing" {
  count = 1
  name  = var.resource_group_name

  lifecycle {
    postcondition {
      condition     = self.id != null || self.id == null
      error_message = "Checking resource group existence"
    }
  }
}

# Create resource group for Terraform state if it doesn't exist
resource "azurerm_resource_group" "tfstate" {
  count = try(data.azurerm_resource_group.existing[0].id, null) == null ? 1 : 0

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

# Determine the actual resource group location
locals {
  resource_group_location = try(
    data.azurerm_resource_group.existing[0].location,
    azurerm_resource_group.tfstate[0].location,
    var.location
  )
  resource_group_name = var.resource_group_name
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

# Try to get existing storage account (will be null if it doesn't exist)
data "azurerm_storage_account" "existing" {
  count               = 1
  name                = local.storage_account_name
  resource_group_name = local.resource_group_name

  depends_on = [
    azurerm_resource_group.tfstate
  ]

  lifecycle {
    postcondition {
      condition     = self.id != null || self.id == null
      error_message = "Checking storage account existence"
    }
  }
}

# Create storage account for Terraform state if it doesn't exist
resource "azurerm_storage_account" "tfstate" {
  count = try(data.azurerm_storage_account.existing[0].id, null) == null ? 1 : 0

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

  depends_on = [
    azurerm_resource_group.tfstate
  ]
}

# Get the actual storage account ID
locals {
  storage_account_id = try(
    data.azurerm_storage_account.existing[0].id,
    azurerm_storage_account.tfstate[0].id
  )
}

# Try to get existing container (will be null if it doesn't exist)
data "azurerm_storage_container" "existing" {
  count              = 1
  name               = var.container_name
  storage_account_id = local.storage_account_id

  depends_on = [
    azurerm_storage_account.tfstate
  ]

  lifecycle {
    postcondition {
      condition     = self.id != null || self.id == null
      error_message = "Checking storage container existence"
    }
  }
}

# Create blob container for state files if it doesn't exist
resource "azurerm_storage_container" "tfstate" {
  count = try(data.azurerm_storage_container.existing[0].id, null) == null ? 1 : 0

  name                  = var.container_name
  storage_account_id    = local.storage_account_id
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.tfstate
  ]
}
