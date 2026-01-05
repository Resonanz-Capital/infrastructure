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
  value       = var.os_type == "Windows" ? azurerm_windows_web_app.app_service[0].id : azurerm_linux_web_app.app_service[0].id
}

output "app_service_name" {
  description = "App Service name"
  value       = var.os_type == "Windows" ? azurerm_windows_web_app.app_service[0].name : azurerm_linux_web_app.app_service[0].name
}

output "app_service_default_hostname" {
  description = "App Service default hostname"
  value       = var.os_type == "Windows" ? azurerm_windows_web_app.app_service[0].default_hostname : azurerm_linux_web_app.app_service[0].default_hostname
}
