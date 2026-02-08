# Outputs to be used by Terragrunt
output "resource_group_name" {
  description = "Name of the resource group"
  value       = var.resource_group_name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = local.resource_group_location
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = local.storage_account_name
}

output "container_name" {
  description = "Name of the storage container"
  value       = var.container_name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = local.storage_account_id
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = data.external.sa_check.result.exists == "true" ? data.azurerm_storage_account.existing[0].primary_access_key : azurerm_storage_account.tfstate[0].primary_access_key
  sensitive   = true
}

output "resource_group_created" {
  description = "Whether the resource group was created (true) or already existed (false)"
  value       = data.external.rg_check.result.exists == "false"
}

output "storage_account_created" {
  description = "Whether the storage account was created (true) or already existed (false)"
  value       = data.external.sa_check.result.exists == "false"
}
