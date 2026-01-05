output "acr_id" {
  description = "ACR ID"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "ACR name"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "ACR login server"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_username : null
}

output "acr_admin_password" {
  description = "ACR admin password"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_password : null
  sensitive   = true
}
