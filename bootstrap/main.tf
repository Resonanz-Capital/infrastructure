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
  subscription_id = "6ab2e1b8-b57e-4fbb-8c05-12629a7ddcf7"

  # Skip automatic resource provider registration (works in older versions)
  skip_provider_registration = true
}

# Generate unique suffix for storage account name
resource "random_id" "storage_suffix" {
  byte_length = 4
}

# Create resource group for Terraform state
resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Purpose   = "Terraform State Storage"
    ManagedBy = "Terraform Bootstrap"
  }
}

# Create storage account for Terraform state
resource "azurerm_storage_account" "tfstate" {
  name                     = "${var.storage_account_prefix}${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
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
