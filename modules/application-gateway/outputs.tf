output "app_gateway_id" {
  description = "Application Gateway ID"
  value       = azurerm_application_gateway.app_gateway.id
}

output "app_gateway_public_ip" {
  description = "Application Gateway public IP address"
  value       = azurerm_public_ip.app_gateway.ip_address
}

output "app_gateway_name" {
  description = "Application Gateway name"
  value       = azurerm_application_gateway.app_gateway.name
}
