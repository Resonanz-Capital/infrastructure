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

# Check if resource group already exists
data "external" "rg_exists" {
  program = ["sh", "-c", "az group show --name ${var.resource_group_name} --query '{exists:true}' -o json 2>/dev/null || echo '{\"exists\": false}'"]
}

# Data source for existing resource group
data "azurerm_resource_group" "existing" {
  count = data.external.rg_exists.result.exists == "true" ? 1 : 0
  name  = var.resource_group_name
}

# Create resource group for Terraform state if it doesn't exist
resource "azurerm_resource_group" "tfstate" {
  count = data.external.rg_exists.result.exists == "true" ? 0 : 1

  name     = var.resource_group_name
  location = var.location

  tags = {
    Purpose   = "Terraform State Storage"
    ManagedBy = "Terraform Bootstrap"
  }
}

# Locals for resource group location
locals {
  rg_location = data.external.rg_exists.result.exists == "true" ? data.azurerm_resource_group.existing[0].location : var.location
}

# Generate unique suffix for storage account name
resource "random_id" "storage_suffix" {
  byte_length = 4
}

# Create storage account for Terraform state
resource "azurerm_storage_account" "tfstate" {
  name                     = "${var.storage_account_prefix}${random_id.storage_suffix.hex}"
  resource_group_name      = var.resource_group_name
  location                 = local.rg_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security settings
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  tags = {
    Purpose   = "Terraform State Storage"
    ManagedBy = "Terraform Bootstrap"
  }
}

# Create blob container for state files
resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
