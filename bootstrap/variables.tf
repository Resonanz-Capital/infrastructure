variable "resource_group_name" {
  description = "Name of the resource group for Terraform state"
  type        = string
  default     = "RCA-AZ-RG-TFSTATES"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "storage_account_prefix" {
  description = "Prefix for storage account name (will be suffixed with random characters)"
  type        = string
  default     = "tfstate"

  validation {
    condition     = length(var.storage_account_prefix) <= 16 && can(regex("^[a-z0-9]+$", var.storage_account_prefix))
    error_message = "Storage account prefix must be lowercase alphanumeric and max 16 chars."
  }
}

variable "storage_account_name" {
  description = "Full name of the storage account (optional, will be generated if not provided)"
  type        = string
  default     = null

  validation {
    condition     = var.storage_account_name == null || can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be lowercase alphanumeric, between 3-24 characters."
  }
}

variable "deployment_name" {
  description = "Name of the deployment (used to create unique container names)"
  type        = string
  default     = "default"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.deployment_name))
    error_message = "Deployment name must be lowercase alphanumeric with hyphens, between 3-63 characters."
  }
}

variable "container_name" {
  description = "Name of the blob container for state files (optional, will be generated from deployment_name if not provided)"
  type        = string
  default     = null
}
