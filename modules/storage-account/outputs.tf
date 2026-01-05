output "storage_account_id" {
  description = "Storage account ID"
  value       = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.storage.name
}

output "storage_account_primary_connection_string" {
  description = "Storage account primary connection string"
  value       = azurerm_storage_account.storage.primary_connection_string
  sensitive   = true
}

output "storage_account_primary_access_key" {
  description = "Storage account primary access key"
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}

output "storage_account_secondary_access_key" {
  description = "Storage account secondary access key"
  value       = azurerm_storage_account.storage.secondary_access_key
  sensitive   = true
}

output "storage_account_primary_blob_endpoint" {
  description = "Storage account primary blob endpoint"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "storage_account_primary_queue_endpoint" {
  description = "Storage account primary queue endpoint"
  value       = azurerm_storage_account.storage.primary_queue_endpoint
}

output "storage_account_primary_table_endpoint" {
  description = "Storage account primary table endpoint"
  value       = azurerm_storage_account.storage.primary_table_endpoint
}

output "storage_account_primary_file_endpoint" {
  description = "Storage account primary file endpoint"
  value       = azurerm_storage_account.storage.primary_file_endpoint
}
