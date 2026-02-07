variable "resource_group_name" {
  description = "Name of the resource group for Terraform state"
  type        = string
  default     = "RCA-AZ-RG-SNDBX-TEST"
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

variable "container_name" {
  description = "Name of the blob container for state files"
  type        = string
  default     = "tfstate"
}
