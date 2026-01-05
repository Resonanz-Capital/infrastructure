output "app_service_plan_id" {
  description = "App Service Plan ID"
  value       = azurerm_service_plan.app_service_plan.id
}

output "app_service_plan_name" {
  description = "App Service Plan name"
  value       = azurerm_service_plan.app_service_plan.name
}

output "app_service_id" {
  description = "App Service ID"
  value       = azurerm_linux_web_app.app_service.id
}

output "app_service_name" {
  description = "App Service name"
  value       = azurerm_linux_web_app.app_service.name
}

output "app_service_default_hostname" {
  description = "App Service default hostname"
  value       = azurerm_linux_web_app.app_service.default_hostname
}
