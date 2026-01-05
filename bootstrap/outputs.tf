# Outputs to be used by Terragrunt
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.tfstate.name
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.tfstate.primary_access_key
  sensitive   = true
}
