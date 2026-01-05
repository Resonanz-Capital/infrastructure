output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.log_analytics.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.log_analytics.name
}

output "log_analytics_workspace_primary_shared_key" {
  description = "Log Analytics workspace primary shared key"
  value       = azurerm_log_analytics_workspace.log_analytics.primary_shared_key
  sensitive   = true
}

# Deprecated: portal_url removed in newer azurerm provider versions
# output "log_analytics_workspace_portal_url" {
#   description = "Log Analytics workspace portal URL"
#   value       = azurerm_log_analytics_workspace.log_analytics.portal_url
# }
